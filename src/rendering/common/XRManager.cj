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
 * @file[zh-cn] XR 管理器
 * @brief[zh-cn] XR 管理器类，管理 WebXR 会话状态
 * @explain[zh-cn] XRManager 管理 XR（扩展现实）会话的启用状态、会话设置与查询，提供基本的 XR 呈现检测功能。对照源码: three.js/src/renderers/common/XRManager.js
 *
 * @file[en] XR Manager
 * @brief[en] XR Manager class, managing WebXR session state
 * @explain[en] XRManager manages the enabled state, session setting and querying for XR (Extended Reality) sessions, providing basic XR presentation detection. Reference: three.js/src/renderers/common/XRManager.js
 */
package three.rendering.common

/**
 * @brief[zh-cn] XR 管理器类
 * @explain[zh-cn] 管理 WebXR 会话的启用状态、会话设置与查询，提供 isPresenting 检测 XR 是否正在呈现。
 *
 * @brief[en] XR Manager class
 * @explain[en] Manages the enabled state, session setting and querying for WebXR sessions, providing isPresenting to detect whether XR is currently presenting.
 */
public open class XRManager {

    /**
     * @brief[zh-cn] 是否启用 XR
     *
     * @brief[en] Whether XR is enabled
     */
    public var enabled: Bool

    /**
     * @brief[zh-cn] 构造器，默认 XR 未启用
     *
     * @brief[en] Constructor, XR disabled by default
     */
    public init() { this.enabled = false }

    /**
     * @brief[zh-cn] 判断 XR 是否正在呈现
     * @return[zh-cn] 是否正在呈现
     *
     * @brief[en] Check whether XR is currently presenting
     * @return[en] Whether currently presenting
     */
    public func isPresenting(): Bool { return false }

    /**
     * @brief[zh-cn] 设置 XR 会话
     * @param[zh-cn] session 会话标识
     *
     * @brief[en] Set XR session
     * @param[en] session Session identifier
     */
    public func setSession(session: String): Unit { }

    /**
     * @brief[zh-cn] 获取当前 XR 会话
     * @return[zh-cn] 会话标识
     *
     * @brief[en] Get current XR session
     * @return[en] Session identifier
     */
    public func getSession(): String { return "" }
}
