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
 * @file[zh-cn] utils_constants 引擎全局常量的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.constants 的 public 顶层常量绑定为 Lua 命名空间
 * three.utils.constants.Constants 上的静态方法
 * @explain[zh-cn] constants.cj 中全部 public let 常量（版本号、鼠标/触摸交互、
 * 面剔除、阴影、混合模式/方程/因子、深度测试、色调映射、纹理映射/环绕/
 * 过滤/类型/格式、压缩纹理格式、动画循环/插值/结束行为/混合、绘制模式、
 * 深度打包、法线贴图、色彩空间/传输/打包、模板操作/函数、纹理比较、
 * 缓冲用途、着色器语言、坐标系等）以同名 staticMethod 暴露：
 * 数值常量返回 Int64 数值，字符串常量返回字符串。无构造器，不安装 new。
 *
 * @file[en] utils_constants  Lua binding of the engine-wide constants (three.script.prebind)
 * @brief[en] Binds the public top-level constants of three.utils.constants as static
 * methods on the Lua namespace three.utils.constants.Constants
 * @explain[en] Every public top-level let in constants.cj (revision, mouse/touch
 * interaction, culling, shadows, blending modes/equations/factors, depth tests,
 * tone mapping, texture mapping/wrapping/filters/types/formats, compressed
 * texture formats, animation loops/interpolations/endings/blends, draw modes,
 * depth packing, normal maps, color spaces/transfers/packing, stencil ops/funcs,
 * texture compares, buffer usages, shader languages, coordinate systems etc.)
 * is exposed as a same-named staticMethod: numeric constants return Int64 values
 * and string constants return strings. No constructor, no `new`.
 */
package three.script.prebind

import three.utils.constants.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装引擎全局常量的 Lua 绑定（无构造器，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.utils.constants.Constants）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of the engine-wide constants (no constructor, no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at three.utils.constants.Constants)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installConstants(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.constants.Constants")
    // ===== 版本号 =====
    b.staticMethod("REVISION") {_ => [LuaValue.of(REVISION)]}
    // ===== 鼠标交互 =====
    b.staticMethod("MOUSE_LEFT") {_ => [LuaValue.of(MOUSE_LEFT)]}
    b.staticMethod("MOUSE_MIDDLE") {_ => [LuaValue.of(MOUSE_MIDDLE)]}
    b.staticMethod("MOUSE_RIGHT") {_ => [LuaValue.of(MOUSE_RIGHT)]}
    b.staticMethod("MOUSE_ROTATE") {_ => [LuaValue.of(MOUSE_ROTATE)]}
    b.staticMethod("MOUSE_DOLLY") {_ => [LuaValue.of(MOUSE_DOLLY)]}
    b.staticMethod("MOUSE_PAN") {_ => [LuaValue.of(MOUSE_PAN)]}
    // ===== 触摸交互 =====
    b.staticMethod("TOUCH_ROTATE") {_ => [LuaValue.of(TOUCH_ROTATE)]}
    b.staticMethod("TOUCH_PAN") {_ => [LuaValue.of(TOUCH_PAN)]}
    b.staticMethod("TOUCH_DOLLY_PAN") {_ => [LuaValue.of(TOUCH_DOLLY_PAN)]}
    b.staticMethod("TOUCH_DOLLY_ROTATE") {_ => [LuaValue.of(TOUCH_DOLLY_ROTATE)]}
    // ===== 面剔除 =====
    b.staticMethod("CullFaceNone") {_ => [LuaValue.of(CullFaceNone)]}
    b.staticMethod("CullFaceBack") {_ => [LuaValue.of(CullFaceBack)]}
    b.staticMethod("CullFaceFront") {_ => [LuaValue.of(CullFaceFront)]}
    b.staticMethod("CullFaceFrontBack") {_ => [LuaValue.of(CullFaceFrontBack)]}
    // ===== 阴影映射 =====
    b.staticMethod("BasicShadowMap") {_ => [LuaValue.of(BasicShadowMap)]}
    b.staticMethod("PCFShadowMap") {_ => [LuaValue.of(PCFShadowMap)]}
    b.staticMethod("PCFSoftShadowMap") {_ => [LuaValue.of(PCFSoftShadowMap)]}
    b.staticMethod("VSMShadowMap") {_ => [LuaValue.of(VSMShadowMap)]}
    // ===== 面渲染 =====
    b.staticMethod("FrontSide") {_ => [LuaValue.of(FrontSide)]}
    b.staticMethod("BackSide") {_ => [LuaValue.of(BackSide)]}
    b.staticMethod("DoubleSide") {_ => [LuaValue.of(DoubleSide)]}
    // ===== 混合模式 =====
    b.staticMethod("NoBlending") {_ => [LuaValue.of(NoBlending)]}
    b.staticMethod("NormalBlending") {_ => [LuaValue.of(NormalBlending)]}
    b.staticMethod("AdditiveBlending") {_ => [LuaValue.of(AdditiveBlending)]}
    b.staticMethod("SubtractiveBlending") {_ => [LuaValue.of(SubtractiveBlending)]}
    b.staticMethod("MultiplyBlending") {_ => [LuaValue.of(MultiplyBlending)]}
    b.staticMethod("CustomBlending") {_ => [LuaValue.of(CustomBlending)]}
    b.staticMethod("MaterialBlending") {_ => [LuaValue.of(MaterialBlending)]}
    // ===== 混合方程 =====
    b.staticMethod("AddEquation") {_ => [LuaValue.of(AddEquation)]}
    b.staticMethod("SubtractEquation") {_ => [LuaValue.of(SubtractEquation)]}
    b.staticMethod("ReverseSubtractEquation") {_ => [LuaValue.of(ReverseSubtractEquation)]}
    b.staticMethod("MinEquation") {_ => [LuaValue.of(MinEquation)]}
    b.staticMethod("MaxEquation") {_ => [LuaValue.of(MaxEquation)]}
    // ===== 混合因子 =====
    b.staticMethod("ZeroFactor") {_ => [LuaValue.of(ZeroFactor)]}
    b.staticMethod("OneFactor") {_ => [LuaValue.of(OneFactor)]}
    b.staticMethod("SrcColorFactor") {_ => [LuaValue.of(SrcColorFactor)]}
    b.staticMethod("OneMinusSrcColorFactor") {_ => [LuaValue.of(OneMinusSrcColorFactor)]}
    b.staticMethod("SrcAlphaFactor") {_ => [LuaValue.of(SrcAlphaFactor)]}
    b.staticMethod("OneMinusSrcAlphaFactor") {_ => [LuaValue.of(OneMinusSrcAlphaFactor)]}
    b.staticMethod("DstAlphaFactor") {_ => [LuaValue.of(DstAlphaFactor)]}
    b.staticMethod("OneMinusDstAlphaFactor") {_ => [LuaValue.of(OneMinusDstAlphaFactor)]}
    b.staticMethod("DstColorFactor") {_ => [LuaValue.of(DstColorFactor)]}
    b.staticMethod("OneMinusDstColorFactor") {_ => [LuaValue.of(OneMinusDstColorFactor)]}
    b.staticMethod("SrcAlphaSaturateFactor") {_ => [LuaValue.of(SrcAlphaSaturateFactor)]}
    b.staticMethod("ConstantColorFactor") {_ => [LuaValue.of(ConstantColorFactor)]}
    b.staticMethod("OneMinusConstantColorFactor") {_ => [LuaValue.of(OneMinusConstantColorFactor)]}
    b.staticMethod("ConstantAlphaFactor") {_ => [LuaValue.of(ConstantAlphaFactor)]}
    b.staticMethod("OneMinusConstantAlphaFactor") {_ => [LuaValue.of(OneMinusConstantAlphaFactor)]}
    // ===== 深度测试函数 =====
    b.staticMethod("NeverDepth") {_ => [LuaValue.of(NeverDepth)]}
    b.staticMethod("AlwaysDepth") {_ => [LuaValue.of(AlwaysDepth)]}
    b.staticMethod("LessDepth") {_ => [LuaValue.of(LessDepth)]}
    b.staticMethod("LessEqualDepth") {_ => [LuaValue.of(LessEqualDepth)]}
    b.staticMethod("EqualDepth") {_ => [LuaValue.of(EqualDepth)]}
    b.staticMethod("GreaterEqualDepth") {_ => [LuaValue.of(GreaterEqualDepth)]}
    b.staticMethod("GreaterDepth") {_ => [LuaValue.of(GreaterDepth)]}
    b.staticMethod("NotEqualDepth") {_ => [LuaValue.of(NotEqualDepth)]}
    // ===== 环境贴图混合操作 =====
    b.staticMethod("MultiplyOperation") {_ => [LuaValue.of(MultiplyOperation)]}
    b.staticMethod("MixOperation") {_ => [LuaValue.of(MixOperation)]}
    b.staticMethod("AddOperation") {_ => [LuaValue.of(AddOperation)]}
    // ===== 色调映射 =====
    b.staticMethod("NoToneMapping") {_ => [LuaValue.of(NoToneMapping)]}
    b.staticMethod("LinearToneMapping") {_ => [LuaValue.of(LinearToneMapping)]}
    b.staticMethod("ReinhardToneMapping") {_ => [LuaValue.of(ReinhardToneMapping)]}
    b.staticMethod("CineonToneMapping") {_ => [LuaValue.of(CineonToneMapping)]}
    b.staticMethod("ACESFilmicToneMapping") {_ => [LuaValue.of(ACESFilmicToneMapping)]}
    b.staticMethod("CustomToneMapping") {_ => [LuaValue.of(CustomToneMapping)]}
    b.staticMethod("AgXToneMapping") {_ => [LuaValue.of(AgXToneMapping)]}
    b.staticMethod("NeutralToneMapping") {_ => [LuaValue.of(NeutralToneMapping)]}
    // ===== 绑定模式 =====
    b.staticMethod("AttachedBindMode") {_ => [LuaValue.of(AttachedBindMode)]}
    b.staticMethod("DetachedBindMode") {_ => [LuaValue.of(DetachedBindMode)]}
    // ===== 纹理映射模式 =====
    b.staticMethod("UVMapping") {_ => [LuaValue.of(UVMapping)]}
    b.staticMethod("CubeReflectionMapping") {_ => [LuaValue.of(CubeReflectionMapping)]}
    b.staticMethod("CubeRefractionMapping") {_ => [LuaValue.of(CubeRefractionMapping)]}
    b.staticMethod("EquirectangularReflectionMapping") {_ => [LuaValue.of(EquirectangularReflectionMapping)]}
    b.staticMethod("EquirectangularRefractionMapping") {_ => [LuaValue.of(EquirectangularRefractionMapping)]}
    b.staticMethod("CubeUVReflectionMapping") {_ => [LuaValue.of(CubeUVReflectionMapping)]}
    // ===== 纹理环绕模式 =====
    b.staticMethod("RepeatWrapping") {_ => [LuaValue.of(RepeatWrapping)]}
    b.staticMethod("ClampToEdgeWrapping") {_ => [LuaValue.of(ClampToEdgeWrapping)]}
    b.staticMethod("MirroredRepeatWrapping") {_ => [LuaValue.of(MirroredRepeatWrapping)]}
    // ===== 纹理过滤模式 =====
    b.staticMethod("NearestFilter") {_ => [LuaValue.of(NearestFilter)]}
    b.staticMethod("NearestMipmapNearestFilter") {_ => [LuaValue.of(NearestMipmapNearestFilter)]}
    b.staticMethod("NearestMipMapNearestFilter") {_ => [LuaValue.of(NearestMipMapNearestFilter)]}
    b.staticMethod("NearestMipmapLinearFilter") {_ => [LuaValue.of(NearestMipmapLinearFilter)]}
    b.staticMethod("NearestMipMapLinearFilter") {_ => [LuaValue.of(NearestMipMapLinearFilter)]}
    b.staticMethod("LinearFilter") {_ => [LuaValue.of(LinearFilter)]}
    b.staticMethod("LinearMipmapNearestFilter") {_ => [LuaValue.of(LinearMipmapNearestFilter)]}
    b.staticMethod("LinearMipMapNearestFilter") {_ => [LuaValue.of(LinearMipMapNearestFilter)]}
    b.staticMethod("LinearMipmapLinearFilter") {_ => [LuaValue.of(LinearMipmapLinearFilter)]}
    b.staticMethod("LinearMipMapLinearFilter") {_ => [LuaValue.of(LinearMipMapLinearFilter)]}
    // ===== 纹理数据类型 =====
    b.staticMethod("UnsignedByteType") {_ => [LuaValue.of(UnsignedByteType)]}
    b.staticMethod("ByteType") {_ => [LuaValue.of(ByteType)]}
    b.staticMethod("ShortType") {_ => [LuaValue.of(ShortType)]}
    b.staticMethod("UnsignedShortType") {_ => [LuaValue.of(UnsignedShortType)]}
    b.staticMethod("IntType") {_ => [LuaValue.of(IntType)]}
    b.staticMethod("UnsignedIntType") {_ => [LuaValue.of(UnsignedIntType)]}
    b.staticMethod("FloatType") {_ => [LuaValue.of(FloatType)]}
    b.staticMethod("HalfFloatType") {_ => [LuaValue.of(HalfFloatType)]}
    b.staticMethod("UnsignedShort4444Type") {_ => [LuaValue.of(UnsignedShort4444Type)]}
    b.staticMethod("UnsignedShort5551Type") {_ => [LuaValue.of(UnsignedShort5551Type)]}
    b.staticMethod("UnsignedInt248Type") {_ => [LuaValue.of(UnsignedInt248Type)]}
    b.staticMethod("UnsignedInt5999Type") {_ => [LuaValue.of(UnsignedInt5999Type)]}
    b.staticMethod("UnsignedInt101111Type") {_ => [LuaValue.of(UnsignedInt101111Type)]}
    // ===== 纹理格式 =====
    b.staticMethod("AlphaFormat") {_ => [LuaValue.of(AlphaFormat)]}
    b.staticMethod("RGBFormat") {_ => [LuaValue.of(RGBFormat)]}
    b.staticMethod("RGBAFormat") {_ => [LuaValue.of(RGBAFormat)]}
    b.staticMethod("DepthFormat") {_ => [LuaValue.of(DepthFormat)]}
    b.staticMethod("DepthStencilFormat") {_ => [LuaValue.of(DepthStencilFormat)]}
    b.staticMethod("RedFormat") {_ => [LuaValue.of(RedFormat)]}
    b.staticMethod("RedIntegerFormat") {_ => [LuaValue.of(RedIntegerFormat)]}
    b.staticMethod("RGFormat") {_ => [LuaValue.of(RGFormat)]}
    b.staticMethod("RGIntegerFormat") {_ => [LuaValue.of(RGIntegerFormat)]}
    b.staticMethod("RGBIntegerFormat") {_ => [LuaValue.of(RGBIntegerFormat)]}
    b.staticMethod("RGBAIntegerFormat") {_ => [LuaValue.of(RGBAIntegerFormat)]}
    // ===== 压缩纹理格式 (S3TC) =====
    b.staticMethod("RGB_S3TC_DXT1_Format") {_ => [LuaValue.of(RGB_S3TC_DXT1_Format)]}
    b.staticMethod("RGBA_S3TC_DXT1_Format") {_ => [LuaValue.of(RGBA_S3TC_DXT1_Format)]}
    b.staticMethod("RGBA_S3TC_DXT3_Format") {_ => [LuaValue.of(RGBA_S3TC_DXT3_Format)]}
    b.staticMethod("RGBA_S3TC_DXT5_Format") {_ => [LuaValue.of(RGBA_S3TC_DXT5_Format)]}
    // ===== 压缩纹理格式 (PVRTC) =====
    b.staticMethod("RGB_PVRTC_4BPPV1_Format") {_ => [LuaValue.of(RGB_PVRTC_4BPPV1_Format)]}
    b.staticMethod("RGB_PVRTC_2BPPV1_Format") {_ => [LuaValue.of(RGB_PVRTC_2BPPV1_Format)]}
    b.staticMethod("RGBA_PVRTC_4BPPV1_Format") {_ => [LuaValue.of(RGBA_PVRTC_4BPPV1_Format)]}
    b.staticMethod("RGBA_PVRTC_2BPPV1_Format") {_ => [LuaValue.of(RGBA_PVRTC_2BPPV1_Format)]}
    // ===== 压缩纹理格式 (ETC) =====
    b.staticMethod("RGB_ETC1_Format") {_ => [LuaValue.of(RGB_ETC1_Format)]}
    b.staticMethod("RGB_ETC2_Format") {_ => [LuaValue.of(RGB_ETC2_Format)]}
    b.staticMethod("RGBA_ETC2_EAC_Format") {_ => [LuaValue.of(RGBA_ETC2_EAC_Format)]}
    // ===== 压缩纹理格式 (EAC) =====
    b.staticMethod("R11_EAC_Format") {_ => [LuaValue.of(R11_EAC_Format)]}
    b.staticMethod("SIGNED_R11_EAC_Format") {_ => [LuaValue.of(SIGNED_R11_EAC_Format)]}
    b.staticMethod("RG11_EAC_Format") {_ => [LuaValue.of(RG11_EAC_Format)]}
    b.staticMethod("SIGNED_RG11_EAC_Format") {_ => [LuaValue.of(SIGNED_RG11_EAC_Format)]}
    // ===== 压缩纹理格式 (ASTC) =====
    b.staticMethod("RGBA_ASTC_4x4_Format") {_ => [LuaValue.of(RGBA_ASTC_4x4_Format)]}
    b.staticMethod("RGBA_ASTC_5x4_Format") {_ => [LuaValue.of(RGBA_ASTC_5x4_Format)]}
    b.staticMethod("RGBA_ASTC_5x5_Format") {_ => [LuaValue.of(RGBA_ASTC_5x5_Format)]}
    b.staticMethod("RGBA_ASTC_6x5_Format") {_ => [LuaValue.of(RGBA_ASTC_6x5_Format)]}
    b.staticMethod("RGBA_ASTC_6x6_Format") {_ => [LuaValue.of(RGBA_ASTC_6x6_Format)]}
    b.staticMethod("RGBA_ASTC_8x5_Format") {_ => [LuaValue.of(RGBA_ASTC_8x5_Format)]}
    b.staticMethod("RGBA_ASTC_8x6_Format") {_ => [LuaValue.of(RGBA_ASTC_8x6_Format)]}
    b.staticMethod("RGBA_ASTC_8x8_Format") {_ => [LuaValue.of(RGBA_ASTC_8x8_Format)]}
    b.staticMethod("RGBA_ASTC_10x5_Format") {_ => [LuaValue.of(RGBA_ASTC_10x5_Format)]}
    b.staticMethod("RGBA_ASTC_10x6_Format") {_ => [LuaValue.of(RGBA_ASTC_10x6_Format)]}
    b.staticMethod("RGBA_ASTC_10x8_Format") {_ => [LuaValue.of(RGBA_ASTC_10x8_Format)]}
    b.staticMethod("RGBA_ASTC_10x10_Format") {_ => [LuaValue.of(RGBA_ASTC_10x10_Format)]}
    b.staticMethod("RGBA_ASTC_12x10_Format") {_ => [LuaValue.of(RGBA_ASTC_12x10_Format)]}
    b.staticMethod("RGBA_ASTC_12x12_Format") {_ => [LuaValue.of(RGBA_ASTC_12x12_Format)]}
    // ===== 压缩纹理格式 (BPTC) =====
    b.staticMethod("RGBA_BPTC_Format") {_ => [LuaValue.of(RGBA_BPTC_Format)]}
    b.staticMethod("RGB_BPTC_SIGNED_Format") {_ => [LuaValue.of(RGB_BPTC_SIGNED_Format)]}
    b.staticMethod("RGB_BPTC_UNSIGNED_Format") {_ => [LuaValue.of(RGB_BPTC_UNSIGNED_Format)]}
    // ===== 压缩纹理格式 (RGTC) =====
    b.staticMethod("RED_RGTC1_Format") {_ => [LuaValue.of(RED_RGTC1_Format)]}
    b.staticMethod("SIGNED_RED_RGTC1_Format") {_ => [LuaValue.of(SIGNED_RED_RGTC1_Format)]}
    b.staticMethod("RED_GREEN_RGTC2_Format") {_ => [LuaValue.of(RED_GREEN_RGTC2_Format)]}
    b.staticMethod("SIGNED_RED_GREEN_RGTC2_Format") {_ => [LuaValue.of(SIGNED_RED_GREEN_RGTC2_Format)]}
    // ===== 动画循环模式 =====
    b.staticMethod("LoopOnce") {_ => [LuaValue.of(LoopOnce)]}
    b.staticMethod("LoopRepeat") {_ => [LuaValue.of(LoopRepeat)]}
    b.staticMethod("LoopPingPong") {_ => [LuaValue.of(LoopPingPong)]}
    // ===== 插值模式 =====
    b.staticMethod("InterpolateDiscrete") {_ => [LuaValue.of(InterpolateDiscrete)]}
    b.staticMethod("InterpolateLinear") {_ => [LuaValue.of(InterpolateLinear)]}
    b.staticMethod("InterpolateSmooth") {_ => [LuaValue.of(InterpolateSmooth)]}
    b.staticMethod("InterpolateBezier") {_ => [LuaValue.of(InterpolateBezier)]}
    // ===== 动画结束行为 =====
    b.staticMethod("ZeroCurvatureEnding") {_ => [LuaValue.of(ZeroCurvatureEnding)]}
    b.staticMethod("ZeroSlopeEnding") {_ => [LuaValue.of(ZeroSlopeEnding)]}
    b.staticMethod("WrapAroundEnding") {_ => [LuaValue.of(WrapAroundEnding)]}
    // ===== 动画混合模式 =====
    b.staticMethod("NormalAnimationBlendMode") {_ => [LuaValue.of(NormalAnimationBlendMode)]}
    b.staticMethod("AdditiveAnimationBlendMode") {_ => [LuaValue.of(AdditiveAnimationBlendMode)]}
    // ===== 绘制模式 =====
    b.staticMethod("TrianglesDrawMode") {_ => [LuaValue.of(TrianglesDrawMode)]}
    b.staticMethod("TriangleStripDrawMode") {_ => [LuaValue.of(TriangleStripDrawMode)]}
    b.staticMethod("TriangleFanDrawMode") {_ => [LuaValue.of(TriangleFanDrawMode)]}
    // ===== 深度打包 =====
    b.staticMethod("BasicDepthPacking") {_ => [LuaValue.of(BasicDepthPacking)]}
    b.staticMethod("RGBADepthPacking") {_ => [LuaValue.of(RGBADepthPacking)]}
    b.staticMethod("RGBDepthPacking") {_ => [LuaValue.of(RGBDepthPacking)]}
    b.staticMethod("RGDepthPacking") {_ => [LuaValue.of(RGDepthPacking)]}
    // ===== 法线贴图空间 =====
    b.staticMethod("TangentSpaceNormalMap") {_ => [LuaValue.of(TangentSpaceNormalMap)]}
    b.staticMethod("ObjectSpaceNormalMap") {_ => [LuaValue.of(ObjectSpaceNormalMap)]}
    // ===== 色彩空间 =====
    b.staticMethod("NoColorSpace") {_ => [LuaValue.of(NoColorSpace)]}
    b.staticMethod("SRGBColorSpace") {_ => [LuaValue.of(SRGBColorSpace)]}
    b.staticMethod("LinearSRGBColorSpace") {_ => [LuaValue.of(LinearSRGBColorSpace)]}
    // ===== 传输函数 =====
    b.staticMethod("LinearTransfer") {_ => [LuaValue.of(LinearTransfer)]}
    b.staticMethod("SRGBTransfer") {_ => [LuaValue.of(SRGBTransfer)]}
    // ===== 法线贴图打包 =====
    b.staticMethod("NoNormalPacking") {_ => [LuaValue.of(NoNormalPacking)]}
    b.staticMethod("NormalRGPacking") {_ => [LuaValue.of(NormalRGPacking)]}
    b.staticMethod("NormalGAPacking") {_ => [LuaValue.of(NormalGAPacking)]}
    // ===== 模板操作 =====
    b.staticMethod("ZeroStencilOp") {_ => [LuaValue.of(ZeroStencilOp)]}
    b.staticMethod("KeepStencilOp") {_ => [LuaValue.of(KeepStencilOp)]}
    b.staticMethod("ReplaceStencilOp") {_ => [LuaValue.of(ReplaceStencilOp)]}
    b.staticMethod("IncrementStencilOp") {_ => [LuaValue.of(IncrementStencilOp)]}
    b.staticMethod("DecrementStencilOp") {_ => [LuaValue.of(DecrementStencilOp)]}
    b.staticMethod("IncrementWrapStencilOp") {_ => [LuaValue.of(IncrementWrapStencilOp)]}
    b.staticMethod("DecrementWrapStencilOp") {_ => [LuaValue.of(DecrementWrapStencilOp)]}
    b.staticMethod("InvertStencilOp") {_ => [LuaValue.of(InvertStencilOp)]}
    // ===== 模板测试函数 =====
    b.staticMethod("NeverStencilFunc") {_ => [LuaValue.of(NeverStencilFunc)]}
    b.staticMethod("LessStencilFunc") {_ => [LuaValue.of(LessStencilFunc)]}
    b.staticMethod("EqualStencilFunc") {_ => [LuaValue.of(EqualStencilFunc)]}
    b.staticMethod("LessEqualStencilFunc") {_ => [LuaValue.of(LessEqualStencilFunc)]}
    b.staticMethod("GreaterStencilFunc") {_ => [LuaValue.of(GreaterStencilFunc)]}
    b.staticMethod("NotEqualStencilFunc") {_ => [LuaValue.of(NotEqualStencilFunc)]}
    b.staticMethod("GreaterEqualStencilFunc") {_ => [LuaValue.of(GreaterEqualStencilFunc)]}
    b.staticMethod("AlwaysStencilFunc") {_ => [LuaValue.of(AlwaysStencilFunc)]}
    // ===== 纹理比较函数 =====
    b.staticMethod("NeverCompare") {_ => [LuaValue.of(NeverCompare)]}
    b.staticMethod("LessCompare") {_ => [LuaValue.of(LessCompare)]}
    b.staticMethod("EqualCompare") {_ => [LuaValue.of(EqualCompare)]}
    b.staticMethod("LessEqualCompare") {_ => [LuaValue.of(LessEqualCompare)]}
    b.staticMethod("GreaterCompare") {_ => [LuaValue.of(GreaterCompare)]}
    b.staticMethod("NotEqualCompare") {_ => [LuaValue.of(NotEqualCompare)]}
    b.staticMethod("GreaterEqualCompare") {_ => [LuaValue.of(GreaterEqualCompare)]}
    b.staticMethod("AlwaysCompare") {_ => [LuaValue.of(AlwaysCompare)]}
    // ===== 缓冲区使用模式 =====
    b.staticMethod("StaticDrawUsage") {_ => [LuaValue.of(StaticDrawUsage)]}
    b.staticMethod("DynamicDrawUsage") {_ => [LuaValue.of(DynamicDrawUsage)]}
    b.staticMethod("StreamDrawUsage") {_ => [LuaValue.of(StreamDrawUsage)]}
    b.staticMethod("StaticReadUsage") {_ => [LuaValue.of(StaticReadUsage)]}
    b.staticMethod("DynamicReadUsage") {_ => [LuaValue.of(DynamicReadUsage)]}
    b.staticMethod("StreamReadUsage") {_ => [LuaValue.of(StreamReadUsage)]}
    b.staticMethod("StaticCopyUsage") {_ => [LuaValue.of(StaticCopyUsage)]}
    b.staticMethod("DynamicCopyUsage") {_ => [LuaValue.of(DynamicCopyUsage)]}
    b.staticMethod("StreamCopyUsage") {_ => [LuaValue.of(StreamCopyUsage)]}
    // ===== 着色器语言 =====
    b.staticMethod("GLSL1") {_ => [LuaValue.of(GLSL1)]}
    b.staticMethod("GLSL3") {_ => [LuaValue.of(GLSL3)]}
    // ===== 坐标系 =====
    b.staticMethod("WebGLCoordinateSystem") {_ => [LuaValue.of(WebGLCoordinateSystem)]}
    b.staticMethod("WebGPUCoordinateSystem") {_ => [LuaValue.of(WebGPUCoordinateSystem)]}
    // ===== 时间戳查询 =====
    b.staticMethod("TimestampQuery_COMPUTE") {_ => [LuaValue.of(TimestampQuery_COMPUTE)]}
    b.staticMethod("TimestampQuery_RENDER") {_ => [LuaValue.of(TimestampQuery_RENDER)]}
    // ===== 插值采样类型 =====
    b.staticMethod("InterpolationSamplingType_PERSPECTIVE") {_ => [LuaValue.of(InterpolationSamplingType_PERSPECTIVE)]}
    b.staticMethod("InterpolationSamplingType_LINEAR") {_ => [LuaValue.of(InterpolationSamplingType_LINEAR)]}
    b.staticMethod("InterpolationSamplingType_FLAT") {_ => [LuaValue.of(InterpolationSamplingType_FLAT)]}
    // ===== 插值采样模式 =====
    b.staticMethod("InterpolationSamplingMode_NORMAL") {_ => [LuaValue.of(InterpolationSamplingMode_NORMAL)]}
    b.staticMethod("InterpolationSamplingMode_CENTROID") {_ => [LuaValue.of(InterpolationSamplingMode_CENTROID)]}
    b.staticMethod("InterpolationSamplingMode_SAMPLE") {_ => [LuaValue.of(InterpolationSamplingMode_SAMPLE)]}
    b.staticMethod("InterpolationSamplingMode_FIRST") {_ => [LuaValue.of(InterpolationSamplingMode_FIRST)]}
    b.staticMethod("InterpolationSamplingMode_EITHER") {_ => [LuaValue.of(InterpolationSamplingMode_EITHER)]}
    // ===== 兼容性 =====
    b.staticMethod("COMPATIBILITY_TEXTURE_COMPARE") {_ => [LuaValue.of(COMPATIBILITY_TEXTURE_COMPARE)]}
    b.install(vm)
}
