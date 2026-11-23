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
 * @file[zh-cn] animation_blend_propertybinding 属性绑定 PropertyBinding 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.animation.blend.PropertyBinding 绑定为 Lua 类型
 * three.animation.blend.PropertyBinding（仅静态解析工具）
 * @explain[zh-cn] 只绑定无 HashMap 依赖的静态工具方法：
 * - sanitizeNodeName(name)：清洗节点名；
 * - parseTrackName(trackName)：解析轨道名并返回「键值对表」——因无 Lua 表 ↔ HashMap
 *   双向通道，返回值改为按固定顺序展开的 Lua 表 {nodeName=?, objectName=?,
 *   objectIndex=?, propertyName=?, propertyIndex=?}（下标 1..5，缺失项为 nil）；
 * - findNode(root, nodeName)：在层级中查找节点（返回 three.scene.objects.Object3D）。
 * 跳过：构造（parsedPath 为 HashMap）、create（同上且返回 Any）、getValue/setValue/
 * bind/unbind（实例态依赖 HashMap 解析结果与场景图类型）。
 *
 * @file[en] animation_blend_propertybinding  Lua binding of PropertyBinding (three.script.prebind)
 * @brief[en] Binds three.animation.blend.PropertyBinding as the Lua type
 * three.animation.blend.PropertyBinding (static parsing utilities only)
 * @explain[en] Binds only the static utilities that do not depend on HashMap:
 * - sanitizeNodeName(name): sanitizes a node name;
 * - parseTrackName(trackName): parses a track name and returns an ordered Lua table
 * {nodeName=?, objectName=?, objectIndex=?, propertyName=?, propertyIndex=?} (1..5, nil for
 * missing entries) because no bidirectional Lua table ↔ HashMap channel exists;
 * - findNode(root, nodeName): searches the hierarchy for a node (returns
 * three.scene.objects.Object3D).
 * Skipped: the constructor (parsedPath is a HashMap), create (same, and returns Any), and the
 * instance-side getValue/setValue/bind/unbind (they depend on HashMap parse results and the
 * scene-graph types).
 */
package three.script.prebind

import three.animation.blend.PropertyBinding
import three.core._interfaces.IPropertyBindingRoot
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 从解析结果哈希表按固定顺序取字符串项
 * @param[zh-cn] map 解析结果
 * @param[zh-cn] key 键名
 * @return[zh-cn] 对应 LuaValue（字符串或 nil）
 *
 * @brief[en] Fetches a string entry from the parse-result map in a fixed order
 * @param[en] map The parse result
 * @param[en] key The key name
 * @return[en] The corresponding LuaValue (a string or nil)
 */
private func _prebindMapStr(map: HashMap<String, Any>, key: String): LuaValue {
    if (let Some(v) <- map.get(key)) {
        match (v) {
            case s: String =>
                if (s == "") {
                    LuaValue.Nil
                } else {
                    LuaValue.Str(s)
                }
            case _ => LuaValue.Nil
        }
    } else {
        LuaValue.Nil
    }
}

/**
 * @brief[zh-cn] 从解析结果哈希表按固定顺序取 Option 项（Some(String) → 字符串）
 * @param[zh-cn] map 解析结果
 * @param[zh-cn] key 键名
 * @return[zh-cn] 对应 LuaValue（字符串或 nil）
 *
 * @brief[en] Fetches an Option entry from the parse-result map (Some(String) → string)
 * @param[en] map The parse result
 * @param[en] key The key name
 * @return[en] The corresponding LuaValue (a string or nil)
 */
private func _prebindMapOptStr(map: HashMap<String, Any>, key: String): LuaValue {
    if (let Some(v) <- map.get(key)) {
        match (v) {
            case s: Option<String> => match (s) {
                case Some(txt) => LuaValue.Str(txt)
                case None => LuaValue.Nil
            }
            case _ => LuaValue.Nil
        }
    } else {
        LuaValue.Nil
    }
}

/**
 * @brief[zh-cn] 安装 PropertyBinding 的 Lua 绑定（仅静态解析工具，不注册构造器）
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.blend.PropertyBinding）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PropertyBinding (static utilities only; no constructor)
 * @param[en] vm The target virtual machine (class table installed at three.animation.blend.PropertyBinding)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPropertyBinding(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.blend.PropertyBinding")
    // ===== 节点名清洗 =====
    b.staticMethod("sanitizeNodeName") {
        args => [LuaValue.of(PropertyBinding.sanitizeNodeName(prebindStr(args, 0)))]
    }
    // ===== 轨道名解析（返回 5 元有序表） =====
    b.staticMethod("parseTrackName") {
        args =>
            let parsed = PropertyBinding.parseTrackName(prebindStr(args, 0))
            [
                LuaValue.Array(
                    [
                        _prebindMapStr(parsed, "nodeName"),
                        _prebindMapStr(parsed, "objectName"),
                        _prebindMapOptStr(parsed, "objectIndex"),
                        _prebindMapStr(parsed, "propertyName"),
                        _prebindMapOptStr(parsed, "propertyIndex")
                    ]
                )
            ]
    }
    // ===== 节点查找 =====
    b.staticMethod("findNode") {
        args =>
            let root = prebindAs<IPropertyBindingRoot>(args, 0)
            match (PropertyBinding.findNode(root, prebindStr(args, 1))) {
                case Some(n) => [prebindRegister(n, "three.scene.objects.Object3D")]
                case None => [LuaValue.Nil]
            }
    }
    b.install(vm)
}
