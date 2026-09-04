/**
 * @file[zh-cn] SocketClient TCP 客户端高级封装（three.network.socket 子包）
 * @brief[zh-cn] 基于 std.net.TcpSocket 提供游戏开发友好的 TCP 客户端
 * @explain[zh-cn] 提供 connect / close 连接管理、write / writeString 发送（原始字节 + 文本）、
 * read / readString 接收（阻塞），并通过 ISocketListener 事件回调（onOpen /
 * onMessage / onError / onClose）上报连接状态与数据。
 * 用法示例：
 * let client = SocketClient(host: "127.0.0.1", port: 8080)
 * if (client.connect()) {
 * client.writeString("hello")
 * let data = client.read()
 * client.close()
 * }
 *
 * @file[en] SocketClient  High-level TCP client wrapper (three.network.socket sub-package)
 * @brief[en] A game-development-friendly TCP client built on std.net.TcpSocket
 * @explain[en] Offers connect / close management, write / writeString sending
 * (raw bytes + text) and read / readString receiving (blocking), reporting
 * connection state and data through the ISocketListener callbacks
 * (onOpen / onMessage / onError / onClose).
 * Usage:
 * let client = SocketClient(host: "127.0.0.1", port: 8080)
 * if (client.connect()) {
 * client.writeString("hello")
 * let data = client.read()
 * client.close()
 * }
 */
package three.network.socket

import std.net.*
import std.core.*

/**
 * @brief[zh-cn] TCP 客户端
 * @explain[zh-cn] 对 std.net.TcpSocket 的游戏开发友好封装，支持阻塞读写与事件回调。
 *
 * @brief[en] TCP client
 * @explain[en] A game-development-friendly wrapper around std.net.TcpSocket with
 * blocking read/write and event callbacks.
 */
public class SocketClient {
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
     * @brief[zh-cn] 底层 std.net 套接字（连接后有效）
     *
     * @brief[en] Underlying std.net socket (valid after connection)
     */
    private var _socket: Option<TcpSocket> = None

    /**
     * @brief[zh-cn] 事件监听器
     *
     * @brief[en] Event listener
     */
    public var listener: Option<ISocketListener> = None

    /**
     * @brief[zh-cn] 是否已连接
     *
     * @brief[en] Whether connected
     */
    private var _connected: Bool = false

    /**
     * @brief[zh-cn] 构造 TCP 客户端
     * @param[zh-cn] host 目标主机（IP 或域名）
     * port 目标端口
     *
     * @brief[en] Constructs a TCP client
     * @param[en] host Target host (IP or domain name)
     * port Target port
     */
    public init(host: String, port: UInt16) {
        this.host = host
        this.port = port
    }

    /**
     * @brief[zh-cn] 是否已连接
     * @return[zh-cn] 已建立连接返回 true
     *
     * @brief[en] Whether the client is connected
     * @return[en] Returns true when a connection is established
     */
    public prop isConnected: Bool {
        get() { this._connected }
    }

    /**
     * @brief[zh-cn] 建立连接（同步阻塞）
     * @return[zh-cn] 连接成功返回 true；失败返回 false
     *
     * @brief[en] Establishes a connection (synchronous, blocking)
     * @return[en] Returns true on success, false on failure
     *
     * @note[zh-cn] 连接成功时触发 onOpen，失败时触发 onError。
     * @note[en] Fires onOpen on success and onError on failure.
     */
    public func connect(): Bool {
        if (this._connected) { return true }
        try {
            let s = TcpSocket(this.host, this.port)
            s.connect()
            this._socket = Some(s)
            this._connected = true
            // 通知 onOpen
            match (this.listener) {
                case Some(l) => l.onOpen(this)
                case None => ()
            }
            return true
        } catch (e: Exception) {
            this._connected = false
            match (this.listener) {
                case Some(l) => l.onError(this, e.toString())
                case None => ()
            }
            return false
        }
    }

    /**
     * @brief[zh-cn] 发送原始字节
     * @param[zh-cn] data 待发送的字节数组
     * @return[zh-cn] 发送成功返回 true；失败返回 false
     *
     * @brief[en] Sends raw bytes
     * @param[en] data The byte array to send
     * @return[en] Returns true on success, false on failure
     */
    public func write(data: Array<UInt8>): Bool {
        match (this._socket) {
            case Some(s) =>
                try {
                    s.write(data)
                    return true
                } catch (e: Exception) {
                    this._notifyError(e.toString())
                    return false
                }
            case None =>
                this._notifyError("Socket not connected")
                return false
        }
    }

    /**
     * @brief[zh-cn] 发送文本（UTF-8 编码）
     * @param[zh-cn] s 待发送的文本
     * @return[zh-cn] 发送成功返回 true；失败返回 false
     *
     * @brief[en] Sends a text string (UTF-8 encoded)
     * @param[en] s The text to send
     * @return[en] Returns true on success, false on failure
     */
    public func writeString(s: String): Bool {
        return this.write(s.toArray())
    }

    /**
     * @brief[zh-cn] 接收数据（阻塞）
     * @param[zh-cn] buf 接收缓冲区，最多读取 buf 大小字节
     * @return[zh-cn] 返回实际读取的字节数；连接关闭或出错返回 -1
     *
     * @brief[en] Receives data (blocking)
     * @param[en] buf Receive buffer; reads at most buf.size bytes
     * @return[en] Returns the actual number of bytes read, or -1 when the connection
     * is closed or an error occurs
     *
     * @note[zh-cn] 收到数据时触发 onMessage，出错时触发 onError。
     * @note[en] Fires onMessage when data arrives and onError on failure.
     */
    public func read(buf: Array<UInt8>): Int64 {
        match (this._socket) {
            case Some(s) =>
                try {
                    let n = s.read(buf)
                    if (n > 0) {
                        let data = Array<UInt8>(n, { _ => 0u8 })
                        for (i in 0..n) {
                            data[Int64(i)] = buf[Int64(i)]
                        }
                        match (this.listener) {
                            case Some(l) => l.onMessage(this, data)
                            case None => ()
                        }
                    }
                    return n
                } catch (e: Exception) {
                    this._notifyError(e.toString())
                    return -1
                }
            case None =>
                this._notifyError("Socket not connected")
                return -1
        }
    }

    /**
     * @brief[zh-cn] 接收文本（阻塞）
     * @return[zh-cn] 返回本次 read 读取的数据解码为 UTF-8 的字符串；无数据时返回空串
     *
     * @brief[en] Receives text (blocking)
     * @return[en] Returns the data of a single read decoded as a UTF-8 string, or an
     * empty string when there is no data
     *
     * @note[zh-cn] 按单次 read 返回；如需读取一整行可在上层自行组包。
     * @note[en] Returns a single read; assemble frames yourself at the call site when
     * reading whole lines.
     */
    public func readString(): String {
        let buf = Array<UInt8>(4096, { _ => 0u8 })
        let n = this.read(buf)
        if (n <= 0) { return "" }
        let data = Array<UInt8>(n, { _ => 0u8 })
        for (i in 0..n) {
            data[Int64(i)] = buf[Int64(i)]
        }
        return String.fromUtf8(data)
    }

    /**
     * @brief[zh-cn] 关闭连接
     *
     * @brief[en] Closes the connection
     *
     * @note[zh-cn] 关闭后触发 onClose。
     * @note[en] Fires onClose after closing.
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
                this._connected = false
                match (this.listener) {
                    case Some(l) => l.onClose(this)
                    case None => ()
                }
            case None => ()
        }
    }

    // =========================================================================
    // 内部
    // =========================================================================

    /**
     * @brief[zh-cn] 通知错误
     * @param[zh-cn] message 错误消息
     *
     * @brief[en] Notify error
     * @param[en] message Error message
     */
    private func _notifyError(message: String): Unit {
        match (this.listener) {
            case Some(l) => l.onError(this, message)
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 由已接受的底层套接字构造客户端
     * @param[zh-cn] tcp 底层已接受的套接字
     * @return[zh-cn] 包装好的 SocketClient（已标记为已连接）
     *
     * @note[zh-cn] 包内使用，供 SocketServer.accept 调用。
     *
     * @brief[en] Construct a client from an accepted underlying socket
     * @param[en] tcp The underlying accepted socket
     * @return[en] Wrapped SocketClient (marked as connected)
     *
     * @note[en] For internal package use, called by SocketServer.accept.
     */
    internal static func _fromAccepted(tcp: TcpSocket): SocketClient {
        let c = SocketClient("", 0)
        c._socket = Some(tcp)
        c._connected = true
        return c
    }
}
