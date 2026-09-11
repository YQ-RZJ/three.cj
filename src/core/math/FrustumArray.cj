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
 * @file[zh-cn] FrustumArray
 * @brief[zh-cn] 视锥体数组
 * @explain[zh-cn] 表示多个视锥体的集合，用于多层渲染。通过 IArrayCameraSource 接口从 ArrayCamera 获取子相机矩阵数据，避免 math 与 cameras 包的循环依赖。
 *
 * @file[en] FrustumArray
 * @brief[en] Frustum array
 * @explain[en] Represents a collection of multiple frustums for multi-layer rendering. Obtains sub-camera matrix data from ArrayCamera via IArrayCameraSource interface, avoiding circular dependency between math and cameras packages.
 */
package three.core.math

import three.core.interfaces.*

/**
 * @brief[zh-cn] 视锥体数组类，用于多层渲染的视锥体裁剪
 * @explain[zh-cn] 每个子相机对应一个 Frustum，支持从数组相机设置以及包围盒/球体/点相交测试
 *
 * @brief[en] Frustum array class for multi-layer rendering frustum culling
 * @explain[en] Each sub-camera corresponds to a Frustum, supports setting from array camera and bounding box/sphere/point intersection tests
 */
public class FrustumArray {
    /**
     * @brief[zh-cn] 视锥体数组
     *
     * @brief[en] Frustum array
     */
    public var frustums: Array<Frustum>

    /**
     * @brief[zh-cn] 用指定视锥体数组构造 FrustumArray
     * @param[zh-cn] frustums 视锥体数组
     *
     * @brief[en] Construct FrustumArray with specified frustum array
     * @param[en] frustums Frustum array
     */
    public init(frustums: Array<Frustum>) {
        this.frustums = frustums
    }

    /**
     * @brief[zh-cn] 获取指定索引的视锥体
     * @param[zh-cn] index 索引
     * @return[zh-cn] 视锥体
     *
     * @brief[en] Get the frustum at the specified index
     * @param[en] index Index
     * @return[en] Frustum
     */
    public func get(index: Int64): Frustum {
        return this.frustums[index]
    }

    /**
     * @brief[zh-cn] 判断包围盒是否与任意视锥体相交
     * @param[zh-cn] box 包围盒
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if the bounding box intersects any frustum
     * @param[en] box Bounding box
     * @return[en] Whether they intersect
     */
    public func intersectsBox(box: Box3): Bool {
        for (f in this.frustums) {
            if (f.intersectsBox(box)) {
                return true
            }
        }
        return false
    }

    /**
     * @brief[zh-cn] 判断球体是否与任意视锥体相交
     * @param[zh-cn] sphere 球体
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if the sphere intersects any frustum
     * @param[en] sphere Sphere
     * @return[en] Whether they intersect
     */
    public func intersectsSphere(sphere: Sphere): Bool {
        for (f in this.frustums) {
            if (f.intersectsSphere(sphere)) {
                return true
            }
        }
        return false
    }

    /**
     * @brief[zh-cn] 判断点是否在任意视锥体内
     * @param[zh-cn] point 点
     * @return[zh-cn] 是否包含
     *
     * @brief[en] Check if a point is inside any frustum
     * @param[en] point Point
     * @return[en] Whether the point is contained
     */
    public func containsPoint(point: Vector3): Bool {
        for (f in this.frustums) {
            if (f.containsPoint(point)) {
                return true
            }
        }
        return false
    }

    /**
     * @brief[zh-cn] 从数组相机设置视锥体数组
     * @explain[zh-cn] 每个子相机的 projectionMatrix × matrixWorldInverse 对应一个 Frustum
     * @param[zh-cn] cameraArray 实现 IArrayCameraSource 的数组相机
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set frustum array from an array camera
     * @explain[en] JS reference: FrustumArray.setFromArrayCamera. Each sub-camera's projectionMatrix × matrixWorldInverse corresponds to a Frustum
     * @param[en] cameraArray Array camera implementing IArrayCameraSource
     * @return[en] This instance
     */
    public func setFromArrayCamera(cameraArray: IArrayCameraSource): FrustumArray {
        let n = cameraArray.getCameraCount()
        let newFrustums = Array<Frustum>(n, { i =>
            let proj = Matrix4().fromArray(cameraArray.getCameraProjectionElements(i))
            let viewInv = Matrix4().fromArray(cameraArray.getCameraMatrixWorldInverseElements(i))
            let projScreen = Matrix4().multiplyMatrices(proj, viewInv)
            let f = Frustum()
            f.setFromProjectionMatrix(projScreen)
            f
        })
        this.frustums = newFrustums
        return this
    }

    /**
     * @brief[zh-cn] 判断 3D 对象是否与任意视锥体相交
     * @explain[zh-cn] 判断 3D 对象是否与任意视锥体相交
     * @param[zh-cn] object 实现 IFrustumCullable 的对象（Object3D 及子类）
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if a 3D object intersects any frustum
     * @explain[en] JS reference: FrustumArray.intersectsObject
     * @param[en] object Object implementing IFrustumCullable (Object3D and subclasses)
     * @return[en] Whether they intersect
     */
    public func intersectsObject(object: IFrustumCullable): Bool {
        for (f in this.frustums) {
            if (f.intersectsObject(object)) {
                return true
            }
        }
        return false
    }

    /**
     * @brief[zh-cn] 判断精灵是否与任意视锥体相交
     * @explain[zh-cn] 判断精灵是否与任意视锥体相交
     * @param[zh-cn] sprite 精灵（Sprite <: Object3D <: IFrustumCullable）
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if a sprite intersects any frustum
     * @explain[en] JS reference: FrustumArray.intersectsSprite
     * @param[en] sprite Sprite (Sprite <: Object3D <: IFrustumCullable)
     * @return[en] Whether they intersect
     */
    public func intersectsSprite(sprite: IFrustumCullable): Bool {
        for (f in this.frustums) {
            if (f.intersectsSprite(sprite)) {
                return true
            }
        }
        return false
    }

    /**
     * @brief[zh-cn] 复制另一个视锥体数组的值
     * @param[zh-cn] source 源视锥体数组
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another frustum array
     * @param[en] source Source frustum array
     * @return[en] This instance
     */
    public func copy(source: FrustumArray): FrustumArray {
        this.frustums = Array<Frustum>(source.frustums.size, { i => source.frustums[i].clone() })
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前视锥体数组
     * @return[zh-cn] 新的视锥体数组实例
     *
     * @brief[en] Clone the current frustum array
     * @return[en] New frustum array instance
     */
    public func clone(): FrustumArray {
        return FrustumArray(Array<Frustum>(this.frustums.size, { i => this.frustums[i].clone() }))
    }
}
