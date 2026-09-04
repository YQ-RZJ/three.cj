/**
 * @file[zh-cn] SocketEvent Socket 事件回调定义（three.network.socket 子包）
 * @brief[zh-cn] 定义 Socket 事件回调接口 ISocketListener
 * @explain[zh-cn] 事件回调风格：onOpen 连接建立、onMessage 收到数据、onError 发生错误、
 * onClose 连接关闭。实现该接口并赋值给 SocketClient.listener 即可接收事件。
 *
 * @file[en] SocketEvent  Socket event callback definitions (three.network.socket sub-package)
 * @brief[en] Defines the ISocketListener socket event callback interface
 * @explain[en] Event callback style: onOpen when connected, onMessage when data arrives,
 * onError on failure, onClose when closed. Implement this interface and assign it
 * to SocketClient.listener to receive events.
 */
package three.network.socket

/**
 * @brief[zh-cn] Socket 事件监听器接口
 * @explain[zh-cn] 由 SocketClient 在连接生命周期各阶段回调，覆盖连接建立、数据接收、错误与关闭。
 *
 * @brief[en] Socket event listener interface
 * @explain[en] Invoked by SocketClient at each stage of the connection lifecycle,
 * covering connection establishment, data receipt, errors and closing.
 */
public interface ISocketListener {
    /**
     * @brief[zh-cn] 连接建立回调
     * @param[zh-cn] client 触发事件的客户端
     *
     * @brief[en] Callback invoked when the connection is established
     * @param[en] client The client that fired the event
     */
    func onOpen(client: SocketClient): Unit

    /**
     * @brief[zh-cn] 收到数据回调（原始字节）
     * @param[zh-cn] client 触发事件的客户端
     * data 收到的原始字节
     *
     * @brief[en] Callback invoked when data is received (raw bytes)
     * @param[en] client The client that fired the event
     * data The raw bytes received
     */
    func onMessage(client: SocketClient, data: Array<UInt8>): Unit

    /**
     * @brief[zh-cn] 错误回调
     * @param[zh-cn] client 触发事件的客户端
     * message 错误消息
     *
     * @brief[en] Callback invoked on error
     * @param[en] client The client that fired the event
     * message The error message
     */
    func onError(client: SocketClient, message: String): Unit

    /**
     * @brief[zh-cn] 连接关闭回调
     * @param[zh-cn] client 触发事件的客户端
     *
     * @brief[en] Callback invoked when the connection is closed
     * @param[en] client The client that fired the event
     */
    func onClose(client: SocketClient): Unit
}
