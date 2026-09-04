/**
 * @file[zh-cn] SocketServer TCP 服务端高级封装（three.network.socket 子包）
 * @brief[zh-cn] 基于 std.net.TcpServerSocket 提供游戏开发友好的 TCP 服务端
 * @explain[zh-cn] 提供 bind 绑定端口、accept 阻塞接受客户端连接（返回 SocketClient）、
 * close 关闭服务端。
 * 用法示例：
 * let server = SocketServer(port: 8080)
 * if (server.bind()) {
 * let client = server.accept()     // 阻塞等待客户端连接
 * let data = client.readString()
 * client.writeString("echo: " + data)
 * client.close()
 * }
 * server.close()
 *
 * @file[en] SocketServer  High-level TCP server wrapper (three.network.socket sub-package)
 * @brief[en] A game-development-friendly TCP server built on std.net.TcpServerSocket
 * @explain[en] Provides bind to bind a port, accept to block for an incoming client
 * connection (returning a SocketClient) and close to shut down the server.
 * Usage:
 * let server = SocketServer(port: 8080)
 * if (server.bind()) {
 * let client = server.accept()     // block until a client connects
 * let data = client.readString()
 * client.writeString("echo: " + data)
 * client.close()
 * }
 * server.close()
 */
package three.network.socket

import std.net.*
import std.core.*

/**
 * @brief[zh-cn] TCP 服务端
 * @explain[zh-cn] 对 std.net.TcpServerSocket 的游戏开发友好封装，支持绑定端口与阻塞接受客户端连接。
 *
 * @brief[en] TCP server
 * @explain[en] A game-development-friendly wrapper around std.net.TcpServerSocket with
 * port binding and blocking client acceptance.
 */
public class SocketServer {
    /**
     * @brief[zh-cn] 绑定端口
     *
     * @brief[en] Bind port
     */
    public let port: UInt16

    /**
     * @brief[zh-cn] 底层 std.net 服务端套接字
     *
     * @brief[en] Underlying std.net server socket
     */
    private var _socket: Option<TcpServerSocket> = None

    /**
     * @brief[zh-cn] 是否已绑定
     *
     * @brief[en] Whether bound
     */
    private var _bound: Bool = false

    /**
     * @brief[zh-cn] 构造 TCP 服务端
     * @param[zh-cn] port 绑定端口
     *
     * @brief[en] Constructs a TCP server
     * @param[en] port Bind port
     */
    public init(port: UInt16) {
        this.port = port
    }

    /**
     * @brief[zh-cn] 是否已绑定
     * @return[zh-cn] 已绑定端口返回 true
     *
     * @brief[en] Whether the server is bound
     * @return[en] Returns true when a port is bound
     */
    public prop isBound: Bool {
        get() { this._bound }
    }

    /**
     * @brief[zh-cn] 绑定端口（同步）
     * @return[zh-cn] 绑定成功返回 true；失败返回 false
     *
     * @brief[en] Binds the port (synchronous)
     * @return[en] Returns true on success, false on failure
     */
    public func bind(): Bool {
        if (this._bound) { return true }
        try {
            let s = TcpServerSocket(bindAt: this.port)
            s.bind()
            this._socket = Some(s)
            this._bound = true
            return true
        } catch (e: Exception) {
            return false
        }
    }

    /**
     * @brief[zh-cn] 阻塞接受一个客户端连接
     * @return[zh-cn] 返回包装好的 SocketClient；未绑定或出错时返回 None
     *
     * @brief[en] Accepts a client connection (blocking)
     * @return[en] Returns a wrapped SocketClient, or None when not bound or on error
     */
    public func accept(): Option<SocketClient> {
        match (this._socket) {
            case Some(s) =>
                try {
                    let tcp = s.accept()
                    // 由底层套接字包装客户端
                    return Some(SocketClient._fromAccepted(tcp))
                } catch (e: Exception) {
                    return None
                }
            case None =>
                return None
        }
    }

    /**
     * @brief[zh-cn] 关闭服务端
     *
     * @brief[en] Closes the server
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
