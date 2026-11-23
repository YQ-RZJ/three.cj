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
 * @file[zh-cn] window_ui_uidrawlist UiDrawList.cj 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiDrawList 的自定义绘制能力绑定为 Lua 类型 three.window.ui.UiDrawList
 * @explain[zh-cn] 覆盖范围：静态工厂 window()/background()/foreground()，以及线条、矩形、三角形、
 * 圆、椭圆、文本、贝塞尔曲线、路径、剪裁、水平/垂直线段、四边形、正多边形、折线/多边形、通道分割、
 * 原始顶点绘制等全部可映射的 public 方法。
 * 适配约定：
 * - 构造 UiDrawList(dl!: VoidPtr) 需要裸 ImDrawList 指针，无法在脚本侧构造，故不绑定 constructor，
 *   实例只能由静态工厂获得；工厂返回值经 prebindRegister 注册为 three.window.ui.UiDrawList；
 * - Vector2 参数用对象探测（缺失 / nil / 非对象时回落到默认值 Vector2(0,0)），Vector2 返回值经
 *   prebindRegister 注册为 three.core.math.Vector2；
 * - PtrArray<Float32> 顶点数组参数经 prebindAs<PtrArray<Float32>>(args, i) 接收；
 * - 颜色 col 使用 IM_COL32 打包值：以 UInt32(... & 0xFFFFFFFF) 回写、返回值不需要；
 * - 所有 Unit 方法与 Bool 返回值均在包装函数内 try/catch，异常不会逃逸到 Lua 调用栈之外。
 * 跳过成员及原因：
 * - init(dl!: VoidPtr)：VoidPtr 无法映射到 Lua，且脚本不应持有裸 ImDrawList 指针；
 * - addImage/addImageQuad/addImageRounded(texRef: VoidPtr)：纹理引用为裸 VoidPtr，Lua 侧无对应值；
 * - pushTexture(texRef: VoidPtr)/popTexture()：纹理栈与裸指针成对使用，单个 popTexture 无意义，
 *   一并跳过；
 * - cloneOutput(): VoidPtr：返回值是裸绘制数据指针，无法映射，且生命周期由调用方持有。
 *
 * @file[en] window_ui_uidrawlist  Lua binding of UiDrawList.cj (three.script.prebind)
 * @brief[en] Binds three.window.ui.UiDrawList's custom drawing API as the Lua type
 * three.window.ui.UiDrawList
 * @explain[en] Coverage: the static factories window()/background()/foreground(), plus every mappable
 * public method for lines, rectangles, triangles, circles, ellipses, text, Bézier curves, paths,
 * clipping, horizontal/vertical segments, quads, regular polygons, polylines/polygons, channel
 * splitting and primitive vertex drawing.
 * Conventions:
 * - UiDrawList(dl!: VoidPtr) requires a raw ImDrawList pointer and cannot be constructed from script,
 *   so no constructor is bound; instances come only from the static factories, whose results are
 *   registered as three.window.ui.UiDrawList via prebindRegister;
 * - Vector2 parameters use object probing (missing / nil / non-object falls back to Vector2(0,0));
 *   Vector2 results are registered as three.core.math.Vector2 via prebindRegister;
 * - PtrArray<Float32> vertex arrays are received through prebindAs<PtrArray<Float32>>(args, i);
 * - The col color is a packed IM_COL32 value written back with UInt32(... & 0xFFFFFFFF);
 * - Every Unit method and Bool getter is wrapped in try/catch so no exception escapes to Lua.
 * Skipped members and reasons:
 * - init(dl!: VoidPtr): VoidPtr cannot be mapped to Lua and scripts must not hold raw ImDrawList pointers;
 * - addImage/addImageQuad/addImageRounded(texRef: VoidPtr): the texture reference is a raw VoidPtr with
 *   no Lua representation;
 * - pushTexture(texRef: VoidPtr)/popTexture(): the texture stack is used in pairs with a raw pointer and a
 *   lone popTexture is meaningless, so both are skipped;
 * - cloneOutput(): VoidPtr: returns a raw draw-data pointer that cannot be mapped and whose lifetime
 *   belongs to the caller.
 */
package three.script.prebind

import imgui4cj.imgui.ImVec2
import three.core.math.*
import three.utils.memory.PtrArray
import three.window.ui.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取可选 Vector2 参数（缺失 / nil / 非对象时返回默认值）
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 参数下标
 * @param[zh-cn] default 缺省值
 * @return[zh-cn] 解析到的 Vector2
 *
 * @brief[en] Reads an optional Vector2 argument (falls back to the default when missing/nil/not an object)
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @param[en] default The default value
 * @return[en] The resolved Vector2
 */
private func _prebindUidlVec2(args: Array<LuaValue>, idx: Int64, default!: Vector2): Vector2 {
    if (args.size > idx && args[idx].isObject) {
        return prebindAs<Vector2>(args, idx)
    }
    return default
}

/**
 * @brief[zh-cn] 执行 Unit 方法并吞掉异常（异常不逃逸到 Lua）
 * @param[zh-cn] fn 待执行的绘制调用
 * @return[zh-cn] 空返回值数组
 *
 * @brief[en] Executes a Unit method, swallowing exceptions (nothing escapes to Lua)
 * @param[en] fn The drawing call to execute
 * @return[en] An empty result array
 */
private func _prebindUidlUnit(fn: () -> Unit): Array<LuaValue> {
    try {
        fn()
    } catch (_: Exception) {
        ()
    }
    return []
}

/**
 * @brief[zh-cn] 执行 Bool 方法并包装为 Lua 返回值（异常返回 false）
 * @param[zh-cn] fn 待执行的查询
 * @return[zh-cn] 单元素 Lua 返回值
 *
 * @brief[en] Executes a Bool method and wraps it as a Lua result (false on exception)
 * @param[en] fn The query to execute
 * @return[en] A single-element Lua result
 */
private func _prebindUidlBool(fn: () -> Bool): Array<LuaValue> {
    try {
        return [LuaValue.of(fn())]
    } catch (_: Exception) {
        return [LuaValue.of(false)]
    }
}

/**
 * @brief[zh-cn] 执行 Vector2 查询并注册为 three.core.math.Vector2（异常返回零向量）
 * @param[zh-cn] fn 待执行的查询
 * @return[zh-cn] 单元素 Lua 返回值
 *
 * @brief[en] Executes a Vector2 query and registers it as three.core.math.Vector2 (zero vector on exception)
 * @param[en] fn The query to execute
 * @return[en] A single-element Lua result
 */
private func _prebindUidlVec2Result(fn: () -> Vector2): Array<LuaValue> {
    try {
        return [prebindRegister(fn(), "three.core.math.Vector2")]
    } catch (_: Exception) {
        return [prebindRegister(Vector2(0.0, 0.0), "three.core.math.Vector2")]
    }
}

/**
 * @brief[zh-cn] 执行静态工厂并注册为 three.window.ui.UiDrawList（异常返回 nil）
 * @param[zh-cn] fn 工厂调用
 * @return[zh-cn] 单元素 Lua 返回值
 *
 * @brief[en] Executes a static factory and registers the result as three.window.ui.UiDrawList (nil on exception)
 * @param[en] fn The factory call
 * @return[en] A single-element Lua result
 */
private func _prebindUidlFactory(fn: () -> UiDrawList): Array<LuaValue> {
    try {
        return [prebindRegister(fn(), "three.window.ui.UiDrawList")]
    } catch (_: Exception) {
        return [LuaValue.Nil]
    }
}

/**
 * @brief[zh-cn] 安装 UiDrawList 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDrawList）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDrawList
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDrawList)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDrawList(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDrawList")
    // ===== 静态工厂 =====
    b.staticMethod("window") {_ => _prebindUidlFactory({=> UiDrawList.window()})}
    b.staticMethod("background") {_ => _prebindUidlFactory({=> UiDrawList.background()})}
    b.staticMethod("foreground") {_ => _prebindUidlFactory({=> UiDrawList.foreground()})}
    // ===== 基础绘制 =====
    b.method("addLine") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addLine(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 2) & 0xFFFFFFFF),
                    thickness: Float32(prebindNum(args, 3, default: 1.0)))
        })
    }
    b.method("addRect") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addRect(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 2) & 0xFFFFFFFF),
                    rounding: Float32(prebindNum(args, 3)), thickness: Float32(prebindNum(args, 4, default: 1.0)),
                    flags: Int32(prebindInt(args, 5)))
        })
    }
    b.method("addRectFilled") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addRectFilled(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 2) & 0xFFFFFFFF),
                    rounding: Float32(prebindNum(args, 3)), flags: Int32(prebindInt(args, 4)))
        })
    }
    b.method("addRectFilledMultiColor") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addRectFilledMultiColor(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 2) & 0xFFFFFFFF),
                    UInt32(prebindInt(args, 3) & 0xFFFFFFFF), UInt32(prebindInt(args, 4) & 0xFFFFFFFF),
                    UInt32(prebindInt(args, 5) & 0xFFFFFFFF))
        })
    }
    b.method("addTriangle") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addTriangle(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 2, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 3) & 0xFFFFFFFF),
                    thickness: Float32(prebindNum(args, 4, default: 1.0)))
        })
    }
    b.method("addTriangleFilled") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addTriangleFilled(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 2, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 3) & 0xFFFFFFFF))
        })
    }
    b.method("addCircle") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addCircle(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)), Float32(prebindNum(args, 1)),
                    UInt32(prebindInt(args, 2) & 0xFFFFFFFF), numSegments: Int32(prebindInt(args, 3)),
                    thickness: Float32(prebindNum(args, 4, default: 1.0)))
        })
    }
    b.method("addCircleFilled") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addCircleFilled(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)), Float32(prebindNum(args, 1)),
                    UInt32(prebindInt(args, 2) & 0xFFFFFFFF), numSegments: Int32(prebindInt(args, 3)))
        })
    }
    b.method("addEllipse") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addEllipse(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 2) & 0xFFFFFFFF),
                    rot: Float32(prebindNum(args, 3)), numSegments: Int32(prebindInt(args, 4)),
                    thickness: Float32(prebindNum(args, 5, default: 1.0)))
        })
    }
    b.method("addEllipseFilled") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addEllipseFilled(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 2) & 0xFFFFFFFF),
                    rot: Float32(prebindNum(args, 3)), numSegments: Int32(prebindInt(args, 4)))
        })
    }
    // ===== 文本 =====
    b.method("addText") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addText(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 1) & 0xFFFFFFFF),
                    prebindStr(args, 2))
        })
    }
    // ===== 贝塞尔 =====
    b.method("addBezierCubic") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addBezierCubic(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 2, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 3, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 4) & 0xFFFFFFFF),
                    thickness: Float32(prebindNum(args, 5, default: 1.0)), numSegments: Int32(prebindInt(args, 6)))
        })
    }
    b.method("addBezierQuadratic") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addBezierQuadratic(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 2, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 3) & 0xFFFFFFFF),
                    thickness: Float32(prebindNum(args, 4, default: 1.0)), numSegments: Int32(prebindInt(args, 5)))
        })
    }
    // ===== 路径 =====
    b.method("pathClear") {
        ref, _ => _prebindUidlUnit({=> ref.cast<UiDrawList>().pathClear()})
    }
    b.method("pathMoveTo") {
        ref, args => _prebindUidlUnit({
            => ref.cast<UiDrawList>().pathMoveTo(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)))
        })
    }
    b.method("pathLineTo") {
        ref, args => _prebindUidlUnit({
            => ref.cast<UiDrawList>().pathLineTo(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)))
        })
    }
    b.method("pathStroke") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .pathStroke(UInt32(prebindInt(args, 0) & 0xFFFFFFFF), flags: Int32(prebindInt(args, 1)),
                    thickness: Float32(prebindNum(args, 2, default: 1.0)))
        })
    }
    b.method("pathFillConvex") {
        ref, args => _prebindUidlUnit({
            => ref.cast<UiDrawList>().pathFillConvex(UInt32(prebindInt(args, 0) & 0xFFFFFFFF))
        })
    }
    b.method("pathArcTo") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .pathArcTo(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)), Float32(prebindNum(args, 1)),
                    Float32(prebindNum(args, 2)), Float32(prebindNum(args, 3)), numSegments: Int32(prebindInt(args, 4)))
        })
    }
    b.method("pathRect") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .pathRect(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)), rounding: Float32(prebindNum(args, 2)),
                    flags: Int32(prebindInt(args, 3)))
        })
    }
    // ===== 剪裁 =====
    b.method("pushClipRect") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .pushClipRect(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)), intersectWithCurrent: prebindBool(args, 2))
        })
    }
    b.method("popClipRect") {
        ref, _ => _prebindUidlUnit({=> ref.cast<UiDrawList>().popClipRect()})
    }
    // ===== 状态查询 =====
    b.method("getClipRectMin") {
        ref, _ => _prebindUidlVec2Result({=> ref.cast<UiDrawList>().getClipRectMin()})
    }
    b.method("getClipRectMax") {
        ref, _ => _prebindUidlVec2Result({=> ref.cast<UiDrawList>().getClipRectMax()})
    }
    b.method("isRectVisible") {
        ref, args => _prebindUidlBool({
            => ref
                .cast<UiDrawList>()
                .isRectVisible(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)))
        })
    }
    // ===== 水平/垂直线段 =====
    b.method("addLineH") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addLineH(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)), Float32(prebindNum(args, 2)),
                    UInt32(prebindInt(args, 3) & 0xFFFFFFFF), thickness: Float32(prebindNum(args, 4, default: 1.0)))
        })
    }
    b.method("addLineV") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addLineV(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)), Float32(prebindNum(args, 2)),
                    UInt32(prebindInt(args, 3) & 0xFFFFFFFF), thickness: Float32(prebindNum(args, 4, default: 1.0)))
        })
    }
    // ===== 四边形 =====
    b.method("addQuad") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addQuad(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 2, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 3, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 4) & 0xFFFFFFFF),
                    thickness: Float32(prebindNum(args, 5, default: 1.0)))
        })
    }
    b.method("addQuadFilled") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addQuadFilled(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 2, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 3, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 4) & 0xFFFFFFFF))
        })
    }
    // ===== 正多边形 =====
    b.method("addNgon") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addNgon(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)), Float32(prebindNum(args, 1)),
                    UInt32(prebindInt(args, 2) & 0xFFFFFFFF), Int32(prebindInt(args, 3)),
                    thickness: Float32(prebindNum(args, 4, default: 1.0)))
        })
    }
    b.method("addNgonFilled") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addNgonFilled(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)), Float32(prebindNum(args, 1)),
                    UInt32(prebindInt(args, 2) & 0xFFFFFFFF), Int32(prebindInt(args, 3)))
        })
    }
    // ===== 折线/多边形 =====
    b.method("addPolyline") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addPolyline(prebindAs<PtrArray<Float32>>(args, 0), UInt32(prebindInt(args, 1) & 0xFFFFFFFF),
                    thickness: Float32(prebindNum(args, 2, default: 1.0)), flags: Int32(prebindInt(args, 3)))
        })
    }
    b.method("addConvexPolyFilled") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addConvexPolyFilled(prebindAs<PtrArray<Float32>>(args, 0), UInt32(prebindInt(args, 1) & 0xFFFFFFFF))
        })
    }
    b.method("addConcavePolyFilled") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .addConcavePolyFilled(prebindAs<PtrArray<Float32>>(args, 0), UInt32(prebindInt(args, 1) & 0xFFFFFFFF))
        })
    }
    // ===== 路径扩展 =====
    b.method("pathLineToMergeDuplicate") {
        ref, args => _prebindUidlUnit({
            => ref.cast<UiDrawList>().pathLineToMergeDuplicate(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)))
        })
    }
    b.method("pathFillConcave") {
        ref, args => _prebindUidlUnit({
            => ref.cast<UiDrawList>().pathFillConcave(UInt32(prebindInt(args, 0) & 0xFFFFFFFF))
        })
    }
    b.method("pathEllipticalArcTo") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .pathEllipticalArcTo(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)), Float32(prebindNum(args, 2)),
                    Float32(prebindNum(args, 3)), Float32(prebindNum(args, 4)), numSegments: Int32(prebindInt(args, 5)))
        })
    }
    b.method("pathBezierCubicCurveTo") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .pathBezierCubicCurveTo(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 2, default: Vector2(0.0, 0.0)), numSegments: Int32(prebindInt(args, 3)))
        })
    }
    b.method("pathBezierQuadraticCurveTo") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .pathBezierQuadraticCurveTo(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)), numSegments: Int32(prebindInt(args, 2)))
        })
    }
    b.method("pathArcToFast") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .pathArcToFast(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)), Float32(prebindNum(args, 1)),
                    Int32(prebindInt(args, 2)), Int32(prebindInt(args, 3)))
        })
    }
    // ===== 通道分割 =====
    b.method("channelsSplit") {
        ref, args => _prebindUidlUnit({
            => ref.cast<UiDrawList>().channelsSplit(Int32(prebindInt(args, 0)))
        })
    }
    b.method("channelsMerge") {
        ref, _ => _prebindUidlUnit({=> ref.cast<UiDrawList>().channelsMerge()})
    }
    b.method("channelsSetCurrent") {
        ref, args => _prebindUidlUnit({
            => ref.cast<UiDrawList>().channelsSetCurrent(Int32(prebindInt(args, 0)))
        })
    }
    // ===== 原始顶点操作 =====
    b.method("primReserve") {
        ref, args => _prebindUidlUnit({
            => ref.cast<UiDrawList>().primReserve(Int32(prebindInt(args, 0)), Int32(prebindInt(args, 1)))
        })
    }
    b.method("primUnreserve") {
        ref, args => _prebindUidlUnit({
            => ref.cast<UiDrawList>().primUnreserve(Int32(prebindInt(args, 0)), Int32(prebindInt(args, 1)))
        })
    }
    b.method("primRect") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .primRect(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 2) & 0xFFFFFFFF))
        })
    }
    b.method("primRectUV") {
        ref, args => _prebindUidlUnit({
            => ref
                .cast<UiDrawList>()
                .primRectUV(_prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 2, default: Vector2(0.0, 0.0)),
                    _prebindUidlVec2(args, 3, default: Vector2(0.0, 0.0)), UInt32(prebindInt(args, 4) & 0xFFFFFFFF))
        })
    }
    // primQuadUV 的 uvA~uvD 在仓颉侧是 ImVec2，脚本侧统一以 Vector2 传入后转 ImVec2
    b.method("primQuadUV") {
        ref, args => _prebindUidlUnit(
            {
                =>
                    let a = _prebindUidlVec2(args, 0, default: Vector2(0.0, 0.0))
                    let b2 = _prebindUidlVec2(args, 1, default: Vector2(0.0, 0.0))
                    let c = _prebindUidlVec2(args, 2, default: Vector2(0.0, 0.0))
                    let d = _prebindUidlVec2(args, 3, default: Vector2(0.0, 0.0))
                    let uvA = _prebindUidlVec2(args, 4, default: Vector2(0.0, 0.0))
                    let uvB = _prebindUidlVec2(args, 5, default: Vector2(0.0, 0.0))
                    let uvC = _prebindUidlVec2(args, 6, default: Vector2(0.0, 0.0))
                    let uvD = _prebindUidlVec2(args, 7, default: Vector2(0.0, 0.0))
                    ref
                        .cast<UiDrawList>()
                        .primQuadUV(a, b2, c, d, ImVec2(Float32(uvA.x), Float32(uvA.y)),
                            ImVec2(Float32(uvB.x), Float32(uvB.y)), ImVec2(Float32(uvC.x), Float32(uvC.y)),
                            ImVec2(Float32(uvD.x), Float32(uvD.y)), UInt32(prebindInt(args, 8) & 0xFFFFFFFF))
            }
        )
    }
    b.install(vm)
}
