/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] ReliableChannel 可靠 UDP 通道（three.network.transport 子包）
 * @brief[zh-cn] seq/ack 位图确认 + 超时重发 + 按序派发的游戏可靠 UDP 通道
 * @explain[zh-cn] 在 std.net.UdpSocket 之上补齐"可靠 + 有序"传输（对照 ENet/KCP 的最小核心）：
 * - 包格式：[seq u32][ack u32][ackBits u32][payload]，全部大端；
 *   ack = 本端已按序收到的最高 seq；ackBits 第 i 位（从低位数起）= seq == ack-(31-i)
 *   是否已收到（覆盖 [ack-31, ack] 共 32 个 seq 的乱序确认）。
 * - 可靠性：send() 挂入 pending 表，update() 对超过 resendDelayMs 未确认的包重发，
 *   每次重发间隔翻倍（封顶 maxResendDelayMs）；收到确认即从 pending 移除。
 * - 有序性：收包线程按 expected seq 顺序投递；乱序包入 ooo 缓存，缺口补齐后按序派发。
 * - 确认回报：收包线程每收一包立即回一个仅 12 字节头的 ack 帧（实现简单、延迟最低；
 *   @todo 后续可合并到数据包 piggyback 以省流量）。
 * - 线程模型：bind() 后 spawn 收包线程（阻塞 receiveFrom，负责 ack 回执/乱序缓存/投递队列）；
 *   onMessage 在主循环 update() 中派发；send/update/收包线程并发安全（pending 用锁保护）。
 * - RTT：收到确认时按 pending 记录的发送时刻采样，指数平滑（smoothed = 0.875*s + 0.125*rtt），
 *   通过 rttMs 属性读取（@todo 用作自适应重发间隔）。
 * 用法：
 * let chan = ReliableChannel("127.0.0.1", 9000, bindPort: 9001)
 * chan.onMessage = Some({ data => ... })
 * chan.bind()
 * chan.send("hit".toArray())
 * // 主循环每帧：
 * chan.update()
 *
 * @file[en] ReliableChannel  Reliable UDP channel (three.network.transport sub-package)
 * @brief[en] Game-grade reliable UDP channel: seq/ack bitmap confirmation + timeout resend
 * + in-order delivery
 * @explain[en] Adds "reliable + ordered" transport on top of std.net.UdpSocket (the minimal
 * core of ENet/KCP):
 * - Packet format: [seq u32][ack u32][ackBits u32][payload], all big-endian; ack = highest
 *   in-order received seq on this side; ackBits bit i (from LSB) = whether seq == ack-(31-i)
 *   was received (covers 32 out-of-order seqs in [ack-31, ack]).
 * - Reliability: send() parks packets in a pending table; update() resends packets
 *   unconfirmed for resendDelayMs, doubling the interval per resend (capped at
 *   maxResendDelayMs); confirmations remove entries from pending.
 * - Ordering: the receive thread delivers in expected-seq order; out-of-order packets wait
 *   in the ooo cache and are delivered once the gap fills.
 * - Acknowledgement: the receive thread replies with a 12-byte header-only ack frame per
 *   received packet (simplest, lowest latency; @todo piggyback acks onto data packets later).
 * - Threading: bind() spawns the receive thread (blocking receiveFrom, handling ack replies /
 *   ooo cache / delivery queue); onMessage dispatches on the main-loop update(); send/update/
 *   receive-thread concurrency is safe (pending guarded by a lock).
 * - RTT: sampled from pending send timestamps on confirmation, exponentially smoothed
 *   (smoothed = 0.875*s + 0.125*rtt); read via rttMs (@todo adaptive resend interval).
 * Usage:
 * let chan = ReliableChannel("127.0.0.1", 9000, bindPort: 9001)
 * chan.onMessage = Some({ data => ... })
 * chan.bind()
 * chan.send("hit".toArray())
 * // every frame in the main loop:
 * chan.update()
 */
package three.network.transport

import std.collection.*
import std.collection.concurrent.ConcurrentLinkedQueue
import std.core.*
import std.binary.*
import std.net.*
import std.sync.*
import std.time.*
import three.utils.log.*
import three.utils.log.macros.*

/** 可靠包头部字节数（seq + ack + ackBits，各 4 字节大端） */
public const RELIABLE_HEADER_SIZE: Int64 = 12

/** 纯 ack 帧的 seq 标记（不承载载荷，接收端跳过数据派发） */
public const RELIABLE_ACK_SEQ: UInt32 = 0xFFFFFFFFu32

/** 单个可靠包载荷上限（保守取以太网友好的 1200 字节，避免 IP 分片；@todo 分片重组） */
public const RELIABLE_MAX_PAYLOAD: Int64 = 1200

/** 乱序缓存条目上限（防恶意 seq 注入撑爆内存） */
internal const _OOO_CAP: Int64 = 1024

/** 收包缓冲区大小（需容纳 RELIABLE_HEADER_SIZE + RELIABLE_MAX_PAYLOAD） */
internal const _RECV_BUF_SIZE: Int64 = 4096

/**
 * @brief[zh-cn] 待确认包（发送侧）
 *
 * @brief[en] Pending packet (sender side)
 */
internal class PendingPacket {
    /** 载荷 */
    public let payload: Array<UInt8>
    /** 最近一次发送时刻（epoch 毫秒） */
    public var sendTimeMs: Int64
    /** 当前重发间隔（毫秒，翻倍退避） */
    public var delayMs: Float64
    /** 已重发次数 */
    public var resends: Int64

    public init(payload: Array<UInt8>, nowMs: Int64, delayMs: Float64) {
        this.payload = payload
        this.sendTimeMs = nowMs
        this.delayMs = delayMs
        this.resends = 0
    }
}

/**
 * @brief[zh-cn] 可靠 UDP 通道
 * @explain[zh-cn] seq/ack 确认 + 超时重发 + 按序派发；一个通道绑定一个远端
 * （多远端各建一个通道、各自 bindPort）。
 *
 * @brief[en] Reliable UDP channel
 * @explain[en] seq/ack confirmation + timeout resend + in-order delivery; one channel is
 * bound to one remote peer (create one channel with its own bindPort per remote).
 */
public class ReliableChannel {
    /**
     * @brief[zh-cn] 远端主机
     *
     * @brief[en] Remote host
     */
    public let remoteHost: String

    /**
     * @brief[zh-cn] 远端端口
     *
     * @brief[en] Remote port
     */
    public let remotePort: UInt16

    /**
     * @brief[zh-cn] 初始重发间隔（毫秒，默认 100）
     *
     * @brief[en] Initial resend interval in ms (default 100)
     */
    public var resendDelayMs: Float64 = 100.0

    /**
     * @brief[zh-cn] 重发间隔上限（毫秒，默认 2000）
     *
     * @brief[en] Resend interval cap in ms (default 2000)
     */
    public var maxResendDelayMs: Float64 = 2000.0

    /**
     * @brief[zh-cn] 数据到达回调（主循环 update 派发，按序）
     *
     * @brief[en] Data callback (dispatched in order on main-loop update)
     */
    public var onMessage: Option<(Array<UInt8>) -> Unit> = None

    /** 底层 UDP 套接字 */
    private var _udp: Option<UdpSocket>

    /** 远端地址（bind 后有效） */
    private var _remote: Option<IPSocketAddress>

    /** 是否已绑定 */
    private var _bound: Bool

    /** 收包线程停止标志 */
    private let _stop: AtomicBool

    /** 发送序号（下一分配的 seq） */
    private var _nextSeq: UInt32

    /** 待确认表（seq → 待确认包；send/update/收包线程并发，锁保护） */
    private var _pending: HashMap<UInt32, PendingPacket>

    /** 待确认表锁 */
    private let _pendingMutex: Mutex

    /** 期望接收的下一 seq（仅收包线程访问） */
    private var _recvSeq: UInt32

    /** 乱序缓存（seq → 载荷；仅收包线程访问） */
    private var _ooo: HashMap<UInt32, Array<UInt8>>

    /** ack 位图（最近 32 个非按序接收标记；仅收包线程访问） */
    private var _ackBits: UInt32

    /** 已按序收到的最高 seq（ack 字段来源；仅收包线程访问） */
    private var _highestInOrder: UInt32

    /** 是否已收到过任何包（ack 初值处理） */
    private var _hasReceived: Bool

    /** 按序投递队列（收包线程压入，主循环 update 派发） */
    private let _deliver: ConcurrentLinkedQueue<Array<UInt8>>

    /** 平滑 RTT（毫秒；收包线程写，主循环读） */
    private let _rttMs: AtomicInt64

    /** 发送锁（send 与收包线程 ack 回执互斥写 socket） */
    private let _sendMutex: Mutex

    /** 单调毫秒时钟起点（进程级） */
    private static let _epoch: MonoTime = MonoTime.now()

    /**
     * @brief[zh-cn] 构造可靠通道（需调用 bind）
     * @param[zh-cn] remoteHost 远端主机
     * remotePort 远端端口
     * bindPort 本地绑定端口（0 = 自动分配）
     *
     * @brief[en] Constructs a reliable channel (call bind)
     * @param[en] remoteHost Remote host
     * remotePort Remote port
     * bindPort Local bind port (0 = auto-assigned)
     */
    public init(remoteHost: String, remotePort: UInt16, bindPort!: UInt16 = 0) {
        this.remoteHost = remoteHost
        this.remotePort = remotePort
        this._udp = Some(UdpSocket(bindAt: bindPort))
        this._remote = None
        this._bound = false
        this._stop = AtomicBool(false)
        this._nextSeq = 0u32
        this._pending = HashMap<UInt32, PendingPacket>()
        this._pendingMutex = Mutex()
        this._recvSeq = 0u32
        this._ooo = HashMap<UInt32, Array<UInt8>>()
        this._ackBits = 0u32
        this._highestInOrder = 0u32
        this._hasReceived = false
        this._deliver = ConcurrentLinkedQueue<Array<UInt8>>()
        this._rttMs = AtomicInt64(0)
        this._sendMutex = Mutex()
    }

    /**
     * @brief[zh-cn] 平滑 RTT（毫秒；未采样时为 0）
     *
     * @brief[en] Smoothed RTT in ms (0 before any sample)
     */
    public prop rttMs: Int64 {
        get() { _rttMs.load() }
    }

    /**
     * @brief[zh-cn] 在途未确认包数量
     *
     * @brief[en] Number of in-flight unconfirmed packets
     */
    public prop pendingCount: Int64 {
        get() {
            synchronized(_pendingMutex) {
                return _pending.size
            }
        }
    }

    /**
     * @brief[zh-cn] 绑定本地端口并启动收包线程（同步）
     * @return[zh-cn] 绑定成功返回 true
     *
     * @brief[en] Binds the local port and starts the receive thread (synchronous)
     * @return[en] True on successful bind
     */
    public func bind(): Bool {
        if (this._bound) { return true }
        let udpOpt = this._udp
        if (let Some(udp) <- udpOpt) {
            try {
                udp.bind()
            } catch (e: Exception) {
                @LogError(["ReliableChannel: bind failed: ${e.message}"])
                return false
            }
            this._remote = Some(IPSocketAddress(this.remoteHost, this.remotePort))
            this._bound = true
            this._stop.store(false)
            let selfRef = this
            spawn { => selfRef._recvLoop() }
            return true
        } else {
            return false
        }
    }

    /**
     * @brief[zh-cn] 发送可靠包（挂 pending 待确认；任意线程可调用）
     * @param[zh-cn] data 载荷（≤ RELIABLE_MAX_PAYLOAD）
     * @return[zh-cn] 入队并发送成功返回 true
     *
     * @brief[en] Sends a reliable packet (parked in pending; callable from any thread)
     * @param[en] data Payload (≤ RELIABLE_MAX_PAYLOAD)
     * @return[en] True when enqueued and sent
     */
    public func send(data: Array<UInt8>): Bool {
        if (!this._bound) { return false }
        if (Int64(data.size) > RELIABLE_MAX_PAYLOAD) {
            @LogWarn(["ReliableChannel: payload ${data.size} > RELIABLE_MAX_PAYLOAD(${RELIABLE_MAX_PAYLOAD}) - dropped"])
            return false
        }
        let seq = this._nextSeq
        this._nextSeq = _seqAdd(this._nextSeq, 1)
        let now = _nowMs()
        let pkt = PendingPacket(data, now, this.resendDelayMs)
        synchronized(_pendingMutex) {
            _pending.add(seq, pkt)
        }
        let ackBits = if (this._hasReceived) { this._ackBits } else { 0u32 }
        return this._sendRaw(seq, this._makeAck(), ackBits, data)
    }

    /**
     * @brief[zh-cn] 主循环每帧驱动：超时重发 + 按序派发回调
     *
     * @brief[en] Per-frame main-loop driver: timeout resends + in-order callback dispatch
     */
    public func update(): Unit {
        let now = _nowMs()
        // 1. 重发超时未确认的包（间隔翻倍退避）
        synchronized(_pendingMutex) {
            let expired = ArrayList<UInt32>()
            let ackBits = if (this._hasReceived) { this._ackBits } else { 0u32 }
            let ack = this._makeAck()
            for ((seq, pkt) in _pending) {
                if (Float64(now - pkt.sendTimeMs) >= pkt.delayMs) {
                    pkt.resends += 1
                    pkt.sendTimeMs = now
                    pkt.delayMs *= 2.0
                    if (pkt.delayMs > this.maxResendDelayMs) {
                        pkt.delayMs = this.maxResendDelayMs
                    }
                    let ok = this._sendRaw(seq, ack, ackBits, pkt.payload)
                    if (!ok) {
                        expired.add(seq)
                    }
                }
            }
            // 发送失败的包直接移除（上层超时感知链路断裂）
            for (seq in expired) {
                _pending.remove(seq)
            }
        }
        // 2. 按序派发到达的数据
        while (let Some(data) <- this._deliver.remove()) {
            if (let Some(cb) <- this.onMessage) { cb(data) }
        }
    }

    /**
     * @brief[zh-cn] 关闭通道并停止收包线程
     *
     * @brief[en] Closes the channel and stops the receive thread
     */
    public func close(): Unit {
        this._stop.store(true)
        this._bound = false
        let udpOpt = this._udp
        if (let Some(udp) <- udpOpt) {
            try {
                udp.close()
            } catch (_) {
                // 忽略关闭异常
            }
        }
    }

    // ===== 内部 =====

    /** 收包线程主循环：收包 → 处理对端确认 → 数据按序入投递队列 → 立即回 ack */
    private func _recvLoop(): Unit {
        let udpOpt = this._udp
        if (let Some(udp) <- udpOpt) {
            // 复用接收缓冲区：receiveFrom 填充缓冲区并返回实际长度（不分配新数组）
            let recvBuf = Array<UInt8>(_RECV_BUF_SIZE, repeat: 0u8)
            while (!this._stop.load()) {
                var data: Array<UInt8> = Array<UInt8>()
                try {
                    let (from, recvLen) = udp.receiveFrom(recvBuf)
                    if (recvLen > 0) {
                        data = recvBuf[0..recvLen]
                    }
                } catch (e: Exception) {
                    if (this._stop.load()) {
                        break
                    }
                    continue
                }
                if (Int64(data.size) < RELIABLE_HEADER_SIZE) {
                    continue
                }
                let seq = UInt32.readBigEndian(data[0..4])
                let ack = UInt32.readBigEndian(data[4..8])
                let ackBits = UInt32.readBigEndian(data[8..12])
                // 1. 处理对端对我方包的确认
                this._handleAck(ack, ackBits)
                // 2. 纯 ack 帧只做确认，不进数据派发
                if (seq == RELIABLE_ACK_SEQ) {
                    continue
                }
                // 3. 数据按序入投递队列
                if (seq == this._recvSeq) {
                    this._deliverInOrder(seq, data[12..Int64(data.size)])
                } else {
                    let d = _seqDiff(seq, this._recvSeq)
                    if (d > 0) {
                        // 新的乱序包：入缓存（限量防炸）
                        if (Int64(this._ooo.size) < _OOO_CAP) {
                            this._ooo.add(seq, data[12..Int64(data.size)])
                        }
                    }
                    // 重复包（d < 0）：忽略，ack 会再确认
                }
                // 4. 立即回 ack 帧（12 字节头，seq 用纯 ack 标记，载荷为空）
                let replyBuf = Array<UInt8>(RELIABLE_HEADER_SIZE, repeat: 0u8)
                let replyBits = if (this._hasReceived) { this._ackBits } else { 0u32 }
                this._writeHeader(replyBuf, RELIABLE_ACK_SEQ, this._makeAck(), replyBits)
                synchronized(_sendMutex) {
                    try {
                        let remoteOpt = this._remote
                        if (let Some(addr) <- remoteOpt) { udp.sendTo(addr, replyBuf) }
                    } catch (_) {
                        // 回执失败由重发机制兜底
                    }
                }
            }
        }
    }

    /** 按序投递：先投当前 seq，再从乱序缓存补齐后续（仅收包线程） */
    private func _deliverInOrder(seq: UInt32, payload: Array<UInt8>): Unit {
        this._deliver.add(payload)
        this._recvSeq = _seqAdd(seq, 1)
        this._markReceived(seq)
        while (true) {
            let nextOpt = this._ooo.get(this._recvSeq)
            if (let Some(next) <- nextOpt) {
                this._ooo.remove(this._recvSeq)
                this._deliver.add(next)
                this._markReceived(this._recvSeq)
                this._recvSeq = _seqAdd(this._recvSeq, 1)
            } else {
                break
            }
        }
    }

    /** 标记 seq 已收：seq == 最高按序时设 ack 位（位 i ↔ seq = ack-(31-i)；仅收包线程） */
    private func _markReceived(seq: UInt32): Unit {
        if (!this._hasReceived) {
            this._hasReceived = true
            this._highestInOrder = seq
            this._ackBits = 0x80000000u32
            return
        }
        let d = _seqDiff(seq, this._highestInOrder)
        if (d == 1) {
            // 连续推进：位图整体右移 1 位，最高位（ack 自身）置 1
            this._highestInOrder = seq
            this._ackBits = (this._ackBits >> 1) | 0x80000000u32
        } else if (d <= 0 && d >= -31) {
            // 乱序补收：置对应位
            let bitIdx: UInt32 = UInt32(31 + d)
            this._ackBits = this._ackBits | (0x80000000u32 >> bitIdx)
        }
    }

    /** 生成当前 ack 字段（未收到过任何包时回 0） */
    private func _makeAck(): UInt32 {
        return if (this._hasReceived) { this._highestInOrder } else { 0u32 }
    }

    /** 处理对端确认：移除 pending 中被 ack/ackBits 覆盖的 seq 并采样 RTT（仅收包线程） */
    private func _handleAck(ack: UInt32, ackBits: UInt32): Unit {
        if (!this._hasAckMeaning(ack, ackBits)) {
            return
        }
        let now = _nowMs()
        synchronized(_pendingMutex) {
            // ack 本身
            this._confirmOne(ack, now)
            // ackBits 覆盖 [ack-31, ack-1]
            var i: UInt32 = 0u32
            while (i < 32u32) {
                let bit = (ackBits >> (31u32 - i)) & 1u32
                if (bit == 1u32) {
                    let seq = _seqAdd(ack, Int64(i) - 31)
                    this._confirmOne(seq, now)
                }
                i += 1u32
            }
        }
    }

    /** 单个 seq 确认：移除 + RTT 采样（须持 _pendingMutex；仅收包线程） */
    private func _confirmOne(seq: UInt32, nowMs: Int64): Unit {
        let pktOpt = _pending.get(seq)
        if (let Some(pkt) <- pktOpt) {
            _pending.remove(seq)
            let rtt = Float64(nowMs - pkt.sendTimeMs)
            let prev = Float64(_rttMs.load())
            // 首样本直接取值，否则指数平滑 0.875/0.125
            let smoothed = if (prev <= 0.0) { rtt } else { prev * 0.875 + rtt * 0.125 }
            _rttMs.store(Int64(smoothed))
        }
    }

    /** ack 是否有意义（对端尚未收到任何包时 ack=0 且 ackBits=0，不应误触发确认） */
    private func _hasAckMeaning(ack: UInt32, ackBits: UInt32): Bool {
        return ack != 0u32 || ackBits != 0u32
    }

    /** 组包并发出（头 12 字节 + 载荷） */
    private func _sendRaw(seq: UInt32, ack: UInt32, ackBits: UInt32, payload: Array<UInt8>): Bool {
        let pkt = Array<UInt8>(RELIABLE_HEADER_SIZE + Int64(payload.size), repeat: 0u8)
        this._writeHeader(pkt, seq, ack, ackBits)
        for (i in 0..Int64(payload.size)) {
            pkt[RELIABLE_HEADER_SIZE + i] = payload[i]
        }
        let udpOpt = this._udp
        if (let Some(udp) <- udpOpt) {
            synchronized(_sendMutex) {
                let remoteOpt = this._remote
                if (let Some(addr) <- remoteOpt) {
                    try {
                        udp.sendTo(addr, pkt)
                        return true
                    } catch (e: Exception) {
                        return false
                    }
                } else {
                    return false
                }
            }
        } else {
            return false
        }
    }

    /** 写 12 字节包头（seq/ack/ackBits 大端；手写偏移写入，避免切片拷贝写不回） */
    private func _writeHeader(buf: Array<UInt8>, seq: UInt32, ack: UInt32, ackBits: UInt32): Unit {
        buf[0] = UInt8((seq >> 24) & 0xFFu32)
        buf[1] = UInt8((seq >> 16) & 0xFFu32)
        buf[2] = UInt8((seq >> 8) & 0xFFu32)
        buf[3] = UInt8(seq & 0xFFu32)
        buf[4] = UInt8((ack >> 24) & 0xFFu32)
        buf[5] = UInt8((ack >> 16) & 0xFFu32)
        buf[6] = UInt8((ack >> 8) & 0xFFu32)
        buf[7] = UInt8(ack & 0xFFu32)
        buf[8] = UInt8((ackBits >> 24) & 0xFFu32)
        buf[9] = UInt8((ackBits >> 16) & 0xFFu32)
        buf[10] = UInt8((ackBits >> 8) & 0xFFu32)
        buf[11] = UInt8(ackBits & 0xFFu32)
    }

    /** seq 环加法（mod 2^32） */
    internal static func _seqAdd(s: UInt32, d: Int64): UInt32 {
        let m = (Int64(s) + d) % 4294967296
        return if (m < 0) { UInt32(m + 4294967296) } else { UInt32(m) }
    }

    /** seq 环距离（a - b，结果映射到 [-2^31, 2^31)） */
    internal static func _seqDiff(a: UInt32, b: UInt32): Int64 {
        var d = Int64(a) - Int64(b)
        if (d > 2147483647) {
            d -= 4294967296
        } else if (d < -2147483648) {
            d += 4294967296
        }
        return d
    }

    /** 单调毫秒时钟（进程级 epoch） */
    private static func _nowMs(): Int64 {
        return Int64((MonoTime.now() - _epoch).toMilliseconds())
    }
}
