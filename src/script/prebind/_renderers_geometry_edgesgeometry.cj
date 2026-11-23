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
 * @file[zh-cn] renderers_geometry_edgesgeometry 边线几何体的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.EdgesGeometry 绑定为 Lua 类型
 * three.renderers.geometry.EdgesGeometry
 * @explain[zh-cn] 覆盖构造：geometry（BufferGeometry 对象，必需）与 thresholdAngle
 * （Float64，默认 1.0）。geometry 缺失或类型不符时以空 BufferGeometry 兜底，构造异常
 * 在绑定内捕获，不逃逸到 Lua。继承自 BufferGeometry 的成员由 BufferGeometry 绑定提供。
 * 跳过 parameters（HashMap<String, Any> 泛型容器）。
 *
 * @file[en] renderers_geometry_edgesgeometry  Lua binding of EdgesGeometry
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.EdgesGeometry as the Lua type
 * three.renderers.geometry.EdgesGeometry
 * @explain[en] Covers the constructor: geometry (a BufferGeometry object, required) and
 * thresholdAngle (Float64, default 1.0). When geometry is missing or not an object, an
 * empty BufferGeometry is used as the fallback; construction exceptions are caught inside
 * the binding and never escape to Lua. Members inherited from BufferGeometry are provided
 * by the BufferGeometry binding. parameters (HashMap<String, Any> generic container) is
 * skipped.
 */
package three.script.prebind

import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 EdgesGeometry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.EdgesGeometry）
 *
 * @brief[en] Installs the Lua binding of EdgesGeometry
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.geometry.EdgesGeometry)
 */
public func installEdgesGeometry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.EdgesGeometry")
    // ===== 构造 =====
    b.constructor { args =>
        let threshold = prebindNum(args, 1, default: 1.0)
        try {
            if (args.size >= 1 && args[0].isObject) {
                EdgesGeometry(prebindAs<BufferGeometry>(args, 0), thresholdAngle: threshold)
            } else {
                EdgesGeometry(BufferGeometry(), thresholdAngle: threshold)
            }
        } catch (_: Exception) {
            EdgesGeometry(BufferGeometry(), thresholdAngle: threshold)
        }
    }
    _prebindRgcBufferGeometryMembers(b, vm)
    b.install(vm)
}
