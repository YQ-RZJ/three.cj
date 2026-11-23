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
 * @file[zh-cn] renderers_gfx_gfxdefs 抽象层枚举 / 标志 / 值结构的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.common 的公开枚举、位标志类与值结构绑定到 Lua
 * @explain[zh-cn] 约定：
 * - 枚举成员以类表上的同名 staticMethod 暴露，返回后端数值（Int64，等于仓颉 value()）；
 * - 位标志类（GfxTextureFlag / GfxSamplerFlag / GfxBufferFlag / GfxState / GfxStencilFlag /
 *   GfxClearFlag / GfxResetFlag）同样以同名 staticMethod 暴露常量数值，Lua 侧按位或组合；
 * - 值结构（GfxAttributeDesc / GfxAttachmentDesc / GfxUniformDesc / GfxCapsSummary /
 *   GfxStatsSummary）绑定构造（枚举参数用数值传入）与只读属性。
 *
 * @file[en] renderers_gfx_gfxdefs  Lua bindings of the abstraction-layer enums / flags / value structs
 * (three.script.prebind)
 * @brief[en] Binds the public enums, bit-flag classes and value structs of three.renderers.common to Lua
 * @explain[en] Conventions:
 * - Enum members are exposed as same-named staticMethods on the class table, returning the backend
 *   numeric value (Int64, equal to the Cangjie value());
 * - Bit-flag classes (GfxTextureFlag / GfxSamplerFlag / GfxBufferFlag / GfxState / GfxStencilFlag /
 *   GfxClearFlag / GfxResetFlag) likewise expose their constant values as same-named staticMethods,
 *   composed in Lua via bitwise or;
 * - Value structs (GfxAttributeDesc / GfxAttachmentDesc / GfxUniformDesc / GfxCapsSummary /
 *   GfxStatsSummary) bind their constructors (enum params passed numerically) and read-only props.
 */
package three.script.prebind

import three.renderers.common.*
import three.script.vm.*
import three.script.binding.*

// =============================================================================
// ===== 枚举数值 → 枚举值（结构构造参数用） =====
// =============================================================================

/// 数值 → GfxTextureFormat（未知值回退 BC1）
internal func prebindGfxTextureFormat(v: Int64): GfxTextureFormat {
    match (v) {
        case 0 => GfxTextureFormat.BC1
        case 1 => GfxTextureFormat.BC2
        case 2 => GfxTextureFormat.BC3
        case 3 => GfxTextureFormat.BC4
        case 5 => GfxTextureFormat.BC5
        case 7 => GfxTextureFormat.BC6H
        case 9 => GfxTextureFormat.BC7
        case 10 => GfxTextureFormat.ETC1
        case 11 => GfxTextureFormat.ETC2
        case 12 => GfxTextureFormat.ETC2A
        case 27 => GfxTextureFormat.ASTC4X4
        case 28 => GfxTextureFormat.ASTC5X4
        case 29 => GfxTextureFormat.ASTC5X5
        case 30 => GfxTextureFormat.ASTC6X5
        case 31 => GfxTextureFormat.ASTC6X6
        case 32 => GfxTextureFormat.ASTC8X5
        case 33 => GfxTextureFormat.ASTC8X6
        case 34 => GfxTextureFormat.ASTC8X8
        case 35 => GfxTextureFormat.ASTC10X5
        case 36 => GfxTextureFormat.ASTC10X6
        case 37 => GfxTextureFormat.ASTC10X8
        case 38 => GfxTextureFormat.ASTC10X10
        case 39 => GfxTextureFormat.ASTC12X10
        case 40 => GfxTextureFormat.ASTC12X12
        case 43 => GfxTextureFormat.A8
        case 44 => GfxTextureFormat.R8
        case 48 => GfxTextureFormat.R16
        case 49 => GfxTextureFormat.R16I
        case 51 => GfxTextureFormat.R16F
        case 56 => GfxTextureFormat.RG8
        case 63 => GfxTextureFormat.RG16F
        case 65 => GfxTextureFormat.RG32I
        case 72 => GfxTextureFormat.RGB9E5F
        case 74 => GfxTextureFormat.RGBA8
        case 81 => GfxTextureFormat.RGBA16F
        case 83 => GfxTextureFormat.RGBA32I
        case 85 => GfxTextureFormat.RGBA32F
        case 94 => GfxTextureFormat.RG11B10F
        case 97 => GfxTextureFormat.D24
        case 98 => GfxTextureFormat.D24S8
        case 99 => GfxTextureFormat.D32
        case 102 => GfxTextureFormat.D32F
        case _ => GfxTextureFormat.BC1
    }
}

/// 数值 → GfxUniformType（未知值回退 Sampler）
internal func prebindGfxUniformType(v: Int64): GfxUniformType {
    match (v) {
        case 0 => GfxUniformType.Sampler
        case 2 => GfxUniformType.Vec4
        case 3 => GfxUniformType.Mat3
        case 4 => GfxUniformType.Mat4
        case _ => GfxUniformType.Sampler
    }
}

/// 数值 → GfxAttrib（未知值回退 Position）
internal func prebindGfxAttrib(v: Int64): GfxAttrib {
    match (v) {
        case 0 => GfxAttrib.Position
        case 1 => GfxAttrib.Normal
        case 2 => GfxAttrib.Tangent
        case 3 => GfxAttrib.Bitangent
        case 4 => GfxAttrib.Color0
        case 5 => GfxAttrib.Color1
        case 6 => GfxAttrib.Color2
        case 7 => GfxAttrib.Color3
        case 8 => GfxAttrib.Indices
        case 9 => GfxAttrib.Weight
        case 10 => GfxAttrib.TexCoord0
        case 11 => GfxAttrib.TexCoord1
        case 12 => GfxAttrib.TexCoord2
        case 13 => GfxAttrib.TexCoord3
        case 14 => GfxAttrib.TexCoord4
        case 15 => GfxAttrib.TexCoord5
        case 16 => GfxAttrib.TexCoord6
        case 17 => GfxAttrib.TexCoord7
        case _ => GfxAttrib.Position
    }
}

/// 数值 → GfxAttribType（未知值回退 Uint8）
internal func prebindGfxAttribType(v: Int64): GfxAttribType {
    match (v) {
        case 0 => GfxAttribType.`Int8`
        case 1 => GfxAttribType.Uint8
        case 2 => GfxAttribType.Uint10
        case 3 => GfxAttribType.`Int16`
        case 4 => GfxAttribType.Uint16
        case 5 => GfxAttribType.Half
        case 6 => GfxAttribType.Float
        case 7 => GfxAttribType.`Int32`
        case 8 => GfxAttribType.Uint32
        case _ => GfxAttribType.Uint8
    }
}

/// 数值 → GfxAccess（未知值回退 Write）
internal func prebindGfxAccess(v: Int64): GfxAccess {
    match (v) {
        case 0 => GfxAccess.Read
        case 1 => GfxAccess.Write
        case 2 => GfxAccess.ReadWrite
        case _ => GfxAccess.Write
    }
}

/// 数值 → GfxRendererType（未知值回退 Noop）
internal func prebindGfxRendererType(v: Int64): GfxRendererType {
    match (v) {
        case 0 => GfxRendererType.Noop
        case 1 => GfxRendererType.Agc
        case 2 => GfxRendererType.Direct3D11
        case 3 => GfxRendererType.Direct3D12
        case 4 => GfxRendererType.Gnm
        case 5 => GfxRendererType.Metal
        case 6 => GfxRendererType.Nvn
        case 7 => GfxRendererType.OpenGLES
        case 8 => GfxRendererType.OpenGL
        case 9 => GfxRendererType.Vulkan
        case 10 => GfxRendererType.WebGPU
        case _ => GfxRendererType.Noop
    }
}

// =============================================================================
// ===== 枚举绑定 =====
// =============================================================================

/**
 * @brief[zh-cn] 安装 GfxTextureFormat 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxTextureFormat
 * @param[en] vm The target virtual machine
 */
public func installGfxTextureFormat(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxTextureFormat")
    b.staticMethod("BC1") {_ => [LuaValue.of(Int64(GfxTextureFormat.BC1.value()))]}
    b.staticMethod("BC2") {_ => [LuaValue.of(Int64(GfxTextureFormat.BC2.value()))]}
    b.staticMethod("BC3") {_ => [LuaValue.of(Int64(GfxTextureFormat.BC3.value()))]}
    b.staticMethod("BC4") {_ => [LuaValue.of(Int64(GfxTextureFormat.BC4.value()))]}
    b.staticMethod("BC5") {_ => [LuaValue.of(Int64(GfxTextureFormat.BC5.value()))]}
    b.staticMethod("BC6H") {_ => [LuaValue.of(Int64(GfxTextureFormat.BC6H.value()))]}
    b.staticMethod("BC7") {_ => [LuaValue.of(Int64(GfxTextureFormat.BC7.value()))]}
    b.staticMethod("ETC1") {_ => [LuaValue.of(Int64(GfxTextureFormat.ETC1.value()))]}
    b.staticMethod("ETC2") {_ => [LuaValue.of(Int64(GfxTextureFormat.ETC2.value()))]}
    b.staticMethod("ETC2A") {_ => [LuaValue.of(Int64(GfxTextureFormat.ETC2A.value()))]}
    b.staticMethod("ASTC4X4") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC4X4.value()))]}
    b.staticMethod("ASTC5X4") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC5X4.value()))]}
    b.staticMethod("ASTC5X5") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC5X5.value()))]}
    b.staticMethod("ASTC6X5") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC6X5.value()))]}
    b.staticMethod("ASTC6X6") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC6X6.value()))]}
    b.staticMethod("ASTC8X5") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC8X5.value()))]}
    b.staticMethod("ASTC8X6") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC8X6.value()))]}
    b.staticMethod("ASTC8X8") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC8X8.value()))]}
    b.staticMethod("ASTC10X5") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC10X5.value()))]}
    b.staticMethod("ASTC10X6") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC10X6.value()))]}
    b.staticMethod("ASTC10X8") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC10X8.value()))]}
    b.staticMethod("ASTC10X10") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC10X10.value()))]}
    b.staticMethod("ASTC12X10") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC12X10.value()))]}
    b.staticMethod("ASTC12X12") {_ => [LuaValue.of(Int64(GfxTextureFormat.ASTC12X12.value()))]}
    b.staticMethod("A8") {_ => [LuaValue.of(Int64(GfxTextureFormat.A8.value()))]}
    b.staticMethod("R8") {_ => [LuaValue.of(Int64(GfxTextureFormat.R8.value()))]}
    b.staticMethod("R16") {_ => [LuaValue.of(Int64(GfxTextureFormat.R16.value()))]}
    b.staticMethod("R16I") {_ => [LuaValue.of(Int64(GfxTextureFormat.R16I.value()))]}
    b.staticMethod("R16F") {_ => [LuaValue.of(Int64(GfxTextureFormat.R16F.value()))]}
    b.staticMethod("RG8") {_ => [LuaValue.of(Int64(GfxTextureFormat.RG8.value()))]}
    b.staticMethod("RG16F") {_ => [LuaValue.of(Int64(GfxTextureFormat.RG16F.value()))]}
    b.staticMethod("RG32I") {_ => [LuaValue.of(Int64(GfxTextureFormat.RG32I.value()))]}
    b.staticMethod("RGB9E5F") {_ => [LuaValue.of(Int64(GfxTextureFormat.RGB9E5F.value()))]}
    b.staticMethod("RGBA8") {_ => [LuaValue.of(Int64(GfxTextureFormat.RGBA8.value()))]}
    b.staticMethod("RGBA16F") {_ => [LuaValue.of(Int64(GfxTextureFormat.RGBA16F.value()))]}
    b.staticMethod("RGBA32I") {_ => [LuaValue.of(Int64(GfxTextureFormat.RGBA32I.value()))]}
    b.staticMethod("RGBA32F") {_ => [LuaValue.of(Int64(GfxTextureFormat.RGBA32F.value()))]}
    b.staticMethod("RG11B10F") {_ => [LuaValue.of(Int64(GfxTextureFormat.RG11B10F.value()))]}
    b.staticMethod("D24") {_ => [LuaValue.of(Int64(GfxTextureFormat.D24.value()))]}
    b.staticMethod("D24S8") {_ => [LuaValue.of(Int64(GfxTextureFormat.D24S8.value()))]}
    b.staticMethod("D32") {_ => [LuaValue.of(Int64(GfxTextureFormat.D32.value()))]}
    b.staticMethod("D32F") {_ => [LuaValue.of(Int64(GfxTextureFormat.D32F.value()))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxUniformType 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxUniformType
 * @param[en] vm The target virtual machine
 */
public func installGfxUniformType(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxUniformType")
    b.staticMethod("Sampler") {_ => [LuaValue.of(Int64(GfxUniformType.Sampler.value()))]}
    b.staticMethod("Vec4") {_ => [LuaValue.of(Int64(GfxUniformType.Vec4.value()))]}
    b.staticMethod("Mat3") {_ => [LuaValue.of(Int64(GfxUniformType.Mat3.value()))]}
    b.staticMethod("Mat4") {_ => [LuaValue.of(Int64(GfxUniformType.Mat4.value()))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxAttrib 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxAttrib
 * @param[en] vm The target virtual machine
 */
public func installGfxAttrib(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxAttrib")
    b.staticMethod("Position") {_ => [LuaValue.of(Int64(GfxAttrib.Position.value()))]}
    b.staticMethod("Normal") {_ => [LuaValue.of(Int64(GfxAttrib.Normal.value()))]}
    b.staticMethod("Tangent") {_ => [LuaValue.of(Int64(GfxAttrib.Tangent.value()))]}
    b.staticMethod("Bitangent") {_ => [LuaValue.of(Int64(GfxAttrib.Bitangent.value()))]}
    b.staticMethod("Color0") {_ => [LuaValue.of(Int64(GfxAttrib.Color0.value()))]}
    b.staticMethod("Color1") {_ => [LuaValue.of(Int64(GfxAttrib.Color1.value()))]}
    b.staticMethod("Color2") {_ => [LuaValue.of(Int64(GfxAttrib.Color2.value()))]}
    b.staticMethod("Color3") {_ => [LuaValue.of(Int64(GfxAttrib.Color3.value()))]}
    b.staticMethod("Indices") {_ => [LuaValue.of(Int64(GfxAttrib.Indices.value()))]}
    b.staticMethod("Weight") {_ => [LuaValue.of(Int64(GfxAttrib.Weight.value()))]}
    b.staticMethod("TexCoord0") {_ => [LuaValue.of(Int64(GfxAttrib.TexCoord0.value()))]}
    b.staticMethod("TexCoord1") {_ => [LuaValue.of(Int64(GfxAttrib.TexCoord1.value()))]}
    b.staticMethod("TexCoord2") {_ => [LuaValue.of(Int64(GfxAttrib.TexCoord2.value()))]}
    b.staticMethod("TexCoord3") {_ => [LuaValue.of(Int64(GfxAttrib.TexCoord3.value()))]}
    b.staticMethod("TexCoord4") {_ => [LuaValue.of(Int64(GfxAttrib.TexCoord4.value()))]}
    b.staticMethod("TexCoord5") {_ => [LuaValue.of(Int64(GfxAttrib.TexCoord5.value()))]}
    b.staticMethod("TexCoord6") {_ => [LuaValue.of(Int64(GfxAttrib.TexCoord6.value()))]}
    b.staticMethod("TexCoord7") {_ => [LuaValue.of(Int64(GfxAttrib.TexCoord7.value()))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxAttribType 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxAttribType
 * @param[en] vm The target virtual machine
 */
public func installGfxAttribType(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxAttribType")
    b.staticMethod("Int8") {_ => [LuaValue.of(Int64(GfxAttribType.`Int8`.value()))]}
    b.staticMethod("Uint8") {_ => [LuaValue.of(Int64(GfxAttribType.Uint8.value()))]}
    b.staticMethod("Uint10") {_ => [LuaValue.of(Int64(GfxAttribType.Uint10.value()))]}
    b.staticMethod("Int16") {_ => [LuaValue.of(Int64(GfxAttribType.`Int16`.value()))]}
    b.staticMethod("Uint16") {_ => [LuaValue.of(Int64(GfxAttribType.Uint16.value()))]}
    b.staticMethod("Half") {_ => [LuaValue.of(Int64(GfxAttribType.Half.value()))]}
    b.staticMethod("Float") {_ => [LuaValue.of(Int64(GfxAttribType.Float.value()))]}
    b.staticMethod("Int32") {_ => [LuaValue.of(Int64(GfxAttribType.`Int32`.value()))]}
    b.staticMethod("Uint32") {_ => [LuaValue.of(Int64(GfxAttribType.Uint32.value()))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxViewMode 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxViewMode
 * @param[en] vm The target virtual machine
 */
public func installGfxViewMode(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxViewMode")
    b.staticMethod("Default") {_ => [LuaValue.of(Int64(GfxViewMode.Default.value()))]}
    b.staticMethod("Sequential") {_ => [LuaValue.of(Int64(GfxViewMode.Sequential.value()))]}
    b.staticMethod("DepthAscending") {_ => [LuaValue.of(Int64(GfxViewMode.DepthAscending.value()))]}
    b.staticMethod("DepthDescending") {_ => [LuaValue.of(Int64(GfxViewMode.DepthDescending.value()))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxBackbufferRatio 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxBackbufferRatio
 * @param[en] vm The target virtual machine
 */
public func installGfxBackbufferRatio(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxBackbufferRatio")
    b.staticMethod("Equal") {_ => [LuaValue.of(Int64(GfxBackbufferRatio.Equal.value()))]}
    b.staticMethod("Half") {_ => [LuaValue.of(Int64(GfxBackbufferRatio.Half.value()))]}
    b.staticMethod("Quarter") {_ => [LuaValue.of(Int64(GfxBackbufferRatio.Quarter.value()))]}
    b.staticMethod("Eighth") {_ => [LuaValue.of(Int64(GfxBackbufferRatio.Eighth.value()))]}
    b.staticMethod("Sixteenth") {_ => [LuaValue.of(Int64(GfxBackbufferRatio.Sixteenth.value()))]}
    b.staticMethod("Double") {_ => [LuaValue.of(Int64(GfxBackbufferRatio.Double.value()))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxAccess 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxAccess
 * @param[en] vm The target virtual machine
 */
public func installGfxAccess(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxAccess")
    b.staticMethod("Read") {_ => [LuaValue.of(Int64(GfxAccess.Read.value()))]}
    b.staticMethod("Write") {_ => [LuaValue.of(Int64(GfxAccess.Write.value()))]}
    b.staticMethod("ReadWrite") {_ => [LuaValue.of(Int64(GfxAccess.ReadWrite.value()))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxRendererType 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxRendererType
 * @param[en] vm The target virtual machine
 */
public func installGfxRendererType(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxRendererType")
    b.staticMethod("Noop") {_ => [LuaValue.of(Int64(GfxRendererType.Noop.value()))]}
    b.staticMethod("Agc") {_ => [LuaValue.of(Int64(GfxRendererType.Agc.value()))]}
    b.staticMethod("Direct3D11") {_ => [LuaValue.of(Int64(GfxRendererType.Direct3D11.value()))]}
    b.staticMethod("Direct3D12") {_ => [LuaValue.of(Int64(GfxRendererType.Direct3D12.value()))]}
    b.staticMethod("Gnm") {_ => [LuaValue.of(Int64(GfxRendererType.Gnm.value()))]}
    b.staticMethod("Metal") {_ => [LuaValue.of(Int64(GfxRendererType.Metal.value()))]}
    b.staticMethod("Nvn") {_ => [LuaValue.of(Int64(GfxRendererType.Nvn.value()))]}
    b.staticMethod("OpenGLES") {_ => [LuaValue.of(Int64(GfxRendererType.OpenGLES.value()))]}
    b.staticMethod("OpenGL") {_ => [LuaValue.of(Int64(GfxRendererType.OpenGL.value()))]}
    b.staticMethod("Vulkan") {_ => [LuaValue.of(Int64(GfxRendererType.Vulkan.value()))]}
    b.staticMethod("WebGPU") {_ => [LuaValue.of(Int64(GfxRendererType.WebGPU.value()))]}
    b.install(vm)
}

// =============================================================================
// ===== 位标志类绑定 =====
// =============================================================================

/**
 * @brief[zh-cn] 安装 GfxTextureFlag 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxTextureFlag
 * @param[en] vm The target virtual machine
 */
public func installGfxTextureFlag(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxTextureFlag")
    b.staticMethod("NONE") {_ => [LuaValue.of(Int64(GfxTextureFlag.NONE))]}
    b.staticMethod("RT") {_ => [LuaValue.of(Int64(GfxTextureFlag.RT))]}
    b.staticMethod("BLIT_DST") {_ => [LuaValue.of(Int64(GfxTextureFlag.BLIT_DST))]}
    b.staticMethod("RT_WRITE_ONLY") {_ => [LuaValue.of(Int64(GfxTextureFlag.RT_WRITE_ONLY))]}
    b.staticMethod("RT_MSAA_SAMPLE") {_ => [LuaValue.of(Int64(GfxTextureFlag.RT_MSAA_SAMPLE))]}
    b.staticMethod("RT_MSAA_X2") {_ => [LuaValue.of(Int64(GfxTextureFlag.RT_MSAA_X2))]}
    b.staticMethod("RT_MSAA_X4") {_ => [LuaValue.of(Int64(GfxTextureFlag.RT_MSAA_X4))]}
    b.staticMethod("RT_MSAA_X8") {_ => [LuaValue.of(Int64(GfxTextureFlag.RT_MSAA_X8))]}
    b.staticMethod("RT_MSAA_X16") {_ => [LuaValue.of(Int64(GfxTextureFlag.RT_MSAA_X16))]}
    b.staticMethod("COMPUTE_WRITE") {_ => [LuaValue.of(Int64(GfxTextureFlag.COMPUTE_WRITE))]}
    b.staticMethod("SRGB") {_ => [LuaValue.of(Int64(GfxTextureFlag.SRGB))]}
    b.staticMethod("READ_BACK") {_ => [LuaValue.of(Int64(GfxTextureFlag.READ_BACK))]}
    b.staticMethod("SAMPLER_U_MIRROR") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_U_MIRROR))]}
    b.staticMethod("SAMPLER_U_CLAMP") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_U_CLAMP))]}
    b.staticMethod("SAMPLER_U_BORDER") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_U_BORDER))]}
    b.staticMethod("SAMPLER_V_MIRROR") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_V_MIRROR))]}
    b.staticMethod("SAMPLER_V_CLAMP") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_V_CLAMP))]}
    b.staticMethod("SAMPLER_V_BORDER") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_V_BORDER))]}
    b.staticMethod("SAMPLER_W_MIRROR") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_W_MIRROR))]}
    b.staticMethod("SAMPLER_W_CLAMP") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_W_CLAMP))]}
    b.staticMethod("SAMPLER_W_BORDER") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_W_BORDER))]}
    b.staticMethod("SAMPLER_MIN_POINT") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_MIN_POINT))]}
    b.staticMethod("SAMPLER_MIN_ANISOTROPIC") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_MIN_ANISOTROPIC))]}
    b.staticMethod("SAMPLER_MAG_POINT") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_MAG_POINT))]}
    b.staticMethod("SAMPLER_MAG_ANISOTROPIC") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_MAG_ANISOTROPIC))]}
    b.staticMethod("SAMPLER_MIP_POINT") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_MIP_POINT))]}
    b.staticMethod("SAMPLER_POINT") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_POINT))]}
    b.staticMethod("SAMPLER_UVW_MIRROR") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_UVW_MIRROR))]}
    b.staticMethod("SAMPLER_UVW_CLAMP") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_UVW_CLAMP))]}
    b.staticMethod("SAMPLER_UVW_BORDER") {_ => [LuaValue.of(Int64(GfxTextureFlag.SAMPLER_UVW_BORDER))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxSamplerFlag 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxSamplerFlag
 * @param[en] vm The target virtual machine
 */
public func installGfxSamplerFlag(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxSamplerFlag")
    b.staticMethod("NONE") {_ => [LuaValue.of(Int64(GfxSamplerFlag.NONE))]}
    b.staticMethod("U_MIRROR") {_ => [LuaValue.of(Int64(GfxSamplerFlag.U_MIRROR))]}
    b.staticMethod("U_CLAMP") {_ => [LuaValue.of(Int64(GfxSamplerFlag.U_CLAMP))]}
    b.staticMethod("U_BORDER") {_ => [LuaValue.of(Int64(GfxSamplerFlag.U_BORDER))]}
    b.staticMethod("V_MIRROR") {_ => [LuaValue.of(Int64(GfxSamplerFlag.V_MIRROR))]}
    b.staticMethod("V_CLAMP") {_ => [LuaValue.of(Int64(GfxSamplerFlag.V_CLAMP))]}
    b.staticMethod("V_BORDER") {_ => [LuaValue.of(Int64(GfxSamplerFlag.V_BORDER))]}
    b.staticMethod("W_MIRROR") {_ => [LuaValue.of(Int64(GfxSamplerFlag.W_MIRROR))]}
    b.staticMethod("W_CLAMP") {_ => [LuaValue.of(Int64(GfxSamplerFlag.W_CLAMP))]}
    b.staticMethod("W_BORDER") {_ => [LuaValue.of(Int64(GfxSamplerFlag.W_BORDER))]}
    b.staticMethod("MIN_POINT") {_ => [LuaValue.of(Int64(GfxSamplerFlag.MIN_POINT))]}
    b.staticMethod("MIN_ANISOTROPIC") {_ => [LuaValue.of(Int64(GfxSamplerFlag.MIN_ANISOTROPIC))]}
    b.staticMethod("MAG_POINT") {_ => [LuaValue.of(Int64(GfxSamplerFlag.MAG_POINT))]}
    b.staticMethod("MAG_ANISOTROPIC") {_ => [LuaValue.of(Int64(GfxSamplerFlag.MAG_ANISOTROPIC))]}
    b.staticMethod("MIP_POINT") {_ => [LuaValue.of(Int64(GfxSamplerFlag.MIP_POINT))]}
    b.staticMethod("POINT") {_ => [LuaValue.of(Int64(GfxSamplerFlag.POINT))]}
    b.staticMethod("UVW_CLAMP") {_ => [LuaValue.of(Int64(GfxSamplerFlag.UVW_CLAMP))]}
    b.staticMethod("COMPARE_LEQUAL") {_ => [LuaValue.of(Int64(GfxSamplerFlag.COMPARE_LEQUAL))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxBufferFlag 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxBufferFlag
 * @param[en] vm The target virtual machine
 */
public func installGfxBufferFlag(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxBufferFlag")
    b.staticMethod("NONE") {_ => [LuaValue.of(Int64(GfxBufferFlag.NONE))]}
    b.staticMethod("COMPUTE_READ") {_ => [LuaValue.of(Int64(GfxBufferFlag.COMPUTE_READ))]}
    b.staticMethod("COMPUTE_WRITE") {_ => [LuaValue.of(Int64(GfxBufferFlag.COMPUTE_WRITE))]}
    b.staticMethod("COMPUTE_READ_WRITE") {_ => [LuaValue.of(Int64(GfxBufferFlag.COMPUTE_READ_WRITE))]}
    b.staticMethod("DRAW_INDIRECT") {_ => [LuaValue.of(Int64(GfxBufferFlag.DRAW_INDIRECT))]}
    b.staticMethod("ALLOW_RESIZE") {_ => [LuaValue.of(Int64(GfxBufferFlag.ALLOW_RESIZE))]}
    b.staticMethod("INDEX32") {_ => [LuaValue.of(Int64(GfxBufferFlag.INDEX32))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxState 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxState
 * @param[en] vm The target virtual machine
 */
public func installGfxState(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxState")
    b.staticMethod("NONE") {_ => [LuaValue.of(Int64(GfxState.NONE))]}
    b.staticMethod("DEFAULT") {_ => [LuaValue.of(Int64(GfxState.DEFAULT))]}
    b.staticMethod("WRITE_R") {_ => [LuaValue.of(Int64(GfxState.WRITE_R))]}
    b.staticMethod("WRITE_G") {_ => [LuaValue.of(Int64(GfxState.WRITE_G))]}
    b.staticMethod("WRITE_B") {_ => [LuaValue.of(Int64(GfxState.WRITE_B))]}
    b.staticMethod("WRITE_A") {_ => [LuaValue.of(Int64(GfxState.WRITE_A))]}
    b.staticMethod("WRITE_RGB") {_ => [LuaValue.of(Int64(GfxState.WRITE_RGB))]}
    b.staticMethod("WRITE_Z") {_ => [LuaValue.of(Int64(GfxState.WRITE_Z))]}
    b.staticMethod("DEPTH_TEST_LESS") {_ => [LuaValue.of(Int64(GfxState.DEPTH_TEST_LESS))]}
    b.staticMethod("DEPTH_TEST_LEQUAL") {_ => [LuaValue.of(Int64(GfxState.DEPTH_TEST_LEQUAL))]}
    b.staticMethod("DEPTH_TEST_EQUAL") {_ => [LuaValue.of(Int64(GfxState.DEPTH_TEST_EQUAL))]}
    b.staticMethod("DEPTH_TEST_GEQUAL") {_ => [LuaValue.of(Int64(GfxState.DEPTH_TEST_GEQUAL))]}
    b.staticMethod("DEPTH_TEST_GREATER") {_ => [LuaValue.of(Int64(GfxState.DEPTH_TEST_GREATER))]}
    b.staticMethod("DEPTH_TEST_NOTEQUAL") {_ => [LuaValue.of(Int64(GfxState.DEPTH_TEST_NOTEQUAL))]}
    b.staticMethod("DEPTH_TEST_NEVER") {_ => [LuaValue.of(Int64(GfxState.DEPTH_TEST_NEVER))]}
    b.staticMethod("DEPTH_TEST_ALWAYS") {_ => [LuaValue.of(Int64(GfxState.DEPTH_TEST_ALWAYS))]}
    b.staticMethod("BLEND_ZERO") {_ => [LuaValue.of(Int64(GfxState.BLEND_ZERO))]}
    b.staticMethod("BLEND_ONE") {_ => [LuaValue.of(Int64(GfxState.BLEND_ONE))]}
    b.staticMethod("BLEND_SRC_COLOR") {_ => [LuaValue.of(Int64(GfxState.BLEND_SRC_COLOR))]}
    b.staticMethod("BLEND_INV_SRC_COLOR") {_ => [LuaValue.of(Int64(GfxState.BLEND_INV_SRC_COLOR))]}
    b.staticMethod("BLEND_SRC_ALPHA") {_ => [LuaValue.of(Int64(GfxState.BLEND_SRC_ALPHA))]}
    b.staticMethod("BLEND_INV_SRC_ALPHA") {_ => [LuaValue.of(Int64(GfxState.BLEND_INV_SRC_ALPHA))]}
    b.staticMethod("BLEND_DST_ALPHA") {_ => [LuaValue.of(Int64(GfxState.BLEND_DST_ALPHA))]}
    b.staticMethod("BLEND_INV_DST_ALPHA") {_ => [LuaValue.of(Int64(GfxState.BLEND_INV_DST_ALPHA))]}
    b.staticMethod("BLEND_DST_COLOR") {_ => [LuaValue.of(Int64(GfxState.BLEND_DST_COLOR))]}
    b.staticMethod("BLEND_INV_DST_COLOR") {_ => [LuaValue.of(Int64(GfxState.BLEND_INV_DST_COLOR))]}
    b.staticMethod("BLEND_SRC_ALPHA_SAT") {_ => [LuaValue.of(Int64(GfxState.BLEND_SRC_ALPHA_SAT))]}
    b.staticMethod("BLEND_FACTOR") {_ => [LuaValue.of(Int64(GfxState.BLEND_FACTOR))]}
    b.staticMethod("BLEND_INV_FACTOR") {_ => [LuaValue.of(Int64(GfxState.BLEND_INV_FACTOR))]}
    b.staticMethod("BLEND_EQUATION_ADD") {_ => [LuaValue.of(Int64(GfxState.BLEND_EQUATION_ADD))]}
    b.staticMethod("BLEND_EQUATION_SUB") {_ => [LuaValue.of(Int64(GfxState.BLEND_EQUATION_SUB))]}
    b.staticMethod("BLEND_EQUATION_REVSUB") {_ => [LuaValue.of(Int64(GfxState.BLEND_EQUATION_REVSUB))]}
    b.staticMethod("BLEND_EQUATION_MIN") {_ => [LuaValue.of(Int64(GfxState.BLEND_EQUATION_MIN))]}
    b.staticMethod("BLEND_EQUATION_MAX") {_ => [LuaValue.of(Int64(GfxState.BLEND_EQUATION_MAX))]}
    b.staticMethod("BLEND_INDEPENDENT") {_ => [LuaValue.of(Int64(GfxState.BLEND_INDEPENDENT))]}
    b.staticMethod("BLEND_ALPHA_TO_COVERAGE") {_ => [LuaValue.of(Int64(GfxState.BLEND_ALPHA_TO_COVERAGE))]}
    b.staticMethod("CULL_CW") {_ => [LuaValue.of(Int64(GfxState.CULL_CW))]}
    b.staticMethod("CULL_CCW") {_ => [LuaValue.of(Int64(GfxState.CULL_CCW))]}
    b.staticMethod("FRONT_CCW") {_ => [LuaValue.of(Int64(GfxState.FRONT_CCW))]}
    b.staticMethod("PT_TRISTRIP") {_ => [LuaValue.of(Int64(GfxState.PT_TRISTRIP))]}
    b.staticMethod("PT_LINES") {_ => [LuaValue.of(Int64(GfxState.PT_LINES))]}
    b.staticMethod("PT_LINESTRIP") {_ => [LuaValue.of(Int64(GfxState.PT_LINESTRIP))]}
    b.staticMethod("PT_POINTS") {_ => [LuaValue.of(Int64(GfxState.PT_POINTS))]}
    b.staticMethod("MSAA") {_ => [LuaValue.of(Int64(GfxState.MSAA))]}
    b.staticMethod("LINEAA") {_ => [LuaValue.of(Int64(GfxState.LINEAA))]}
    b.staticMethod("CONSERVATIVE_RASTER") {_ => [LuaValue.of(Int64(GfxState.CONSERVATIVE_RASTER))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxStencilFlag 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxStencilFlag
 * @param[en] vm The target virtual machine
 */
public func installGfxStencilFlag(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxStencilFlag")
    b.staticMethod("TEST_EQUAL") {_ => [LuaValue.of(Int64(GfxStencilFlag.TEST_EQUAL))]}
    b.staticMethod("TEST_ALWAYS") {_ => [LuaValue.of(Int64(GfxStencilFlag.TEST_ALWAYS))]}
    b.staticMethod("OP_FAIL_S_KEEP") {_ => [LuaValue.of(Int64(GfxStencilFlag.OP_FAIL_S_KEEP))]}
    b.staticMethod("OP_FAIL_Z_KEEP") {_ => [LuaValue.of(Int64(GfxStencilFlag.OP_FAIL_Z_KEEP))]}
    b.staticMethod("OP_PASS_Z_KEEP") {_ => [LuaValue.of(Int64(GfxStencilFlag.OP_PASS_Z_KEEP))]}
    b.staticMethod("OP_PASS_Z_REPLACE") {_ => [LuaValue.of(Int64(GfxStencilFlag.OP_PASS_Z_REPLACE))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxClearFlag 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxClearFlag
 * @param[en] vm The target virtual machine
 */
public func installGfxClearFlag(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxClearFlag")
    b.staticMethod("NONE") {_ => [LuaValue.of(Int64(GfxClearFlag.NONE))]}
    b.staticMethod("COLOR") {_ => [LuaValue.of(Int64(GfxClearFlag.COLOR))]}
    b.staticMethod("DEPTH") {_ => [LuaValue.of(Int64(GfxClearFlag.DEPTH))]}
    b.staticMethod("STENCIL") {_ => [LuaValue.of(Int64(GfxClearFlag.STENCIL))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxResetFlag 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxResetFlag
 * @param[en] vm The target virtual machine
 */
public func installGfxResetFlag(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxResetFlag")
    b.staticMethod("NONE") {_ => [LuaValue.of(Int64(GfxResetFlag.NONE))]}
    b.staticMethod("VSYNC") {_ => [LuaValue.of(Int64(GfxResetFlag.VSYNC))]}
    b.staticMethod("MAXANISOTROPY") {_ => [LuaValue.of(Int64(GfxResetFlag.MAXANISOTROPY))]}
    b.staticMethod("MSAA_X2") {_ => [LuaValue.of(Int64(GfxResetFlag.MSAA_X2))]}
    b.staticMethod("MSAA_X4") {_ => [LuaValue.of(Int64(GfxResetFlag.MSAA_X4))]}
    b.staticMethod("MSAA_X8") {_ => [LuaValue.of(Int64(GfxResetFlag.MSAA_X8))]}
    b.staticMethod("MSAA_X16") {_ => [LuaValue.of(Int64(GfxResetFlag.MSAA_X16))]}
    b.install(vm)
}

// =============================================================================
// ===== 值结构绑定 =====
// =============================================================================

/**
 * @brief[zh-cn] 安装 GfxAttributeDesc 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxAttributeDesc
 * @param[en] vm The target virtual machine
 */
public func installGfxAttributeDesc(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxAttributeDesc")
    b.constructor {
        args => GfxAttributeDesc(prebindGfxAttrib(prebindInt(args, 0)), UInt8(prebindInt(args, 1) & 0xFF),
            prebindGfxAttribType(prebindInt(args, 2)), normalized: prebindBool(args, 3), asInt: prebindBool(args, 4))
    }
    b.property("attrib", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxAttributeDesc>().attrib.value()))}))
    b.property("num", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxAttributeDesc>().num))}))
    b.property("attribType", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxAttributeDesc>().attribType.value()))}))
    b.property("normalized", getter: Some({ref => LuaValue.of(ref.cast<GfxAttributeDesc>().normalized)}))
    b.property("asInt", getter: Some({ref => LuaValue.of(ref.cast<GfxAttributeDesc>().asInt)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxAttachmentDesc 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxAttachmentDesc
 * @param[en] vm The target virtual machine
 */
public func installGfxAttachmentDesc(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxAttachmentDesc")
    b.constructor {
        args => GfxAttachmentDesc(prebindTextureHandle(args, 0), access: prebindGfxAccess(prebindInt(args, 1, default: 1)),
            layer: UInt16(prebindInt(args, 2) & 0xFFFF), numLayers: UInt16(prebindInt(args, 3, default: 1) & 0xFFFF),
            mip: UInt8(prebindInt(args, 4) & 0xFF), resolve: UInt8(prebindInt(args, 5) & 0xFF))
    }
    b.property("texture", getter: Some({ref => LuaValue.of(prebindGfxHandleIdx(ref.cast<GfxAttachmentDesc>().texture))}))
    b.property("access", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxAttachmentDesc>().access.value()))}))
    b.property("layer", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxAttachmentDesc>().layer))}))
    b.property("numLayers", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxAttachmentDesc>().numLayers))}))
    b.property("mip", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxAttachmentDesc>().mip))}))
    b.property("resolve", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxAttachmentDesc>().resolve))}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxUniformDesc 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxUniformDesc
 * @param[en] vm The target virtual machine
 */
public func installGfxUniformDesc(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxUniformDesc")
    b.constructor {
        args => GfxUniformDesc(name: prebindStr(args, 0), uniformType: prebindGfxUniformType(prebindInt(args, 1)),
            num: UInt16(prebindInt(args, 2, default: 1) & 0xFFFF))
    }
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<GfxUniformDesc>().name)}))
    b.property("uniformType", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxUniformDesc>().uniformType.value()))}))
    b.property("num", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxUniformDesc>().num))}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxCapsSummary 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxCapsSummary
 * @param[en] vm The target virtual machine
 */
public func installGfxCapsSummary(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxCapsSummary")
    b.constructor {
        args => GfxCapsSummary(prebindGfxRendererType(prebindInt(args, 0)), vendorId: UInt16(prebindInt(args, 1) & 0xFFFF),
            deviceId: UInt16(prebindInt(args, 2) & 0xFFFF), supported: UInt64(prebindInt(args, 3)),
            originBottomLeft: prebindBool(args, 4), maxTextureSize: UInt32(prebindInt(args, 5) & 0xFFFFFFFF),
            maxViews: UInt32(prebindInt(args, 6) & 0xFFFFFFFF))
    }
    b.property("rendererType",
        getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxCapsSummary>().rendererType.value()))}))
    b.property("vendorId", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxCapsSummary>().vendorId))}))
    b.property("deviceId", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxCapsSummary>().deviceId))}))
    b.property("supported", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxCapsSummary>().supported))}))
    b.property("originBottomLeft", getter: Some({ref => LuaValue.of(ref.cast<GfxCapsSummary>().originBottomLeft)}))
    b.property("maxTextureSize", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxCapsSummary>().maxTextureSize))}))
    b.property("maxViews", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxCapsSummary>().maxViews))}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxStatsSummary 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxStatsSummary
 * @param[en] vm The target virtual machine
 */
public func installGfxStatsSummary(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxStatsSummary")
    b.constructor {
        args => GfxStatsSummary(cpuTimeFrame: prebindNum(args, 0), gpuTimeFrame: prebindNum(args, 1),
            drawCalls: UInt32(prebindInt(args, 2) & 0xFFFFFFFF), computeCalls: UInt32(prebindInt(args, 3) & 0xFFFFFFFF),
            blitCalls: UInt32(prebindInt(args, 4) & 0xFFFFFFFF), textureMemoryUsed: prebindInt(args, 5))
    }
    b.property("cpuTimeFrame", getter: Some({ref => LuaValue.of(ref.cast<GfxStatsSummary>().cpuTimeFrame)}))
    b.property("gpuTimeFrame", getter: Some({ref => LuaValue.of(ref.cast<GfxStatsSummary>().gpuTimeFrame)}))
    b.property("drawCalls", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxStatsSummary>().drawCalls))}))
    b.property("computeCalls", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxStatsSummary>().computeCalls))}))
    b.property("blitCalls", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxStatsSummary>().blitCalls))}))
    b.property("textureMemoryUsed", getter: Some({ref => LuaValue.of(ref.cast<GfxStatsSummary>().textureMemoryUsed)}))
    b.install(vm)
}
