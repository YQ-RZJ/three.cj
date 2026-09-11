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
 * @file[zh-cn] 聚光源阴影配置
 * @brief[zh-cn] 专用于SpotLight的阴影配置，根据光源角度动态调整相机视锥
 * @explain[zh-cn] 
 * 对应 Three.js lights/SpotLightShadow.js。内部相机为 PerspectiveCamera（透视投影），
 * 默认 fov=50、aspect=1、near=0.5、far=500。每次更新时根据光源角度和 focus 动态调整相机视锥，
 * 确保阴影贴图仅覆盖聚光锥体有效区域。
 *
 * @file[en] Spot Light Shadow
 * @brief[en] Shadow configuration specific to SpotLight, dynamically adjusts camera frustum based on light angle
 * @explain[en] 
 * Corresponds to Three.js lights/SpotLightShadow.js. The internal camera is a PerspectiveCamera,
 * default fov=50, aspect=1, near=0.5, far=500. Each update dynamically adjusts the camera frustum
 * based on the light angle and focus, ensuring the shadow map only covers the spotlight cone's effective area.
 */
package three.rendering.lights

import three.rendering.cameras.*
import three.core.math.*
import three.utils.constants.*
import three.utils.log.Logger
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 专用于SpotLight的阴影配置，根据光源角度动态调整相机视锥
 * @explain[zh-cn] 
 * 对应 Three.js lights/SpotLightShadow.js。内部相机为 PerspectiveCamera（透视投影），
 * 默认 fov=50、aspect=1、near=0.5、far=500。每次更新时根据光源角度和 focus 动态调整相机视锥，
 * 确保阴影贴图仅覆盖聚光锥体有效区域。
 *
 * @brief[en] Shadow configuration specific to SpotLight, dynamically adjusts camera frustum based on light angle
 * @explain[en] 
 * Corresponds to Three.js lights/SpotLightShadow.js. The internal camera is a PerspectiveCamera,
 * default fov=50, aspect=1, near=0.5, far=500. Each update dynamically adjusts the camera frustum
 * based on the light angle and focus, ensuring the shadow map only covers the spotlight cone's effective area.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = LightShadow]
public class SpotLightShadow <: LightShadow {
    /**
     * @brief[zh-cn] 聚焦系数，相机视场角=光源角度×focus×RAD2DEG，值域[0,1]，默认1
     *
     * @brief[en] Focus factor, camera FOV=light angle×focus×RAD2DEG, range [0,1], default 1
     */
    public var focus: Float64

    /**
     * @brief[zh-cn] 纹理宽高比修正因子，最终aspect=(mapSize.width/mapSize.height)×this.aspect，默认1
     *
     * @brief[en] Texture aspect ratio correction factor, final aspect=(mapSize.width/mapSize.height)×this.aspect, default 1
     */
    public var aspect: Float64

    /**
     * @brief[zh-cn] 构造一个新的聚光源阴影配置
     *
     * @brief[en] Construct a new spot light shadow configuration
     */
    public init() {
        super(PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.5, far: 500.0))
        this.focus = 1.0
        this.aspect = 1.0
    }

    /**
     * @brief[zh-cn] 更新阴影相机的投影矩阵及阴影矩阵
     * @explain[zh-cn] 
     * 与 JS 侧一致：根据光源 angle/focus/distance 动态更新相机 fov/aspect/far。
     * 仅当参数变化时触发 updateProjectionMatrix，避免每帧不必要的计算。
     * @param[zh-cn] light 正在渲染阴影的SpotLight实例
     *
     * @brief[en] Update the shadow camera projection matrix and shadow matrix
     * @explain[en] 
     * Consistent with JS side: dynamically updates camera fov/aspect/far based on light angle/focus/distance.
     * Only triggers updateProjectionMatrix when parameters change, avoiding unnecessary per-frame computation.
     * @param[en] light The SpotLight instance for which the shadow is being rendered
     */
    public func updateMatrices(light: Light): Unit {
        Logger.debug(["SpotLightShadow", "updateMatrices ENTER"])
        let camera = this.camera
        match (camera) {
            case pc: PerspectiveCamera =>
                Logger.debug(["SpotLightShadow", "pc.fov=${pc.fov} pc.aspect=${pc.aspect} pc.far=${pc.far}"])
                
                let angle = match (light) {
                    case sl: SpotLight => sl.angle
                    case _ => 1.0
                }
                let fov = (180.0 / Float64(PI)) * 2.0 * angle * this.focus
                
                let asp = (this.mapSize.x / this.mapSize.y) * this.aspect
                
                let far = match (light) {
                    case sl: SpotLight => if (sl.distance != 0.0) { sl.distance } else { pc.far }
                    case _ => pc.far
                }
                Logger.debug(["SpotLightShadow", "fov=${fov} asp=${asp} far=${far} focus=${this.focus}"])
                // 仅当参数变化时触发 updateProjectionMatrix（避免每帧不必要计算）
                if (fov != pc.fov || asp != pc.aspect || far != pc.far) {
                    Logger.debug(["SpotLightShadow", "params changed, updating projection"])
                    pc.fov = fov
                    pc.aspect = asp
                    pc.far = far
                    Logger.debug(["SpotLightShadow", "BEFORE updateProjectionMatrix"])
                    pc.updateProjectionMatrix()
                    Logger.debug(["SpotLightShadow", "AFTER updateProjectionMatrix"])
                } else {
                    Logger.debug(["SpotLightShadow", "params unchanged, skip"])
                }
            case _ => ()
        }
        Logger.debug(["SpotLightShadow", "BEFORE super.updateMatrices"])
        // 调用父类 updateMatrices（设置相机位置、目标、计算 shadowMatrix）
        super.updateMatrices(light)
        Logger.debug(["SpotLightShadow", "AFTER super.updateMatrices"])
    }

    /**
     * @brief[zh-cn] 将给定SpotLightShadow实例的值复制到本实例
     * @param[zh-cn] source 源光源阴影实例
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the values from the given SpotLightShadow instance to this instance
     * @param[en] source Source light shadow instance
     * @return[en] This instance
     */
    public func copy(source: LightShadow): LightShadow {
        super.copy(source)
        match (source) {
            case sls: SpotLightShadow =>
                this.focus = sls.focus
                this.aspect = sls.aspect
            case _ => ()
        }
        return this
    }
}
