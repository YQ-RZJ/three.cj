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
 * @brief[zh-cn] 重导出 Socket 事件回调接口 ISocketListener（声明位于 three.network._interfaces）
 * @explain[zh-cn] 事件回调风格：onOpen 连接建立、onMessage 收到数据、onError 发生错误、
 * onClose 连接关闭。实现该接口并赋值给 SocketClient.listener 即可接收事件。
 *
 * @file[en] SocketEvent  Socket event callback definitions (three.network.socket sub-package)
 * @brief[en] Re-exports the ISocketListener socket event callback interface (declared in three.network._interfaces)
 * @explain[en] Event callback style: onOpen when connected, onMessage when data arrives,
 * onError on failure, onClose when closed. Implement this interface and assign it
 * to SocketClient.listener to receive events.
 */
package three.network.socket

public import three.network._interfaces.ISocketClient
public import three.network._interfaces.ISocketListener
