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
 * @file[zh-cn] bgfx 光照管理
 * @brief[zh-cn] 替代 WebGLLights，收集和设置光照 uniform 数据
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLLights.js 及 16-shadowmaps/shadowmaps.cpp。多光源 uniform 策略：方向光、点光源、聚光源、半球光等均使用数组化 uniform 传递到着色器。阴影相关 uniform 与 shadowmaps Uniforms 结构对齐。
 *
 * @file[en] bgfx Light Management
 * @brief[en] Replaces WebGLLights, collects and sets light uniform data
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLLights.js and 16-shadowmaps/shadowmaps.cpp. Multi-light uniform strategy: directional, point, spot, hemisphere lights all use array uniforms to pass to shaders. Shadow-related uniforms align with shadowmaps Uniforms structure.
 */
package three.rendering.bgfx

import std.collection.*

/**
 * @brief[zh-cn] 光照 uniform 缓存
 * @explain[zh-cn] 对照 WebGLLights 中的 UniformsCache，按光源类型缓存 uniform 数据
 *
 * @brief[en] Light uniform cache
 * @explain[en] Corresponds to UniformsCache in WebGLLights, caches uniform data by light type
 */
/**
 * @brief[zh-cn] 单光源 uniform 数据
 * @explain[zh-cn] 对照 LightUniformsCache.get 按 lightType 初始化的字段集合
 *
 * @brief[en] Single light uniform data
 * @explain[en] Corresponds to field set initialized by LightUniformsCache.get by lightType
 */
public class LightUniformData {
    /**
     * @brief[zh-cn] 方向
     *
     * @brief[en] Direction
     */
    public var direction: Array<Float32>
    /**
     * @brief[zh-cn] 颜色
     *
     * @brief[en] Color
     */
    public var color: Array<Float32>
    /**
     * @brief[zh-cn] 位置
     *
     * @brief[en] Position
     */
    public var position: Array<Float32>
    /**
     * @brief[zh-cn] 天空颜色
     *
     * @brief[en] Sky color
     */
    public var skyColor: Array<Float32>
    /**
     * @brief[zh-cn] 地面颜色
     *
     * @brief[en] Ground color
     */
    public var groundColor: Array<Float32>
    /**
     * @brief[zh-cn] 半宽
     *
     * @brief[en] Half width
     */
    public var halfWidth: Array<Float32>
    /**
     * @brief[zh-cn] 半高
     *
     * @brief[en] Half height
     */
    public var halfHeight: Array<Float32>
    /**
     * @brief[zh-cn] 距离
     *
     * @brief[en] Distance
     */
    public var distance: Float32
    /**
     * @brief[zh-cn] 锥角余弦
     *
     * @brief[en] Cone cosine
     */
    public var coneCos: Float32
    /**
     * @brief[zh-cn] 半影余弦
     *
     * @brief[en] Penumbra cosine
     */
    public var penumbraCos: Float32
    /**
     * @brief[zh-cn] 衰减
     *
     * @brief[en] Decay
     */
    public var decay: Float32

    public init() {
        this.direction = Array<Float32>(3, { _ => 0.0f32 })
        this.color = Array<Float32>(3, { _ => 0.0f32 })
        this.position = Array<Float32>(3, { _ => 0.0f32 })
        this.skyColor = Array<Float32>(3, { _ => 0.0f32 })
        this.groundColor = Array<Float32>(3, { _ => 0.0f32 })
        this.halfWidth = Array<Float32>(3, { _ => 0.0f32 })
        this.halfHeight = Array<Float32>(3, { _ => 0.0f32 })
        this.distance = 0.0f32
        this.coneCos = 0.0f32
        this.penumbraCos = 0.0f32
        this.decay = 0.0f32
    }
}

/**
 * @brief[zh-cn] 光照 uniform 缓存
 * @explain[zh-cn] 对照 WebGLLights 中的 UniformsCache，按光源 ID 缓存 uniform 数据
 *
 * @brief[en] Light uniform cache
 * @explain[en] Corresponds to UniformsCache in WebGLLights, caches uniform data by light ID
 */
public class LightUniformsCache {
    /**
     * @brief[zh-cn] 光照 uniform 缓存（光源 ID -> uniform 数据）
     *
     * @brief[en] Light uniform cache (light ID -> uniform data)
     */
    private var cache: HashMap<Int64, LightUniformData>

    public init() {
        this.cache = HashMap<Int64, LightUniformData>()
    }

    /**
     * @brief[zh-cn] 获取光照 uniform 数据
     * @explain[zh-cn] 对照 UniformsCache.get()，按光源 ID 查找或创建
     * @param[zh-cn] lightId 光源 ID
     * lightType 光源类型名称
     * @return[zh-cn] 光照 uniform 数据
     *
     * @brief[en] Gets light uniform data
     * @explain[en] Corresponds to UniformsCache.get(), finds or creates by light ID
     * @param[en] lightId Light ID
     * lightType Light type name
     * @return[en] Light uniform data
     */
    public func get(lightId: Int64, lightType: String): LightUniformData {
        match (cache.get(lightId)) {
            case Some(uniforms) => return uniforms
            case None =>
                let uniforms = LightUniformData()
                // 根据光源类型初始化 uniform 数据
                if (lightType == "DirectionalLight") {
                    uniforms.direction = Array<Float32>(3, { _ => 0.0f32 })
                    uniforms.color = Array<Float32>(3, { _ => 0.0f32 })
                } else if (lightType == "SpotLight") {
                    uniforms.position = Array<Float32>(3, { _ => 0.0f32 })
                    uniforms.direction = Array<Float32>(3, { _ => 0.0f32 })
                    uniforms.color = Array<Float32>(3, { _ => 0.0f32 })
                    uniforms.distance = 0.0f32
                    uniforms.coneCos = 0.0f32
                    uniforms.penumbraCos = 0.0f32
                    uniforms.decay = 0.0f32
                } else if (lightType == "PointLight") {
                    uniforms.position = Array<Float32>(3, { _ => 0.0f32 })
                    uniforms.color = Array<Float32>(3, { _ => 0.0f32 })
                    uniforms.distance = 0.0f32
                    uniforms.decay = 0.0f32
                } else if (lightType == "HemisphereLight") {
                    uniforms.direction = Array<Float32>(3, { _ => 0.0f32 })
                    uniforms.skyColor = Array<Float32>(3, { _ => 0.0f32 })
                    uniforms.groundColor = Array<Float32>(3, { _ => 0.0f32 })
                } else if (lightType == "RectAreaLight") {
                    uniforms.position = Array<Float32>(3, { _ => 0.0f32 })
                    uniforms.color = Array<Float32>(3, { _ => 0.0f32 })
                    uniforms.halfWidth = Array<Float32>(3, { _ => 0.0f32 })
                    uniforms.halfHeight = Array<Float32>(3, { _ => 0.0f32 })
                }
                cache.add(lightId, uniforms)
                return uniforms
        }
    }

    /**
     * @brief[zh-cn] 释放缓存
     *
     * @brief[en] Disposes cache
     */
    public func dispose(): Unit {
        cache = HashMap<Int64, LightUniformData>()
    }
}

/**
 * @brief[zh-cn] 多光源 uniform 容器
 * @explain[zh-cn] 参考 16-shadowmaps: Uniforms 结构。每种光源类型用数组化 uniform，最多支持 MAX_LIGHTS 个同类型光源。阴影相关 uniform 与 16-shadowmaps Uniforms 结构对齐。
 *
 * @brief[en] Multi-light uniform container
 * @explain[en] References 16-shadowmaps: Uniforms structure. Each light type uses array uniforms, supporting up to MAX_LIGHTS of the same type. Shadow-related uniforms align with 16-shadowmaps Uniforms structure.
 */
public class LightUniformContainer {
    /**
     * @brief[zh-cn] 方向光最大数量
     *
     * @brief[en] Max directional lights
     */
    public static let MAX_DIR_LIGHTS: Int64 = 4
    /**
     * @brief[zh-cn] 点光源最大数量
     *
     * @brief[en] Max point lights
     */
    public static let MAX_POINT_LIGHTS: Int64 = 4
    /**
     * @brief[zh-cn] 聚光源最大数量
     *
     * @brief[en] Max spot lights
     */
    public static let MAX_SPOT_LIGHTS: Int64 = 4
    /**
     * @brief[zh-cn] 半球光最大数量
     *
     * @brief[en] Max hemisphere lights
     */
    public static let MAX_HEMI_LIGHTS: Int64 = 4
    /**
     * @brief[zh-cn] 方向光阴影最大数量
     *
     * @brief[en] Max directional shadow lights
     */
    public static let MAX_DIR_SHADOW_LIGHTS: Int64 = 4
    /**
     * @brief[zh-cn] 聚光灯阴影最大数量
     *
     * @brief[en] Max spot shadow lights
     */
    public static let MAX_SPOT_SHADOW_LIGHTS: Int64 = 4
    /**
     * @brief[zh-cn] 点光源阴影最大数量
     *
     * @brief[en] Max point shadow lights
     */
    public static let MAX_POINT_SHADOW_LIGHTS: Int64 = 4

    /**
     * @brief[zh-cn] 方向光方向数组
     *
     * @brief[en] Directional light directions array
     */
    public var dirLightDirections: Array<Float32>
    /**
     * @brief[zh-cn] 方向光颜色数组
     *
     * @brief[en] Directional light colors array
     */
    public var dirLightColors: Array<Float32>
    /**
     * @brief[zh-cn] 当前方向光数量
     *
     * @brief[en] Current directional light count
     */
    public var numDirLights: Int64 = 0

    /**
     * @brief[zh-cn] 点光源位置数组
     *
     * @brief[en] Point light positions array
     */
    public var pointLightPositions: Array<Float32>
    /**
     * @brief[zh-cn] 点光源颜色数组
     *
     * @brief[en] Point light colors array
     */
    public var pointLightColors: Array<Float32>
    /**
     * @brief[zh-cn] 点光源参数数组
     *
     * @brief[en] Point light params array
     */
    public var pointLightParams: Array<Float32>
    /**
     * @brief[zh-cn] 当前点光源数量
     *
     * @brief[en] Current point light count
     */
    public var numPointLights: Int64 = 0

    /**
     * @brief[zh-cn] 聚光源位置数组
     *
     * @brief[en] Spot light positions array
     */
    public var spotLightPositions: Array<Float32>
    /**
     * @brief[zh-cn] 聚光源颜色数组
     *
     * @brief[en] Spot light colors array
     */
    public var spotLightColors: Array<Float32>
    /**
     * @brief[zh-cn] 聚光源方向数组
     *
     * @brief[en] Spot light directions array
     */
    public var spotLightDirections: Array<Float32>
    /**
     * @brief[zh-cn] 聚光源参数数组
     *
     * @brief[en] Spot light params array
     */
    public var spotLightParams: Array<Float32>
    /**
     * @brief[zh-cn] 当前聚光源数量
     *
     * @brief[en] Current spot light count
     */
    public var numSpotLights: Int64 = 0

    /**
     * @brief[zh-cn] 半球光天空颜色数组
     *
     * @brief[en] Hemisphere light sky colors array
     */
    public var hemiLightSkyColors: Array<Float32>
    /**
     * @brief[zh-cn] 半球光地面颜色数组
     *
     * @brief[en] Hemisphere light ground colors array
     */
    public var hemiLightGroundColors: Array<Float32>
    /**
     * @brief[zh-cn] 半球光方向数组
     *
     * @brief[en] Hemisphere light directions array
     */
    public var hemiLightDirections: Array<Float32>
    /**
     * @brief[zh-cn] 当前半球光数量
     *
     * @brief[en] Current hemisphere light count
     */
    public var numHemiLights: Int64 = 0

    /**
     * @brief[zh-cn] 环境光颜色
     *
     * @brief[en] Ambient light color
     */
    public var ambientColor: Array<Float32>

    /**
     * @brief[zh-cn] 方向光阴影数量
     *
     * @brief[en] Directional shadow light count
     */
    public var numDirShadowLights: Int64 = 0
    /**
     * @brief[zh-cn] 聚光灯阴影数量
     *
     * @brief[en] Spot shadow light count
     */
    public var numSpotShadowLights: Int64 = 0
    /**
     * @brief[zh-cn] 点光源阴影数量
     *
     * @brief[en] Point shadow light count
     */
    public var numPointShadowLights: Int64 = 0

    public init() {
        let maxDir = Int64(LightUniformContainer.MAX_DIR_LIGHTS)
        let maxPt = Int64(LightUniformContainer.MAX_POINT_LIGHTS)
        let maxSp = Int64(LightUniformContainer.MAX_SPOT_LIGHTS)
        let maxHm = Int64(LightUniformContainer.MAX_HEMI_LIGHTS)
        this.dirLightDirections = Array<Float32>(maxDir * 4, { _ => 0.0f32 })
        this.dirLightColors = Array<Float32>(maxDir * 4, { _ => 0.0f32 })
        this.pointLightPositions = Array<Float32>(maxPt * 4, { _ => 0.0f32 })
        this.pointLightColors = Array<Float32>(maxPt * 4, { _ => 0.0f32 })
        this.pointLightParams = Array<Float32>(maxPt * 4, { _ => 0.0f32 })
        this.spotLightPositions = Array<Float32>(maxSp * 4, { _ => 0.0f32 })
        this.spotLightColors = Array<Float32>(maxSp * 4, { _ => 0.0f32 })
        this.spotLightDirections = Array<Float32>(maxSp * 4, { _ => 0.0f32 })
        this.spotLightParams = Array<Float32>(maxSp * 4, { _ => 0.0f32 })
        this.hemiLightSkyColors = Array<Float32>(maxHm * 4, { _ => 0.0f32 })
        this.hemiLightGroundColors = Array<Float32>(maxHm * 4, { _ => 0.0f32 })
        this.hemiLightDirections = Array<Float32>(maxHm * 4, { _ => 0.0f32 })
        this.ambientColor = Array<Float32>(4, { _ => 0.0f32 })
    }

    /**
     * @brief[zh-cn] 重置所有 uniform 数据
     * @explain[zh-cn] 每帧开始时调用
     *
     * @brief[en] Resets all uniform data
     * @explain[en] Called at the start of each frame
     */
    public func reset(): Unit {
        for (i in 0..this.dirLightDirections.size) { this.dirLightDirections[i] = 0.0f32 }
        for (i in 0..this.dirLightColors.size) { this.dirLightColors[i] = 0.0f32 }
        for (i in 0..this.pointLightPositions.size) { this.pointLightPositions[i] = 0.0f32 }
        for (i in 0..this.pointLightColors.size) { this.pointLightColors[i] = 0.0f32 }
        for (i in 0..this.pointLightParams.size) { this.pointLightParams[i] = 0.0f32 }
        for (i in 0..this.spotLightPositions.size) { this.spotLightPositions[i] = 0.0f32 }
        for (i in 0..this.spotLightColors.size) { this.spotLightColors[i] = 0.0f32 }
        for (i in 0..this.spotLightDirections.size) { this.spotLightDirections[i] = 0.0f32 }
        for (i in 0..this.spotLightParams.size) { this.spotLightParams[i] = 0.0f32 }
        for (i in 0..this.hemiLightSkyColors.size) { this.hemiLightSkyColors[i] = 0.0f32 }
        for (i in 0..this.hemiLightGroundColors.size) { this.hemiLightGroundColors[i] = 0.0f32 }
        for (i in 0..this.hemiLightDirections.size) { this.hemiLightDirections[i] = 0.0f32 }
        for (i in 0..this.ambientColor.size) { this.ambientColor[i] = 0.0f32 }
        this.numDirLights = 0
        this.numPointLights = 0
        this.numSpotLights = 0
        this.numHemiLights = 0
        this.numDirShadowLights = 0
        this.numSpotShadowLights = 0
        this.numPointShadowLights = 0
    }

    /**
     * @brief[zh-cn] 写入一个方向光的 uniform 数据
     * @param[zh-cn] index 光源索引
     * dirX 方向 X 分量
     * dirY 方向 Y 分量
     * dirZ 方向 Z 分量
     * colorR 颜色 R 分量
     * colorG 颜色 G 分量
     * colorB 颜色 B 分量
     * intensity 光照强度
     *
     * @brief[en] Writes uniform data for one directional light
     * @param[en] index Light index
     * dirX Direction X component
     * dirY Direction Y component
     * dirZ Direction Z component
     * colorR Color R component
     * colorG Color G component
     * colorB Color B component
     * intensity Light intensity
     */
    public func setDirLight(index: Int64, dirX: Float32, dirY: Float32, dirZ: Float32,
        colorR: Float32, colorG: Float32, colorB: Float32, intensity: Float32): Unit {
        if (index < 0 || index >= LightUniformContainer.MAX_DIR_LIGHTS) { return }
        let base = index * 4
        this.dirLightDirections[base] = dirX
        this.dirLightDirections[base + 1] = dirY
        this.dirLightDirections[base + 2] = dirZ
        this.dirLightDirections[base + 3] = 0.0f32
        this.dirLightColors[base] = colorR
        this.dirLightColors[base + 1] = colorG
        this.dirLightColors[base + 2] = colorB
        this.dirLightColors[base + 3] = intensity
    }

    /**
     * @brief[zh-cn] 写入一个点光源的 uniform 数据
     *
     * @brief[en] Writes uniform data for one point light
     */
    public func setPointLight(index: Int64, posX: Float32, posY: Float32, posZ: Float32, distance: Float32,
        colorR: Float32, colorG: Float32, colorB: Float32, intensity: Float32, decay: Float32): Unit {
        if (index < 0 || index >= LightUniformContainer.MAX_POINT_LIGHTS) { return }
        let base = index * 4
        this.pointLightPositions[base] = posX
        this.pointLightPositions[base + 1] = posY
        this.pointLightPositions[base + 2] = posZ
        this.pointLightPositions[base + 3] = distance
        this.pointLightColors[base] = colorR
        this.pointLightColors[base + 1] = colorG
        this.pointLightColors[base + 2] = colorB
        this.pointLightColors[base + 3] = intensity
        this.pointLightParams[base] = decay
        this.pointLightParams[base + 1] = 0.0f32
        this.pointLightParams[base + 2] = 0.0f32
        this.pointLightParams[base + 3] = 0.0f32
    }

    /**
     * @brief[zh-cn] 写入一个聚光源的 uniform 数据
     *
     * @brief[en] Writes uniform data for one spot light
     */
    public func setSpotLight(index: Int64, posX: Float32, posY: Float32, posZ: Float32, distance: Float32,
        colorR: Float32, colorG: Float32, colorB: Float32, intensity: Float32,
        dirX: Float32, dirY: Float32, dirZ: Float32, angleCos: Float32,
        angle: Float32, penumbra: Float32, decay: Float32): Unit {
        if (index < 0 || index >= LightUniformContainer.MAX_SPOT_LIGHTS) { return }
        let base = index * 4
        this.spotLightPositions[base] = posX
        this.spotLightPositions[base + 1] = posY
        this.spotLightPositions[base + 2] = posZ
        this.spotLightPositions[base + 3] = distance
        this.spotLightColors[base] = colorR
        this.spotLightColors[base + 1] = colorG
        this.spotLightColors[base + 2] = colorB
        this.spotLightColors[base + 3] = intensity
        this.spotLightDirections[base] = dirX
        this.spotLightDirections[base + 1] = dirY
        this.spotLightDirections[base + 2] = dirZ
        this.spotLightDirections[base + 3] = angleCos
        this.spotLightParams[base] = angle
        this.spotLightParams[base + 1] = penumbra
        this.spotLightParams[base + 2] = decay
        this.spotLightParams[base + 3] = 0.0f32
    }

    /**
     * @brief[zh-cn] 写入一个半球光的 uniform 数据
     *
     * @brief[en] Writes uniform data for one hemisphere light
     */
    public func setHemiLight(index: Int64, dirX: Float32, dirY: Float32, dirZ: Float32,
        skyR: Float32, skyG: Float32, skyB: Float32, intensity: Float32,
        grR: Float32, grG: Float32, grB: Float32): Unit {
        if (index < 0 || index >= LightUniformContainer.MAX_HEMI_LIGHTS) { return }
        let base = index * 4
        this.hemiLightDirections[base] = dirX
        this.hemiLightDirections[base + 1] = dirY
        this.hemiLightDirections[base + 2] = dirZ
        this.hemiLightDirections[base + 3] = 0.0f32
        this.hemiLightSkyColors[base] = skyR
        this.hemiLightSkyColors[base + 1] = skyG
        this.hemiLightSkyColors[base + 2] = skyB
        this.hemiLightSkyColors[base + 3] = intensity
        this.hemiLightGroundColors[base] = grR
        this.hemiLightGroundColors[base + 1] = grG
        this.hemiLightGroundColors[base + 2] = grB
        this.hemiLightGroundColors[base + 3] = intensity
    }
}

/**
 * @brief[zh-cn] bgfx 光照管理
 * @explain[zh-cn] 对照 WebGLLights，收集场景中的光源并设置对应的 uniform 数据。多光源 uniform 通过 LightUniformContainer 统一管理。
 *
 * @brief[en] bgfx light management
 * @explain[en] Corresponds to WebGLLights, collects lights in the scene and sets corresponding uniform data. Multi-light uniforms are managed via LightUniformContainer.
 */
public class BgfxLights {
    /**
     * @brief[zh-cn] 光照 uniform 缓存
     *
     * @brief[en] Light uniform cache
     */
    private var cache: LightUniformsCache
    /**
     * @brief[zh-cn] 多光源 uniform 容器
     *
     * @brief[en] Multi-light uniform container
     */
    private var uniformContainer: LightUniformContainer
    /**
     * @brief[zh-cn] 渲染统计
     *
     * @brief[en] Render statistics
     */
    private var info: BgfxInfo

    public init(info!: BgfxInfo = BgfxInfo()) {
        this.cache = LightUniformsCache()
        this.uniformContainer = LightUniformContainer()
        this.info = info
    }

    /**
     * @brief[zh-cn] 获取光照 uniform 缓存
     * @return[zh-cn] 光照 uniform 缓存
     *
     * @brief[en] Gets light uniform cache
     * @return[en] Light uniform cache
     */
    public func getCache(): LightUniformsCache {
        return cache
    }

    /**
     * @brief[zh-cn] 获取多光源 uniform 容器
     * @return[zh-cn] 多光源 uniform 容器
     *
     * @brief[en] Gets multi-light uniform container
     * @return[en] Multi-light uniform container
     */
    public func getUniformContainer(): LightUniformContainer {
        return uniformContainer
    }

    /**
     * @brief[zh-cn] 重置 uniform 容器
     * @explain[zh-cn] 每帧开始时调用
     *
     * @brief[en] Resets uniform container
     * @explain[en] Called at the start of each frame
     */
    public func reset(): Unit {
        uniformContainer.reset()
    }

    /**
     * @brief[zh-cn] 释放所有光照缓存
     *
     * @brief[en] Disposes all light caches
     */
    public func dispose(): Unit {
        cache.dispose()
    }
}
