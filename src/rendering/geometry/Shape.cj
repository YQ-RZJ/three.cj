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
 * @file[zh-cn] 形状
 * @brief[zh-cn] 定义带可选洞的 2D 形状平面
 * @explain[zh-cn] 
 * Shape 继承 Path，定义带可选洞的 2D 形状平面。
 * 可与 ExtrudeGeometry、ShapeGeometry 配合获取点或三角化面。
 * 对应 Three.js extras/core/Shape.js。
 *
 * @file[en] Shape
 * @brief[en] Defines a 2D shape plane with optional holes
 * @explain[en] 
 * Shape extends Path, defining a 2D shape plane with optional holes.
 * Can be used with ExtrudeGeometry and ShapeGeometry to get points or triangulated faces.
 * Corresponds to Three.js extras/core/Shape.js.
 */
package three.rendering.geometry

import three.core.math.*
import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 形状类，定义带可选洞的 2D 形状平面
 * @explain[zh-cn] 
 * 可与 ExtrudeGeometry、ShapeGeometry 配合获取点或三角化面。
 *
 * @brief[en] Shape class, defining a 2D shape plane with optional holes
 * @explain[en] 
 * Can be used with ExtrudeGeometry and ShapeGeometry to get points or triangulated faces.
 */
public class Shape <: Path {
    /**
     * @brief[zh-cn] 形状的 UUID
     *
     * @brief[en] Shape UUID
     */
    public var uuid: String

    /**
     * @brief[zh-cn] 定义形状中的洞，洞定义必须使用与外形相反的缠绕顺序
     *
     * @brief[en] Holes in the shape; hole definitions must use opposite winding order from the outer shape
     */
    public var holes: ArrayList<Path>

    /**
     * @brief[zh-cn] 构造新的空形状
     *
     * @brief[en] Constructs a new empty shape
     */
    public init() {
        super()
        this.kind = "Shape"
        this.uuid = MathUtils.generateUUID()
        this.holes = ArrayList<Path>()
    }

    /**
     * @brief[zh-cn] 从点数组构造形状
     * @param[zh-cn] points 定义形状的 2D 点数组
     *
     * @brief[en] Constructs a shape from an array of points
     * @param[en] points Array of 2D points defining the shape
     */
    public init(points: Array<Vector3>) {
        super(points)
        this.kind = "Shape"
        this.uuid = MathUtils.generateUUID()
        this.holes = ArrayList<Path>()
    }

    /**
     * @brief[zh-cn] 返回各洞轮廓的 2D 点数组
     * @param[zh-cn] divisions 结果精度
     * @return[zh-cn] 各洞的 2D 点数组的数组
     *
     * @brief[en] Returns 2D point arrays for each hole contour
     * @param[en] divisions Result precision
     * @return[en] Array of 2D point arrays for each hole
     */
    public func getPointsHoles(divisions: Int64): Array<Array<Vector3>> {
        let holesPts = ArrayList<Array<Vector3>>()
        for (i in 0..this.holes.size) {
            holesPts.add(this.holes[i].getPoints(divisions))
        }
        return holesPts.toArray()
    }

    /**
     * @brief[zh-cn] 返回形状与其洞的轮廓数据
     * @param[zh-cn] divisions 结果精度
     * @return[zh-cn] 包含 shape（外形点数组）与 holes（各洞点数组）的 HashMap
     *
     * @brief[en] Returns contour data of the shape and its holes
     * @param[en] divisions Result precision
     * @return[en] HashMap containing shape (outer contour points) and holes (hole contour points)
     */
    public func extractPoints(divisions: Int64): HashMap<String, Any> {
        let result = HashMap<String, Any>()
        result.add("shape", this.getPoints(divisions))
        result.add("holes", this.getPointsHoles(divisions))
        return result
    }

    /**
     * @brief[zh-cn] 复制源形状的设置到当前实例
     * @param[zh-cn] source 源曲线
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Copies settings from the source shape to this instance
     * @param[en] source Source curve
     * @return[en] Reference to this instance
     */
    public open override func copy(source: Curve): Curve {
        super.copy(source)
        match (source) {
            case src: Shape =>
                this.uuid = src.uuid
                this.holes = ArrayList<Path>()
                for (i in 0..src.holes.size) {
                    let hole = Path()
                    hole.copy(src.holes[i])
                    this.holes.add(hole)
                }
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 从 JSON 反序列化形状
     * @param[zh-cn] json 包含形状数据的 HashMap
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Deserializes the shape from JSON
     * @param[en] json HashMap containing shape data
     * @return[en] Reference to this instance
     */
    public override func fromJSON(json: HashMap<String, Any>): Curve {
        super.fromJSON(json)
        if (let Some(u) <- json.get("uuid")) {
            match (u) {
                case s: String => this.uuid = s
                case _ => ()
            }
        }
        this.holes = ArrayList<Path>()
        if (let Some(h) <- json.get("holes")) {
            match (h) {
                case arr: ArrayList<Any> =>
                    for (i in 0..arr.size) {
                        let hole = Path()
                        match (arr[i]) {
                            case holeJson: HashMap<String, Any> => hole.fromJSON(holeJson)
                            case _ => ()
                        }
                        this.holes.add(hole)
                    }
                case _ => ()
            }
        }
        return this
    }
}