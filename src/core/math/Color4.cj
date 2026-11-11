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
 * @file[zh-cn] Color4
 * @brief[zh-cn] 带透明度分量的颜色（RGBA）
 * @explain[zh-cn] 继承 Color（RGB）并扩展 alpha 分量，分量范围均为 [0, 1]。
 *         Color 仅表示 RGB（无 alpha 字段，其 4 参构造的 a 为便利占位且被忽略）；
 *         需要 RGBA 的模块（如 three.window.ui 的 ImGui 颜色桥接、粒子透明度等）
 *         应使用本类型，避免对外暴露 Im* 等底层类型。
 *
 * @file[en] Color4
 * @brief[en] Color with alpha component (RGBA)
 * @explain[en] Extends Color (RGB) with an alpha component; all components are in [0, 1].
 *         Color only represents RGB (no alpha field; its 4-parameter constructor takes
 *         a as a convenience placeholder which is ignored). Modules needing RGBA
 *         (e.g. three.window.ui ImGui color bridging, particle transparency) should
 *         use this type instead of exposing low-level Im* types.
 */
package three.core.math

/**
 * @brief[zh-cn] 带透明度分量的颜色类（RGBA，分量范围 [0, 1]）
 * @explain[zh-cn] 继承 Color 的 r/g/b 分量与颜色空间语义，扩展 a（alpha）分量。
 *         hex 构造沿用 Color 的 SRGB→线性工作颜色空间转换；alpha 不参与颜色空间转换。
 *
 * @brief[en] Color class with alpha (RGBA, components in [0, 1])
 * @explain[en] Inherits Color's r/g/b components and color-space semantics, extends with
 *         an a (alpha) component. The hex constructor follows Color's SRGB → linear
 *         working color space conversion; alpha does not participate in color-space conversion.
 */
public class Color4 <: Color {
    /**
     * @brief[zh-cn] 透明度分量（[0, 1]；0=全透明，1=不透明）
     *
     * @brief[en] Alpha component ([0, 1]; 0 = fully transparent, 1 = opaque)
     */
    public var a: Float64

    /**
     * @brief[zh-cn] 构造白色不透明颜色
     *
     * @brief[en] Constructs an opaque white color
     */
    public init() {
        super()
        this.a = 1.0
    }

    /**
     * @brief[zh-cn] 从 RGBA 分量构造
     * @param[zh-cn] r 红色分量
     * g 绿色分量
     * b 蓝色分量
     * a 透明度分量（默认 1.0）
     *
     * @brief[en] Constructs from RGBA components
     * @param[en] r Red component
     * g Green component
     * b Blue component
     * a Alpha component (default 1.0)
     */
    public init(r: Float64, g: Float64, b: Float64, a!: Float64 = 1.0) {
        super(r, g, b)
        this.a = a
    }

    /**
     * @brief[zh-cn] 从十六进制值构造（0xRRGGBB，SRGB 输入自动转到工作颜色空间）
     * @param[zh-cn] hex 颜色十六进制值
     * a 透明度分量（默认 1.0）
     *
     * @brief[en] Constructs from a hex value (0xRRGGBB; SRGB input auto-converted to the working color space)
     * @param[en] hex Color hex value
     * a Alpha component (default 1.0)
     */
    public init(hex: UInt32, a!: Float64 = 1.0) {
        super(hex)
        this.a = a
    }

    /**
     * @brief[zh-cn] 从已有 Color 拷贝 RGB 并指定透明度
     * @param[zh-cn] color 源颜色（提供 r/g/b）
     * a 透明度分量（默认 1.0）
     *
     * @brief[en] Copies RGB from an existing Color with a given alpha
     * @param[en] color Source color (provides r/g/b)
     * a Alpha component (default 1.0)
     */
    public init(color: Color, a!: Float64 = 1.0) {
        super(color.r, color.g, color.b)
        this.a = a
    }

    /**
     * @brief[zh-cn] 设置透明度分量
     * @param[zh-cn] a 透明度分量（[0, 1]）
     * @return[zh-cn] 当前实例（链式调用）
     *
     * @brief[en] Sets the alpha component
     * @param[en] a Alpha component ([0, 1])
     * @return[en] This instance (for chaining)
     */
    public func setAlpha(a: Float64): Color4 {
        this.a = a
        return this
    }

    /**
     * @brief[zh-cn] 克隆（保留 alpha 分量）
     * @return[zh-cn] 新的 Color4 实例
     * @note[zh-cn] 基类 clone() 返回 Color（丢失 alpha），需要保留 alpha 时请用本方法。
     *
     * @brief[en] Clones (preserving the alpha component)
     * @return[en] A new Color4 instance
     * @note[en] The base clone() returns a Color (dropping alpha); use this method to keep it.
     */
    public func clone4(): Color4 {
        return Color4(this.r, this.g, this.b, a: this.a)
    }

    /**
     * @brief[zh-cn] 从另一个 Color4 拷贝 RGBA
     * @param[zh-cn] c 源颜色
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copies RGBA from another Color4
     * @param[en] c Source color
     * @return[en] This instance
     */
    public func copy4(c: Color4): Color4 {
        this.r = c.r
        this.g = c.g
        this.b = c.b
        this.a = c.a
        return this
    }
}
