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
 * @file[zh-cn] 3D 直线段曲线
 * @brief[zh-cn] 起止两点构成的 3D 直线段
 * @explain[zh-cn] 
 * LineCurve3 继承 Curve，由两个端点 v1、v2 定义 3D 直线段。
 * 对应 Three.js extras/curves/LineCurve3.js。
 *
 * @file[en] 3D Line Curve
 * @brief[en] 3D line segment defined by start and end points
 * @explain[en] 
 * LineCurve3 extends Curve, defining a 3D line segment by two endpoints v1 and v2.
 * Corresponds to Three.js extras/curves/LineCurve3.js.
 */
package three.rendering.geometry
import std.collection.*

import three.core.math.*

/**
 * @brief[zh-cn] 3D 直线段曲线类
 * @explain[zh-cn] 
 * 3D 直线段曲线，由两个端点定义。
 *
 * @brief[en] 3D line curve class
 * @explain[en] 
 * 3D line curve defined by two endpoints.
 */
public class LineCurve3 <: Curve {
    /**
     * 起始点
     */
    public var v1: Vector3

    /**
     * 末点
     */
    public var v2: Vector3

    /**
     * @param[zh-cn] v1 起始点，默认为空向量
     * @param[zh-cn] v2 终止点，默认为空向量
     *
     * 构造新的 3D 直线段
     *
     * @param[en] v1 Start point, default zero vector
     * @param[en] v2 End point, default zero vector
     *
     * Construct a new 3D line segment
     */
    public init(v1!: Vector3 = Vector3(), v2!: Vector3 = Vector3()) {
        super()
        this.kind = "LineCurve3"
        this.v1 = v1
        this.v2 = v2
    }


    /**
     * @param[zh-cn] t 插值因子，0 到 1 之间
     * @return[zh-cn] 直线上的点
     *
     * 返回直线上给定插值因子 t 处的点
     *
     * @param[en] t Interpolation factor, between 0 and 1
     * @return[en] Point on the line
     *
     * Return the point on the line at the given interpolation factor t
     */
    public override func getPoint(t: Float64): Vector3 {
        if (t == 1.0) {
            return this.v2.clone()
        }
        let point = this.v2.clone()
        point.sub(this.v1)
        point.multiplyScalar(t)
        point.add(this.v1)
        return point
    }

    /**
     * 直线是线性的，可直接重写 getPointAt
     */
    public override func getPointAt(u: Float64): Vector3 {
        return this.getPoint(u)
    }

    /**
     * 返回直线方向上的归一化切线
     */
    public override func getTangent(t: Float64): Vector3 {
        let tangent = this.v2.clone()
        tangent.sub(this.v1)
        tangent.normalize()
        return tangent
    }

    /**
     * @param[zh-cn] u 0 到 1 之间的均匀弧长参数
     * @return[zh-cn] 归一化切线
     *
     * 直线切线与 u 无关，可直接重写 getTangentAt
     *
     * @param[en] u Uniform arc length parameter between 0 and 1
     * @return[en] Normalized tangent
     *
     * Line tangent is independent of u, so getTangentAt can be directly overridden
     */
    public override func getTangentAt(u: Float64): Vector3 {
        return this.getTangent(u)
    }

    /**
     * @param[zh-cn] source 要复制的源曲线
     * @return[zh-cn] 当前实例的引用
     *
     * 将给定 3D 直线段的设置复制到此实例
     *
     * @param[en] source Source curve to copy from
     * @return[en] Reference to the current instance
     *
     * Copy the settings of the given 3D line segment to this instance
     */
    public override func copy(source: Curve): Curve {
        super.copy(source)
        match (source) {
            case src: LineCurve3 =>
                this.v1.copy(src.v1)
                this.v2.copy(src.v2)
            case _ => ()
        }
        return this
    }

    /**
     * @return[zh-cn] 包含 v1、v2 数组的 HashMap
     *
     * 将 3D 直线段序列化为 JSON
     *
     * @return[en] HashMap containing v1 and v2 arrays
     *
     * Serialize the 3D line segment to JSON
     */
    /**
     * @param[zh-cn] json 包含 v1、v2 数组的 HashMap
     * @return[zh-cn] 当前实例的引用
     *
     * 从 JSON 反序列化 3D 直线段
     *
     * @param[en] json HashMap containing v1 and v2 arrays
     * @return[en] Reference to the current instance
     *
     * Deserialize the 3D line segment from JSON
     */
    public override func fromJSON(json: HashMap<String, Any>): Curve {
        super.fromJSON(json)
        if (let Some(v1) <- json.get("v1")) {
            match (v1) { case arr: ArrayList<Any> => this.v1 = fromArrayToVector3(arr); case _ => () }
        }
        if (let Some(v2) <- json.get("v2")) {
            match (v2) { case arr: ArrayList<Any> => this.v2 = fromArrayToVector3(arr); case _ => () }
        }
        return this
    }

    private static func fromArrayToVector3(arr: ArrayList<Any>): Vector3 {
        let v = Vector3()
        var i = 0
        for (x in arr) {
            match (x) { case d: Float64 => match (i) { case 0 => v.x = d; case 1 => v.y = d; case 2 => v.z = d; case _ => () }; i += 1; case _ => () }
        }
        return v
    }
}
