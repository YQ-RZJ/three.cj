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
 * @explain[zh-cn] 在 WebGL 中通过 gl.getUniformLocation/gl.uniform* 设置 uniform，在 bgfx 中通过 bgfx_create_uniform_cj/bgfx_set_uniform_cj 管理。对外返回/接受的句柄统一为 Box 包装类型。
 *
 * @file[en] bgfx Uniform Variable Management
 * @brief[en] Replaces WebGLUniforms, manages uniform variables using bgfx UniformHandle
 * @explain[en] In WebGL, uniforms are set via gl.getUniformLocation/gl.uniform*; in bgfx, they are managed via bgfx_create_uniform_cj/bgfx_set_uniform_cj. External handle types are unified as Box wrapper types.
 */
protected package three.renderers._bgfx
import std.collection.*
import three._vendor.bgfx4cj.bgfx as bgfx
import three._vendor.bgfx4cj.bx.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.PtrArray
import three.renderers._gfx.*
import three.renderers._interfaces.IUniformRegistry
import three.utils.log.*
import three.utils.log.macros.*
import three.core.thread.bgfxCallMtx
import three.utils.safe.IReleasable

/**
 * @brief[zh-cn] Uniform 信息
 *
 * @brief[en] Uniform information
 */
protected class UniformInfo {
    /**
     * @brief[zh-cn] 引擎 uniform 句柄（值类型）
     *
     * @brief[en] Engine uniform handle (value type)
     */
    public var handle: GfxUniformHandle = GfxUniformHandle.INVALID
    /**
     * @brief[zh-cn] uniform 名称
     *
     * @brief[en] Uniform name
     */
    public var name: String = ""
    /**
     * @brief[zh-cn] uniform 类型（sampler/vec4/mat3/mat4）
     *
     * @brief[en] Uniform type (sampler/vec4/mat3/mat4)
     */
    public var uniformType: GfxUniformType = GfxUniformType.Vec4
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
 * @explain[zh-cn] 管理着色器 uniform 变量的创建和设置。uniform 句柄为引擎自有值类型。
 *
 * @brief[en] bgfx uniform variable management
 * @explain[en] Manages shader uniform variable creation and setting. Uniform handles are the engine's own value types.
 */
protected class BgfxUniforms <: IUniformRegistry {
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
     * @param[zh-cn] name uniform 名称
     * uniformType uniform 类型（Sampler/Vec4/Mat3/Mat4）
     * @return[zh-cn] uniform 句柄
     *
     * @brief[en] Create uniform handle
     * @param[en] name Uniform name
     * uniformType Uniform type (Sampler/Vec4/Mat3/Mat4)
     * @return[en] Uniform handle
     */
    public func createUniform(name: String, uniformType: GfxUniformType): GfxUniformHandle {
        return this.createUniform(name, uniformType, 1u16)
    }

    /**
     * @brief[zh-cn] 创建 uniform 句柄（数组 uniform 版本）
     * @explain[zh-cn] createUniform 第 3 参 num 表示数组长度
     * @param[zh-cn] name uniform 名称
     * uniformType uniform 类型
     * num 数组长度
     * @return[zh-cn] uniform 句柄
     *
     * @brief[en] Create uniform handle (array uniform version)
     * @explain[en] The 3rd param num of createUniform indicates the array length
     * @param[en] name Uniform name
     * uniformType Uniform type
     * num Array length
     * @return[en] Uniform handle
     */
    public func createUniform(name: String, uniformType: GfxUniformType, num: UInt16): GfxUniformHandle {
        bgfxCallMtx.lock()
        try {
            if (let Some(info) <- uniforms.get(name)) {
                return info.handle
            } else {
                @LogDebug(["uniforms", "createUniform CREATE: name=" + name + " num=" + num.toString()])
                let cName = unsafe { LibC.mallocCString(name) }
                let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
                let handle = bgfx.bgfx_create_uniform_cj(cName, uniformType.value(), num)
                cNameHolder.dispose()
                let info = UniformInfo()
                info.handle = GfxUniformHandle(handle.idx)
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
     * @explain[zh-cn] 经 bgfx_set_uniform_cj 提交一份 vec4 数据
     * @param[zh-cn] name uniform 名称
     * data 数据（BgfxMemory，内部取指针）
     *
     * @brief[en] Set vec4 uniform
     * @explain[en] Submits one vec4 value via bgfx_set_uniform_cj
     * @param[en] name Uniform name
     * data Data (BgfxMemory, internal pointer)
     */
    public func setVec4(name: String, data: BgfxMemory): Unit {
        if (let Some(info) <- uniforms.get(name)) {
            bgfxCallMtx.lock()
            try {
                bgfx.bgfx_set_uniform_cj(toBgfx(info.handle), unsafe { CPointer<Unit>(data.data()) }, 1u16)
            } finally {
                bgfxCallMtx.unlock()
            }
        }
    }

    /**
     * @brief[zh-cn] 设置 mat4 uniform
     * @explain[zh-cn] 经 bgfx_set_uniform_cj 提交一份 mat4 数据
     * @param[zh-cn] name uniform 名称
     * data 数据（BgfxMemory，内部取指针）
     *
     * @brief[en] Set mat4 uniform
     * @explain[en] Submits one mat4 value via bgfx_set_uniform_cj
     * @param[en] name Uniform name
     * data Data (BgfxMemory, internal pointer)
     */
    public func setMat4(name: String, data: BgfxMemory): Unit {
        if (let Some(info) <- uniforms.get(name)) {
            bgfxCallMtx.lock()
            try {
                bgfx.bgfx_set_uniform_cj(toBgfx(info.handle), unsafe { CPointer<Unit>(data.data()) }, 1u16)
            } finally {
                bgfxCallMtx.unlock()
            }
        }
    }

    /**
     * @brief[zh-cn] 设置 mat3 uniform
     * @explain[zh-cn] bgfx uniform 最小单位是 vec4，mat3 需要填充为 3 个 vec4
     * @param[zh-cn] name uniform 名称
     * data 数据（BgfxMemory，内部取指针）
     *
     * @brief[en] Set mat3 uniform
     * @explain[en] bgfx uniform minimum unit is vec4, mat3 needs to be padded to 3 vec4s
     * @param[en] name Uniform name
     * data Data (BgfxMemory, internal pointer)
     */
    public func setMat3(name: String, data: BgfxMemory): Unit {
        if (let Some(info) <- uniforms.get(name)) {
            bgfxCallMtx.lock()
            try {
                bgfx.bgfx_set_uniform_cj(toBgfx(info.handle), unsafe { CPointer<Unit>(data.data()) }, 1u16)
            } finally {
                bgfxCallMtx.unlock()
            }
        }
    }

    /**
     * @brief[zh-cn] 设置 vec4 uniform（PtrArray 数据源）
     * @param[zh-cn] name uniform 名称
     * @param[zh-cn] data uniform 数据（Float32 数组）
     *
     * @brief[en] Sets a vec4 uniform (PtrArray data source)
     * @param[en] name Uniform name
     * @param[en] data Uniform data (Float32 array)
     */
    public func setVec4(name: String, data: PtrArray<Float32>): Unit {
        if (let Some(info) <- uniforms.get(name)) {
            bgfxCallMtx.lock()
            try {
                bgfx.bgfx_set_uniform_cj(toBgfx(info.handle), unsafe { CPointer<Unit>(data.data()) }, 1u16)
            } finally {
                bgfxCallMtx.unlock()
            }
        }
    }

    /**
     * @brief[zh-cn] 设置 mat4 uniform（PtrArray 数据源）
     * @param[zh-cn] name uniform 名称
     * @param[zh-cn] data uniform 数据（Float32 数组）
     *
     * @brief[en] Sets a mat4 uniform (PtrArray data source)
     * @param[en] name Uniform name
     * @param[en] data Uniform data (Float32 array)
     */
    public func setMat4(name: String, data: PtrArray<Float32>): Unit {
        if (let Some(info) <- uniforms.get(name)) {
            bgfxCallMtx.lock()
            try {
                bgfx.bgfx_set_uniform_cj(toBgfx(info.handle), unsafe { CPointer<Unit>(data.data()) }, 1u16)
            } finally {
                bgfxCallMtx.unlock()
            }
        }
    }

    /**
     * @brief[zh-cn] 设置 mat3 uniform（PtrArray 数据源）
     * @param[zh-cn] name uniform 名称
     * @param[zh-cn] data uniform 数据（Float32 数组）
     *
     * @brief[en] Sets a mat3 uniform (PtrArray data source)
     * @param[en] name Uniform name
     * @param[en] data Uniform data (Float32 array)
     */
    public func setMat3(name: String, data: PtrArray<Float32>): Unit {
        if (let Some(info) <- uniforms.get(name)) {
            bgfxCallMtx.lock()
            try {
                bgfx.bgfx_set_uniform_cj(toBgfx(info.handle), unsafe { CPointer<Unit>(data.data()) }, 1u16)
            } finally {
                bgfxCallMtx.unlock()
            }
        }
    }

    /**
     * @brief[zh-cn] 设置纹理采样器 uniform
     * @explain[zh-cn] bgfx 中纹理绑定通过 bgfx_set_texture_cj 完成
     * @param[zh-cn] name uniform 名称
     * stage 纹理阶段索引
     * handle 纹理句柄
     * flags 采样器标志
     *
     * @brief[en] Set texture sampler uniform
     * @explain[en] In bgfx, texture binding is done via bgfx_set_texture_cj
     * @param[en] name Uniform name
     * stage Texture stage index
     * handle Texture handle
     * flags Sampler flags
     */
    public func setTexture(name: String, stage: UInt8, handle: GfxTextureHandle, flags: UInt32): Unit {
        if (let Some(info) <- uniforms.get(name)) {
            bgfx.bgfx_set_texture_cj(stage, toBgfx(info.handle), toBgfx(handle), flags)
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
    public func getHandle(name: String): Option<GfxUniformHandle> {
        if (let Some(info) <- uniforms.get(name)) {
            Some(info.handle)
        } else {
            None
        }
    }

    /**
     * @brief[zh-cn] 销毁所有 uniform
     *
     * @brief[en] dispose all uniforms
     */
    public func release(): Bool {
        bgfxCallMtx.lock()
        try {
            for ((_, info) in uniforms) {
                if (info.handle.isValid) {
                    bgfx.bgfx_destroy_uniform_cj(toBgfx(info.handle))
                }
            }
            uniforms = HashMap<String, UniformInfo>()
        } finally {
            bgfxCallMtx.unlock()
        }
        return true
    }
}
