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
 * @file[zh-cn] 弧曲线
 * @brief[zh-cn] 继承 EllipseCurve 的圆弧曲线，xRadius/yRadius 相同
 * @explain[zh-cn] 
 * ArcCurve 将 EllipseCurve 的 xRadius 与 yRadius 设为相同的 aRadius，得到圆弧。
 * 对应 Three.js extras/curves/ArcCurve.js。
 *
 * @file[en] Arc Curve
 * @brief[en] Arc curve extending EllipseCurve with equal xRadius and yRadius
 * @explain[en] 
 * ArcCurve sets EllipseCurve's xRadius and yRadius to the same aRadius value, producing a circular arc.
 * Corresponds to Three.js extras/curves/ArcCurve.js.
 */
package three.rendering.geometry
import std.collection.*

import three.core.math.*

/**
 * @brief[zh-cn] 弧曲线类，继承自 EllipseCurve
 * @explain[zh-cn] 
 * ArcCurve 将 EllipseCurve 的 xRadius 与 yRadius 设为相同的 aRadius，得到圆弧。
 *
 * @brief[en] Arc curve class, extending EllipseCurve
 * @explain[en] 
 * ArcCurve sets EllipseCurve's xRadius and yRadius to the same aRadius value, producing a circular arc.
 */
public class ArcCurve <: EllipseCurve {
    /**
     * @brief[zh-cn] 构造新的弧曲线
     * @param[zh-cn] aX 椭圆中心 X 坐标，默认为 0
     * aY 椭圆中心 Y 坐标，默认为 0
     * aRadius 半径，默认为 1
     * aStartAngle 起始角，默认为 0
     * aEndAngle 终止角，默认为 Math.PI*2
     * aClockwise 是否顺时针，默认为 false
     *
     * @brief[en] Constructs a new arc curve
     * @param[en] aX X coordinate of the ellipse center, default 0
     * aY Y coordinate of the ellipse center, default 0
     * aRadius Radius, default 1
     * aStartAngle Start angle, default 0
     * aEndAngle End angle, default Math.PI*2
     * aClockwise Whether clockwise, default false
     */
    public init(aX!: Float64 = 0.0, aY!: Float64 = 0.0, aRadius!: Float64 = 1.0, aStartAngle!: Float64 = 0.0, aEndAngle!: Float64 = 2.0 * PI, aClockwise!: Bool = false) {
        super(aX: aX, aY: aY, xRadius: aRadius, yRadius: aRadius, aStartAngle: aStartAngle, aEndAngle: aEndAngle, aClockwise: aClockwise, aRotation: 0.0)
        this.kind = "ArcCurve"
    }

    /**
     * @brief[zh-cn] 兼容重载：6 参数形式
     *
     * @brief[en] Compatibility overload: 6-parameter form
     */
}
