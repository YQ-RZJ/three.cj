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
 * @file[zh-cn] 材质替换器栈
 * @brief[zh-cn] per-mesh临时材质替换器栈，用完自动还原
 * @explain[zh-cn] 
 * 对照 Three.js SSRPass._renderMetalness 的范式。Three.js 没有"机制化"的材质替换器，
 * 只在 SSRPass 内联临时替换 mesh.material 字段。Three.cj 将此范式工具化：
 * 栈式嵌套安全，多个 override scope 可层叠，restore 时按入栈逆序还原。
 * 本类只依赖 std.collection（零 three 依赖，绝对无环），
 * mesh.material 的读写通过调用方注入的 getter/setter 闭包完成。
 *
 * @file[en] Material Override Scope
 * @brief[en] Per-mesh temporary material override stack with automatic restore
 * @explain[en] 
 * Corresponds to the pattern in Three.js SSRPass._renderMetalness. Three.js has no "mechanized" material override,
 * only inlining temporary mesh.material replacement in SSRPass. Three.cj toolifies this pattern:
 * Stack nesting is safe, multiple override scopes can stack, and restore reverses in LIFO order.
 * This class only depends on std.collection (zero three dependencies, absolutely no cycles),
 * mesh.material read/write is done through getter/setter closures injected by the caller.
 */
package three.rendering.materials

import std.collection.*
import three.core.interfaces.IMaterial
import three.scene.interfaces.IMesh

/**
 * @brief[zh-cn] per-mesh材质替换器栈（回调注入式）
 * @explain[zh-cn] 
 * 每次 pushOverride 调用 getter() 备份当前材质，并记录 setter 回调；
 * restoreAll 按入栈逆序调用各 setter 还原材质。
 * 栈式嵌套安全：上层 scope 还原不会破坏下层 scope 的替换（各 scope 独立栈）。
 * 回调注入：getter/setter 由调用方构造，本类仅依赖 interfaces 包（零 three 依赖），规避 objects↔materials 循环依赖。
 *
 * @brief[en] Per-mesh material override stack (callback injection style)
 * @explain[en] 
 * Each pushOverride call uses getter() to backup the current material and records the setter callback;
 * restoreAll calls setters in reverse order to restore materials.
 * Stack nesting is safe: upper scope restore does not break lower scope replacement (each scope has an independent stack).
 * Callback injection: getter/setter are constructed by the caller, this class only depends on the interfaces package (zero three dependencies), avoiding objects↔materials circular dependency.
 */
public class MaterialOverrideScope {
    /**
     * @brief[zh-cn] 栈帧：备份的原材质列表
     *
     * @brief[en] Stack frame: backup original material list
     */
    private let backups: ArrayList<IMaterial>

    /**
     * @brief[zh-cn] 栈帧：还原回调列表
     *
     * @brief[en] Stack frame: restore callback list
     */
    private let setters: ArrayList<(IMaterial) -> Unit>

    /**
     * @brief[zh-cn] 构造一个新的材质替换器栈
     *
     * @brief[en] Construct a new material override scope
     */
    public init() {
        this.backups = ArrayList<IMaterial>()
        this.setters = ArrayList<(IMaterial) -> Unit>()
    }

    /**
     * @brief[zh-cn] 压入一条材质替换，先备份当前材质并记录setter回调
     * @param[zh-cn] mesh 被替换材质的对象句柄
     * getter 获取当前材质的回调
     * setter 还原材质的回调
     *
     * @brief[en] Push a material override, backup current material and record setter callback
     * @param[en] mesh Object handle whose material is being replaced
     * getter Callback to get the current material
     * setter Callback to restore the material
     */
    public func pushOverride(mesh: IMesh, getter: () -> IMaterial, setter: (IMaterial) -> Unit): Unit {
        this.backups.add(getter())
        this.setters.add(setter)
    }

    /**
     * @brief[zh-cn] 还原所有压入的材质替换（按入栈逆序），还原后清空栈帧
     *
     * @brief[en] Restore all pushed material overrides (in reverse push order), and clear stack frames after restore
     */
    public func restoreAll(): Unit {
        // 逆序还原：后压的先还原，避免中间态引用已被还原的原材质
        let n = this.setters.size
        for (i in 0..n) {
            let idx = n - 1 - i
            let backup = this.backups[idx]
            let setter = this.setters[idx]
            setter(backup)
        }
        this.backups.clear()
        this.setters.clear()
    }
}
