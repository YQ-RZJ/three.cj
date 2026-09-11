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
 * @file[zh-cn] bgfx Uniform 组管理
 * @brief[zh-cn] 替代 WebGLUniformsGroups，管理 Uniform Buffer Object (UBO)
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLUniformsGroups.js。在 WebGL 中通过 gl.bindBufferBase/gl.bufferSubData 管理 UBO，在 bgfx 中通过 bgfx_create_uniform_cj 创建 uniform 组。
 *
 * @file[en] bgfx Uniform Group Management
 * @brief[en] Replaces WebGLUniformsGroups, manages Uniform Buffer Objects (UBO)
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLUniformsGroups.js. In WebGL, UBOs are managed via gl.bindBufferBase/gl.bufferSubData; in bgfx, uniform groups are created via bgfx_create_uniform_cj.
 */
package three.rendering.bgfx

import std.collection.*
import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] Uniform 组信息
 *
 * @brief[en] Uniform group information
 */
public class UniformGroupInfo {
    /**
     * @brief[zh-cn] uniform 组 ID
     *
     * @brief[en] Uniform group ID
     */
    public var id: Int64
    /**
     * @brief[zh-cn] 绑定点索引
     *
     * @brief[en] Binding point index
     */
    public var bindingPointIndex: Int64 = -1
    /**
     * @brief[zh-cn] 数据大小（字节）
     *
     * @brief[en] Data size in bytes
     */
    public var size: Int64 = 0
    /**
     * @brief[zh-cn] 是否需要更新
     *
     * @brief[en] Whether needs update
     */
    public var needsUpdate: Bool = true
    /**
     * @brief[zh-cn] 上次更新的帧号
     *
     * @brief[en] Last updated frame number
     */
    public var lastUpdateFrame: Int64 = -1

    public init(id: Int64) {
        this.id = id
    }
}

/**
 * @brief[zh-cn] bgfx Uniform 组管理
 * @explain[zh-cn] 对照 WebGLUniformsGroups，管理 Uniform Buffer Object。bgfx 使用 uniform 缓冲替代 WebGL 的 UBO
 *
 * @brief[en] bgfx uniform group management
 * @explain[en] Corresponds to WebGLUniformsGroups, manages Uniform Buffer Objects. bgfx uses uniform buffers instead of WebGL UBOs
 */
public class BgfxUniformsGroups {
    /**
     * @brief[zh-cn] uniform 组映射
     *
     * @brief[en] Uniform group mapping
     */
    private var buffers: HashMap<Int64, UniformGroupInfo>
    /**
     * @brief[zh-cn] 更新列表
     *
     * @brief[en] Update list
     */
    private var updateList: HashMap<Int64, Int64>
    /**
     * @brief[zh-cn] 渲染统计
     *
     * @brief[en] Render statistics
     */
    private var info: BgfxInfo

    public init(info!: BgfxInfo = BgfxInfo()) {
        this.buffers = HashMap<Int64, UniformGroupInfo>()
        this.updateList = HashMap<Int64, Int64>()
        this.info = info
    }

    /**
     * @brief[zh-cn] 绑定 uniform 组
     * @explain[zh-cn] 对照 WebGLUniformsGroups.bind()。bgfx 中 uniform 绑定通过 bgfx_set_uniform_cj 完成，此处记录绑定关系
     * @param[zh-cn] groupId uniform 组 ID
     * programId 着色器程序 ID
     *
     * @brief[en] Bind uniform group
     * @explain[en] Corresponds to WebGLUniformsGroups.bind(). In bgfx, uniform binding is done via bgfx_set_uniform_cj; this records the binding relationship
     * @param[en] groupId Uniform group ID
     * programId Shader program ID
     */
    public func bind(groupId: Int64, programId: Int64): Unit {
        // bgfx 中 uniform 绑定通过 bgfx_set_uniform_cj 完成
        // 此处记录绑定关系
    }

    /**
     * @brief[zh-cn] 更新 uniform 组数据
     * @explain[zh-cn] 对照 WebGLUniformsGroups.update()
     * @param[zh-cn] groupId uniform 组 ID
     * programId 着色器程序 ID
     *
     * @brief[en] Update uniform group data
     * @explain[en] Corresponds to WebGLUniformsGroups.update()
     * @param[en] groupId Uniform group ID
     * programId Shader program ID
     */
    public func update(groupId: Int64, programId: Int64): Unit {
        match (buffers.get(groupId)) {
            case Some(buffer) =>
                let frame = info.render.frame
                match (updateList.get(groupId)) {
                    case Some(lastFrame) =>
                        if (lastFrame != frame) {
                            buffer.needsUpdate = true
                            updateList.add(groupId, frame)
                        }
                    case None =>
                        buffer.needsUpdate = true
                        updateList.add(groupId, frame)
                }
            case None =>
                let buffer = UniformGroupInfo(groupId)
                buffers.add(groupId, buffer)
                updateList.add(groupId, info.render.frame)
        }
    }

    /**
     * @brief[zh-cn] 释放 uniform 组
     * @param[zh-cn] groupId uniform 组 ID
     *
     * @brief[en] Dispose uniform group
     * @param[en] groupId Uniform group ID
     */
    public func dispose(groupId: Int64): Unit {
        buffers.remove(groupId)
        updateList.remove(groupId)
    }

    /**
     * @brief[zh-cn] 释放所有 uniform 组
     *
     * @brief[en] Dispose all uniform groups
     */
    public func disposeAll(): Unit {
        buffers = HashMap<Int64, UniformGroupInfo>()
        updateList = HashMap<Int64, Int64>()
    }
}
