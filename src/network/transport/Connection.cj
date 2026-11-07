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
 * @file[zh-cn] Connection TCP 长连接（three.network.transport 子包）
 * @brief[zh-cn] TCP 游戏连接：长度前缀组帧 + 后台收包线程 + 心跳保活 + 指数退避自动重连
 * @explain[zh-cn] 补齐 three.network.socket（阻塞读写原语）之上的游戏级连接能力：
 * - 组帧协议：每帧 [帧长 u32 大端][帧类型 u8][载荷]，帧长含类型字节；
 *   帧类型：FRAME_PING=0x01 / FRAME_PONG=0x02 / FRAME_DATA=0x03（心跳帧内部消化，
 *   只有 FRAME_DATA 载荷上抛 onMessage），未知帧类型忽略（向前兼容）。
 * - 线程模型：connect() 后 spawn 收包线程阻塞读帧；PING→PONG 在收包线程直接回应；
 *   onMessage 在收包线程回调（用户回调内不可调用 Connection 的写接口之外的 SDL/bgfx API，
 *   需要时自行转投队列）；onConnected / onDisconnected / 重连全部在主循环 update() 触发。
 * - 心跳：update() 按 heartbeatIntervalMs 定期发 PING；连续 heartbeatTimeoutMs 未收任何帧
 *   判定断线（对端自会回应 PONG，无需应用层 PONG 处理）。
 * - 重连：autoReconnect=true 时断线后在 update() 中按 1s 起步、翻倍、封顶
 *   maxReconnectDelayMs 的指数退避自动重连；重连成功触发 onConnected。
 * 典型用法：
 * let conn = Connection("127.0.0.1", 9000)
 * conn.onMessage = Some({ data => /* 收包线程 */ })
 * if (conn.connect()) { /* onConnected 同步触发 */ }
 * // 主循环每帧：
 * conn.update()
 * conn.send(PacketWriter().apply(...).toArray()) — 见 send
 *
 * @file[en] Connection  TCP persistent connection (three.network.transport sub-package)
 * @brief[en] Game-grade TCP connection: length-prefixed framing + background receive thread
 * + heartbeat keep-alive + exponential-backoff auto reconnect
 * @explain[en] Adds game-grade connection capability on top of three.network.socket
 * (blocking read/write primitives):
 * - Framing: each frame is [frame length u32 big-endian][frame type u8][payload]; the length
 *   includes the type byte; types: FRAME_PING=0x01 / FRAME_PONG=0x02 / FRAME_DATA=0x03
 *   (heartbeat frames are consumed internally; only FRAME_DATA payloads surface through
 *   onMessage); unknown frame types are ignored (forward compatible).
 * - Threading: connect() spawns a receive thread that blocks reading frames; PING→PONG is
 *   answered directly on the receive thread; onMessage fires on the receive thread (user
 *   callbacks must not call SDL/bgfx APIs from there - forward to your own queue);
 *   onConnected / onDisconnected / reconnection all fire in the main-loop update().
 * - Heartbeat: update() sends PING every heartbeatIntervalMs; no frame received for
 *   heartbeatTimeoutMs marks the connection broken (peers answer PONG, no app-level PONG
 *   handling needed).
 * - Reconnect: with autoReconnect=true, broken connections reconnect from update() with
 *   exponential backoff (1s base, doubling, capped at maxReconnectDelayMs); onConnected
 *   fires on success.
 * Usage:
 * let conn = Connection("127.0.0.1", 9000)
 * conn.onMessage = Some({ data => /* receive thread */ })
 * if (conn.connect()) { /* onConnected fired synchronously */ }
 * // every frame in the main loop:
 * conn.update()
 * conn.send(...)
 */
package three.network.transport

import std.core.*
import std.binary.*
import std.net.*
import std.sync.*
import std.time.*
import three.utils.log.*
import three.utils.log.macros.*
import three.utils.safe.IReleasable

/** 心跳帧（保活探测） */
public const FRAME_PING: UInt8 = 0x01u8

/** 心跳应答帧 */
public const FRAME_PONG: UInt8 = 0x02u8

/** 数据帧（载荷上抛 onMessage） */
public const FRAME_DATA: UInt8 = 0x03u8

/** 单帧最大字节数（帧长字段校验上限，防恶意长度声明炸内存；默认 8MB） */
public const MAX_FRAME_SIZE: Int64 = 8 * 1024 * 1024

/**
 * @brief[zh-cn] TCP 游戏连接
 * @explain[zh-cn] 组帧 + 心跳 + 重连的游戏级 TCP 连接；send 可在任意线程调用（内部加锁），
 * 状态查询线程安全；用户回调线程模型见 @explain 文件头。
 *
 * @brief[en] Game-grade TCP connection
 * @explain[en] TCP connection with framing, heartbeat and reconnect; send may be called from
 * any thread (locked internally); state queries are thread-safe; see the file header
 * @explain for the user-callback threading model.
 */
public class Connection <: IReleasable {
    /**
     * @brief[zh-cn] 目标主机
     *
     * @brief[en] Target host
     */
    public let host: String

    /**
     * @brief[zh-cn] 目标端口
     *
     * @brief[en] Target port
     */
    public let port: UInt16

    /**
     * @brief[zh-cn] 心跳发送间隔（毫秒；0 = 禁用心跳，默认 5000）
     *
     * @brief[en] Heartbeat send interval in ms (0 = disabled, default 5000)
     */
    public var heartbeatIntervalMs: Float64 = 5000.0

    /**
     * @brief[zh-cn] 心跳超时（毫秒；连续无帧超过该值判定断线，0 = 禁用检测，默认 15000）
     *
     * @brief[en] Heartbeat timeout in ms (no frame beyond this marks broken, 0 = disabled,
     * default 15000)
     */
    public var heartbeatTimeoutMs: Float64 = 15000.0

    /**
     * @brief[zh-cn] 断线后是否自动重连（默认 false）
     *
     * @brief[en] Whether to reconnect automatically after a broken connection (default false)
     */
    public var autoReconnect: Bool = false

    /**
     * @brief[zh-cn] 自动重连退避上限（毫秒，默认 30000）
     *
     * @brief[en] Auto reconnect backoff cap in ms (default 30000)
     */
    public var maxReconnectDelayMs: Float64 = 30000.0

    /**
     * @brief[zh-cn] 数据帧回调（在收包线程执行，注意线程模型）
     *
     * @brief[en] Data-frame callback (runs on the receive thread; mind the threading model)
     */
    public var onMessage: Option<(Array<UInt8>) -> Unit> = None

    /**
     * @brief[zh-cn] 连接建立回调（主循环线程执行）
     *
     * @brief[en] Connected callback (runs on the main-loop thread)
     */
    public var onConnected: Option<() -> Unit> = None

    /**
     * @brief[zh-cn] 断线回调（主循环线程执行，参数为原因）
     *
     * @brief[en] Disconnected callback (main-loop thread; parameter is the reason)
     */
    public var onDisconnected: Option<(String) -> Unit> = None

    /** 底层套接字（仅主循环 connect/reconnect 写，收包线程只读引用） */
    private var _socket: Option<TcpSocket>

    /** 是否已连接（原子） */
    private let _connected: AtomicBool

    /** 收包线程停止标志 */
    private let _stop: AtomicBool

    /** 收包线程句柄 */
    private var _recvFuture: Option<Future<Unit>>

    /** 发送锁（多线程 send / 收包线程回应 PONG 互斥） */
    private let _sendMutex: Mutex

    /** 最近一次收到任何帧的时间（epoch 毫秒，原子） */
    private let _lastRecvMs: AtomicInt64

    /** 最近一次发送 PING 的时间（epoch 毫秒，主循环线程专用） */
    private var _lastPingMs: Int64

    // —— 以下状态仅主循环线程（update/connect/close）访问 ——
    /** 断线原因暂存（update 触发 onDisconnected 后清空） */
    private var _pendingDisconnect: Option<String>

    /** 是否处于待重连状态 */
    private var _pendingReconnect: Bool

    /** 已重连尝试次数（退避计算） */
    private var _reconnectAttempts: Int64

    /** 下次允许重连的时间（epoch 毫秒） */
    private var _nextReconnectMs: Int64

    /**
     * @brief[zh-cn] 构造连接（不发起连接，需调用 connect）
     * @param[zh-cn] host 目标主机（IP 或域名）
     * port 目标端口
     *
     * @brief[en] Constructs a connection (call connect to establish)
     * @param[en] host Target host (IP or domain)
     * port Target port
     */
    public init(host: String, port: UInt16) {
        this.host = host
        this.port = port
        this._socket = None
        this._connected = AtomicBool(false)
        this._stop = AtomicBool(false)
        this._recvFuture = None
        this._sendMutex = Mutex()
        this._lastRecvMs = AtomicInt64(0)
        this._lastPingMs = 0
        this._pendingDisconnect = None
        this._pendingReconnect = false
        this._reconnectAttempts = 0
        this._nextReconnectMs = 0
    }

    /**
     * @brief[zh-cn] 是否已连接
     *
     * @brief[en] Whether connected
     */
    public prop isConnected: Bool {
        get() { _connected.load() }
    }

    /**
     * @brief[zh-cn] 建立连接并启动收包线程（同步阻塞）
     * @return[zh-cn] 连接成功返回 true（成功时同步触发 onConnected）；失败返回 false
     *
     * @brief[en] Establishes the connection and starts the receive thread (blocking)
     * @return[en] True on success (onConnected fired synchronously); false on failure
     */
    public func connect(): Bool {
        if (_connected.load()) { return true }
        if (!this._tryConnect()) { return false }
        this._startRecvThread()
        // 连接成功：清重连状态，触发回调
        this._pendingReconnect = false
        this._reconnectAttempts = 0
        this._lastRecvMs.store(_nowMs())
        this._lastPingMs = _nowMs()
        if (let Some(cb) <- this.onConnected) { cb() }
        return true
    }

    /**
     * @brief[zh-cn] 发送数据帧（FRAME_DATA；任意线程可调用）
     * @param[zh-cn] data 载荷字节（不含帧头，内部自动组帧）
     * @return[zh-cn] 发送成功返回 true；未连接或写失败返回 false
     *
     * @brief[en] Sends a data frame (FRAME_DATA; callable from any thread)
     * @param[en] data Payload bytes (framing added internally)
     * @return[en] True on success; false when not connected or on write failure
     */
    public func send(data: Array<UInt8>): Bool {
        return this._sendFrame(FRAME_DATA, data)
    }

    /**
     * @brief[zh-cn] 发送文本数据帧（UTF-8）
     * @param[zh-cn] s 文本
     * @return[zh-cn] 发送成功返回 true
     *
     * @brief[en] Sends a text data frame (UTF-8)
     * @param[en] s Text
     * @return[en] True on success
     */
    public func sendString(s: String): Bool {
        return this.send(s.toArray())
    }

    /**
     * @brief[zh-cn] 主循环每帧驱动：心跳发送 + 断线检测 + 回调派发 + 自动重连
     * @explain[zh-cn] 在窗口主循环（onFrame）中调用；回调 onConnected/onDisconnected
     * 只会在本方法中触发。
     *
     * @brief[en] Per-frame main-loop driver: heartbeat send + liveness check + callback
     * dispatch + auto reconnect
     * @explain[en] Call from the window main loop (onFrame); onConnected/onDisconnected fire
     * only inside this method.
     */
    public func update(): Unit {
        let now = _nowMs()
        // 1. 派发断线回调（收包线程只标记，这里统一触发）
        if (let Some(reason) <- this._pendingDisconnect) {
            this._pendingDisconnect = None
            this._pendingReconnect = this.autoReconnect
            this._reconnectAttempts = 0
            this._nextReconnectMs = now
            if (let Some(cb) <- this.onDisconnected) { cb(reason) }
        }
        if (_connected.load()) {
            // 2. 心跳：按间隔发 PING（任何响应帧都会刷新 _lastRecvMs）
            if (this.heartbeatIntervalMs > 0.0 && Float64(now - this._lastPingMs) >= this.heartbeatIntervalMs) {
                this._lastPingMs = now
                let _ = this._sendFrame(FRAME_PING, Array<UInt8>())
            }
            // 3. 存活检测：连续无帧超时 → 判定断线
            if (this.heartbeatTimeoutMs > 0.0) {
                let lastRecv = this._lastRecvMs.load()
                if (lastRecv > 0 && Float64(now - lastRecv) >= this.heartbeatTimeoutMs) {
                    @LogWarn(["Connection: heartbeat timeout (${this.heartbeatTimeoutMs} ms) - marking broken"])
                    // 关闭 socket 以解除收包线程在旧 socket 上的阻塞读
                    this._closeSocket()
                    this._markBroken("heartbeat timeout")
                }
            }
        } else if (this._pendingReconnect && now >= this._nextReconnectMs) {
            // 4. 自动重连（指数退避）
            this._pendingReconnect = false
            // 重连前必须先释放旧 socket（含其收包线程的阻塞读），否则每次重连
            // 都遗留一个 socket 句柄与一个卡在旧 socket 上的收包线程
            this._closeSocket()
            if (this._tryConnect()) {
                this._startRecvThread()
                this._reconnectAttempts = 0
                this._lastRecvMs.store(now)
                this._lastPingMs = now
                _connected.store(true)
                if (let Some(cb) <- this.onConnected) { cb() }
            } else {
                this._reconnectAttempts += 1
                let delay = this._backoffMs(this._reconnectAttempts)
                this._nextReconnectMs = now + Int64(delay)
                this._pendingReconnect = true
                @LogWarn(["Connection: reconnect attempt ${this._reconnectAttempts} failed, next in ${delay} ms"])
            }
        }
    }

    /**
     * @brief[zh-cn] 关闭连接（用户主动；不触发 onDisconnected、不自动重连）
     *
     * @brief[en] Closes the connection (user-initiated; no
     * onDisconnected, no auto reconnect)
     */
    public func release(): Bool {
        this._stop.store(true)
        this._pendingReconnect = false
        this._pendingDisconnect = None
        _connected.store(false)
        this._closeSocket()
        return true
    }

    // ===== 内部 =====

    /**
     * @brief[zh-cn] 关闭并清空当前 socket（可指定期望实例，避免误关重连后的新 socket）
     * @param[zh-cn] expected 期望关闭的 socket 实例；None 表示关闭当前持有的 socket
     *
     * @brief[en] Closes and clears the current socket (optionally pinned to an expected instance
     * so a reconnect-created new socket is never closed by mistake)
     * @param[en] expected The socket instance expected to be closed; None closes the current one
     */
    private func _closeSocket(expected!: Option<TcpSocket> = None): Unit {
        if (let Some(s) <- this._socket) {
            var shouldClose = true
            if (let Some(exp) <- expected) {
                shouldClose = refEq(exp, s)
            }
            if (shouldClose) {
                try {
                    s.close()
                } catch (_) {
                    // 忽略关闭异常
                }
                this._socket = None
            }
        }
    }

    /** 同步建连（不启动线程） */
    private func _tryConnect(): Bool {
        try {
            let s = TcpSocket(this.host, this.port)
            s.connect()
            this._socket = Some(s)
            this._stop.store(false)
            return true
        } catch (e: Exception) {
            @LogError(["Connection: connect to ${this.host}:${this.port} failed: ${e.message}"])
            return false
        }
    }

    /** 启动收包线程 */
    private func _startRecvThread(): Unit {
        this._stop.store(false)
        let selfRef = this
        this._recvFuture = Some(spawn { => selfRef._recvLoop() })
    }

    /** 收包线程主循环：阻塞读帧 → 心跳内部消化 / 数据上抛 */
    private func _recvLoop(): Unit {
        let socketOpt = this._socket
        if (let Some(s) <- socketOpt) {
            let header = Array<UInt8>(5, repeat: 0u8)
            while (!this._stop.load()) {
                if (!_readFull(s, header, 5)) {
                    break
                }
                let frameLen = Int64(UInt32.readBigEndian(header[0..4]))
                let frameType = header[4]
                if (frameLen < 1 || frameLen > MAX_FRAME_SIZE) {
                    @LogError(["Connection: bad frame length ${frameLen} - closing"])
                    break
                }
                let payloadLen = frameLen - 1
                var payload = Array<UInt8>()
                if (payloadLen > 0) {
                    payload = Array<UInt8>(payloadLen, repeat: 0u8)
                    if (!_readFull(s, payload, payloadLen)) {
                        break
                    }
                }
                // 任何帧都刷新存活时间
                this._lastRecvMs.store(_nowMs())
                if (frameType == FRAME_PING) {
                    // 心跳探测：收包线程直接回应 PONG（无锁竞争面小，send 内部自会加锁）
                    let _ = this._sendFrame(FRAME_PONG, Array<UInt8>())
                } else if (frameType == FRAME_DATA) {
                    if (let Some(cb) <- this.onMessage) { cb(payload) }
                }
                // 其他帧类型（含 PONG）忽略——收到即已刷新存活时间
            }
            // 读失败/对端关闭：先释放本线程持有的 socket（钉住实例，避免误关重连后的新 socket）
            this._closeSocket(expected: Some(s))
        }
        // 线程退出：统一走断线标记（update 派发回调）；用户主动 close 时不标记
        if (!this._stop.load()) {
            this._markBroken("connection closed by peer or read error")
        } else {
            _connected.store(false)
        }
    }

    /** 发送一帧（帧长 u32 大端 + 类型 u8 + 载荷），发送锁保护 */
    private func _sendFrame(frameType: UInt8, payload: Array<UInt8>): Bool {
        if (!_connected.load()) { return false }
        let total: UInt32 = UInt32(payload.size) + 1u32
        synchronized(_sendMutex) {
            let socketOpt = this._socket
            if (let Some(s) <- socketOpt) {
                try {
                    // 帧头：u32 帧长（含类型字节）大端 + u8 类型
                    let header = Array<UInt8>(5, repeat: 0u8)
                    header[0] = UInt8((total >> 24) & 0xFFu32)
                    header[1] = UInt8((total >> 16) & 0xFFu32)
                    header[2] = UInt8((total >> 8) & 0xFFu32)
                    header[3] = UInt8(total & 0xFFu32)
                    header[4] = frameType
                    s.write(header)
                    if (payload.size > 0) {
                        s.write(payload)
                    }
                    return true
                } catch (e: Exception) {
                    @LogError(["Connection: send failed: ${e.message}"])
                    return false
                }
            } else {
                return false
            }
        }
    }

    /** 断线标记（收包线程 / update 超时检测调用）：置状态、暂存原因，回调留给 update */
    private func _markBroken(reason: String): Unit {
        let wasConnected = _connected.swap(false)
        if (wasConnected) {
            this._pendingDisconnect = Some(reason)
        }
    }

    /** 指数退避：1s * 2^attempts，封顶 maxReconnectDelayMs */
    private func _backoffMs(attempts: Int64): Float64 {
        let base = 1000.0
        var delay = base
        var i: Int64 = 0
        while (i < attempts && delay < this.maxReconnectDelayMs) {
            delay *= 2.0
            i += 1
        }
        if (delay > this.maxReconnectDelayMs) {
            delay = this.maxReconnectDelayMs
        }
        return delay
    }

    /** 单调毫秒时钟（进程级 epoch） */
    private static func _nowMs(): Int64 {
        return Int64((MonoTime.now() - _epoch).toMilliseconds())
    }

    /** 进程级时钟起点 */
    private static let _epoch: MonoTime = MonoTime.now()
}

/**
 * @brief[zh-cn] 循环读满 n 字节（TCP 粘包/半包的底层补偿）
 * @param[zh-cn] s 底层套接字
 * buf 目标缓冲（从索引 0 起使用）
 * n 需要读满的字节数（≤ buf.size）
 * @return[zh-cn] 读满返回 true；对端关闭或读错误返回 false
 *
 * @brief[en] Reads exactly n bytes in a loop (low-level TCP coalescing/partial-read fixup)
 * @param[en] s Underlying socket
 * buf Destination buffer (used from index 0)
 * n Byte count to fill (≤ buf.size)
 * @return[en] True when n bytes were read; false on peer close or read error
 */
internal func _readFull(s: TcpSocket, buf: Array<UInt8>, n: Int64): Bool {
    var got: Int64 = 0
    // read() 固定从缓冲区索引 0 起读，且仓颉切片返回拷贝（写切片不会回写原数组），
    // 故先读进临时数组再逐字节回填到 buf 的 got 位置
    let tmp = Array<UInt8>(n, repeat: 0u8)
    while (got < n) {
        var r: Int64 = -1
        try {
            r = s.read(tmp)
        } catch (e: Exception) {
            return false
        }
        if (r <= 0) {
            return false
        }
        for (i in 0..r) {
            buf[got + i] = tmp[i]
        }
        got += r
    }
    return true
}
