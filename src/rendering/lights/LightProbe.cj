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
 * @file[zh-cn] 光照探针
 * @brief[zh-cn] 光照探针，用球面调和描述场景光照环境的光源
 * @explain[zh-cn] 
 * 对应 Three.js lights/LightProbe.js。常用于 Image-Based Lighting：
 * 从 HDR 环境贴图烘焙 SH 系数后作为光源参与渲染。
 *
 * @file[en] Light Probe
 * @brief[en] Light probe using spherical harmonics to describe scene lighting environment
 * @explain[en] 
 * Corresponds to Three.js lights/LightProbe.js. Commonly used for Image-Based Lighting:
 * bake SH coefficients from HDR environment maps and use as a light source in rendering.
 */
package three.rendering.lights

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

import three.core.math.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import std.collection.*

/**
 * @brief[zh-cn] 光照探针，用球面调和描述场景光照环境的光源
 * @explain[zh-cn] 
 * 常用于 Image-Based Lighting：从 HDR 环境贴图烘焙 SH 系数后作为光源参与渲染。
 *
 * @brief[en] Light probe using spherical harmonics to describe scene lighting environment
 * @explain[en] 
 * Commonly used for Image-Based Lighting: bake SH coefficients from HDR
 * environment maps and use as a light source in rendering.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Light]
public class LightProbe <: Light {

    /**
     * @brief[zh-cn] 球面调和系数，描述场景光照环境
     *
     * @brief[en] Spherical harmonics coefficients describing scene lighting
     */
    @JsonIgnore
    public var sh: SphericalHarmonics3

    /**
     * @brief[zh-cn] 构造一个新的光照探针
     * @param[zh-cn] sh 球面调和系数，默认空 SH3
     * intensity 光源强度，默认 1
     *
     * @brief[en] Construct a new light probe
     * @param[en] sh Spherical harmonics coefficients, default empty SH3
     * intensity Light intensity, default 1
     */
    public init(sh!: SphericalHarmonics3 = SphericalHarmonics3(), intensity!: Float64 = 1.0) {
        super(color: Color(0xffffff), intensity: intensity)
        this.sh = sh
    }

    /**
     * @brief[zh-cn] 复制另一个光照探针实例的值到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Copy values from another light probe instance
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] Self reference
     */
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case lp: LightProbe =>
                this.sh.copy(lp.sh)
            case _ => ()
        }
        return this
    }
}
