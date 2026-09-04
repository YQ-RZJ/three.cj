/**
 * @file[zh-cn] bgfx 材质管理
 * @brief[zh-cn] 替代 WebGLMaterials，跟踪材质编译和更新状态
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLMaterials.js。WebGLMaterials 负责刷新材质的 uniform 数据。
 *
 * @file[en] bgfx Material Management
 * @brief[en] Replaces WebGLMaterials, tracks material compilation and update state
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLMaterials.js. WebGLMaterials is responsible for refreshing material uniform data.
 */
package three.rendering.bgfx

import std.collection.*

/**
 * @brief[zh-cn] 材质状态信息
 * @explain[zh-cn] 存储材质的编译和更新状态，包括程序 ID、uniform 更新标记和帧号
 *
 * @brief[en] Material state info
 * @explain[en] Stores material compilation and update state, including program ID, uniform update flags, and frame number
 */
public class MaterialState {
    /**
     * @brief[zh-cn] 材质 ID
     *
     * @brief[en] Material ID
     */
    public var materialId: Int64
    /**
     * @brief[zh-cn] 上次编译的程序 ID
     *
     * @brief[en] Last compiled program ID
     */
    public var programId: Int64 = -1
    /**
     * @brief[zh-cn] 是否需要更新 uniform
     *
     * @brief[en] Whether uniforms need update
     */
    public var uniformsNeedUpdate: Bool = true
    /**
     * @brief[zh-cn] 上次更新的帧号
     *
     * @brief[en] Last update frame number
     */
    public var lastUpdateFrame: Int64 = -1
    /**
     * @brief[zh-cn] fog uniform 是否需要更新
     *
     * @brief[en] Whether fog uniforms need update
     */
    public var fogNeedsUpdate: Bool = true

    public init(materialId: Int64) {
        this.materialId = materialId
    }
}

/**
 * @brief[zh-cn] bgfx 材质管理
 * @explain[zh-cn] 对照 WebGLMaterials，跟踪材质编译和更新状态。管理材质的 uniform 刷新逻辑。
 *
 * @brief[en] bgfx material management
 * @explain[en] Corresponds to WebGLMaterials, tracks material compilation and update state. Manages material uniform refresh logic.
 */
public class BgfxMaterials {
    /**
     * @brief[zh-cn] 材质状态映射
     */
    private var materialStates: HashMap<Int64, MaterialState>
    /**
     * @brief[zh-cn] 渲染统计
     */
    private var info: BgfxInfo

    public init(info!: BgfxInfo = BgfxInfo()) {
        this.materialStates = HashMap<Int64, MaterialState>()
        this.info = info
    }

    /**
     * @brief[zh-cn] 获取或创建材质状态
     * @param[zh-cn] materialId 材质 ID
     * @return[zh-cn] 材质状态
     *
     * @brief[en] Gets or creates material state
     * @param[en] materialId Material ID
     * @return[en] Material state
     */
    public func getMaterialState(materialId: Int64): MaterialState {
        match (materialStates.get(materialId)) {
            case Some(state) => return state
            case None =>
                let state = MaterialState(materialId)
                materialStates.add(materialId, state)
                return state
        }
    }

    /**
     * @brief[zh-cn] 标记材质需要更新
     * @explain[zh-cn] 对照 WebGLMaterials 中的 uniformsNeedUpdate 逻辑
     * @param[zh-cn] materialId 材质 ID
     *
     * @brief[en] Marks material as needing update
     * @explain[en] Corresponds to uniformsNeedUpdate logic in WebGLMaterials
     * @param[en] materialId Material ID
     */
    public func markNeedsUpdate(materialId: Int64): Unit {
        match (materialStates.get(materialId)) {
            case Some(state) =>
                state.uniformsNeedUpdate = true
                state.fogNeedsUpdate = true
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 检查材质是否需要更新
     * @param[zh-cn] materialId 材质 ID
     * @return[zh-cn] 是否需要更新
     *
     * @brief[en] Checks if material needs update
     * @param[en] materialId Material ID
     * @return[en] Whether update is needed
     */
    public func needsUpdate(materialId: Int64): Bool {
        match (materialStates.get(materialId)) {
            case Some(state) => return state.uniformsNeedUpdate
            case None => return true
        }
    }

    /**
     * @brief[zh-cn] 标记材质已更新
     * @param[zh-cn] materialId 材质 ID
     *
     * @brief[en] Marks material as updated
     * @param[en] materialId Material ID
     */
    public func markUpdated(materialId: Int64): Unit {
        match (materialStates.get(materialId)) {
            case Some(state) =>
                state.uniformsNeedUpdate = false
                state.lastUpdateFrame = info.render.frame
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 释放材质状态
     * @param[zh-cn] materialId 材质 ID
     *
     * @brief[en] Disposes material state
     * @param[en] materialId Material ID
     */
    public func dispose(materialId: Int64): Unit {
        materialStates.remove(materialId)
    }

    /**
     * @brief[zh-cn] 释放所有材质状态
     *
     * @brief[en] Disposes all material states
     */
    public func disposeAll(): Unit {
        materialStates = HashMap<Int64, MaterialState>()
    }
}
