/**
 * @file[zh-cn] SocketUdp UDP 客户端/服务端高级封装（three.network.socket 子包）
 * @brief[zh-cn] 基于 std.net.UdpSocket 提供游戏开发友好的 UDP 通信
 * @explain[zh-cn] 提供 bind 绑定本地端口、sendTo 指定远端发送（IP + 端口 + 字节）、
 * receive 阻塞接收（返回远端地址 + 数据）、close 关闭。
 * 用法示例：
 * // 发送方
 * let udp = SocketUdp()
 * udp.bind(0)
 * udp.sendTo("127.0.0.1", 9000, "hello".toArray())
 * // 接收方
 * let udp = SocketUdp(bindPort: 9000)
 * udp.bind(9000)
 * let (from, data) = udp.receive()   // 阻塞接收
 *
 * @file[en] SocketUdp  High-level UDP client/server wrapper (three.network.socket sub-package)
 * @brief[en] A game-development-friendly UDP communication wrapper built on std.net.UdpSocket
 * @explain[en] Provides bind to bind a local port, sendTo to send to a remote peer
 * (IP + port + bytes), receive to block for data (returning remote address + data)
 * and close to shut down.
 * Usage:
 * // sender
 * let udp = SocketUdp()
 * udp.bind(0)
 * udp.sendTo("127.0.0.1", 9000, "hello".toArray())
 * // receiver
 * let udp = SocketUdp(bindPort: 9000)
 * udp.bind(9000)
 * let (from, data) = udp.receive()   // blocking receive
 */
package three.network.socket

import std.net.*
import std.core.*

/**
 * @brief[zh-cn] UDP 套接字
 * @explain[zh-cn] 对 std.net.UdpSocket 的游戏开发友好封装，支持绑定端口、向指定远端发送与阻塞接收。
 *
 * @brief[en] UDP socket
 * @explain[en] A game-development-friendly wrapper around std.net.UdpSocket with port
 * binding, remote sending and blocking receive.
 */
public class SocketUdp {
    /**
     * @brief[zh-cn] 底层 std.net 套接字
     *
     * @brief[en] Underlying std.net socket
     */
    private var _socket: Option<UdpSocket> = None

    /**
     * @brief[zh-cn] 是否已绑定
     *
     * @brief[en] Whether bound
     */
    private var _bound: Bool = false

    /**
     * @brief[zh-cn] 构造 UDP 套接字
     * @param[zh-cn] bindPort 本地绑定端口（0 = 自动分配）
     *
     * @brief[en] Constructs a UDP socket
     * @param[en] bindPort Local bind port (0 = automatically assigned)
     */
    public init(bindPort!: UInt16 = 0) {
        let s = UdpSocket(bindAt: bindPort)
        this._socket = Some(s)
    }

    /**
     * @brief[zh-cn] 是否已绑定
     * @return[zh-cn] 已绑定本地端口返回 true
     *
     * @brief[en] Whether the socket is bound
     * @return[en] Returns true when a local port is bound
     */
    public prop isBound: Bool {
        get() { this._bound }
    }

    /**
     * @brief[zh-cn] 绑定本地端口（同步）
     * @param[zh-cn] port 要绑定的端口
     * @return[zh-cn] 绑定成功返回 true；失败返回 false
     *
     * @brief[en] Binds a local port (synchronous)
     * @param[en] port The port to bind
     * @return[en] Returns true on success, false on failure
     */
    public func bind(port: UInt16): Bool {
        match (this._socket) {
            case Some(s) =>
                try {
                    s.bind()
                    this._bound = true
                    return true
                } catch (e: Exception) {
                    return false
                }
            case None => return false
        }
    }

    /**
     * @brief[zh-cn] 绑定（使用构造时指定的端口）
     * @return[zh-cn] 绑定成功返回 true；失败返回 false
     *
     * @brief[en] Binds using the port given at construction time
     * @return[en] Returns true on success, false on failure
     */
    public func bind(): Bool {
        match (this._socket) {
            case Some(s) =>
                try {
                    s.bind()
                    this._bound = true
                    return true
                } catch (e: Exception) {
                    return false
                }
            case None => return false
        }
    }

    /**
     * @brief[zh-cn] 发送数据到指定远端
     * @param[zh-cn] host 目标 IP（如 "127.0.0.1"）
     * port 目标端口
     * data 数据字节
     * @return[zh-cn] 发送成功返回 true；失败返回 false
     *
     * @brief[en] Sends data to the specified remote peer
     * @param[en] host Target IP (e.g. "127.0.0.1")
     * port Target port
     * data The data bytes
     * @return[en] Returns true on success, false on failure
     */
    public func sendTo(host: String, port: UInt16, data: Array<UInt8>): Bool {
        match (this._socket) {
            case Some(s) =>
                try {
                    let addr = IPSocketAddress(host, port)
                    s.sendTo(addr, data)
                    return true
                } catch (e: Exception) {
                    return false
                }
            case None => return false
        }
    }

    /**
     * @brief[zh-cn] 发送文本到指定远端（UTF-8）
     * @param[zh-cn] host 目标 IP
     * port 目标端口
     * text 待发送的文本
     * @return[zh-cn] 发送成功返回 true；失败返回 false
     *
     * @brief[en] Sends a text string to the specified remote peer (UTF-8)
     * @param[en] host Target IP
     * port Target port
     * text The text to send
     * @return[en] Returns true on success, false on failure
     */
    public func sendString(host: String, port: UInt16, text: String): Bool {
        return this.sendTo(host, port, text.toArray())
    }

    /**
     * @brief[zh-cn] 阻塞接收数据
     * @return[zh-cn] 返回 (远端地址字符串, 数据字节)；失败时返回 ("", [])
     *
     * @brief[en] Receives data (blocking)
     * @return[en] Returns (remote address string, data bytes); on failure returns ("", [])
     *
     * @note[zh-cn] 远端地址以 "host:port" 形式表达。
     * @note[en] The remote address is expressed as "host:port".
     */
    public func receive(): (String, Array<UInt8>) {
        let buf = Array<UInt8>(65536, { _ => 0u8 })
        match (this._socket) {
            case Some(s) =>
                try {
                    let (from, n) = s.receiveFrom(buf)
                    let data = Array<UInt8>(n, { _ => 0u8 })
                    for (i in 0..n) {
                        data[Int64(i)] = buf[Int64(i)]
                    }
                    // from 是 SocketAddress（抽象），转 IPSocketAddress 取 host/port
                    // （ip.address 类型不统一，统一用 toString() 表达 "host:port"）
                    let host = match (from as IPSocketAddress) {
                        case Some(ip) => ip.toString()
                        case None => from.toString()
                    }
                    return (host, data)
                } catch (e: Exception) {
                    return ("", [])
                }
            case None => return ("", [])
        }
    }

    /**
     * @brief[zh-cn] 关闭套接字
     *
     * @brief[en] Closes the socket
     */
    public func close(): Unit {
        match (this._socket) {
            case Some(s) =>
                try {
                    s.close()
                } catch (_) {
                    // 忽略关闭异常
                }
                this._socket = None
                this._bound = false
            case None => ()
        }
    }
}
