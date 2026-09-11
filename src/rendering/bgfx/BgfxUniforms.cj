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
 * @file[zh-cn] bgfx Uniform 变量管理
 * @brief[zh-cn] 替代 WebGLUniforms，使用 bgfx UniformHandle 管理 Uniform 变量
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLUniforms.js。在 WebGL 中通过 gl.getUniformLocation/gl.uniform* 设置 uniform，在 bgfx 中通过 bgfx_create_uniform_cj/bgfx_set_uniform_cj 管理。对外返回/接受的句柄统一为 Box 包装类型。
 *
 * @file[en] bgfx Uniform Variable Management
 * @brief[en] Replaces WebGLUniforms, manages uniform variables using bgfx UniformHandle
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLUniforms.js. In WebGL, uniforms are set via gl.getUniformLocation/gl.uniform*; in bgfx, they are managed via bgfx_create_uniform_cj/bgfx_set_uniform_cj. External handle types are unified as Box wrapper types.
 */
package three.rendering.bgfx

import std.collection.*
import bgfx4cj.bgfx as bgfx
import bgfx4cj.bx.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.rendering.types.*
import three.utils.log.Logger
import three.core.thread.bgfxCallMtx

/**
 * @brief[zh-cn] Uniform 信息
 *
 * @brief[en] Uniform information
 */
public class UniformInfo {
    /**
     * @brief[zh-cn] bgfx uniform 句柄（Box 包装）
     *
     * @brief[en] bgfx uniform handle (Box wrapper)
     */
    public var handle: UniformHandle = INVALID_UNIFORM_HANDLE
    /**
     * @brief[zh-cn] uniform 名称
     *
     * @brief[en] Uniform name
     */
    public var name: String = ""
    /**
     * @brief[zh-cn] uniform 类型（vec4/mat3/mat4/sampler 等）
     *
     * @brief[en] Uniform type (vec4/mat3/mat4/sampler etc.)
     */
    public var uniformType: UInt32 = 0u32
    /**
     * @brief[zh-cn] 数组大小
     *
     * @brief[en] Array size
     */
    public var num: Int64 = 1

    public init() {}
}

/**
 * @brief[zh-cn] bgfx Uniform 变量管理
 * @explain[zh-cn] 对照 WebGLUniforms，管理着色器 uniform 变量的创建和设置。bgfx 使用 UniformHandle 替代 WebGL 的 uniform location
 *
 * @brief[en] bgfx uniform variable management
 * @explain[en] Corresponds to WebGLUniforms, manages shader uniform variable creation and setting. bgfx uses UniformHandle instead of WebGL uniform location
 */
public class BgfxUniforms {
    /**
     * @brief[zh-cn] uniform 缓存（名称 -> UniformInfo）
     *
     * @brief[en] Uniform cache (name -> UniformInfo)
     */
    private var uniforms: HashMap<String, UniformInfo>

    public init() {
        this.uniforms = HashMap<String, UniformInfo>()
    }

    /**
     * @brief[zh-cn] 创建 uniform 句柄
     * @explain[zh-cn] 对照 WebGLUniforms 中的 uniform 获取
     * @param[zh-cn] name uniform 名称
     * uniformType uniform 类型（BGFX_UNIFORM_VEC4/BGFX_UNIFORM_MAT3/BGFX_UNIFORM_MAT4/BGFX_UNIFORM_SAMPLER 等）
     * @return[zh-cn] uniform 句柄（Box 包装）
     *
     * @brief[en] Create uniform handle
     * @explain[en] Corresponds to uniform acquisition in WebGLUniforms
     * @param[en] name Uniform name
     * uniformType Uniform type (BGFX_UNIFORM_VEC4/BGFX_UNIFORM_MAT3/BGFX_UNIFORM_MAT4/BGFX_UNIFORM_SAMPLER etc.)
     * @return[en] Uniform handle (Box wrapper)
     */
    public func createUniform(name: String, uniformType: UInt32): UniformHandle {
        return this.createUniform(name, uniformType, 1u16)
    }

    /**
     * @brief[zh-cn] 创建 uniform 句柄（数组 uniform 版本）
     * @explain[zh-cn] 对照原始有效实现 getOrCreateUniform(name, type, num)。bgfx_create_uniform_cj 第 3 参 num 表示数组长度
     * @param[zh-cn] name uniform 名称
     * uniformType uniform 类型
     * num 数组长度
     * @return[zh-cn] uniform 句柄
     *
     * @brief[en] Create uniform handle (array uniform version)
     * @explain[en] Corresponds to original implementation getOrCreateUniform(name, type, num). bgfx_create_uniform_cj 3rd param num indicates array length
     * @param[en] name Uniform name
     * uniformType Uniform type
     * num Array length
     * @return[en] Uniform handle
     */
    public func createUniform(name: String, uniformType: UInt32, num: UInt16): UniformHandle {
        bgfxCallMtx.lock()
        try {
            match (uniforms.get(name)) {
                case Some(info) =>
                    return info.handle
                case None =>
                    Logger.debug(["uniforms", "createUniform CREATE: name=" + name + " type=" + uniformType.toString() + " num=" + num.toString()])
                    let cName = unsafe { LibC.mallocCString(name) }
                    let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
                    let handle = bgfx.bgfx_create_uniform_cj(cName, uniformType, num)
                    cNameHolder.dispose()
                    let info = UniformInfo()
                    info.handle = Box(handle)
                    info.name = name
                    info.uniformType = uniformType
                    uniforms.add(name, info)
                    return info.handle
            }
        } finally {
            bgfxCallMtx.unlock()
        }
    }

    /**
     * @brief[zh-cn] 设置 vec4 uniform
     * @explain[zh-cn] 对照 gl.uniform4fv()
     * @param[zh-cn] name uniform 名称
     * data 数据（BgfxMemory，内部取指针）
     *
     * @brief[en] Set vec4 uniform
     * @explain[en] Corresponds to gl.uniform4fv()
     * @param[en] name Uniform name
     * data Data (BgfxMemory, internal pointer)
     */
    public func setVec4(name: String, data: BgfxMemory): Unit {
        match (uniforms.get(name)) {
            case Some(info) =>
                bgfxCallMtx.lock()
                try {
                    bgfx.bgfx_set_uniform_cj(info.handle.value, unsafe { CPointer<Unit>(data.data()) }, 1u16)
                } finally {
                    bgfxCallMtx.unlock()
                }
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 设置 mat4 uniform
     * @explain[zh-cn] 对照 gl.uniformMatrix4fv()
     * @param[zh-cn] name uniform 名称
     * data 数据（BgfxMemory，内部取指针）
     *
     * @brief[en] Set mat4 uniform
     * @explain[en] Corresponds to gl.uniformMatrix4fv()
     * @param[en] name Uniform name
     * data Data (BgfxMemory, internal pointer)
     */
    public func setMat4(name: String, data: BgfxMemory): Unit {
        match (uniforms.get(name)) {
            case Some(info) =>
                bgfxCallMtx.lock()
                try {
                    bgfx.bgfx_set_uniform_cj(info.handle.value, unsafe { CPointer<Unit>(data.data()) }, 1u16)
                } finally {
                    bgfxCallMtx.unlock()
                }
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 设置 mat3 uniform
     * @explain[zh-cn] 对照 gl.uniformMatrix3fv()。bgfx uniform 最小单位是 vec4，mat3 需要填充为 3 个 vec4
     * @param[zh-cn] name uniform 名称
     * data 数据（BgfxMemory，内部取指针）
     *
     * @brief[en] Set mat3 uniform
     * @explain[en] Corresponds to gl.uniformMatrix3fv(). bgfx uniform minimum unit is vec4, mat3 needs to be padded to 3 vec4s
     * @param[en] name Uniform name
     * data Data (BgfxMemory, internal pointer)
     */
    public func setMat3(name: String, data: BgfxMemory): Unit {
        match (uniforms.get(name)) {
            case Some(info) =>
                bgfxCallMtx.lock()
                try {
                    bgfx.bgfx_set_uniform_cj(info.handle.value, unsafe { CPointer<Unit>(data.data()) }, 1u16)
                } finally {
                    bgfxCallMtx.unlock()
                }
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 设置纹理采样器 uniform
     * @explain[zh-cn] 对照 gl.uniform1i() 对 sampler 的设置。bgfx 中纹理绑定通过 bgfx_set_texture_cj 完成
     * @param[zh-cn] name uniform 名称
     * stage 纹理阶段索引
     * handle 纹理句柄
     * flags 采样器标志
     *
     * @brief[en] Set texture sampler uniform
     * @explain[en] Corresponds to gl.uniform1i() for sampler setting. In bgfx, texture binding is done via bgfx_set_texture_cj
     * @param[en] name Uniform name
     * stage Texture stage index
     * handle Texture handle
     * flags Sampler flags
     */
    public func setTexture(name: String, stage: UInt8, handle: TextureHandle, flags: UInt32): Unit {
        match (uniforms.get(name)) {
            case Some(info) =>
                bgfx.bgfx_set_texture_cj(stage, info.handle.value, handle.value, flags)
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 获取 uniform 句柄
     * @param[zh-cn] name uniform 名称
     * @return[zh-cn] uniform 句柄（若不存在返回 None）
     *
     * @brief[en] Get uniform handle
     * @param[en] name Uniform name
     * @return[en] Uniform handle (None if not found)
     */
    public func getHandle(name: String): Option<UniformHandle> {
        match (uniforms.get(name)) {
            case Some(info) => Some(info.handle)
            case None => None
        }
    }

    /**
     * @brief[zh-cn] 销毁所有 uniform
     *
     * @brief[en] Dispose all uniforms
     */
    public func dispose(): Unit {
        bgfxCallMtx.lock()
        try {
            for ((_, info) in uniforms) {
                if (isValidHandle(info.handle)) {
                    bgfx.bgfx_destroy_uniform_cj(info.handle.value)
                }
            }
            uniforms = HashMap<String, UniformInfo>()
        } finally {
            bgfxCallMtx.unlock()
        }
    }
}
