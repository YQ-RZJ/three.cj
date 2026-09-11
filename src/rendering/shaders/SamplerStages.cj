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
 * @file[zh-cn] SamplerStages  全局 sampler stage 分配器
 * @brief[zh-cn] 全局 sampler stage 分配器（动态分配 shadow 数组段 + 固定段错开）
 *
 * @file[en] SamplerStages  Global sampler stage allocator
 * @brief[en] Global sampler stage allocator (dynamic shadow array segment allocation + fixed segment offset)
 * ★设计动机（修复"点光源矩形阴影 + 方向光阴影消失" bug 的根因）：
 * bgfx 的纹理 stage（bgfx_set_texture_cj 第 1 参）是 per-draw 的瞬时绑定状态，
 * 但在同一 draw 内 stage 必须互不重叠——后绑会覆盖先绑。
 * 原代码把材质 map 绑到 stage 0，与 directionalShadowMap[0] 冲突 → 方向光阴影被覆盖消失；
 * 其他材质 stage 挤占 point cube sampler stage → 点光源采样错乱成矩形。
 * 更进一步：复杂场景下多盏方向光/点光源各自的 shadowMap 占用动态长度的数组 stage 段，
 * 材质/envMap/dfgLUT/shadow 各类 sampler 的 stage 段必须全局协调，硬编码边界值
 * 会随场景规模增长而错乱。故集中管理 sampler stage 分配，确保互不重叠。
 * ★分配模型（动态 + 固定混合）：
 * 1) shadow 数组段（动态，跟随实际光源数）：
 * bgfx 对裸 `uniform samplerCubeShadow pointShadowMap[N]` 数组按声明顺序
 * 自动累加寄存器：dir 占 0..numDir-1，spot 占 numDir..numDir+numSpot-1，
 * point 占 numDir+numSpot..numDir+numSpot+numPoint-1。
 * 后端绑定必须用同样的动态 base（spotStageBase=numDir，pointStageBase=numDir+numSpot），
 * 否则与着色器 reg 错位 → 采到空纹理 → 阴影/高光消失。
 * 分配器仅提供 MAX_*_SHADOW 上限（约束数组容量）和动态段终止 stage 计算。
 * 2) 固定段（常量，错开动态 shadow 段）：
 * D3D11 的 sampler 槽位上限 = 16（s0..s15，D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT），
 * HLSL 中 SAMPLER2D(name, reg) 的 reg 编译期硬编码到 register(sN)，
 * N 必须 < 16，否则 X4509（maximum sampler register index exceeded）。
 * 故动态 shadow 段最多占用 0..7（≤8 个阴影光源），固定段从 8 起分配：
 * 材质段 8..13：map/roughnessMap/metalnessMap/normalMap/aoMap/emissiveMap
 * envMap=14、dfgLUT=15
 * （注意：旧版把固定段放在 16..23，超过 D3D11 上限，
 * standard 材质引用 dfgLUT(23) 时编译失败，本版已修正。）
 * 3) shadow blit 专用（shadow 内部 pass，独立 view，不与主 pass 冲突）：stage 0
 * ★约束（来自 BgfxShaderSource.cj 宏定义调研）：
 * 着色器端 SAMPLER2D(name, reg)/SAMPLERCUBE(name, reg) 的 reg 是编译期硬编码到
 * HLSL REGISTER(s/t, reg) 的，不能运行时改。所以：
 * - 固定段 chunk 侧 reg 用占位符 `__STAGE_XXX__`，ShaderLibs 组装时 .replace() 注入；
 * - shadow 数组 sampler 用裸 `uniform samplerCubeShadow name[N]`（无 reg），bgfx 自动累加；
 * - 后端运行时引用本类常量（固定段）或动态算 base（shadow 数组段）。
 * ★扩展规则：
 * 新增固定段 sampler 时，先查本分配器确认段位空闲（≥ STAGE_FIXED_BASE 且 < 16），再添加常量。
 * shadow 数组新增类型时，更新 MAX_*_SHADOW 上限并确保动态段总占用 ≤ STAGE_FIXED_BASE。
 */
package three.rendering.shaders

import three.utils.log.Logger

/**
 * @brief[zh-cn] 全局 sampler stage 分配器
 * @explain[zh-cn] 固定段 sampler（材质/env/dfgLUT）引用本类的 static 常量；
 * shadow 数组段由后端按实际光源数动态算 base（spotStageBase/pointStageBase）。
 * 使用模式：
 * 固定段 cj 侧：`bgfx_set_texture_cj(SamplerStages.STAGE_MAP, sampler, handle, flags)`
 * 固定段着色器侧：`SAMPLER2D(map, __STAGE_MAP__)`，ShaderLibs 组装时 .replace 注入
 * shadow 数组段：动态算 base，`bgfx_set_texture_cj(UInt8(base + i), ...)`，着色器用裸数组声明
 *
 * @brief[en] Global sampler stage allocator
 * @explain[en] Fixed-segment samplers (material/env/dfgLUT) reference this class's static constants;
 * shadow array segments are dynamically computed by the backend based on actual light counts (spotStageBase/pointStageBase).
 * Usage patterns:
 * Fixed segment Cangjie side: `bgfx_set_texture_cj(SamplerStages.STAGE_MAP, sampler, handle, flags)`
 * Fixed segment shader side: `SAMPLER2D(map, __STAGE_MAP__)`, injected via .replace during ShaderLibs assembly
 * Shadow array segment: dynamically computed base, `bgfx_set_texture_cj(UInt8(base + i), ...)`, shader uses bare array declaration
 */
public class SamplerStages {
    // ===== shadow 数组段上限（约束数组容量，动态段总占用 ≤ STAGE_FIXED_BASE）=====
    // 受 D3D11 16 槽位限制，动态段合计 ≤ 8（与 BgfxBackend.maxDirShadows/maxSpotShadows/maxPointShadows 对齐）
    /**
     * @brief[zh-cn] directionalShadowMap 数组上限
     *
     * @brief[en] Maximum directional shadow map array size
     */
    public static let MAX_DIR_SHADOW: Int64 = 4
    /**
     * @brief[zh-cn] spotShadowMap 数组上限
     *
     * @brief[en] Maximum spot shadow map array size
     */
    public static let MAX_SPOT_SHADOW: Int64 = 2
    /**
     * @brief[zh-cn] pointShadowMap 数组上限
     *
     * @brief[en] Maximum point shadow map array size
     */
    public static let MAX_POINT_SHADOW: Int64 = 2

    // 固定段起点 = 动态段最大占用（exclusive bound）
    // dynamic shadow 段最大占 0..(MAX_DIR+MAX_SPOT+MAX_POINT)-1 = 0..7
    /**
     * @brief[zh-cn] 固定段起始 stage 编号，动态 shadow 段最大占用 0..7
     *
     * @brief[en] Fixed segment base stage number; dynamic shadow segment occupies 0..7
     */
    public static let STAGE_FIXED_BASE: UInt8 = 8u8

    // ===== 固定段：材质（8..13）=====
    /**
     * @brief[zh-cn] map 纹理 stage（MeshStandard.map / MeshBasic.map）
     *
     * @brief[en] map texture stage (MeshStandard.map / MeshBasic.map)
     */
    public static let STAGE_MAP: UInt8 = 8u8
    /**
     * @brief[zh-cn] roughnessMap 纹理 stage
     *
     * @brief[en] roughnessMap texture stage
     */
    public static let STAGE_ROUGHNESS_MAP: UInt8 = 9u8
    /**
     * @brief[zh-cn] metalnessMap 纹理 stage
     *
     * @brief[en] metalnessMap texture stage
     */
    public static let STAGE_METALNESS_MAP: UInt8 = 10u8
    /**
     * @brief[zh-cn] normalMap 纹理 stage
     *
     * @brief[en] normalMap texture stage
     */
    public static let STAGE_NORMAL_MAP: UInt8 = 11u8
    /**
     * @brief[zh-cn] aoMap 纹理 stage
     *
     * @brief[en] aoMap texture stage
     */
    public static let STAGE_AO_MAP: UInt8 = 12u8
    /**
     * @brief[zh-cn] emissiveMap 纹理 stage
     *
     * @brief[en] emissiveMap texture stage
     */
    public static let STAGE_EMISSIVE_MAP: UInt8 = 13u8

    // ===== 固定段：非材质（14..15）=====
    /**
     * @brief[zh-cn] 环境贴图 stage（u_envMap, SAMPLERCUBE）
     *
     * @brief[en] Environment map stage (u_envMap, SAMPLERCUBE)
     */
    public static let STAGE_ENV_MAP: UInt8 = 14u8
    /**
     * @brief[zh-cn] DFG LUT 纹理 stage（SAMPLER2D）
     *
     * @brief[en] DFG LUT texture stage (SAMPLER2D)
     */
    public static let STAGE_DFGLUT: UInt8 = 15u8

    // ===== shadow blit 专用（shadow 内部 pass，独立 view，不与主 pass 冲突）=====
    /**
     * @brief[zh-cn] shadow blit sampler stage（shadow blit view 专用）
     *
     * @brief[en] Shadow blit sampler stage (dedicated for shadow blit view)
     */
    public static let STAGE_SHADOW_BLIT: UInt8 = 0u8

    public init() {}

    /**
     * @brief[zh-cn] 计算动态 shadow 段的终止 stage（固定段起点，exclusive）
     * @explain[zh-cn] 后端在绑定完所有 shadow 数组后，可用此值校验动态段未越界到固定段。
     * 实际动态段占用 = numDir + numSpot + numPoint，必须 ≤ STAGE_FIXED_BASE。
     * @param[zh-cn] numDir 实际方向光阴影数
     * numSpot 实际聚光灯阴影数
     * numPoint 实际点光源阴影数
     * @return[zh-cn] 动态段终止 stage（= numDir + numSpot + numPoint）
     *
     * @brief[en] Compute the end stage of the dynamic shadow segment (fixed segment base, exclusive)
     * @explain[en] After binding all shadow arrays, the backend can use this value to verify
     * the dynamic segment does not overflow into the fixed segment.
     * Actual dynamic segment usage = numDir + numSpot + numPoint, must be ≤ STAGE_FIXED_BASE.
     * @param[en] numDir Actual directional light shadow count
     * numSpot Actual spot light shadow count
     * numPoint Actual point light shadow count
     * @return[en] Dynamic segment end stage (= numDir + numSpot + numPoint)
     */
    public static func dynamicShadowEnd(numDir: Int64, numSpot: Int64, numPoint: Int64): UInt8 {
        return UInt8(UInt32(numDir + numSpot + numPoint))
    }

    /**
     * @brief[zh-cn] 着色器 chunk 占位符 → 实际 stage 的替换映射（仅固定段）
     * @explain[zh-cn] ShaderLibs 组装着色器时，对本表逐项 .replace("__STAGE_XXX__", value.toString())。
     * shadow 数组段不用占位符（bgfx 自动按声明顺序累加寄存器）。
     * 固定尺寸数组：占位符映射表是编译期常量（9 项），无动态扩容需求，
     * 用仓颉固定数组而非 ArrayList，避免不必要的堆分配。
     *
     * @brief[en] Shader chunk placeholder to actual stage replacement mapping (fixed segment only)
     * @explain[en] During shader assembly, ShaderLibs iterates this table and calls .replace("__STAGE_XXX__", value.toString()).
     * Shadow array segments do not use placeholders (bgfx auto-increments registers by declaration order).
     * Fixed-size array: the placeholder mapping table is a compile-time constant (9 entries),
     * using Cangjie fixed array instead of ArrayList to avoid unnecessary heap allocation.
     */
    public static func getPlaceholderReplacements(): Array<(String, String)> {
        return [
            ("__STAGE_MAP__", SamplerStages.STAGE_MAP.toString()),
            ("__STAGE_ROUGHNESS_MAP__", SamplerStages.STAGE_ROUGHNESS_MAP.toString()),
            ("__STAGE_METALNESS_MAP__", SamplerStages.STAGE_METALNESS_MAP.toString()),
            ("__STAGE_NORMAL_MAP__", SamplerStages.STAGE_NORMAL_MAP.toString()),
            ("__STAGE_AO_MAP__", SamplerStages.STAGE_AO_MAP.toString()),
            ("__STAGE_EMISSIVE_MAP__", SamplerStages.STAGE_EMISSIVE_MAP.toString()),
            ("__STAGE_ENV_MAP__", SamplerStages.STAGE_ENV_MAP.toString()),
            ("__STAGE_DFGLUT__", SamplerStages.STAGE_DFGLUT.toString()),
            ("__STAGE_SHADOW_BLIT__", SamplerStages.STAGE_SHADOW_BLIT.toString())
        ]
    }

    /**
     * @brief[zh-cn] 把着色器源码中的 __STAGE_XXX__ 占位符替换为实际 stage 数字（仅固定段）
     * @param[zh-cn] source 着色器源码
     * @return[zh-cn] 替换后的着色器源码
     *
     * @brief[en] Replace __STAGE_XXX__ placeholders in shader source with actual stage numbers (fixed segment only)
     * @param[en] source Shader source code
     * @return[en] Shader source code after replacement
     */
    public static func applyPlaceholders(source: String): String {
        var result = source
        for ((placeholder, value) in SamplerStages.getPlaceholderReplacements()) {
            result = result.replace(placeholder, value)
        }
        return result
    }

    /**
     * @brief[zh-cn] 校验 stage 分配无冲突（调试用，可在启动时调一次）
     * @explain[zh-cn] 检查动态段总占用 ≤ STAGE_FIXED_BASE，固定段互不重叠。
     * @param[zh-cn] numDir 方向光阴影数（默认 0）
     * numSpot 聚光灯阴影数（默认 0）
     * numPoint 点光源阴影数（默认 0）
     * @return[zh-cn] 分配是否无冲突
     *
     * @brief[en] Validate stage allocation has no conflicts (for debugging, can be called once at startup)
     * @explain[en] Checks dynamic segment total usage ≤ STAGE_FIXED_BASE, fixed segments do not overlap.
     * @param[en] numDir Directional light shadow count (default 0)
     * numSpot Spot light shadow count (default 0)
     * numPoint Point light shadow count (default 0)
     * @return[en] Whether allocation has no conflicts
     */
    public static func validate(numDir!: Int64 = 0, numSpot!: Int64 = 0, numPoint!: Int64 = 0): Bool {
        let dynEnd = SamplerStages.dynamicShadowEnd(numDir, numSpot, numPoint)
        if (dynEnd > SamplerStages.STAGE_FIXED_BASE) {
            Logger.error(["stage", "dynamic shadow segment [0, ${dynEnd}) overflows into fixed segment base=${SamplerStages.STAGE_FIXED_BASE} (numDir=${numDir} numSpot=${numSpot} numPoint=${numPoint})"])
            return false
        }
        Logger.debug(["stage", "stage allocation OK: dynamic shadow[0..${dynEnd}), fixed mat[${SamplerStages.STAGE_FIXED_BASE}..${SamplerStages.STAGE_ENV_MAP}), envMap=${SamplerStages.STAGE_ENV_MAP}, dfgLUT=${SamplerStages.STAGE_DFGLUT}"])
        return true
    }
}
