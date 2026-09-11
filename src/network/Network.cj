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
 * @file[zh-cn] Network 网络模块父包，仅用于声明 three.network 包，便于 cjpm 识别 http/socket 子包
 * @brief[zh-cn] 网络模块父包，用于组织 HTTP 与 Socket 子包
 * @explain[zh-cn] 对照 Engine/Network 目录规划（doc/dir.md）：
 * Network/
 * ├── Socket/             # 网络通信
 * ├── Protocol/           # 协议层
 * └── Replication/        # 状态同步
 * 仓颉侧拆分为子包：
 * three.network.http   — HTTP 客户端高级封装（基于 httpclient4cj：GET/POST/头部/超时/回调）
 * three.network.socket — Socket/TCP 客户端高级封装（基于 stdx.net：连接/收发/事件回调）
 * 底层依赖：
 * - httpclient4cj（gitcode.com/raozj/httpclient4cj，OkHttp 风格完整 HTTP 客户端）
 * - stdx.net / stdx.net.http / stdx.net.tls（仓颉扩展标准库网络模块）
 *
 * @file[en] Network  Network module parent package, used only to declare the three.network
 * package so that cjpm can recognize the http/socket sub-packages
 * @brief[en] Parent package of the network module, organizing the HTTP and Socket sub-packages
 * @explain[en] Per the Engine/Network directory plan (doc/dir.md), the module is split
 * into sub-packages on the Cangjie side:
 * three.network.http   — high-level HTTP client wrapper (built on httpclient4cj:
 * GET/POST/headers/timeouts/callbacks)
 * three.network.socket — high-level Socket/TCP client wrapper (built on stdx.net:
 * connect/send/receive/event callbacks)
 * Underlying dependencies:
 * - httpclient4cj (OkHttp-style full HTTP client)
 * - stdx.net / stdx.net.http / stdx.net.tls (Cangjie extended standard library network module)
 *
 * @intro[zh-cn] three.network 提供基于 httpclient4cj 与 stdx.net 的 HTTP 与 Socket 高级网络封装。
 * @intro[en] three.network provides high-level HTTP and Socket network wrappers built on
 * httpclient4cj and stdx.net.
 */
package three.network
