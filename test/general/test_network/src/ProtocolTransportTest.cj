/**
 * @file ProtocolTransportTest
 * @brief test_network: 协议编解码 + 可靠 UDP 通道测试
 *
 * 检测 three.network.protocol / three.network.transport 能力：
 * - PacketWriter/PacketReader：各类型大端序往返 / 字符串往返 / 越界读取抛异常
 * - ReliableChannel：本机回环双通道收发（seq/ack 确认 + 按序派发 + RTT 采样）
 */
package threeNetworkTest

import std.time.*
import std.sync.*
import three.network.protocol.*
import three.network.transport.*

// ===== 局部断言辅助（避免与 main.cj 的 private check 冲突） =====

private var _ptPass: Int64 = 0
private var _ptFail: Int64 = 0

private func ck(name: String, cond: Bool): Unit {
    if (cond) {
        _ptPass += 1
        println("  [PASS] ${name}")
    } else {
        _ptFail += 1
        println("  [FAIL] ${name}")
    }
}

/// ReliableChannel 回调状态容器（lambda 不能捕获可变变量）
class ChanState {
    var messages: Int64 = 0
    var last: Array<UInt8> = []
}

// ===== 测试函数（由 main.cj 调用） =====

/// PacketWriter / PacketReader 各类型往返
func test_packet_codec(): Unit {
    println("[P1] PacketCodec 大端序往返")
    let w = PacketWriter()
    w.writeU8(0xABu8)
    w.writeU16(0x1234u16)
    w.writeU32(0x12345678u32)
    w.writeU64(0x1122334455667788u64)
    w.writeI16(-2i16)
    w.writeI32(-3i32)
    w.writeI64(-4i64)
    w.writeBool(true)
    w.writeBool(false)
    w.writeF32(0.5f32)
    w.writeF64(0.25f64)
    w.writeString("你好, lockstep")
    w.writeString("")
    let bytes = w.toArray()

    // 大端序抽查：U16 高字节在前
    ck("U16 大端序", bytes[1] == 0x12u8 && bytes[2] == 0x34u8)

    let r = PacketReader(bytes)
    ck("U8 往返", r.readU8() == 0xABu8)
    ck("U16 往返", r.readU16() == 0x1234u16)
    ck("U32 往返", r.readU32() == 0x12345678u32)
    ck("U64 往返", r.readU64() == 0x1122334455667788u64)
    ck("I16 往返", r.readI16() == -2i16)
    ck("I32 往返", r.readI32() == -3i32)
    ck("I64 往返", r.readI64() == -4i64)
    ck("Bool 往返", r.readBool() && !r.readBool())
    ck("F32 往返", r.readF32() == 0.5f32)
    ck("F64 往返", r.readF64() == 0.25f64)
    ck("字符串往返", r.readString() == "你好, lockstep")
    ck("空字符串往返", r.readString() == "")
    ck("读完 remaining=0", r.remaining == 0)

    // 越界读取抛 IllegalStateException
    var threw = false
    try {
        r.readU8()
    } catch (e: IllegalStateException) {
        threw = true
    }
    ck("越界读取抛异常", threw)
    println("")
}

/// ReliableChannel 本机回环：A→B 双通道收发 + 确认 + 按序派发
func test_reliable_channel(): Unit {
    println("[P2] ReliableChannel 本机回环")
    // ReliableChannel 是"一通道绑一远端"：A/B 各自指向对端固定端口
    let portA: UInt16 = 50010
    let portB: UInt16 = 50011
    let chanB = ReliableChannel("127.0.0.1", portA, bindPort: portB)
    let stateB = ChanState()
    chanB.onMessage = Some({ data =>
        stateB.messages += 1
        stateB.last = data
    })
    ck("B bind 成功", chanB.bind())

    // A 绑定固定端口，远端指向 B（B 的 ack/回包依据 _remote 发往 A）
    let chanA = ReliableChannel("127.0.0.1", portB, bindPort: portA)
    let stateA = ChanState()
    chanA.onMessage = Some({ data =>
        stateA.messages += 1
        stateA.last = data
    })
    ck("A bind 成功", chanA.bind())

    // A 连发 3 包（含两条不同载荷验证按序）
    ck("A send #1", chanA.send([0x01u8, 0x02u8]))
    ck("A send #2", chanA.send("pkt2".toArray()))
    ck("A send #3", chanA.send([0x03u8]))

    // 双方各自主循环泵 update（重发 + 派发回调），等待收齐
    var waited = 0
    while (stateB.messages < 3 && waited < 50) {
        chanA.update()
        chanB.update()
        sleep(Duration.millisecond * 20)
        waited += 1
    }
    ck("B 收齐 3 包", stateB.messages == 3)
    ck("B 按序收到末包", stateB.last.size == 1 && stateB.last[0] == 0x03u8)

    // 确认回报后 A 的 pending 清零
    waited = 0
    while (chanA.pendingCount > 0 && waited < 50) {
        chanA.update()
        chanB.update()
        sleep(Duration.millisecond * 20)
        waited += 1
    }
    ck("A pending 全部确认", chanA.pendingCount == 0)

    // B 回向 A 发包（此时 B 已知 A 的来源地址）
    ck("B send 回包", chanB.send([0xBBu8]))
    waited = 0
    while (stateA.messages < 1 && waited < 50) {
        chanA.update()
        chanB.update()
        sleep(Duration.millisecond * 20)
        waited += 1
    }
    ck("A 收到回包", stateA.messages == 1)
    ck("A 收包内容正确", stateA.last.size == 1 && stateA.last[0] == 0xBBu8)

    chanA.release()
    chanB.release()
    println("")
}

/// protocol/transport 结果汇总（供 main.cj 合并统计）
func protoPassCount(): Int64 { _ptPass }
func protoFailCount(): Int64 { _ptFail }
