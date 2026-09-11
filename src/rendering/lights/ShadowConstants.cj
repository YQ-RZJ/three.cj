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
 * @file[zh-cn] 阴影常量
 * @brief[zh-cn] 阴影贴图相关常量定义（跨包共享，避免循环依赖）
 * @explain[zh-cn] 
 * 对照源码: 16-shadowmaps/shadowmaps.cpp 的 LightType/DepthImpl/PackDepth/SmImpl/SmType 枚举，
 * 以及 three.js/src/constants.js 的 BasicShadowMap/PCFShadowMap/PCFSoftShadowMap/VSMShadowMap。
 * 本文件单独放在 three.rendering.lights 包，使 lights 与 renderers.bgfx 都能 import，
 * 避免 BgfxShadowMap ↔ lights 的循环依赖。
 *
 * @file[en] Shadow Constants
 * @brief[en] Shadow map related constant definitions (shared across packages to avoid circular dependencies)
 * @explain[en] 
 * Corresponds to: 16-shadowmaps/shadowmaps.cpp LightType/DepthImpl/PackDepth/SmImpl/SmType enums,
 * and three.js/src/constants.js BasicShadowMap/PCFShadowMap/PCFSoftShadowMap/VSMShadowMap.
 * Placed in three.rendering.lights package so both lights and renderers.bgfx can import it,
 * avoiding circular dependency between BgfxShadowMap and lights.
 */
package three.rendering.lights

/**
 * @brief[zh-cn] 阴影贴图实现类型 (SmImpl)
 *
 * @brief[en] Shadow map implementation type (SmImpl)
 */
public let BASIC_SHADOW_MAP: Int64 = 0      // SmImpl::Hard
/**
 * @brief[zh-cn] PCF 阴影贴图
 *
 * @brief[en] PCF shadow map
 */
public let PCF_SHADOW_MAP: Int64 = 1        // SmImpl::PCF
/**
 * @brief[zh-cn] PCF 柔和阴影贴图（已废弃，统一降级为 PCF）
 *
 * @brief[en] PCF soft shadow map (deprecated, falls back to PCF)
 */
public let PCF_SOFT_SHADOW_MAP: Int64 = 2   // 已废弃，统一降级为 PCF
/**
 * @brief[zh-cn] VSM 阴影贴图
 *
 * @brief[en] VSM shadow map
 */
public let VSM_SHADOW_MAP: Int64 = 3        // SmImpl::VSM
/**
 * @brief[zh-cn] PCSS 阴影贴图（16-shadowmaps 独有）
 *
 * @brief[en] PCSS shadow map (16-shadowmaps exclusive)
 */
public let PCSS_SHADOW_MAP: Int64 = 4       // SmImpl::PCSS (16-shadowmaps 独有)
/**
 * @brief[zh-cn] ESM 阴影贴图（16-shadowmaps 独有）
 *
 * @brief[en] ESM shadow map (16-shadowmaps exclusive)
 */
public let ESM_SHADOW_MAP: Int64 = 5        // SmImpl::ESM (16-shadowmaps 独有)

/**
 * @brief[zh-cn] 阴影贴图分布类型 (SmType)
 * @explain[zh-cn] 
 * 对照 16-shadowmaps: SmType enum (Single/Omni/Cascade)。
 *
 * @brief[en] Shadow map distribution type (SmType)
 * @explain[en] 
 * Corresponds to 16-shadowmaps: SmType enum (Single/Omni/Cascade).
 */
public let SM_TYPE_SINGLE: Int64 = 0    // 单张贴图（方向光/聚光默认）
/**
 * @brief[zh-cn] 立方体贴图分布（点光源）或 tetrahedron 4 面
 *
 * @brief[en] Cube map distribution (point light) or tetrahedron 4 faces
 */
public let SM_TYPE_OMNI: Int64 = 1      // 立方体贴图（点光源）或 tetrahedron 4 面
/**
 * @brief[zh-cn] CSM 级联（4 级 atlas，方向光远距场景）
 *
 * @brief[en] CSM cascade (4-level atlas, directional light far scenes)
 */
public let SM_TYPE_CASCADE: Int64 = 2   // CSM 级联（4 级 atlas，方向光远距场景）

/**
 * @brief[zh-cn] 深度计算方式 (DepthImpl)
 * @explain[zh-cn] 
 * 对照 16-shadowmaps: DepthImpl enum (InvZ/Linear)。
 *
 * @brief[en] Depth calculation method (DepthImpl)
 * @explain[en] 
 * Corresponds to 16-shadowmaps: DepthImpl enum (InvZ/Linear).
 */
public let DEPTH_IMPL_INVZ: Int64 = 0   // 透视投影 Z 倒数
/**
 * @brief[zh-cn] 线性深度（光空间距离）
 *
 * @brief[en] Linear depth (light space distance)
 */
public let DEPTH_IMPL_LINEAR: Int64 = 1 // 线性深度（光空间距离）

/**
 * @brief[zh-cn] 深度打包方式 (PackDepth)
 * @explain[zh-cn] 
 * 对照 16-shadowmaps: PackDepth enum (RGBA/VSM)。
 *
 * @brief[en] Depth packing method (PackDepth)
 * @explain[en] 
 * Corresponds to 16-shadowmaps: PackDepth enum (RGBA/VSM).
 */
public let PACK_DEPTH_RGBA: Int64 = 0   // 24bit depth → RGBA8
/**
 * @brief[zh-cn] VSM 深度打包（depth + depth² → 2× half float）
 *
 * @brief[en] VSM depth packing (depth + depth² → 2× half float)
 */
public let PACK_DEPTH_VSM: Int64 = 1    // depth + depth² → 2× half float

/**
 * @brief[zh-cn] CSM 级联数量常量
 * @explain[zh-cn] 
 * 对照 16-shadowmaps: CSM_CASCADE_COUNT = 4。
 *
 * @brief[en] CSM cascade count constant
 * @explain[en] 
 * Corresponds to 16-shadowmaps: CSM_CASCADE_COUNT = 4.
 */
public let CSM_CASCADE_COUNT: Int64 = 4
