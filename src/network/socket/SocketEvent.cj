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
