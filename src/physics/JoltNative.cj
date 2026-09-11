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
 * @file[zh-cn] JoltNative Jolt 特有高级功能共享工具（three.physics 模块内部设施）
 * @brief[zh-cn] 提供 three 左手系 ↔ Jolt 右手系坐标转换与 \@C 结构体缓冲辅助
 * @explain[zh-cn] 本类为 three.physics 模块内部设施（internal），不对模块外公开，
 * 因此其签名中可以出现 CPointer——这些指针只在模块内部的 ragdoll/vehicle/softbody
 * 等高级封装与 backend 之间传递，用户代码不可见也不可操作。
 * 布娃娃/车辆/软体/高级约束等 Jolt 特有封装直接调用 jolt4cj FFI，
 * 它们需要与 JoltBackend 完全一致的坐标系转换和 LibC.malloc/free 缓冲模式。
 * 坐标系约定（与 JoltBackend 相同，M = diag(1,1,-1)，det = -1）：
 * - 普通向量（位置/轴/锚点/线速度/力）: v' = (x, y, -z)
 * - 四元数（旋转矩阵共轭 M R M）:      q' = (-x, -y, z, w)
 * - 伪向量（角速度/力矩/角冲量）:       w' = (-x, -y, z)
 * 线程约定：本工具仅提供纯函数与缓冲分配，调用方必须保证 FFI 访问发生在
 * PhysicsWorld 物理线程内（world.execPhysics 闭包中）。
 *
 * @file[en] JoltNative shared utilities for Jolt-specific advanced features (three.physics module-internal facility)
 * @brief[en] Provides three left-handed ↔ Jolt right-handed coordinate conversion and \@C struct buffer helpers
 * @explain[en] This class is an internal facility of the three.physics module and is not
 * exported outside the module, so CPointer may appear in its signatures — those pointers
 * only flow between the module's ragdoll/vehicle/softbody wrappers and the backend; user
 * code can neither see nor touch them.
 * Coordinate convention (same as JoltBackend, M = diag(1,1,-1), det = -1):
 * - plain vectors (position/axis/anchor/linear velocity/force): v' = (x, y, -z)
 * - quaternions (rotation matrix conjugate M R M):          q' = (-x, -y, z, w)
 * - axial vectors (angular velocity/torque/angular impulse): w' = (-x, -y, z)
 * Threading: this utility only provides pure functions and buffer allocation; callers must
 * guarantee FFI access happens on the PhysicsWorld physics thread (inside world.execPhysics).
 */
package three.physics

import three.core.math.*
import jolt4cj.jolt.*

/**
 * @brief[zh-cn] Jolt 高级功能共享工具（模块内部，纯函数）
 *
 * @brief[en] Shared utilities for advanced Jolt features (module-internal, pure functions)
 */
internal class JoltNative {
    /**
     * @brief[zh-cn] 左手系 → 右手系（普通向量：位置/轴/锚点/线速度/力），Z 取反
     *
     * @brief[en] Left-handed → right-handed (plain vector), Z negated
     */
    internal static func lhToRh(v: Vector3): Vector3 {
        return Vector3(v.x, v.y, -v.z)
    }

    /**
     * @brief[zh-cn] 右手系 → 左手系（普通向量，与 lhToRh 互为同一镜像，自逆）
     *
     * @brief[en] Right-handed → left-handed (plain vector; self-inverse)
     */
    internal static func rhToLh(v: Vector3): Vector3 {
        return Vector3(v.x, v.y, -v.z)
    }

    /**
     * @brief[zh-cn] 左手系 → 右手系（四元数），x、y 取反
     *
     * @brief[en] Left-handed → right-handed (quaternion), x and y negated
     */
    internal static func lhToRhQuat(q: Quaternion): Quaternion {
        return Quaternion(-q.x, -q.y, q.z, q.w)
    }

    /**
     * @brief[zh-cn] 右手系 → 左手系（四元数，自逆）
     *
     * @brief[en] Right-handed → left-handed (quaternion, self-inverse)
     */
    internal static func rhToLhQuat(q: Quaternion): Quaternion {
        return Quaternion(-q.x, -q.y, q.z, q.w)
    }

    /**
     * @brief[zh-cn] 左手系 → 右手系（伪向量：角速度/力矩/角冲量）
     *
     * @brief[en] Left-handed → right-handed (axial vector: angular velocity/torque/impulse)
     */
    internal static func lhToRhAxial(w: Vector3): Vector3 {
        return Vector3(-w.x, -w.y, w.z)
    }

    /**
     * @brief[zh-cn] 右手系 → 左手系（伪向量，自逆）
     *
     * @brief[en] Right-handed → left-handed (axial vector, self-inverse)
     */
    internal static func rhToLhAxial(w: Vector3): Vector3 {
        return Vector3(-w.x, -w.y, w.z)
    }

    // =========================================================================
    // JPHVec3 / JPHQuat 缓冲区辅助
    // =========================================================================

    /**
     * @brief[zh-cn] 分配 JPHVec3 缓冲并写入 three 向量（自动左手→右手转换）
     * @param[zh-cn] v three 左手系向量
     * @return[zh-cn] 已写入的 JPHVec3 缓冲（调用方负责 LibC.free）
     *
     * @brief[en] Allocates a JPHVec3 buffer and writes a three vector (auto left→right)
     * @param[en] v The three left-handed vector
     * @return[en] The written JPHVec3 buffer (caller is responsible for LibC.free)
     */
    internal static func allocVec3(v: Vector3): CPointer<JPHVec3> {
        let jv = JoltNative.lhToRh(v)
        let p = unsafe { LibC.malloc<JPHVec3>() }
        unsafe {
            p.write(JPHVec3(x: Float32(jv.x), y: Float32(jv.y), z: Float32(jv.z)))
        }
        return p
    }

    /**
     * @brief[zh-cn] 分配 JPHVec3 缓冲并写入向量（不做坐标转换，用于方向无关量）
     *
     * @brief[en] Allocates a JPHVec3 buffer and writes the vector as-is (no conversion)
     */
    internal static func allocVec3Raw(v: Vector3): CPointer<JPHVec3> {
        let p = unsafe { LibC.malloc<JPHVec3>() }
        unsafe {
            p.write(JPHVec3(x: Float32(v.x), y: Float32(v.y), z: Float32(v.z)))
        }
        return p
    }

    /**
     * @brief[zh-cn] 读取 JPHVec3 缓冲并转回 three 向量（右手→左手）
     *
     * @brief[en] Reads a JPHVec3 buffer back into a three vector (right→left)
     */
    internal static func readVec3(p: CPointer<JPHVec3>): Vector3 {
        let r = unsafe { p.read() }
        return JoltNative.rhToLh(Vector3(Float64(r.x), Float64(r.y), Float64(r.z)))
    }

    /**
     * @brief[zh-cn] 读取 JPHVec3 缓冲（不做坐标转换）
     *
     * @brief[en] Reads a JPHVec3 buffer as-is (no conversion)
     */
    internal static func readVec3Raw(p: CPointer<JPHVec3>): Vector3 {
        let r = unsafe { p.read() }
        return Vector3(Float64(r.x), Float64(r.y), Float64(r.z))
    }

    /**
     * @brief[zh-cn] 分配 JPHQuat 缓冲并写入四元数（自动左手→右手转换）
     *
     * @brief[en] Allocates a JPHQuat buffer and writes a quaternion (auto left→right)
     */
    internal static func allocQuat(q: Quaternion): CPointer<JPHQuat> {
        let jq = JoltNative.lhToRhQuat(q)
        let p = unsafe { LibC.malloc<JPHQuat>() }
        unsafe {
            p.write(JPHQuat(x: Float32(jq.x), y: Float32(jq.y), z: Float32(jq.z), w: Float32(jq.w)))
        }
        return p
    }

    /**
     * @brief[zh-cn] 读取 JPHQuat 缓冲并转回 three 四元数（右手→左手）
     *
     * @brief[en] Reads a JPHQuat buffer back into a three quaternion (right→left)
     */
    internal static func readQuat(p: CPointer<JPHQuat>): Quaternion {
        let r = unsafe { p.read() }
        return JoltNative.rhToLhQuat(Quaternion(Float64(r.x), Float64(r.y), Float64(r.z), Float64(r.w)))
    }

    // =========================================================================
    // JPHMat4 缓冲区辅助（列主序 4x4；Jolt Mat44 与 three Matrix4 同为列主序）
    // 坐标系镜像：M' = P M P，P = diag(1,1,-1,1)（齐次 w 分量符号为 +1），自逆。
    // =========================================================================

    /// 齐次坐标各轴镜像符号（x,y,z,w）
    private static let _mirrorSign: Array<Float32> = [1.0f32, 1.0f32, -1.0f32, 1.0f32]

    /**
     * @brief[zh-cn] 分配 JPHMat4 缓冲并写入 three 矩阵（自动左手→右手镜像）
     * @param[zh-cn] m three 左手系列主序 Matrix4
     * @return[zh-cn] JPHMat4 缓冲（调用方负责 LibC.free）
     *
     * @brief[en] Allocates a JPHMat4 buffer and writes a three matrix (auto left→right mirror)
     * @param[en] m The three left-handed column-major Matrix4
     * @return[en] The JPHMat4 buffer (caller is responsible for LibC.free)
     */
    internal static func allocMat4(m: Matrix4): CPointer<JPHMat4> {
        let p = unsafe { LibC.malloc<JPHMat4>() }
        let e = m.elements
        var cols = VArray<JPHVec4, $4>(repeat: JPHVec4())
        for (col in 0..4) {
            let pc = JoltNative._mirrorSign[col]
            var v = JPHVec4()
            for (row in 0..4) {
                let val = JoltNative._mirrorSign[row] * pc * Float32(e[col * 4 + row])
                match (row) {
                    case 0 => v.x = val
                    case 1 => v.y = val
                    case 2 => v.z = val
                    case _ => v.w = val
                }
            }
            cols[col] = v
        }
        unsafe { p.write(JPHMat4(c0: cols[0], c1: cols[1], c2: cols[2], c3: cols[3])) }
        return p
    }

    /**
     * @brief[zh-cn] 读取 JPHMat4 缓冲并转回 three 矩阵（右手→左手镜像，自逆）
     *
     * @brief[en] Reads a JPHMat4 buffer back into a three matrix (right→left mirror, self-inverse)
     */
    internal static func readMat4(p: CPointer<JPHMat4>): Matrix4 {
        let jm = unsafe { p.read() }
        let out = Matrix4()
        for (col in 0..4) {
            let pc = JoltNative._mirrorSign[col]
            let jv = jm.column[col]
            let jvals = [jv.x, jv.y, jv.z, jv.w]
            for (row in 0..4) {
                out.elements[col * 4 + row] = Float64(JoltNative._mirrorSign[row] * pc * jvals[row])
            }
        }
        return out
    }
}
