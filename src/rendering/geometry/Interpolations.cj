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
 * @file[zh-cn] 插值函数
 * @brief[zh-cn] 包含样条和贝塞尔插值函数，由具体曲线类内部使用
 * @explain[zh-cn] 
 * 对应 Three.js extras/core/Interpolations.js，提供 CatmullRom、QuadraticBezier、CubicBezier 插值函数。
 *
 * @file[en] Interpolation Functions
 * @brief[en] Contains spline and Bezier interpolation functions used internally by curve classes
 * @explain[en] 
 * Corresponds to Three.js extras/core/Interpolations.js, providing CatmullRom, QuadraticBezier, CubicBezier interpolation functions.
 */
package three.rendering.geometry

/**
 * @param[zh-cn] t 插值因子
 * @param[zh-cn] p0 第一个控制点
 * @param[zh-cn] p1 第二个控制点
 * @param[zh-cn] p2 第三个控制点
 * @param[zh-cn] p3 第四个控制点
 * @return[zh-cn] Catmull-Rom 样条上的计算点
 *
 * 计算 Catmull-Rom 样条上的一个点
 *
 * @param[en] t Interpolation factor
 * @param[en] p0 First control point
 * @param[en] p1 Second control point
 * @param[en] p2 Third control point
 * @param[en] p3 Fourth control point
 * @return[en] Computed point on the Catmull-Rom spline
 *
 * Compute a point on the Catmull-Rom spline
 */
public func CatmullRom(t: Float64, p0: Float64, p1: Float64, p2: Float64, p3: Float64): Float64 {
    let v0 = (p2 - p0) * 0.5
    let v1 = (p3 - p1) * 0.5
    let t2 = t * t
    let t3 = t * t2
    return (2.0 * p1 - 2.0 * p2 + v0 + v1) * t3 + (-3.0 * p1 + 3.0 * p2 - 2.0 * v0 - v1) * t2 + v0 * t + p1
}

internal func QuadraticBezierP0(t: Float64, p: Float64): Float64 { let k = 1.0 - t; return k * k * p }
internal func QuadraticBezierP1(t: Float64, p: Float64): Float64 { return 2.0 * (1.0 - t) * t * p }
internal func QuadraticBezierP2(t: Float64, p: Float64): Float64 { return t * t * p }

/**
 * @param[zh-cn] t 插值因子
 * @param[zh-cn] p0 第一个控制点
 * @param[zh-cn] p1 第二个控制点
 * @param[zh-cn] p2 第三个控制点
 * @return[zh-cn] 二次贝塞尔曲线上的计算点
 *
 * 计算二次贝塞尔曲线上的一个点
 *
 * @param[en] t Interpolation factor
 * @param[en] p0 First control point
 * @param[en] p1 Second control point
 * @param[en] p2 Third control point
 * @return[en] Computed point on the quadratic Bezier curve
 *
 * Compute a point on the quadratic Bezier curve
 */
public func QuadraticBezier(t: Float64, p0: Float64, p1: Float64, p2: Float64): Float64 {
    return QuadraticBezierP0(t, p0) + QuadraticBezierP1(t, p1) + QuadraticBezierP2(t, p2)
}

internal func CubicBezierP0(t: Float64, p: Float64): Float64 { let k = 1.0 - t; return k * k * k * p }
internal func CubicBezierP1(t: Float64, p: Float64): Float64 { let k = 1.0 - t; return 3.0 * k * k * t * p }
internal func CubicBezierP2(t: Float64, p: Float64): Float64 { return 3.0 * (1.0 - t) * t * t * p }
internal func CubicBezierP3(t: Float64, p: Float64): Float64 { return t * t * t * p }

/**
 * @param[zh-cn] t 插值因子
 * @param[zh-cn] p0 第一个控制点
 * @param[zh-cn] p1 第二个控制点
 * @param[zh-cn] p2 第三个控制点
 * @param[zh-cn] p3 第四个控制点
 * @return[zh-cn] 三次贝塞尔曲线上的计算点
 *
 * 计算三次贝塞尔曲线上的一个点
 *
 * @param[en] t Interpolation factor
 * @param[en] p0 First control point
 * @param[en] p1 Second control point
 * @param[en] p2 Third control point
 * @param[en] p3 Fourth control point
 * @return[en] Computed point on the cubic Bezier curve
 *
 * Compute a point on the cubic Bezier curve
 */
public func CubicBezier(t: Float64, p0: Float64, p1: Float64, p2: Float64, p3: Float64): Float64 {
    return CubicBezierP0(t, p0) + CubicBezierP1(t, p1) + CubicBezierP2(t, p2) + CubicBezierP3(t, p3)
}