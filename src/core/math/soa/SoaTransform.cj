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
 * @file[zh-cn] SoaTransform
 * @brief[zh-cn] SoA (Structure-of-Arrays) 格式的四元组变换
 * @explain[zh-cn] 将 4 个关节的平移、旋转、缩放以 SoA 布局存储，便于顺序遍历时保持 cache 友好性。
 *
 * @file[en] SoaTransform
 * @brief[en] Structure-of-Arrays layout for 4 joint transforms
 * @explain[en] Stores translation/rotation/scale of 4 joints in SoA layout for cache-friendly sequential access.
 */
package three.core.math.soa
import three.core.math.*

/**
 * @brief[zh-cn] SoA 变换结构体，存储 4 个关节的平移、旋转、缩放
 * @explain[zh-cn] 每个分量数组连续存储 4 个关节的值：translations[0..3] 存储 4 个平移的 x/y/z，
 *                  rotations[0..3] 存储 4 个旋转的 x/y/z/w，scales[0..3] 存储 4 个缩放的 x/y/z。
 *                  这种布局在遍历时可以顺序访问，对 CPU cache 更友好。
 *
 * @brief[en] SoA transform struct storing translation/rotation/scale for 4 joints
 * @explain[en] Each component array stores 4 joints' values contiguously.
 *              Layout: translations = [4]Vec3, rotations = [4]Quat, scales = [4]Vec3.
 */
public class SoaTransform {
    /**
     * @brief[zh-cn] 4 个关节的平移分量
     * @explain[zh-cn] layout: [tx0, ty0, tz0, tx1, ty1, tz1, tx2, ty2, tz2, tx3, ty3, tz3]
     *
     * @brief[en] Translation components for 4 joints
     * @explain[en] layout: [tx0, ty0, tz0, tx1, ty1, tz1, tx2, ty2, tz2, tx3, ty3, tz3]
     */
    public var translations: Array<Float32>

    /**
     * @brief[zh-cn] 4 个关节的旋转分量（四元数）
     * @explain[zh-cn] layout: [qx0, qy0, qz0, qw0, qx1, qy1, qz1, qw1, ...]
     *
     * @brief[en] Rotation components for 4 joints (quaternions)
     * @explain[en] layout: [qx0, qy0, qz0, qw0, qx1, qy1, qz1, qw1, ...]
     */
    public var rotations: Array<Float32>

    /**
     * @brief[zh-cn] 4 个关节的缩放分量
     * @explain[zh-cn] layout: [sx0, sy0, sz0, sx1, sy1, sz1, sx2, sy2, sz2, sx3, sy3, sz3]
     *
     * @brief[en] Scale components for 4 joints
     * @explain[en] layout: [sx0, sy0, sz0, sx1, sy1, sz1, sx2, sy2, sz2, sx3, sy3, sz3]
     */
    public var scales: Array<Float32>

    /**
     * @brief[zh-cn] 默认构造函数，初始化为单位变换（零平移、单位旋转、单位缩放）
     *
     * @brief[en] Default constructor, initializes to identity transform
     */
    public init() {
        this.translations = Array<Float32>(12, { _ => 0.0f32 })
        this.rotations = Array<Float32>(16, { i =>
            if (i % 4 == 3) { 1.0f32 } else { 0.0f32 }
        })
        this.scales = Array<Float32>(12, { _ => 1.0f32 })
    }

    /**
     * @brief[zh-cn] 从原始数组构造
     * @param[zh-cn] translations 平移数组（12 个元素）
     * @param[zh-cn] rotations 旋转数组（16 个元素）
     * @param[zh-cn] scales 缩放数组（12 个元素）
     *
     * @brief[en] Construct from raw arrays
     * @param[en] translations Translation array (12 elements)
     * @param[en] rotations Rotation array (16 elements)
     * @param[en] scales Scale array (12 elements)
     */
    public init(translations: Array<Float32>, rotations: Array<Float32>, scales: Array<Float32>) {
        this.translations = translations
        this.rotations = rotations
        this.scales = scales
    }

    /**
     * @brief[zh-cn] 从单个关节的平移、旋转、缩放构造第0个槽位
     * @param[zh-cn] tx 平移 x
     * @param[zh-cn] ty 平移 y
     * @param[zh-cn] tz 平移 z
     * @param[zh-cn] rx 旋转 x
     * @param[zh-cn] ry 旋转 y
     * @param[zh-cn] rz 旋转 z
     * @param[zh-cn] rw 旋转 w
     * @param[zh-cn] sx 缩放 x
     * @param[zh-cn] sy 缩放 y
     * @param[zh-cn] sz 缩放 z
     *
     * @brief[en] Construct with a single joint in slot 0
     * @param[en] tx Translation x
     * @param[en] ty Translation y
     * @param[en] tz Translation z
     * @param[en] rx Rotation x
     * @param[en] ry Rotation y
     * @param[en] rz Rotation z
     * @param[en] rw Rotation w
     * @param[en] sx Scale x
     * @param[en] sy Scale y
     * @param[en] sz Scale z
     */
    public init(tx: Float32, ty: Float32, tz: Float32,
                rx: Float32, ry: Float32, rz: Float32, rw: Float32,
                sx: Float32, sy: Float32, sz: Float32) {
        this.translations = Array<Float32>(12, { i =>
            match (i % 12) {
                case 0 => tx
                case 1 => ty
                case 2 => tz
                case _ => 0.0f32
            }
        })
        this.rotations = Array<Float32>(16, { i =>
            match (i % 4) {
                case 0 => rx
                case 1 => ry
                case 2 => rz
                case _ => rw
            }
        })
        this.scales = Array<Float32>(12, { i =>
            match (i % 12) {
                case 0 => sx
                case 1 => sy
                case 2 => sz
                case _ => 1.0f32
            }
        })
    }

    // --- Joint accessors (slot = 0..3) ---

    /**
     * @brief[zh-cn] 获取指定槽位的平移
     * @param[zh-cn] slot 槽位索引 (0-3)
     * @return[zh-cn] [tx, ty, tz]
     *
     * @brief[en] Get translation for a given slot (0-3)
     * @param[en] slot Slot index (0-3)
     * @return[en] [tx, ty, tz]
     */
    public func getTranslation(slot: Int): Vector3F {
        let base = slot * 3
        Vector3F(this.translations[base], this.translations[base + 1], this.translations[base + 2])
    }

    /**
     * @brief[zh-cn] 获取指定槽位的旋转
     * @param[zh-cn] slot 槽位索引 (0-3)
     * @return[zh-cn] (x, y, z, w)
     *
     * @brief[en] Get rotation quaternion for a given slot (0-3)
     * @param[en] slot Slot index (0-3)
     * @return[en] (x, y, z, w)
     */
    public func getRotation(slot: Int): QuaternionF {
        let base = slot * 4
        QuaternionF(this.rotations[base], this.rotations[base + 1], this.rotations[base + 2], this.rotations[base + 3])
    }

    /**
     * @brief[zh-cn] 获取指定槽位的缩放
     * @param[zh-cn] slot 槽位索引 (0-3)
     * @return[zh-cn] (sx, sy, sz)
     *
     * @brief[en] Get scale for a given slot (0-3)
     * @param[en] slot Slot index (0-3)
     * @return[en] (sx, sy, sz)
     */
    public func getScale(slot: Int): Vector3F {
        let base = slot * 3
        Vector3F(this.scales[base], this.scales[base + 1], this.scales[base + 2])
    }

    // --- Mutable slot setters ---

    /**
     * @brief[zh-cn] 设置指定槽位的平移
     * @param[zh-cn] slot 槽位索引 (0-3)
     * @param[zh-cn] tx 平移 x
     * @param[zh-cn] ty 平移 y
     * @param[zh-cn] tz 平移 z
     *
     * @brief[en] Set translation for a given slot
     * @param[en] slot Slot index (0-3)
     * @param[en] tx Translation x
     * @param[en] ty Translation y
     * @param[en] tz Translation z
     */
    public func setTranslation(slot: Int, tx: Float32, ty: Float32, tz: Float32): Unit {
        let base = slot * 3
        this.translations[base] = tx
        this.translations[base + 1] = ty
        this.translations[base + 2] = tz
    }

    /**
     * @brief[zh-cn] 设置指定槽位的旋转
     * @param[zh-cn] slot 槽位索引 (0-3)
     * @param[zh-cn] rx 旋转 x
     * @param[zh-cn] ry 旋转 y
     * @param[zh-cn] rz 旋转 z
     * @param[zh-cn] rw 旋转 w
     *
     * @brief[en] Set rotation quaternion for a given slot
     * @param[en] slot Slot index (0-3)
     * @param[en] rx Rotation x
     * @param[en] ry Rotation y
     * @param[en] rz Rotation z
     * @param[en] rw Rotation w
     */
    public func setRotation(slot: Int, rx: Float32, ry: Float32, rz: Float32, rw: Float32): Unit {
        let base = slot * 4
        this.rotations[base] = rx
        this.rotations[base + 1] = ry
        this.rotations[base + 2] = rz
        this.rotations[base + 3] = rw
    }

    /**
     * @brief[zh-cn] 设置指定槽位的缩放
     * @param[zh-cn] slot 槽位索引 (0-3)
     * @param[zh-cn] sx 缩放 x
     * @param[zh-cn] sy 缩放 y
     * @param[zh-cn] sz 缩放 z
     *
     * @brief[en] Set scale for a given slot
     * @param[en] slot Slot index (0-3)
     * @param[en] sx Scale x
     * @param[en] sy Scale y
     * @param[en] sz Scale z
     */
    public func setScale(slot: Int, sx: Float32, sy: Float32, sz: Float32): Unit {
        let base = slot * 3
        this.scales[base] = sx
        this.scales[base + 1] = sy
        this.scales[base + 2] = sz
    }

    // --- Static helpers ---

    /**
     * @brief[zh-cn] 创建单位变换（4 个槽位均为零平移、单位旋转、单位缩放）
     *
     * @brief[en] Create identity transform (4 slots with zero T, identity R, unit S)
     */
    public static func identity(): SoaTransform {
        SoaTransform()
    }

    /**
     * @brief[zh-cn] 深拷贝当前变换
     * @return[zh-cn] 一个新的 SoaTransform，数组内容独立
     *
     * @brief[en] Deep copy of this transform
     * @return[en] A new SoaTransform with independent array contents
     */
    public func clone(): SoaTransform {
        let nt = Array<Float32>(12, { i => this.translations[i] })
        let nr = Array<Float32>(16, { i => this.rotations[i] })
        let ns = Array<Float32>(12, { i => this.scales[i] })
        SoaTransform(nt, nr, ns)
    }

    /**
     * @brief[zh-cn] 将 4 个单关节 Transform 拼装为一个 SoaTransform
     * @param[zh-cn] tx0..tz3 各关节平移
     * @param[zh-cn] rx0..rw3 各关节旋转
     * @param[zh-cn] sx0..sz3 各关节缩放
     *
     * @brief[en] Pack 4 individual transforms into a single SoaTransform
     * @param[en] tx0..tz3 Translation of each joint
     * @param[en] rx0..rw3 Rotation of each joint
     * @param[en] sx0..sz3 Scale of each joint
     */
    public static func fromFour(
        tx0: Float32, ty0: Float32, tz0: Float32, rx0: Float32, ry0: Float32, rz0: Float32, rw0: Float32, sx0: Float32, sy0: Float32, sz0: Float32,
        tx1: Float32, ty1: Float32, tz1: Float32, rx1: Float32, ry1: Float32, rz1: Float32, rw1: Float32, sx1: Float32, sy1: Float32, sz1: Float32,
        tx2: Float32, ty2: Float32, tz2: Float32, rx2: Float32, ry2: Float32, rz2: Float32, rw2: Float32, sx2: Float32, sy2: Float32, sz2: Float32,
        tx3: Float32, ty3: Float32, tz3: Float32, rx3: Float32, ry3: Float32, rz3: Float32, rw3: Float32, sx3: Float32, sy3: Float32, sz3: Float32
    ): SoaTransform {
        let trans = Array<Float32>(12, { i =>
            match (i) {
                case 0 => tx0
                case 1 => ty0
                case 2 => tz0
                case 3 => tx1
                case 4 => ty1
                case 5 => tz1
                case 6 => tx2
                case 7 => ty2
                case 8 => tz2
                case 9 => tx3
                case 10 => ty3
                case 11 => tz3
                case _ => 0.0f32
            }
        })
        let rot = Array<Float32>(16, { i =>
            match (i) {
                case 0 => rx0
                case 1 => ry0
                case 2 => rz0
                case 3 => rw0
                case 4 => rx1
                case 5 => ry1
                case 6 => rz1
                case 7 => rw1
                case 8 => rx2
                case 9 => ry2
                case 10 => rz2
                case 11 => rw2
                case 12 => rx3
                case 13 => ry3
                case 14 => rz3
                case 15 => rw3
                case _ => 0.0f32
            }
        })
        let sc = Array<Float32>(12, { i =>
            match (i) {
                case 0 => sx0
                case 1 => sy0
                case 2 => sz0
                case 3 => sx1
                case 4 => sy1
                case 5 => sz1
                case 6 => sx2
                case 7 => sy2
                case 8 => sz2
                case 9 => sx3
                case 10 => sy3
                case 11 => sz3
                case _ => 1.0f32
            }
        })
        SoaTransform(trans, rot, sc)
    }
}
