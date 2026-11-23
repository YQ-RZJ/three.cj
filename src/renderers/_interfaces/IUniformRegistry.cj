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
 * @file[zh-cn] IUniformRegistry uniform 注册表接口
 * @brief[zh-cn] uniform 注册表抽象接口，解耦 postprocessing 与具体后端 uniform 实现
 * @explain[zh-cn] 后处理 pass 只经本接口创建 uniform 句柄与提交 uniform 数据，
 * 不依赖 bgfx 包的 BgfxUniforms 具体类型。方法集由 pass 实际调用面决定：
 * - createUniform：创建（或命中缓存）uniform 句柄
 * - setVec4 / setMat4 / setMat3：以 PtrArray<Float32> 数据源设置 uniform
 * - setTexture：绑定纹理采样器
 * - getHandle：按名查询 uniform 句柄
 * - release：销毁本注册表持有的全部 uniform
 *
 * @file[en] IUniformRegistry uniform registry interface
 * @brief[en] Uniform registry abstraction, decoupling postprocessing from the concrete backend uniform implementation
 * @explain[en] Post-processing passes only create uniform handles and submit uniform data through this
 * interface, never depending on the concrete BgfxUniforms type in the bgfx package. The method set is
 * derived from actual pass call sites:
 * - createUniform: create (or hit the cache for) a uniform handle
 * - setVec4 / setMat4 / setMat3: set uniform from a PtrArray<Float32> data source
 * - setTexture: bind a texture sampler
 * - getHandle: look up a uniform handle by name
 * - release: destroy all uniforms held by this registry
 *
 * @protected package three.renderers._interfaces
 */
protected package three.renderers._interfaces

import three.renderers._gfx.{GfxTextureHandle, GfxUniformHandle, GfxUniformType}
import three.utils.memory.PtrArray
import three.utils.safe.IReleasable

/**
 * @brief[zh-cn] uniform 注册表接口：创建句柄、提交 uniform 数据、绑定纹理采样器
 *
 * @brief[en] Uniform registry interface: create handles, submit uniform data, bind texture samplers
 */
public interface IUniformRegistry <: IReleasable {
    /**
     * @brief[zh-cn] 创建 uniform 句柄（非数组）
     * @param[zh-cn] name uniform 名称
     * @param[zh-cn] uniformType uniform 类型（Sampler/Vec4/Mat3/Mat4）
     * @return[zh-cn] uniform 句柄
     *
     * @brief[en] Creates a uniform handle (non-array)
     * @param[en] name Uniform name
     * @param[en] uniformType Uniform type (Sampler/Vec4/Mat3/Mat4)
     * @return[en] Uniform handle
     */
    func createUniform(name: String, uniformType: GfxUniformType): GfxUniformHandle

    /**
     * @brief[zh-cn] 创建 uniform 句柄（数组版本）
     * @param[zh-cn] name uniform 名称
     * @param[zh-cn] uniformType uniform 类型
     * @param[zh-cn] num 数组长度
     * @return[zh-cn] uniform 句柄
     *
     * @brief[en] Creates a uniform handle (array version)
     * @param[en] name Uniform name
     * @param[en] uniformType Uniform type
     * @param[en] num Array length
     * @return[en] Uniform handle
     */
    func createUniform(name: String, uniformType: GfxUniformType, num: UInt16): GfxUniformHandle

    /**
     * @brief[zh-cn] 设置 vec4 uniform
     * @param[zh-cn] name uniform 名称
     * @param[zh-cn] data uniform 数据（Float32 数组）
     *
     * @brief[en] Sets a vec4 uniform
     * @param[en] name Uniform name
     * @param[en] data Uniform data (Float32 array)
     */
    func setVec4(name: String, data: PtrArray<Float32>): Unit

    /**
     * @brief[zh-cn] 设置 mat4 uniform
     * @param[zh-cn] name uniform 名称
     * @param[zh-cn] data uniform 数据（Float32 数组）
     *
     * @brief[en] Sets a mat4 uniform
     * @param[en] name Uniform name
     * @param[en] data Uniform data (Float32 array)
     */
    func setMat4(name: String, data: PtrArray<Float32>): Unit

    /**
     * @brief[zh-cn] 设置 mat3 uniform
     * @param[zh-cn] name uniform 名称
     * @param[zh-cn] data uniform 数据（Float32 数组）
     *
     * @brief[en] Sets a mat3 uniform
     * @param[en] name Uniform name
     * @param[en] data Uniform data (Float32 array)
     */
    func setMat3(name: String, data: PtrArray<Float32>): Unit

    /**
     * @brief[zh-cn] 设置纹理采样器 uniform
     * @param[zh-cn] name uniform 名称
     * @param[zh-cn] stage 纹理阶段索引
     * @param[zh-cn] handle 纹理句柄
     * @param[zh-cn] flags 采样器标志
     *
     * @brief[en] Sets a texture sampler uniform
     * @param[en] name Uniform name
     * @param[en] stage Texture stage index
     * @param[en] handle Texture handle
     * @param[en] flags Sampler flags
     */
    func setTexture(name: String, stage: UInt8, handle: GfxTextureHandle, flags: UInt32): Unit

    /**
     * @brief[zh-cn] 获取 uniform 句柄
     * @param[zh-cn] name uniform 名称
     * @return[zh-cn] uniform 句柄（若不存在返回 None）
     *
     * @brief[en] Gets a uniform handle
     * @param[en] name Uniform name
     * @return[en] Uniform handle (None if not found)
     */
    func getHandle(name: String): Option<GfxUniformHandle>

    /**
     * @brief[zh-cn] 销毁本注册表持有的全部 uniform
     * @return[zh-cn] true 表示执行了释放
     *
     * @brief[en] Destroys all uniforms held by this registry
     * @return[en] true if the release was performed
     */
    func release(): Bool
}
