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
 * @file[zh-cn] ISocketListener Socket 事件回调接口（自 three.network.socket 迁入本接口包）
 * @brief[zh-cn] Socket 连接生命周期回调契约；回调参数抽象为 ISocketClient 标记接口，避免反向依赖 socket 实现包
 * @explain[zh-cn] 按 C9 约定收纳于 network/interfaces（protected 包），经实现包重导出为
 * three.network.socket.ISocketListener。原签名中的 SocketClient 参数改为 ISocketClient
 * 标记接口（SocketClient 实现之），消除 interfaces → socket 的包循环。
 *
 * @file[en] ISocketListener  Socket event callback interface (moved from three.network.socket into this interface package)
 * @brief[en] The connection-lifecycle callback contract; the callback parameter is abstracted as the ISocketClient marker interface to avoid a reverse dependency on the socket implementation package
 * @explain[en] Collected into network/interfaces per C9 (protected package), re-exported by the implementation package as three.network.socket.ISocketListener. The original SocketClient parameter becomes the ISocketClient marker interface (implemented by SocketClient), removing the interfaces → socket package cycle.
 */
protected package three.network._interfaces

/**
 * @brief[zh-cn] Socket 客户端标记接口
 * @explain[zh-cn] 解耦 ISocketListener 与具体 SocketClient 类型的抽象：由 SocketClient 实现。
 * 回调实现方如需访问客户端细节，可将该参数向下转型为具体类型。
 *
 * @brief[en] Socket client marker interface
 * @explain[en] Abstraction decoupling ISocketListener from the concrete SocketClient type:
 * implemented by SocketClient. Callback implementations needing client details can
 * downcast the parameter to the concrete type.
 */
public interface ISocketClient {}

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
    func onOpen(client: ISocketClient): Unit

    /**
     * @brief[zh-cn] 收到数据回调（原始字节）
     * @param[zh-cn] client 触发事件的客户端
     * data 收到的原始字节
     *
     * @brief[en] Callback invoked when data is received (raw bytes)
     * @param[en] client The client that fired the event
     * data The raw bytes received
     */
    func onMessage(client: ISocketClient, data: Array<UInt8>): Unit

    /**
     * @brief[zh-cn] 错误回调
     * @param[zh-cn] client 触发事件的客户端
     * message 错误消息
     *
     * @brief[en] Callback invoked on error
     * @param[en] client The client that fired the event
     * message The error message
     */
    func onError(client: ISocketClient, message: String): Unit

    /**
     * @brief[zh-cn] 连接关闭回调
     * @param[zh-cn] client 触发事件的客户端
     *
     * @brief[en] Callback invoked when the connection is closed
     * @param[en] client The client that fired the event
     */
    func onClose(client: ISocketClient): Unit
}
