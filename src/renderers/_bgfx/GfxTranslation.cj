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
 * @file[zh-cn] GfxTranslation 引擎句柄/枚举与 bgfx 的双向翻译
 * @brief[zh-cn] 抽象层 Gfx* 词汇与 bgfx 类型之间唯一的翻译点
 * @explain[zh-cn] 本文件是 `Gfx*Handle ↔ bgfx.*Handle`、`Gfx* 枚举 → bgfx 枚举`
 * 的全部翻译代码所在——引擎其余代码只接触 Gfx 词汇，后端替换时仅改本文件与
 * BgfxBackend 实现。枚举翻译采用穷尽 match：新增 Gfx 枚举成员而未补映射时
 * 编译失败，杜绝漏翻译。位组合标志（GfxTextureFlag/GfxSamplerFlag/GfxBufferFlag/
 * GfxState/GfxClearFlag/GfxResetFlag/GfxStencilFlag）的数值与 bgfx 位序一致，
 * 无须翻译、直接透传。
 *
 * @file[en] GfxTranslation bidirectional translation between engine handles/enums and bgfx
 * @brief[en] The single translation point between Gfx* vocabulary and bgfx types
 * @explain[en] This file hosts all translation code of `Gfx*Handle ↔ bgfx.*Handle` and
 * `Gfx* enums → bgfx enums` — the rest of the engine only touches Gfx vocabulary, and
 * a backend replacement only rewrites this file plus the BgfxBackend implementation.
 * Enum translations use exhaustive matches: adding a Gfx enum member without a mapping
 * fails to compile, preventing missed translations. Bit-combination flags
 * (GfxTextureFlag/GfxSamplerFlag/GfxBufferFlag/GfxState/GfxClearFlag/GfxResetFlag/
 * GfxStencilFlag) share the bgfx bit order, pass through without translation.
 *
 * @package three.renderers._bgfx
 */
protected package three.renderers._bgfx
import three._vendor.bgfx4cj.bgfx as bgfx
import three.renderers._gfx.*
// ============================================================================
// ===== 句柄翻译（Gfx* ↔ bgfx.*，均为 16 位索引值拷贝） =====
// ============================================================================

/** Gfx 纹理句柄 → bgfx 句柄 */
internal func toBgfx(h: GfxTextureHandle): bgfx.TextureHandle {
    bgfx.TextureHandle(h.idx)
}

/** bgfx 纹理句柄 → Gfx 句柄 */
internal func toGfx(h: bgfx.TextureHandle): GfxTextureHandle {
    GfxTextureHandle(h.idx)
}

/** Gfx 帧缓冲句柄 → bgfx 句柄 */
internal func toBgfx(h: GfxFrameBufferHandle): bgfx.FrameBufferHandle {
    bgfx.FrameBufferHandle(h.idx)
}

/** bgfx 帧缓冲句柄 → Gfx 句柄 */
internal func toGfx(h: bgfx.FrameBufferHandle): GfxFrameBufferHandle {
    GfxFrameBufferHandle(h.idx)
}

/** Gfx 程序句柄 → bgfx 句柄 */
internal func toBgfx(h: GfxProgramHandle): bgfx.ProgramHandle {
    bgfx.ProgramHandle(h.idx)
}

/** bgfx 程序句柄 → Gfx 句柄 */
internal func toGfx(h: bgfx.ProgramHandle): GfxProgramHandle {
    GfxProgramHandle(h.idx)
}

/** Gfx uniform 句柄 → bgfx 句柄 */
internal func toBgfx(h: GfxUniformHandle): bgfx.UniformHandle {
    bgfx.UniformHandle(h.idx)
}

/** bgfx uniform 句柄 → Gfx 句柄 */
internal func toGfx(h: bgfx.UniformHandle): GfxUniformHandle {
    GfxUniformHandle(h.idx)
}

/** Gfx 着色器句柄 → bgfx 句柄 */
internal func toBgfx(h: GfxShaderHandle): bgfx.ShaderHandle {
    bgfx.ShaderHandle(h.idx)
}

/** bgfx 着色器句柄 → Gfx 句柄 */
internal func toGfx(h: bgfx.ShaderHandle): GfxShaderHandle {
    GfxShaderHandle(h.idx)
}

/** Gfx 静态顶点缓冲句柄 → bgfx 句柄 */
internal func toBgfx(h: GfxVertexBufferHandle): bgfx.VertexBufferHandle {
    bgfx.VertexBufferHandle(h.idx)
}

/** bgfx 静态顶点缓冲句柄 → Gfx 句柄 */
internal func toGfx(h: bgfx.VertexBufferHandle): GfxVertexBufferHandle {
    GfxVertexBufferHandle(h.idx)
}

/** Gfx 静态索引缓冲句柄 → bgfx 句柄 */
internal func toBgfx(h: GfxIndexBufferHandle): bgfx.IndexBufferHandle {
    bgfx.IndexBufferHandle(h.idx)
}

/** bgfx 静态索引缓冲句柄 → Gfx 句柄 */
internal func toGfx(h: bgfx.IndexBufferHandle): GfxIndexBufferHandle {
    GfxIndexBufferHandle(h.idx)
}

/** Gfx 顶点布局句柄 → bgfx 句柄 */
internal func toBgfx(h: GfxVertexLayoutHandle): bgfx.VertexLayoutHandle {
    bgfx.VertexLayoutHandle(h.idx)
}

/** bgfx 顶点布局句柄 → Gfx 句柄 */
internal func toGfx(h: bgfx.VertexLayoutHandle): GfxVertexLayoutHandle {
    GfxVertexLayoutHandle(h.idx)
}

/** Gfx 动态顶点缓冲句柄 → bgfx 句柄 */
internal func toBgfx(h: GfxDynamicVertexBufferHandle): bgfx.DynamicVertexBufferHandle {
    bgfx.DynamicVertexBufferHandle(h.idx)
}

/** bgfx 动态顶点缓冲句柄 → Gfx 句柄 */
internal func toGfx(h: bgfx.DynamicVertexBufferHandle): GfxDynamicVertexBufferHandle {
    GfxDynamicVertexBufferHandle(h.idx)
}

/** Gfx 动态索引缓冲句柄 → bgfx 句柄 */
internal func toBgfx(h: GfxDynamicIndexBufferHandle): bgfx.DynamicIndexBufferHandle {
    bgfx.DynamicIndexBufferHandle(h.idx)
}

/** bgfx 动态索引缓冲句柄 → Gfx 句柄 */
internal func toGfx(h: bgfx.DynamicIndexBufferHandle): GfxDynamicIndexBufferHandle {
    GfxDynamicIndexBufferHandle(h.idx)
}

/** Gfx 间接绘制缓冲句柄 → bgfx 句柄 */
internal func toBgfx(h: GfxIndirectBufferHandle): bgfx.IndirectBufferHandle {
    bgfx.IndirectBufferHandle(h.idx)
}

/** bgfx 间接绘制缓冲句柄 → Gfx 句柄 */
internal func toGfx(h: bgfx.IndirectBufferHandle): GfxIndirectBufferHandle {
    GfxIndirectBufferHandle(h.idx)
}

/** Gfx 遮挡查询句柄 → bgfx 句柄 */
internal func toBgfx(h: GfxOcclusionQueryHandle): bgfx.OcclusionQueryHandle {
    bgfx.OcclusionQueryHandle(h.idx)
}

/** bgfx 遮挡查询句柄 → Gfx 句柄 */
internal func toGfx(h: bgfx.OcclusionQueryHandle): GfxOcclusionQueryHandle {
    GfxOcclusionQueryHandle(h.idx)
}

// ============================================================================
// ===== 枚举翻译（穷尽 match，新增 Gfx 成员未补映射时编译失败） =====
// ============================================================================

/** bgfx uniform 类型值 → Gfx uniform 类型。 */
internal func gfxUniformType(v: UInt32): GfxUniformType {
    match (v) {
        case 0u32 => GfxUniformType.Sampler
        case 2u32 => GfxUniformType.Vec4
        case 3u32 => GfxUniformType.Mat3
        case 4u32 => GfxUniformType.Mat4
        case _ => GfxUniformType.Vec4
    }
}

/** Gfx 纹理格式 → bgfx 纹理格式 */
internal func toBgfx(f: GfxTextureFormat): bgfx.TextureFormat {
    match (f) {
        case GfxTextureFormat.BC1 => bgfx.TextureFormat.BC1
        case GfxTextureFormat.BC2 => bgfx.TextureFormat.BC2
        case GfxTextureFormat.BC3 => bgfx.TextureFormat.BC3
        case GfxTextureFormat.BC4 => bgfx.TextureFormat.BC4
        case GfxTextureFormat.BC5 => bgfx.TextureFormat.BC5
        case GfxTextureFormat.BC6H => bgfx.TextureFormat.BC6H
        case GfxTextureFormat.BC7 => bgfx.TextureFormat.BC7
        case GfxTextureFormat.ETC1 => bgfx.TextureFormat.ETC1
        case GfxTextureFormat.ETC2 => bgfx.TextureFormat.ETC2
        case GfxTextureFormat.ETC2A => bgfx.TextureFormat.ETC2A
        case GfxTextureFormat.ASTC4X4 => bgfx.TextureFormat.ASTC4X4
        case GfxTextureFormat.ASTC5X4 => bgfx.TextureFormat.ASTC5X4
        case GfxTextureFormat.ASTC5X5 => bgfx.TextureFormat.ASTC5X5
        case GfxTextureFormat.ASTC6X5 => bgfx.TextureFormat.ASTC6X5
        case GfxTextureFormat.ASTC6X6 => bgfx.TextureFormat.ASTC6X6
        case GfxTextureFormat.ASTC8X5 => bgfx.TextureFormat.ASTC8X5
        case GfxTextureFormat.ASTC8X6 => bgfx.TextureFormat.ASTC8X6
        case GfxTextureFormat.ASTC8X8 => bgfx.TextureFormat.ASTC8X8
        case GfxTextureFormat.ASTC10X5 => bgfx.TextureFormat.ASTC10X5
        case GfxTextureFormat.ASTC10X6 => bgfx.TextureFormat.ASTC10X6
        case GfxTextureFormat.ASTC10X8 => bgfx.TextureFormat.ASTC10X8
        case GfxTextureFormat.ASTC10X10 => bgfx.TextureFormat.ASTC10X10
        case GfxTextureFormat.ASTC12X10 => bgfx.TextureFormat.ASTC12X10
        case GfxTextureFormat.ASTC12X12 => bgfx.TextureFormat.ASTC12X12
        case GfxTextureFormat.A8 => bgfx.TextureFormat.A8
        case GfxTextureFormat.R8 => bgfx.TextureFormat.R8
        case GfxTextureFormat.R16 => bgfx.TextureFormat.R16
        case GfxTextureFormat.R16I => bgfx.TextureFormat.R16I
        case GfxTextureFormat.R16F => bgfx.TextureFormat.R16F
        case GfxTextureFormat.RG8 => bgfx.TextureFormat.RG8
        case GfxTextureFormat.RG16F => bgfx.TextureFormat.RG16F
        case GfxTextureFormat.RG32I => bgfx.TextureFormat.RG32I
        case GfxTextureFormat.RGB9E5F => bgfx.TextureFormat.RGB9E5F
        case GfxTextureFormat.RGBA8 => bgfx.TextureFormat.RGBA8
        case GfxTextureFormat.RGBA16F => bgfx.TextureFormat.RGBA16F
        case GfxTextureFormat.RGBA32I => bgfx.TextureFormat.RGBA32I
        case GfxTextureFormat.RGBA32F => bgfx.TextureFormat.RGBA32F
        case GfxTextureFormat.RG11B10F => bgfx.TextureFormat.RG11B10F
        case GfxTextureFormat.D24 => bgfx.TextureFormat.D24
        case GfxTextureFormat.D24S8 => bgfx.TextureFormat.D24S8
        case GfxTextureFormat.D32 => bgfx.TextureFormat.D32
        case GfxTextureFormat.D32F => bgfx.TextureFormat.D32F
    }
}

/** Gfx uniform 类型 → bgfx uniform 类型 */
internal func toBgfx(t: GfxUniformType): bgfx.UniformType {
    match (t) {
        case GfxUniformType.Sampler => bgfx.UniformType.Sampler
        case GfxUniformType.Vec4 => bgfx.UniformType.Vec4
        case GfxUniformType.Mat3 => bgfx.UniformType.Mat3
        case GfxUniformType.Mat4 => bgfx.UniformType.Mat4
    }
}

/** Gfx 顶点属性槽位 → bgfx 属性槽位 */
internal func toBgfx(a: GfxAttrib): bgfx.Attrib {
    match (a) {
        case GfxAttrib.Position => bgfx.Attrib.Position
        case GfxAttrib.Normal => bgfx.Attrib.Normal
        case GfxAttrib.Tangent => bgfx.Attrib.Tangent
        case GfxAttrib.Bitangent => bgfx.Attrib.Bitangent
        case GfxAttrib.Color0 => bgfx.Attrib.Color0
        case GfxAttrib.Color1 => bgfx.Attrib.Color1
        case GfxAttrib.Color2 => bgfx.Attrib.Color2
        case GfxAttrib.Color3 => bgfx.Attrib.Color3
        case GfxAttrib.Indices => bgfx.Attrib.Indices
        case GfxAttrib.Weight => bgfx.Attrib.Weight
        case GfxAttrib.TexCoord0 => bgfx.Attrib.TexCoord0
        case GfxAttrib.TexCoord1 => bgfx.Attrib.TexCoord1
        case GfxAttrib.TexCoord2 => bgfx.Attrib.TexCoord2
        case GfxAttrib.TexCoord3 => bgfx.Attrib.TexCoord3
        case GfxAttrib.TexCoord4 => bgfx.Attrib.TexCoord4
        case GfxAttrib.TexCoord5 => bgfx.Attrib.TexCoord5
        case GfxAttrib.TexCoord6 => bgfx.Attrib.TexCoord6
        case GfxAttrib.TexCoord7 => bgfx.Attrib.TexCoord7
    }
}

/** Gfx 顶点属性存储类型 → bgfx 属性存储类型 */
internal func toBgfx(t: GfxAttribType): bgfx.AttribType {
    match (t) {
        case GfxAttribType.`Int8` => bgfx.AttribType.`Int8`
        case GfxAttribType.Uint8 => bgfx.AttribType.Uint8
        case GfxAttribType.Uint10 => bgfx.AttribType.Uint10
        case GfxAttribType.`Int16` => bgfx.AttribType.`Int16`
        case GfxAttribType.Uint16 => bgfx.AttribType.Uint16
        case GfxAttribType.Half => bgfx.AttribType.Half
        case GfxAttribType.Float => bgfx.AttribType.Float
        case GfxAttribType.`Int32` => bgfx.AttribType.`Int32`
        case GfxAttribType.Uint32 => bgfx.AttribType.Uint32
    }
}

/** Gfx 视图排序模式 → bgfx 视图模式 */
internal func toBgfx(m: GfxViewMode): bgfx.ViewMode {
    match (m) {
        case GfxViewMode.Default => bgfx.ViewMode.Default
        case GfxViewMode.Sequential => bgfx.ViewMode.Sequential
        case GfxViewMode.DepthAscending => bgfx.ViewMode.DepthAscending
        case GfxViewMode.DepthDescending => bgfx.ViewMode.DepthDescending
    }
}

/** Gfx 后缓冲比例 → bgfx 后缓冲比例 */
internal func toBgfx(r: GfxBackbufferRatio): bgfx.BackbufferRatio {
    match (r) {
        case GfxBackbufferRatio.Equal => bgfx.BackbufferRatio.Equal
        case GfxBackbufferRatio.Half => bgfx.BackbufferRatio.Half
        case GfxBackbufferRatio.Quarter => bgfx.BackbufferRatio.Quarter
        case GfxBackbufferRatio.Eighth => bgfx.BackbufferRatio.Eighth
        case GfxBackbufferRatio.Sixteenth => bgfx.BackbufferRatio.Sixteenth
        case GfxBackbufferRatio.Double => bgfx.BackbufferRatio.Double
    }
}

/** Gfx 计算访问模式 → bgfx 访问模式 */
internal func toBgfx(a: GfxAccess): bgfx.Access {
    match (a) {
        case GfxAccess.Read => bgfx.Access.Read
        case GfxAccess.Write => bgfx.Access.Write
        case GfxAccess.ReadWrite => bgfx.Access.ReadWrite
    }
}

/** Gfx 渲染后端类型 → bgfx 渲染器类型 */
internal func toBgfx(t: GfxRendererType): bgfx.RendererType {
    match (t) {
        case GfxRendererType.Noop => bgfx.RendererType.Noop
        case GfxRendererType.Agc => bgfx.RendererType.Agc
        case GfxRendererType.Direct3D11 => bgfx.RendererType.Direct3D11
        case GfxRendererType.Direct3D12 => bgfx.RendererType.Direct3D12
        case GfxRendererType.Gnm => bgfx.RendererType.Gnm
        case GfxRendererType.Metal => bgfx.RendererType.Metal
        case GfxRendererType.Nvn => bgfx.RendererType.Nvn
        case GfxRendererType.OpenGLES => bgfx.RendererType.OpenGLES
        case GfxRendererType.OpenGL => bgfx.RendererType.OpenGL
        case GfxRendererType.Vulkan => bgfx.RendererType.Vulkan
        case GfxRendererType.WebGPU => bgfx.RendererType.WebGPU
    }
}

/** bgfx 渲染器类型 → Gfx 渲染后端类型 */
internal func toGfx(t: bgfx.RendererType): GfxRendererType {
    match (t) {
        case bgfx.RendererType.Noop => GfxRendererType.Noop
        case bgfx.RendererType.Agc => GfxRendererType.Agc
        case bgfx.RendererType.Direct3D11 => GfxRendererType.Direct3D11
        case bgfx.RendererType.Direct3D12 => GfxRendererType.Direct3D12
        case bgfx.RendererType.Gnm => GfxRendererType.Gnm
        case bgfx.RendererType.Metal => GfxRendererType.Metal
        case bgfx.RendererType.Nvn => GfxRendererType.Nvn
        case bgfx.RendererType.OpenGLES => GfxRendererType.OpenGLES
        case bgfx.RendererType.OpenGL => GfxRendererType.OpenGL
        case bgfx.RendererType.Vulkan => GfxRendererType.Vulkan
        case bgfx.RendererType.WebGPU => GfxRendererType.WebGPU
        case bgfx.RendererType.Count => GfxRendererType.Noop
    }
}

/** bgfx uniform 类型 → Gfx uniform 类型（反射查询回译；End 归并为 Vec4 不应出现） */
internal func toGfx(t: bgfx.UniformType): GfxUniformType {
    match (t) {
        case bgfx.UniformType.Sampler => GfxUniformType.Sampler
        case bgfx.UniformType.Vec4 => GfxUniformType.Vec4
        case bgfx.UniformType.Mat3 => GfxUniformType.Mat3
        case bgfx.UniformType.Mat4 => GfxUniformType.Mat4
        case _ => GfxUniformType.Vec4
    }
}
