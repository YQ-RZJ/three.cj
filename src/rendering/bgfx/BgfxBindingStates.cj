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
 * @file[zh-cn] bgfx 顶点绑定状态管理
 * @brief[zh-cn] 替代 WebGLBindingStates，管理顶点属性绑定状态
 * @explain[zh-cn] 对照源码: three.js/src/renderers/webgl/WebGLBindingStates.js。在 WebGL 中使用 VAO（Vertex Array Object）管理顶点属性绑定，在 bgfx 中使用 VertexLayout 管理顶点布局，绑定状态通过 bgfx_set_vertex_buffer_cj 设置。
 *
 * @file[en] bgfx Vertex Binding States Management
 * @brief[en] Replace WebGLBindingStates, manage vertex attribute binding states
 * @explain[en] Mirrors three.js/src/renderers/webgl/WebGLBindingStates.js. In WebGL, VAOs manage vertex attribute bindings; in bgfx, VertexLayout manages vertex layout and binding states are set via bgfx_set_vertex_buffer_cj.
 */
package three.rendering.bgfx

import std.collection.*
import bgfx4cj.bgfx.*
import three.rendering.buffer.BufferAttribute

/**
 * @brief[zh-cn] 绑定状态
 * @explain[zh-cn] 对照 WebGLBindingStates 中的 bindingState 对象，存储几何体/程序关联的顶点绑定状态。
 *
 * @brief[en] Binding state
 * @explain[en] Mirrors the bindingState object in WebGLBindingStates, storing vertex binding state associated with geometry/program.
 */
public class BindingState {
    /**
     * @brief[zh-cn] 关联的几何体 ID
     *
     * @brief[en] Associated geometry ID
     */
    public var geometryId: Int64
    /**
     * @brief[zh-cn] 关联的程序 ID
     *
     * @brief[en] Associated program ID
     */
    public var programId: Int64
    /**
     * @brief[zh-cn] 是否线框模式
     *
     * @brief[en] Whether wireframe mode
     */
    public var wireframe: Bool
    /**
     * @brief[zh-cn] 顶点布局
     *
     * @brief[en] Vertex layout
     */
    public var vertexLayout: VertexLayout
    /**
     * @brief[zh-cn] 属性缓存
     *
     * @brief[en] Attribute cache
     */
    public var attributes: HashMap<String, AttributeCache>
    /**
     * @brief[zh-cn] 索引缓冲句柄（0 表示无效）
     *
     * @brief[en] Index buffer handle (0 means invalid)
     */
    public var indexHandle: UInt16 = 0u16
    /**
     * @brief[zh-cn] 属性数量
     *
     * @brief[en] Number of attributes
     */
    public var attributesNum: Int64 = 0

    public init(geometryId: Int64, programId: Int64, wireframe: Bool) {
        this.geometryId = geometryId
        this.programId = programId
        this.wireframe = wireframe
        this.vertexLayout = VertexLayout()
        this.attributes = HashMap<String, AttributeCache>()
    }

    public init() {
        this.geometryId = -1
        this.programId = -1
        this.wireframe = false
        this.vertexLayout = VertexLayout()
        this.attributes = HashMap<String, AttributeCache>()
    }
}

/**
 * @brief[zh-cn] 属性缓存
 * @explain[zh-cn] 对照 WebGLBindingStates 中的缓存数据，存储几何体属性及其 GPU 数据。
 *
 * @brief[en] Attribute cache
 * @explain[en] Mirrors the cached data in WebGLBindingStates, storing geometry attribute and its GPU data.
 */
public class AttributeCache {
    /**
     * @brief[zh-cn] 关联的几何体属性（BufferAttribute）
     *
     * @brief[en] Associated geometry attribute (BufferAttribute)
     */
    public var attribute: BufferAttribute
    /**
     * @brief[zh-cn] 属性数据（GPU 顶点数据）
     *
     * @brief[en] Attribute data (GPU vertex data)
     */
    public var data: Array<Float32>

    public init(attribute: BufferAttribute, data: Array<Float32>) {
        this.attribute = attribute
        this.data = data
    }

    public init(attribute: BufferAttribute) {
        this.attribute = attribute
        this.data = Array<Float32>(0, { _ => 0.0f32 })
    }
}

/**
 * @brief[zh-cn] bgfx 顶点绑定状态管理
 * @explain[zh-cn] 对照 WebGLBindingStates，管理顶点属性绑定状态。bgfx 使用 VertexLayout 替代 WebGL 的 VAO，通过 bgfx_set_vertex_buffer_cj 设置绑定。
 *
 * @brief[en] bgfx vertex binding states management
 * @explain[en] Mirrors WebGLBindingStates, managing vertex attribute binding states. bgfx uses VertexLayout instead of WebGL VAOs, setting bindings via bgfx_set_vertex_buffer_cj.
 */
public class BgfxBindingStates {
    /**
     * @brief[zh-cn] 最大顶点属性数
     *
     * @brief[en] Maximum number of vertex attributes
     */
    private var maxVertexAttributes: Int64
    /**
     * @brief[zh-cn] 绑定状态缓存：geometryId -> objectId -> programId -> wireframe -> state
     *
     * @brief[en] Binding state cache: geometryId -> objectId -> programId -> wireframe -> state
     */
    private var bindingStates: HashMap<Int64, HashMap<Int64, HashMap<Int64, HashMap<Bool, BindingState>>>>
    /**
     * @brief[zh-cn] 默认状态
     *
     * @brief[en] Default state
     */
    private let defaultState: BindingState
    /**
     * @brief[zh-cn] 当前状态
     *
     * @brief[en] Current state
     */
    private var currentState: BindingState
    /**
     * @brief[zh-cn] 是否强制更新
     *
     * @brief[en] Whether to force update
     */
    private var forceUpdate: Bool

    public init() {
        this.maxVertexAttributes = 16
        this.bindingStates = HashMap<Int64, HashMap<Int64, HashMap<Int64, HashMap<Bool, BindingState>>>>()
        this.defaultState = BindingState()
        this.currentState = defaultState
        this.forceUpdate = true
    }

    /**
     * @brief[zh-cn] 设置顶点绑定
     * @explain[zh-cn] 对照 WebGLBindingStates.setup()
     * @param[zh-cn] geometryId 几何体 ID
     * objectId 对象 ID
     * programId 程序 ID
     * wireframe 是否线框模式
     * @return[zh-cn] 绑定状态
     *
     * @brief[en] Set up vertex binding
     * @explain[en] Mirrors WebGLBindingStates.setup()
     * @param[en] geometryId Geometry ID
     * objectId Object ID
     * programId Program ID
     * wireframe Whether wireframe mode
     * @return[en] Binding state
     */
    public func setup(geometryId: Int64, objectId: Int64, programId: Int64, wireframe: Bool): BindingState {
        let state = getBindingState(geometryId, objectId, programId, wireframe)
        if (!refEq(currentState, state)) {
            currentState = state
        }
        return state
    }

    /**
     * @brief[zh-cn] 获取或创建绑定状态
     * @explain[zh-cn] 对照 WebGLBindingStates.getBindingState()
     * @param[zh-cn] geometryId 几何体 ID
     * objectId 对象 ID
     * programId 程序 ID
     * wireframe 是否线框模式
     * @return[zh-cn] 绑定状态
     *
     * @brief[en] Get or create binding state
     * @explain[en] Mirrors WebGLBindingStates.getBindingState()
     * @param[en] geometryId Geometry ID
     * objectId Object ID
     * programId Program ID
     * wireframe Whether wireframe mode
     * @return[en] Binding state
     */
    private func getBindingState(geometryId: Int64, objectId: Int64, programId: Int64, wireframe: Bool): BindingState {
        // 获取或创建 objectMap
        var objectMap: HashMap<Int64, HashMap<Int64, HashMap<Bool, BindingState>>> = 
            match (bindingStates.get(geometryId)) {
                case Some(m) => m
                case None =>
                    let m = HashMap<Int64, HashMap<Int64, HashMap<Bool, BindingState>>>()
                    bindingStates.add(geometryId, m)
                    m
            }

        // 获取或创建 programMap
        var programMap: HashMap<Int64, HashMap<Bool, BindingState>> = 
            match (objectMap.get(objectId)) {
                case Some(m) => m
                case None =>
                    let m = HashMap<Int64, HashMap<Bool, BindingState>>()
                    objectMap.add(objectId, m)
                    m
            }

        // 获取或创建 stateMap
        var stateMap: HashMap<Bool, BindingState> = 
            match (programMap.get(programId)) {
                case Some(m) => m
                case None =>
                    let m = HashMap<Bool, BindingState>()
                    programMap.add(programId, m)
                    m
            }

        // 获取或创建 state
        let state: BindingState = 
            match (stateMap.get(wireframe)) {
                case Some(s) => s
                case None =>
                    let s = BindingState(geometryId, programId, wireframe)
                    stateMap.add(wireframe, s)
                    s
            }
        return state
    }

    /**
     * @brief[zh-cn] 释放几何体的绑定状态
     * @explain[zh-cn] 对照 WebGLBindingStates.releaseStatesOfGeometry()
     * @param[zh-cn] geometryId 几何体 ID
     *
     * @brief[en] Release binding states of a geometry
     * @explain[en] Mirrors WebGLBindingStates.releaseStatesOfGeometry()
     * @param[en] geometryId Geometry ID
     */
    public func releaseStatesOfGeometry(geometryId: Int64): Unit {
        bindingStates.remove(geometryId)
    }

    /**
     * @brief[zh-cn] 释放程序的绑定状态
     * @explain[zh-cn] 对照 WebGLBindingStates.releaseStatesOfProgram()
     * @param[zh-cn] programId 程序 ID
     *
     * @brief[en] Release binding states of a program
     * @explain[en] Mirrors WebGLBindingStates.releaseStatesOfProgram()
     * @param[en] programId Program ID
     */
    public func releaseStatesOfProgram(programId: Int64): Unit {
        for ((_, objectMap) in bindingStates) {
            for ((_, programMap) in objectMap) {
                programMap.remove(programId)
            }
        }
    }

    /**
     * @brief[zh-cn] 重置绑定状态
     * @explain[zh-cn] 对照 WebGLBindingStates.reset()
     *
     * @brief[en] Reset binding states
     * @explain[en] Mirrors WebGLBindingStates.reset()
     */
    public func reset(): Unit {
        forceUpdate = true
        currentState = defaultState
    }

    /**
     * @brief[zh-cn] 释放所有绑定状态
     * @explain[zh-cn] 对照 WebGLBindingStates.dispose()
     *
     * @brief[en] Dispose all binding states
     * @explain[en] Mirrors WebGLBindingStates.dispose()
     */
    public func dispose(): Unit {
        bindingStates = HashMap<Int64, HashMap<Int64, HashMap<Int64, HashMap<Bool, BindingState>>>>()
        reset()
    }
}
