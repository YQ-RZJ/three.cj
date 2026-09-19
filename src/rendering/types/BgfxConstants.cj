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
 * @file[zh-cn] BgfxConstants bgfx 常量全量重公开
 * @brief[zh-cn] bgfx 常量全量重公开，外部使用 Three.cj 无须接触 bgfx4cj
 * @explain[zh-cn] 与 BgfxTypes.cj 相同，本文件把 bgfx4cj.bgfx.constants 中全部
 * 公开常量（309 个）以 public let 别名重公开到 three.rendering.types，
 * 使外部（postprocessing / objects / 自定义渲染扩展）只依赖 Three.cj，
 * 即可完全脱离对 bgfx 底层的操作。
 * 常量与枚举/句柄类型同源（bgfx C API 的 bit mask与状态字），
 * 一并放在 renderers 层独立 types 包，命名与 bgfx 原生保持一致。
 * 使用方式：外部 import three.rendering.types.* 后，直接引用
 * STATE_DEPTH_TEST_LESS / SAMPLER_U_CLAMP / CLEAR_COLOR 等，
 * 与原先引用 bgfx.STATE_DEPTH_TEST_LESS 语义完全等价。
 *
 * @file[en] BgfxConstants bgfx constants re-export
 * @brief[en] Full re-export of bgfx constants, external Three.cj users need not reference bgfx4cj
 * @explain[en] Similar to BgfxTypes.cj, this file re-exports all public constants (309)
 * from bgfx4cj.bgfx.constants as public let aliases into three.rendering.types,
 * allowing external code (postprocessing / objects / custom rendering extensions)
 * to depend only on Three.cj without touching the low-level bgfx layer.
 * Constants share the same source as enum/handle types (bgfx C API bitmasks and state words),
 * and are placed in the renderers-level types package with naming consistent with bgfx native.
 * Usage: after import three.rendering.types.*, reference
 * STATE_DEPTH_TEST_LESS / SAMPLER_U_CLAMP / CLEAR_COLOR etc.,
 * which are semantically equivalent to referencing bgfx.STATE_DEPTH_TEST_LESS.
 *
 * @package three.rendering.types
 */
package three.rendering.types

import bgfx4cj.bgfx as bgfx

// =============================================================================
// API 版本
// =============================================================================
/**
 * @brief[zh-cn] bgfx API 版本号
 *
 * @brief[en] bgfx API version number
 */
public let BGFX_API_VERSION: UInt32 = bgfx.BGFX_API_VERSION

// =============================================================================
// Buffer - 缓冲创建 flags
// =============================================================================
/**
 * @brief[zh-cn] 无特殊标志
 *
 * @brief[en] No special flags
 */
public let BUFFER_NONE: UInt16 = bgfx.BUFFER_NONE
/**
 * @brief[zh-cn] 计算缓冲可读
 *
 * @brief[en] Compute buffer readable
 */
public let BUFFER_COMPUTE_READ: UInt16 = bgfx.BUFFER_COMPUTE_READ
/**
 * @brief[zh-cn] 计算缓冲可写
 *
 * @brief[en] Compute buffer writable
 */
public let BUFFER_COMPUTE_WRITE: UInt16 = bgfx.BUFFER_COMPUTE_WRITE
/**
 * @brief[zh-cn] 计算缓冲可读写
 *
 * @brief[en] Compute buffer read-write
 */
public let BUFFER_COMPUTE_READ_WRITE: UInt16 = bgfx.BUFFER_COMPUTE_READ_WRITE
/**
 * @brief[zh-cn] 允许动态缓冲 resize
 *
 * @brief[en] Allow dynamic buffer resize
 */
public let BUFFER_ALLOW_RESIZE: UInt16 = bgfx.BUFFER_ALLOW_RESIZE
/**
 * @brief[zh-cn] 间接绘制缓冲
 *
 * @brief[en] Draw indirectbuffer
 */
public let BUFFER_DRAW_INDIRECT: UInt16 = bgfx.BUFFER_DRAW_INDIRECT
/**
 * @brief[zh-cn] 32bit 索引缓冲
 *
 * @brief[en] 32bit indexbuffer
 */
public let BUFFER_INDEX32: UInt16 = bgfx.BUFFER_INDEX32

// =============================================================================
// Caps - 能力标志（64bit）
// =============================================================================
/**
 * @brief[zh-cn] 独立混合支持
 *
 * @brief[en] Independentblendsupport
 */
public let CAPS_BLEND_INDEPENDENT: UInt64 = bgfx.CAPS_BLEND_INDEPENDENT
/**
 * @brief[zh-cn] 计算着色器支持
 *
 * @brief[en] Computeshadersupport
 */
public let CAPS_COMPUTE: UInt64 = bgfx.CAPS_COMPUTE
/**
 * @brief[zh-cn] 保守光栅化支持
 *
 * @brief[en] Conservative rasterization support
 */
public let CAPS_CONSERVATIVE_RASTER: UInt64 = bgfx.CAPS_CONSERVATIVE_RASTER
/**
 * @brief[zh-cn] 间接绘制支持
 *
 * @brief[en] Draw indirectsupport
 */
public let CAPS_DRAW_INDIRECT: UInt64 = bgfx.CAPS_DRAW_INDIRECT
/**
 * @brief[zh-cn] 带计数的间接绘制支持
 *
 * @brief[en] With countdraw indirectsupport
 */
public let CAPS_DRAW_INDIRECT_COUNT: UInt64 = bgfx.CAPS_DRAW_INDIRECT_COUNT
/**
 * @brief[zh-cn] 片元排序支持
 *
 * @brief[en] Fragment orderingsupport
 */
public let CAPS_FRAGMENT_ORDERING: UInt64 = bgfx.CAPS_FRAGMENT_ORDERING
/**
 * @brief[zh-cn] Graphics debugger support
 *
 * @brief[en] Graphics debugger support
 */
public let CAPS_GRAPHICS_DEBUGGER: UInt64 = bgfx.CAPS_GRAPHICS_DEBUGGER
/**
 * @brief[zh-cn] HDR10 支持
 *
 * @brief[en] HDR10 support
 */
public let CAPS_HDR10: UInt64 = bgfx.CAPS_HDR10
/**
 * @brief[zh-cn] 图像读写支持
 *
 * @brief[en] Image read-writesupport
 */
public let CAPS_IMAGE_RW: UInt64 = bgfx.CAPS_IMAGE_RW
/**
 * @brief[zh-cn] 32bit 索引支持
 *
 * @brief[en] 32-bit indexsupport
 */
public let CAPS_INDEX32: UInt64 = bgfx.CAPS_INDEX32
/**
 * @brief[zh-cn] 图元 ID 支持
 *
 * @brief[en] Primitive ID support
 */
public let CAPS_PRIMITIVE_ID: UInt64 = bgfx.CAPS_PRIMITIVE_ID
/**
 * @brief[zh-cn] 多线程渲染器支持
 *
 * @brief[en] Multi-threaded renderer support
 */
public let CAPS_RENDERER_MULTITHREADED: UInt64 = bgfx.CAPS_RENDERER_MULTITHREADED
/**
 * @brief[zh-cn] 交换链支持
 *
 * @brief[en] Swap chain support
 */
public let CAPS_SWAP_CHAIN: UInt64 = bgfx.CAPS_SWAP_CHAIN
/**
 * @brief[zh-cn] Cube texture array support
 *
 * @brief[en] Cube texture array support
 */
public let CAPS_TEXTURE_CUBE_ARRAY: UInt64 = bgfx.CAPS_TEXTURE_CUBE_ARRAY
/**
 * @brief[zh-cn] Texture direct access support
 *
 * @brief[en] Texture direct access support
 */
public let CAPS_TEXTURE_DIRECT_ACCESS: UInt64 = bgfx.CAPS_TEXTURE_DIRECT_ACCESS
/**
 * @brief[zh-cn] Transparent backbuffer support
 *
 * @brief[en] Transparent backbuffer support
 */
public let CAPS_TRANSPARENT_BACKBUFFER: UInt64 = bgfx.CAPS_TRANSPARENT_BACKBUFFER
/**
 * @brief[zh-cn] 顶点属性 UInt10 支持
 *
 * @brief[en] Vertex attribute UInt10 support
 */
public let CAPS_VERTEX_ATTRIB_UINT10: UInt64 = bgfx.CAPS_VERTEX_ATTRIB_UINT10
/**
 * @brief[zh-cn] Viewport layer array support
 *
 * @brief[en] Viewport layer array support
 */
public let CAPS_VIEWPORT_LAYER_ARRAY: UInt64 = bgfx.CAPS_VIEWPORT_LAYER_ARRAY

// =============================================================================
// Caps - 格式能力标志（32bit，CAPS_FORMAT_TEXTURE_*）
// =============================================================================
/**
 * @brief[zh-cn] 格式无能力
 *
 * @brief[en] Format not supported
 */
public let CAPS_FORMAT_TEXTURE_NONE: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_NONE
/**
 * @brief[zh-cn] 2D 纹理支持
 *
 * @brief[en] 2D texturesupport
 */
public let CAPS_FORMAT_TEXTURE_2D: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_2D
/**
 * @brief[zh-cn] 2D sRGB 纹理支持
 *
 * @brief[en] 2D sRGB texturesupport
 */
public let CAPS_FORMAT_TEXTURE_2D_SRGB: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_2D_SRGB
/**
 * @brief[zh-cn] 2D emulated texture support
 *
 * @brief[en] 2D emulated texture support
 */
public let CAPS_FORMAT_TEXTURE_2D_EMULATED: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_2D_EMULATED
/**
 * @brief[zh-cn] 3D 纹理支持
 *
 * @brief[en] 3D texturesupport
 */
public let CAPS_FORMAT_TEXTURE_3D: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_3D
/**
 * @brief[zh-cn] 3D sRGB 纹理支持
 *
 * @brief[en] 3D sRGB texturesupport
 */
public let CAPS_FORMAT_TEXTURE_3D_SRGB: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_3D_SRGB
/**
 * @brief[zh-cn] 3D emulated texture support
 *
 * @brief[en] 3D emulated texture support
 */
public let CAPS_FORMAT_TEXTURE_3D_EMULATED: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_3D_EMULATED
/**
 * @brief[zh-cn] 立方体纹理支持
 *
 * @brief[en] cubetexturesupport
 */
public let CAPS_FORMAT_TEXTURE_CUBE: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_CUBE
/**
 * @brief[zh-cn] 立方体 sRGB 纹理支持
 *
 * @brief[en] cube sRGB texturesupport
 */
public let CAPS_FORMAT_TEXTURE_CUBE_SRGB: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_CUBE_SRGB
/**
 * @brief[zh-cn] Cube emulated texture support
 *
 * @brief[en] Cube emulated texture support
 */
public let CAPS_FORMAT_TEXTURE_CUBE_EMULATED: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_CUBE_EMULATED
/**
 * @brief[zh-cn] 顶点缓冲纹理支持
 *
 * @brief[en] Vertexbuffertexturesupport
 */
public let CAPS_FORMAT_TEXTURE_VERTEX: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_VERTEX
/**
 * @brief[zh-cn] Image read support
 *
 * @brief[en] Image read support
 */
public let CAPS_FORMAT_TEXTURE_IMAGE_READ: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_IMAGE_READ
/**
 * @brief[zh-cn] Image write support
 *
 * @brief[en] Image write support
 */
public let CAPS_FORMAT_TEXTURE_IMAGE_WRITE: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_IMAGE_WRITE
/**
 * @brief[zh-cn] 帧缓冲支持
 *
 * @brief[en] Framebuffersupport
 */
public let CAPS_FORMAT_TEXTURE_FRAMEBUFFER: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_FRAMEBUFFER
/**
 * @brief[zh-cn] MSAA 帧缓冲支持
 *
 * @brief[en] MSAA framebuffersupport
 */
public let CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA
/**
 * @brief[zh-cn] MSAA 纹理支持
 *
 * @brief[en] MSAA texturesupport
 */
public let CAPS_FORMAT_TEXTURE_MSAA: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_MSAA
/**
 * @brief[zh-cn] Auto mipmap generation support
 *
 * @brief[en] Auto mipmap generation support
 */
public let CAPS_FORMAT_TEXTURE_MIP_AUTOGEN: UInt32 = bgfx.CAPS_FORMAT_TEXTURE_MIP_AUTOGEN

// =============================================================================
// Clear - 清除 flags
// =============================================================================
/**
 * @brief[zh-cn] 无清除
 *
 * @brief[en] No clear
 */
public let CLEAR_NONE: UInt16 = bgfx.CLEAR_NONE
/**
 * @brief[zh-cn] Clear color
 *
 * @brief[en] Clear color
 */
public let CLEAR_COLOR: UInt16 = bgfx.CLEAR_COLOR
/**
 * @brief[zh-cn] Clear depth
 *
 * @brief[en] Clear depth
 */
public let CLEAR_DEPTH: UInt16 = bgfx.CLEAR_DEPTH
/**
 * @brief[zh-cn] Clear stencil
 *
 * @brief[en] Clear stencil
 */
public let CLEAR_STENCIL: UInt16 = bgfx.CLEAR_STENCIL
/**
 * @brief[zh-cn] 丢弃颜色附件 0
 *
 * @brief[en] Discardcolorattachment 0
 */
public let CLEAR_DISCARD_COLOR_0: UInt16 = bgfx.CLEAR_DISCARD_COLOR_0
/**
 * @brief[zh-cn] 丢弃颜色附件 1
 *
 * @brief[en] Discardcolorattachment 1
 */
public let CLEAR_DISCARD_COLOR_1: UInt16 = bgfx.CLEAR_DISCARD_COLOR_1
/**
 * @brief[zh-cn] 丢弃颜色附件 2
 *
 * @brief[en] Discardcolorattachment 2
 */
public let CLEAR_DISCARD_COLOR_2: UInt16 = bgfx.CLEAR_DISCARD_COLOR_2
/**
 * @brief[zh-cn] 丢弃颜色附件 3
 *
 * @brief[en] Discardcolorattachment 3
 */
public let CLEAR_DISCARD_COLOR_3: UInt16 = bgfx.CLEAR_DISCARD_COLOR_3
/**
 * @brief[zh-cn] 丢弃颜色附件 4
 *
 * @brief[en] Discardcolorattachment 4
 */
public let CLEAR_DISCARD_COLOR_4: UInt16 = bgfx.CLEAR_DISCARD_COLOR_4
/**
 * @brief[zh-cn] 丢弃颜色附件 5
 *
 * @brief[en] Discardcolorattachment 5
 */
public let CLEAR_DISCARD_COLOR_5: UInt16 = bgfx.CLEAR_DISCARD_COLOR_5
/**
 * @brief[zh-cn] 丢弃颜色附件 6
 *
 * @brief[en] Discardcolorattachment 6
 */
public let CLEAR_DISCARD_COLOR_6: UInt16 = bgfx.CLEAR_DISCARD_COLOR_6
/**
 * @brief[zh-cn] 丢弃颜色附件 7
 *
 * @brief[en] Discardcolorattachment 7
 */
public let CLEAR_DISCARD_COLOR_7: UInt16 = bgfx.CLEAR_DISCARD_COLOR_7
/**
 * @brief[zh-cn] 丢弃颜色附件mask
 *
 * @brief[en] Discardcolorattachmentmask
 */
public let CLEAR_DISCARD_COLOR_MASK: UInt16 = bgfx.CLEAR_DISCARD_COLOR_MASK
/**
 * @brief[zh-cn] 丢弃深度
 *
 * @brief[en] Discarddepth
 */
public let CLEAR_DISCARD_DEPTH: UInt16 = bgfx.CLEAR_DISCARD_DEPTH
/**
 * @brief[zh-cn] 丢弃模板
 *
 * @brief[en] Discardstencil
 */
public let CLEAR_DISCARD_STENCIL: UInt16 = bgfx.CLEAR_DISCARD_STENCIL
/**
 * @brief[zh-cn] 丢弃mask
 *
 * @brief[en] Discardmask
 */
public let CLEAR_DISCARD_MASK: UInt16 = bgfx.CLEAR_DISCARD_MASK

// =============================================================================
// Debug - 调试 flags
// =============================================================================
/**
 * @brief[zh-cn] 无调试
 *
 * @brief[en] nodebug
 */
public let DEBUG_NONE: UInt32 = bgfx.DEBUG_NONE
/**
 * @brief[zh-cn] 线框调试
 *
 * @brief[en] wireframedebug
 */
public let DEBUG_WIREFRAME: UInt32 = bgfx.DEBUG_WIREFRAME
/**
 * @brief[zh-cn] IFH（无句柄）调试
 *
 * @brief[en] IFH（nohandle）debug
 */
public let DEBUG_IFH: UInt32 = bgfx.DEBUG_IFH
/**
 * @brief[zh-cn] 统计调试
 *
 * @brief[en] Statisticsdebug
 */
public let DEBUG_STATS: UInt32 = bgfx.DEBUG_STATS
/**
 * @brief[zh-cn] 文本调试
 *
 * @brief[en] textdebug
 */
public let DEBUG_TEXT: UInt32 = bgfx.DEBUG_TEXT
/**
 * @brief[zh-cn] 性能分析调试
 *
 * @brief[en] profilingdebug
 */
public let DEBUG_PROFILER: UInt32 = bgfx.DEBUG_PROFILER

// =============================================================================
// Discard - 丢弃 flags（UInt8）
// =============================================================================
/**
 * @brief[zh-cn] 无丢弃
 *
 * @brief[en] NoDiscard
 */
public let DISCARD_NONE: UInt8 = bgfx.DISCARD_NONE
/**
 * @brief[zh-cn] 丢弃绑定
 *
 * @brief[en] Discardbinding
 */
public let DISCARD_BINDINGS: UInt8 = bgfx.DISCARD_BINDINGS
/**
 * @brief[zh-cn] 丢弃索引缓冲
 *
 * @brief[en] Discardindexbuffer
 */
public let DISCARD_INDEX_BUFFER: UInt8 = bgfx.DISCARD_INDEX_BUFFER
/**
 * @brief[zh-cn] 丢弃实例数据
 *
 * @brief[en] Discardinstancedata
 */
public let DISCARD_INSTANCE_DATA: UInt8 = bgfx.DISCARD_INSTANCE_DATA
/**
 * @brief[zh-cn] 丢弃状态
 *
 * @brief[en] Discardstate
 */
public let DISCARD_STATE: UInt8 = bgfx.DISCARD_STATE
/**
 * @brief[zh-cn] 丢弃变换
 *
 * @brief[en] Discardtransform
 */
public let DISCARD_TRANSFORM: UInt8 = bgfx.DISCARD_TRANSFORM
/**
 * @brief[zh-cn] 丢弃顶点流
 *
 * @brief[en] Discardvertexstream
 */
public let DISCARD_VERTEX_STREAMS: UInt8 = bgfx.DISCARD_VERTEX_STREAMS
/**
 * @brief[zh-cn] 丢弃全部
 *
 * @brief[en] Discard all
 */
public let DISCARD_ALL: UInt8 = bgfx.DISCARD_ALL

// =============================================================================
// PCI ID - 厂商标识
// =============================================================================
/**
 * @brief[zh-cn] 无厂商
 *
 * @brief[en] No vendor
 */
public let PCI_ID_NONE: UInt16 = bgfx.PCI_ID_NONE
/**
 * @brief[zh-cn] 软件光栅化
 *
 * @brief[en] Software rasterization
 */
public let PCI_ID_SOFTWARE_RASTERIZER: UInt16 = bgfx.PCI_ID_SOFTWARE_RASTERIZER
/**
 * @brief[zh-cn] AMD
 *
 * @brief[en] AMD
 */
public let PCI_ID_AMD: UInt16 = bgfx.PCI_ID_AMD
/**
 * @brief[zh-cn] Apple
 *
 * @brief[en] Apple
 */
public let PCI_ID_APPLE: UInt16 = bgfx.PCI_ID_APPLE
/**
 * @brief[zh-cn] Intel
 *
 * @brief[en] Intel
 */
public let PCI_ID_INTEL: UInt16 = bgfx.PCI_ID_INTEL
/**
 * @brief[zh-cn] Microsoft
 *
 * @brief[en] Microsoft
 */
public let PCI_ID_MICROSOFT: UInt16 = bgfx.PCI_ID_MICROSOFT
/**
 * @brief[zh-cn] NVIDIA
 *
 * @brief[en] NVIDIA
 */
public let PCI_ID_NVIDIA: UInt16 = bgfx.PCI_ID_NVIDIA

// =============================================================================
// Reset - 重置 flags
// =============================================================================
/**
 * @brief[zh-cn] 无重置
 *
 * @brief[en] No reset
 */
public let RESET_NONE: UInt32 = bgfx.RESET_NONE
/**
 * @brief[zh-cn] 全屏
 *
 * @brief[en] fullscreen
 */
public let RESET_FULLSCREEN: UInt32 = bgfx.RESET_FULLSCREEN
/**
 * @brief[zh-cn] 全屏 bit offset
 *
 * @brief[en] Fullscreen bit offset
 */
public let RESET_FULLSCREEN_SHIFT: UInt32 = bgfx.RESET_FULLSCREEN_SHIFT
/**
 * @brief[zh-cn] 全屏 bit mask
 *
 * @brief[en] Fullscreen bit mask
 */
public let RESET_FULLSCREEN_MASK: UInt32 = bgfx.RESET_FULLSCREEN_MASK
/**
 * @brief[zh-cn] MSAA ×2
 *
 * @brief[en] MSAA ×2
 */
public let RESET_MSAA_X2: UInt32 = bgfx.RESET_MSAA_X2
/**
 * @brief[zh-cn] MSAA ×4
 *
 * @brief[en] MSAA ×4
 */
public let RESET_MSAA_X4: UInt32 = bgfx.RESET_MSAA_X4
/**
 * @brief[zh-cn] MSAA ×8
 *
 * @brief[en] MSAA ×8
 */
public let RESET_MSAA_X8: UInt32 = bgfx.RESET_MSAA_X8
/**
 * @brief[zh-cn] MSAA ×16
 *
 * @brief[en] MSAA ×16
 */
public let RESET_MSAA_X16: UInt32 = bgfx.RESET_MSAA_X16
/**
 * @brief[zh-cn] MSAA  bit offset
 *
 * @brief[en] MSAA bit offset
 */
public let RESET_MSAA_SHIFT: UInt32 = bgfx.RESET_MSAA_SHIFT
/**
 * @brief[zh-cn] MSAA  bit mask
 *
 * @brief[en] MSAA bit mask
 */
public let RESET_MSAA_MASK: UInt32 = bgfx.RESET_MSAA_MASK
/**
 * @brief[zh-cn] VSync
 *
 * @brief[en] VSync
 */
public let RESET_VSYNC: UInt32 = bgfx.RESET_VSYNC
/**
 * @brief[zh-cn] 最大各向异性
 *
 * @brief[en] Maxanisotropic
 */
public let RESET_MAXANISOTROPY: UInt32 = bgfx.RESET_MAXANISOTROPY
/**
 * @brief[zh-cn] 捕获
 *
 * @brief[en] Capture
 */
public let RESET_CAPTURE: UInt32 = bgfx.RESET_CAPTURE
/**
 * @brief[zh-cn] 渲染后刷新
 *
 * @brief[en] Post-render flush
 */
public let RESET_FLUSH_AFTER_RENDER: UInt32 = bgfx.RESET_FLUSH_AFTER_RENDER
/**
 * @brief[zh-cn] 渲染后翻转
 *
 * @brief[en] Post-render flip
 */
public let RESET_FLIP_AFTER_RENDER: UInt32 = bgfx.RESET_FLIP_AFTER_RENDER
/**
 * @brief[zh-cn] sRGB back缓冲
 *
 * @brief[en] sRGB backbuffer
 */
public let RESET_SRGB_BACKBUFFER: UInt32 = bgfx.RESET_SRGB_BACKBUFFER
/**
 * @brief[zh-cn] HDR10
 *
 * @brief[en] HDR10
 */
public let RESET_HDR10: UInt32 = bgfx.RESET_HDR10
/**
 * @brief[zh-cn] HiDPI
 *
 * @brief[en] HiDPI
 */
public let RESET_HIDPI: UInt32 = bgfx.RESET_HIDPI
/**
 * @brief[zh-cn] 深度clamp
 *
 * @brief[en] Depth clamp
 */
public let RESET_DEPTH_CLAMP: UInt32 = bgfx.RESET_DEPTH_CLAMP
/**
 * @brief[zh-cn] Suspended
 *
 * @brief[en] Suspended
 */
public let RESET_SUSPEND: UInt32 = bgfx.RESET_SUSPEND
/**
 * @brief[zh-cn] 透明back缓冲
 *
 * @brief[en] Transparent backbuffer
 */
public let RESET_TRANSPARENT_BACKBUFFER: UInt32 = bgfx.RESET_TRANSPARENT_BACKBUFFER
/**
 * @brief[zh-cn] 保留 bit offset
 *
 * @brief[en] preservebit offset
 */
public let RESET_RESERVED_SHIFT: UInt32 = bgfx.RESET_RESERVED_SHIFT
/**
 * @brief[zh-cn] 保留 bit mask
 *
 * @brief[en] preservebit mask
 */
public let RESET_RESERVED_MASK: UInt32 = bgfx.RESET_RESERVED_MASK

// =============================================================================
// Resolve - 解析 flags
// =============================================================================
/**
 * @brief[zh-cn] 无解析
 *
 * @brief[en] No resolve
 */
public let RESOLVE_NONE: UInt8 = bgfx.RESOLVE_NONE
/**
 * @brief[zh-cn] 自动生成 mipmap
 *
 * @brief[en] autogeneration mipmap
 */
public let RESOLVE_AUTO_GEN_MIPS: UInt8 = bgfx.RESOLVE_AUTO_GEN_MIPS

// =============================================================================
// Sampler - 采样器 flags
// =============================================================================
/**
 * @brief[zh-cn] 无采样器标志
 *
 * @brief[en] nosamplerflag
 */
public let SAMPLER_NONE: UInt32 = bgfx.SAMPLER_NONE
/**
 * @brief[zh-cn] U 方向镜像
 *
 * @brief[en] U direction mirror
 */
public let SAMPLER_U_MIRROR: UInt32 = bgfx.SAMPLER_U_MIRROR
/**
 * @brief[zh-cn] U 方向clamp位
 *
 * @brief[en] U direction clamp bit
 */
public let SAMPLER_U_CLAMP: UInt32 = bgfx.SAMPLER_U_CLAMP
/**
 * @brief[zh-cn] U 方向边界
 *
 * @brief[en] U direction border
 */
public let SAMPLER_U_BORDER: UInt32 = bgfx.SAMPLER_U_BORDER
/**
 * @brief[zh-cn] U 方向 bit offset
 *
 * @brief[en] U direction bit offset
 */
public let SAMPLER_U_SHIFT: UInt32 = bgfx.SAMPLER_U_SHIFT
/**
 * @brief[zh-cn] U 方向 bit mask
 *
 * @brief[en] U direction bit mask
 */
public let SAMPLER_U_MASK: UInt32 = bgfx.SAMPLER_U_MASK
/**
 * @brief[zh-cn] V 方向镜像
 *
 * @brief[en] V direction mirror
 */
public let SAMPLER_V_MIRROR: UInt32 = bgfx.SAMPLER_V_MIRROR
/**
 * @brief[zh-cn] V 方向clamp位
 *
 * @brief[en] V direction clamp bit
 */
public let SAMPLER_V_CLAMP: UInt32 = bgfx.SAMPLER_V_CLAMP
/**
 * @brief[zh-cn] V 方向边界
 *
 * @brief[en] V direction border
 */
public let SAMPLER_V_BORDER: UInt32 = bgfx.SAMPLER_V_BORDER
/**
 * @brief[zh-cn] V 方向 bit offset
 *
 * @brief[en] V direction bit offset
 */
public let SAMPLER_V_SHIFT: UInt32 = bgfx.SAMPLER_V_SHIFT
/**
 * @brief[zh-cn] V 方向 bit mask
 *
 * @brief[en] V direction bit mask
 */
public let SAMPLER_V_MASK: UInt32 = bgfx.SAMPLER_V_MASK
/**
 * @brief[zh-cn] W 方向镜像
 *
 * @brief[en] W direction mirror
 */
public let SAMPLER_W_MIRROR: UInt32 = bgfx.SAMPLER_W_MIRROR
/**
 * @brief[zh-cn] W 方向clamp位
 *
 * @brief[en] W direction clamp bit
 */
public let SAMPLER_W_CLAMP: UInt32 = bgfx.SAMPLER_W_CLAMP
/**
 * @brief[zh-cn] W 方向边界
 *
 * @brief[en] W direction border
 */
public let SAMPLER_W_BORDER: UInt32 = bgfx.SAMPLER_W_BORDER
/**
 * @brief[zh-cn] W 方向 bit offset
 *
 * @brief[en] W direction bit offset
 */
public let SAMPLER_W_SHIFT: UInt32 = bgfx.SAMPLER_W_SHIFT
/**
 * @brief[zh-cn] W 方向 bit mask
 *
 * @brief[en] W direction bit mask
 */
public let SAMPLER_W_MASK: UInt32 = bgfx.SAMPLER_W_MASK
/**
 * @brief[zh-cn] 缩小过滤：点采样
 *
 * @brief[en] Min filtering: point sampling
 */
public let SAMPLER_MIN_POINT: UInt32 = bgfx.SAMPLER_MIN_POINT
/**
 * @brief[zh-cn] 缩小过滤：各向异性
 *
 * @brief[en] Min filtering: anisotropic
 */
public let SAMPLER_MIN_ANISOTROPIC: UInt32 = bgfx.SAMPLER_MIN_ANISOTROPIC
/**
 * @brief[zh-cn] 缩小过滤 bit offset
 *
 * @brief[en] Min filtering bit offset
 */
public let SAMPLER_MIN_SHIFT: UInt32 = bgfx.SAMPLER_MIN_SHIFT
/**
 * @brief[zh-cn] 缩小过滤 bit mask
 *
 * @brief[en] Min filtering bit mask
 */
public let SAMPLER_MIN_MASK: UInt32 = bgfx.SAMPLER_MIN_MASK
/**
 * @brief[zh-cn] 放大过滤：点采样
 *
 * @brief[en] Mag filtering: point sampling
 */
public let SAMPLER_MAG_POINT: UInt32 = bgfx.SAMPLER_MAG_POINT
/**
 * @brief[zh-cn] 放大过滤：各向异性
 *
 * @brief[en] Mag filtering: anisotropic
 */
public let SAMPLER_MAG_ANISOTROPIC: UInt32 = bgfx.SAMPLER_MAG_ANISOTROPIC
/**
 * @brief[zh-cn] 放大过滤 bit offset
 *
 * @brief[en] Mag filtering bit offset
 */
public let SAMPLER_MAG_SHIFT: UInt32 = bgfx.SAMPLER_MAG_SHIFT
/**
 * @brief[zh-cn] 放大过滤 bit mask
 *
 * @brief[en] Mag filtering bit mask
 */
public let SAMPLER_MAG_MASK: UInt32 = bgfx.SAMPLER_MAG_MASK
/**
 * @brief[zh-cn] mip 过滤：点采样
 *
 * @brief[en] Mip filtering: pointsampling
 */
public let SAMPLER_MIP_POINT: UInt32 = bgfx.SAMPLER_MIP_POINT
/**
 * @brief[zh-cn] mip 过滤 bit offset
 *
 * @brief[en] Mip filteringbit offset
 */
public let SAMPLER_MIP_SHIFT: UInt32 = bgfx.SAMPLER_MIP_SHIFT
/**
 * @brief[zh-cn] mip 过滤 bit mask
 *
 * @brief[en] Mip filteringbit mask
 */
public let SAMPLER_MIP_MASK: UInt32 = bgfx.SAMPLER_MIP_MASK
/**
 * @brief[zh-cn] 深度比较：小于
 *
 * @brief[en] Depthcompare: less
 */
public let SAMPLER_COMPARE_LESS: UInt32 = bgfx.SAMPLER_COMPARE_LESS
/**
 * @brief[zh-cn] 深度比较：小于等于
 *
 * @brief[en] Depthcompare: less or equal
 */
public let SAMPLER_COMPARE_LEQUAL: UInt32 = bgfx.SAMPLER_COMPARE_LEQUAL
/**
 * @brief[zh-cn] 深度比较：等于
 *
 * @brief[en] Depthcompare: equal
 */
public let SAMPLER_COMPARE_EQUAL: UInt32 = bgfx.SAMPLER_COMPARE_EQUAL
/**
 * @brief[zh-cn] 深度比较：大于等于
 *
 * @brief[en] Depthcompare: greater or equal
 */
public let SAMPLER_COMPARE_GEQUAL: UInt32 = bgfx.SAMPLER_COMPARE_GEQUAL
/**
 * @brief[zh-cn] 深度比较：大于
 *
 * @brief[en] Depthcompare: greater
 */
public let SAMPLER_COMPARE_GREATER: UInt32 = bgfx.SAMPLER_COMPARE_GREATER
/**
 * @brief[zh-cn] 深度比较：不等于
 *
 * @brief[en] Depthcompare: no equal
 */
public let SAMPLER_COMPARE_NOTEQUAL: UInt32 = bgfx.SAMPLER_COMPARE_NOTEQUAL
/**
 * @brief[zh-cn] 深度比较：从不
 *
 * @brief[en] Depth compare: never
 */
public let SAMPLER_COMPARE_NEVER: UInt32 = bgfx.SAMPLER_COMPARE_NEVER
/**
 * @brief[zh-cn] 深度比较：始终
 *
 * @brief[en] Depthcompare: always
 */
public let SAMPLER_COMPARE_ALWAYS: UInt32 = bgfx.SAMPLER_COMPARE_ALWAYS
/**
 * @brief[zh-cn] 深度比较 bit offset
 *
 * @brief[en] depthcomparebit offset
 */
public let SAMPLER_COMPARE_SHIFT: UInt32 = bgfx.SAMPLER_COMPARE_SHIFT
/**
 * @brief[zh-cn] 深度比较 bit mask
 *
 * @brief[en] depthcomparebit mask
 */
public let SAMPLER_COMPARE_MASK: UInt32 = bgfx.SAMPLER_COMPARE_MASK
/**
 * @brief[zh-cn] 采样模板
 *
 * @brief[en] Samplingstencil
 */
public let SAMPLER_SAMPLE_STENCIL: UInt32 = bgfx.SAMPLER_SAMPLE_STENCIL
/**
 * @brief[zh-cn] 边界颜色 bit offset
 *
 * @brief[en] Bordercolorbit offset
 */
public let SAMPLER_BORDER_COLOR_SHIFT: UInt32 = bgfx.SAMPLER_BORDER_COLOR_SHIFT
/**
 * @brief[zh-cn] 边界颜色 bit mask
 *
 * @brief[en] Bordercolorbit mask
 */
public let SAMPLER_BORDER_COLOR_MASK: UInt32 = bgfx.SAMPLER_BORDER_COLOR_MASK
/**
 * @brief[zh-cn] 保留 bit offset
 *
 * @brief[en] preservebit offset
 */
public let SAMPLER_RESERVED_SHIFT: UInt32 = bgfx.SAMPLER_RESERVED_SHIFT
/**
 * @brief[zh-cn] 保留 bit mask
 *
 * @brief[en] preservebit mask
 */
public let SAMPLER_RESERVED_MASK: UInt32 = bgfx.SAMPLER_RESERVED_MASK
/**
 * @brief[zh-cn] UVW 镜像combination
 *
 * @brief[en] UVW mirrorcombination
 */
public let SAMPLER_UVW_MIRROR: UInt32 = bgfx.SAMPLER_UVW_MIRROR
/**
 * @brief[zh-cn] UVW clamp位combination
 *
 * @brief[en] UVW clamp combination
 */
public let SAMPLER_UVW_CLAMP: UInt32 = bgfx.SAMPLER_UVW_CLAMP
/**
 * @brief[zh-cn] UVW 边界combination
 *
 * @brief[en] UVW bordercombination
 */
public let SAMPLER_UVW_BORDER: UInt32 = bgfx.SAMPLER_UVW_BORDER
/**
 * @brief[zh-cn] 点采样combination（min/mag/mip 均点采样）
 *
 * @brief[en] Point sampling combination (min/mag/mip all point sampling)
 */
public let SAMPLER_POINT: UInt32 = bgfx.SAMPLER_POINT
/**
 * @brief[zh-cn] 采样器 bit maskfull set
 *
 * @brief[en] Sampler bit mask full set
 */
public let SAMPLER_BITS_MASK: UInt32 = bgfx.SAMPLER_BITS_MASK

// =============================================================================
// State - 渲染状态 flags
// =============================================================================
/**
 * @brief[zh-cn] 无状态
 *
 * @brief[en] Nostate
 */
public let STATE_NONE: UInt64 = bgfx.STATE_NONE
/**
 * @brief[zh-cn] 默认状态（深度测试 + write RGB + write Z + CCW face剔除）
 *
 * @brief[en] Default state（depthtest + write RGB + write Z + CCW facecull）
 */
public let STATE_DEFAULT: UInt64 = bgfx.STATE_DEFAULT
/**
 * @brief[zh-cn] 写入 R 通道
 *
 * @brief[en] Write R channel
 */
public let STATE_WRITE_R: UInt64 = bgfx.STATE_WRITE_R
/**
 * @brief[zh-cn] 写入 G 通道
 *
 * @brief[en] Write G channel
 */
public let STATE_WRITE_G: UInt64 = bgfx.STATE_WRITE_G
/**
 * @brief[zh-cn] 写入 B 通道
 *
 * @brief[en] Write B channel
 */
public let STATE_WRITE_B: UInt64 = bgfx.STATE_WRITE_B
/**
 * @brief[zh-cn] 写入 A 通道
 *
 * @brief[en] Write A channel
 */
public let STATE_WRITE_A: UInt64 = bgfx.STATE_WRITE_A
/**
 * @brief[zh-cn] 写入 Z（深度）通道
 *
 * @brief[en] Write Z（depth）channel
 */
public let STATE_WRITE_Z: UInt64 = bgfx.STATE_WRITE_Z
/**
 * @brief[zh-cn] 写入 RGB 通道
 *
 * @brief[en] Write RGB channel
 */
public let STATE_WRITE_RGB: UInt64 = bgfx.STATE_WRITE_RGB
/**
 * @brief[zh-cn] 写入maskfull set
 *
 * @brief[en] Write mask full set
 */
public let STATE_WRITE_MASK: UInt64 = bgfx.STATE_WRITE_MASK
/**
 * @brief[zh-cn] 深度测试：小于
 *
 * @brief[en] Depthtest: less
 */
public let STATE_DEPTH_TEST_LESS: UInt64 = bgfx.STATE_DEPTH_TEST_LESS
/**
 * @brief[zh-cn] 深度测试：小于等于
 *
 * @brief[en] Depthtest: less or equal
 */
public let STATE_DEPTH_TEST_LEQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_LEQUAL
/**
 * @brief[zh-cn] 深度测试：等于
 *
 * @brief[en] Depthtest: equal
 */
public let STATE_DEPTH_TEST_EQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_EQUAL
/**
 * @brief[zh-cn] 深度测试：大于等于
 *
 * @brief[en] Depthtest: greater or equal
 */
public let STATE_DEPTH_TEST_GEQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_GEQUAL
/**
 * @brief[zh-cn] 深度测试：大于
 *
 * @brief[en] Depthtest: greater
 */
public let STATE_DEPTH_TEST_GREATER: UInt64 = bgfx.STATE_DEPTH_TEST_GREATER
/**
 * @brief[zh-cn] 深度测试：不等于
 *
 * @brief[en] Depthtest: no equal
 */
public let STATE_DEPTH_TEST_NOTEQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_NOTEQUAL
/**
 * @brief[zh-cn] 深度测试：从不
 *
 * @brief[en] Depth test: never
 */
public let STATE_DEPTH_TEST_NEVER: UInt64 = bgfx.STATE_DEPTH_TEST_NEVER
/**
 * @brief[zh-cn] 深度测试：始终
 *
 * @brief[en] Depthtest: always
 */
public let STATE_DEPTH_TEST_ALWAYS: UInt64 = bgfx.STATE_DEPTH_TEST_ALWAYS
/**
 * @brief[zh-cn] 深度测试 bit offset
 *
 * @brief[en] Depthtestbit offset
 */
public let STATE_DEPTH_TEST_SHIFT: UInt64 = bgfx.STATE_DEPTH_TEST_SHIFT
/**
 * @brief[zh-cn] 深度测试 bit mask
 *
 * @brief[en] Depthtestbit mask
 */
public let STATE_DEPTH_TEST_MASK: UInt64 = bgfx.STATE_DEPTH_TEST_MASK
/**
 * @brief[zh-cn] 混合因子：零
 *
 * @brief[en] Blendfactor: zero
 */
public let STATE_BLEND_ZERO: UInt64 = bgfx.STATE_BLEND_ZERO
/**
 * @brief[zh-cn] 混合因子：一
 *
 * @brief[en] Blendfactor: one
 */
public let STATE_BLEND_ONE: UInt64 = bgfx.STATE_BLEND_ONE
/**
 * @brief[zh-cn] 混合因子：源颜色
 *
 * @brief[en] Blendfactor: sourcecolor
 */
public let STATE_BLEND_SRC_COLOR: UInt64 = bgfx.STATE_BLEND_SRC_COLOR
/**
 * @brief[zh-cn] 混合因子：源颜色inverted
 *
 * @brief[en] Blend factor: source color inverted
 */
public let STATE_BLEND_INV_SRC_COLOR: UInt64 = bgfx.STATE_BLEND_INV_SRC_COLOR
/**
 * @brief[zh-cn] 混合因子：源 alpha
 *
 * @brief[en] Blendfactor: source alpha
 */
public let STATE_BLEND_SRC_ALPHA: UInt64 = bgfx.STATE_BLEND_SRC_ALPHA
/**
 * @brief[zh-cn] 混合因子：源 alpha inverted
 *
 * @brief[en] Blendfactor: source alpha inverted
 */
public let STATE_BLEND_INV_SRC_ALPHA: UInt64 = bgfx.STATE_BLEND_INV_SRC_ALPHA
/**
 * @brief[zh-cn] 混合因子：目标 alpha
 *
 * @brief[en] Blendfactor: destination alpha
 */
public let STATE_BLEND_DST_ALPHA: UInt64 = bgfx.STATE_BLEND_DST_ALPHA
/**
 * @brief[zh-cn] 混合因子：目标 alpha inverted
 *
 * @brief[en] Blendfactor: destination alpha inverted
 */
public let STATE_BLEND_INV_DST_ALPHA: UInt64 = bgfx.STATE_BLEND_INV_DST_ALPHA
/**
 * @brief[zh-cn] 混合因子：目标颜色
 *
 * @brief[en] Blendfactor: destinationcolor
 */
public let STATE_BLEND_DST_COLOR: UInt64 = bgfx.STATE_BLEND_DST_COLOR
/**
 * @brief[zh-cn] 混合因子：目标颜色inverted
 *
 * @brief[en] Blendfactor: destination color inverted
 */
public let STATE_BLEND_INV_DST_COLOR: UInt64 = bgfx.STATE_BLEND_INV_DST_COLOR
/**
 * @brief[zh-cn] 混合因子：源 alpha 饱和
 *
 * @brief[en] Blendfactor: source alpha saturate
 */
public let STATE_BLEND_SRC_ALPHA_SAT: UInt64 = bgfx.STATE_BLEND_SRC_ALPHA_SAT
/**
 * @brief[zh-cn] 混合因子：常数
 *
 * @brief[en] Blend factor: constant
 */
public let STATE_BLEND_FACTOR: UInt64 = bgfx.STATE_BLEND_FACTOR
/**
 * @brief[zh-cn] 混合因子：常数inverted
 *
 * @brief[en] Blend factor: constant inverted
 */
public let STATE_BLEND_INV_FACTOR: UInt64 = bgfx.STATE_BLEND_INV_FACTOR
/**
 * @brief[zh-cn] 混合因子 bit offset
 *
 * @brief[en] Blendfactorbit offset
 */
public let STATE_BLEND_SHIFT: UInt64 = bgfx.STATE_BLEND_SHIFT
/**
 * @brief[zh-cn] 混合因子 bit mask
 *
 * @brief[en] Blendfactorbit mask
 */
public let STATE_BLEND_MASK: UInt64 = bgfx.STATE_BLEND_MASK
/**
 * @brief[zh-cn] 混合方程：加法
 *
 * @brief[en] Blend equation: additive
 */
public let STATE_BLEND_EQUATION_ADD: UInt64 = bgfx.STATE_BLEND_EQUATION_ADD
/**
 * @brief[zh-cn] 混合方程：减法
 *
 * @brief[en] Blend equation: subtractive
 */
public let STATE_BLEND_EQUATION_SUB: UInt64 = bgfx.STATE_BLEND_EQUATION_SUB
/**
 * @brief[zh-cn] 混合方程：反向减法
 *
 * @brief[en] Blend equation: reverse subtractive
 */
public let STATE_BLEND_EQUATION_REVSUB: UInt64 = bgfx.STATE_BLEND_EQUATION_REVSUB
/**
 * @brief[zh-cn] 混合方程：取最小值
 *
 * @brief[en] Blend equation: min
 */
public let STATE_BLEND_EQUATION_MIN: UInt64 = bgfx.STATE_BLEND_EQUATION_MIN
/**
 * @brief[zh-cn] 混合方程：取最大值
 *
 * @brief[en] Blend equation: max
 */
public let STATE_BLEND_EQUATION_MAX: UInt64 = bgfx.STATE_BLEND_EQUATION_MAX
/**
 * @brief[zh-cn] 混合方程 bit offset
 *
 * @brief[en] Blend equation bit offset
 */
public let STATE_BLEND_EQUATION_SHIFT: UInt64 = bgfx.STATE_BLEND_EQUATION_SHIFT
/**
 * @brief[zh-cn] 混合方程 bit mask
 *
 * @brief[en] Blend equation bit mask
 */
public let STATE_BLEND_EQUATION_MASK: UInt64 = bgfx.STATE_BLEND_EQUATION_MASK
/**
 * @brief[zh-cn] 独立混合
 *
 * @brief[en] independentblend
 */
public let STATE_BLEND_INDEPENDENT: UInt64 = bgfx.STATE_BLEND_INDEPENDENT
/**
 * @brief[zh-cn] alpha 到覆盖
 *
 * @brief[en] Alpha to coverage
 */
public let STATE_BLEND_ALPHA_TO_COVERAGE: UInt64 = bgfx.STATE_BLEND_ALPHA_TO_COVERAGE
/**
 * @brief[zh-cn] face剔除：顺时针
 *
 * @brief[en] Face cull: clockwise
 */
public let STATE_CULL_CW: UInt64 = bgfx.STATE_CULL_CW
/**
 * @brief[zh-cn] face剔除：逆时针
 *
 * @brief[en] Face cull: counter-clockwise
 */
public let STATE_CULL_CCW: UInt64 = bgfx.STATE_CULL_CCW
/**
 * @brief[zh-cn] face剔除 bit offset
 *
 * @brief[en] facecullbit offset
 */
public let STATE_CULL_SHIFT: UInt64 = bgfx.STATE_CULL_SHIFT
/**
 * @brief[zh-cn] face剔除 bit mask
 *
 * @brief[en] facecullbit mask
 */
public let STATE_CULL_MASK: UInt64 = bgfx.STATE_CULL_MASK
/**
 * @brief[zh-cn] 逆时针正face
 *
 * @brief[en] Counter-clockwise front face
 */
public let STATE_FRONT_CCW: UInt64 = bgfx.STATE_FRONT_CCW
/**
 * @brief[zh-cn] MSAA
 *
 * @brief[en] MSAA
 */
public let STATE_MSAA: UInt64 = bgfx.STATE_MSAA
/**
 * @brief[zh-cn] 线段抗锯齿
 *
 * @brief[en] Line AA (anti-aliasing)
 */
public let STATE_LINEAA: UInt64 = bgfx.STATE_LINEAA
/**
 * @brief[zh-cn] 保守光栅化
 *
 * @brief[en] Conservative rasterization
 */
public let STATE_CONSERVATIVE_RASTER: UInt64 = bgfx.STATE_CONSERVATIVE_RASTER
/**
 * @brief[zh-cn] 图元类型 bit offset
 *
 * @brief[en] Primitivetypebit offset
 */
public let STATE_PT_SHIFT: UInt64 = bgfx.STATE_PT_SHIFT
/**
 * @brief[zh-cn] 图元类型 bit mask
 *
 * @brief[en] Primitivetypebit mask
 */
public let STATE_PT_MASK: UInt64 = bgfx.STATE_PT_MASK
/**
 * @brief[zh-cn] 图元类型：三角形条带
 *
 * @brief[en] Primitive type: triangle strip
 */
public let STATE_PT_TRISTRIP: UInt64 = bgfx.STATE_PT_TRISTRIP
/**
 * @brief[zh-cn] 图元类型：线段列表
 *
 * @brief[en] Primitive type: line list
 */
public let STATE_PT_LINES: UInt64 = bgfx.STATE_PT_LINES
/**
 * @brief[zh-cn] 图元类型：线段条带
 *
 * @brief[en] Primitive type: line strip
 */
public let STATE_PT_LINESTRIP: UInt64 = bgfx.STATE_PT_LINESTRIP
/**
 * @brief[zh-cn] 图元类型：点列表
 *
 * @brief[en] Primitivetype: pointlist
 */
public let STATE_PT_POINTS: UInt64 = bgfx.STATE_PT_POINTS
/**
 * @brief[zh-cn] 点大小 bit offset
 *
 * @brief[en] Point size bit offset
 */
public let STATE_POINT_SIZE_SHIFT: UInt64 = bgfx.STATE_POINT_SIZE_SHIFT
/**
 * @brief[zh-cn] 点大小 bit mask
 *
 * @brief[en] Point size bit mask
 */
public let STATE_POINT_SIZE_MASK: UInt64 = bgfx.STATE_POINT_SIZE_MASK
/**
 * @brief[zh-cn] alpha 参考值 bit offset
 *
 * @brief[en] Alpha reference value bit offset
 */
public let STATE_ALPHA_REF_SHIFT: UInt64 = bgfx.STATE_ALPHA_REF_SHIFT
/**
 * @brief[zh-cn] alpha 参考值 bit mask
 *
 * @brief[en] Alpha reference value bit mask
 */
public let STATE_ALPHA_REF_MASK: UInt64 = bgfx.STATE_ALPHA_REF_MASK
/**
 * @brief[zh-cn] 保留 bit offset
 *
 * @brief[en] preservebit offset
 */
public let STATE_RESERVED_SHIFT: UInt64 = bgfx.STATE_RESERVED_SHIFT
/**
 * @brief[zh-cn] 保留 bit mask
 *
 * @brief[en] preservebit mask
 */
public let STATE_RESERVED_MASK: UInt64 = bgfx.STATE_RESERVED_MASK
/**
 * @brief[zh-cn] 状态maskfull set
 *
 * @brief[en] statemaskfull set
 */
public let STATE_MASK: UInt64 = bgfx.STATE_MASK

// =============================================================================
// Stencil - 模板 flags
// =============================================================================
/**
 * @brief[zh-cn] 无模板
 *
 * @brief[en] nostencil
 */
public let STENCIL_NONE: UInt32 = bgfx.STENCIL_NONE
/**
 * @brief[zh-cn] 模板测试：小于
 *
 * @brief[en] Stenciltest: less
 */
public let STENCIL_TEST_LESS: UInt32 = bgfx.STENCIL_TEST_LESS
/**
 * @brief[zh-cn] 模板测试：小于等于
 *
 * @brief[en] Stenciltest: less or equal
 */
public let STENCIL_TEST_LEQUAL: UInt32 = bgfx.STENCIL_TEST_LEQUAL
/**
 * @brief[zh-cn] 模板测试：等于
 *
 * @brief[en] Stenciltest: equal
 */
public let STENCIL_TEST_EQUAL: UInt32 = bgfx.STENCIL_TEST_EQUAL
/**
 * @brief[zh-cn] 模板测试：大于等于
 *
 * @brief[en] Stenciltest: greater or equal
 */
public let STENCIL_TEST_GEQUAL: UInt32 = bgfx.STENCIL_TEST_GEQUAL
/**
 * @brief[zh-cn] 模板测试：大于
 *
 * @brief[en] Stenciltest: greater
 */
public let STENCIL_TEST_GREATER: UInt32 = bgfx.STENCIL_TEST_GREATER
/**
 * @brief[zh-cn] 模板测试：不等于
 *
 * @brief[en] Stenciltest: no equal
 */
public let STENCIL_TEST_NOTEQUAL: UInt32 = bgfx.STENCIL_TEST_NOTEQUAL
/**
 * @brief[zh-cn] 模板测试：从不
 *
 * @brief[en] Stenciltest: never
 */
public let STENCIL_TEST_NEVER: UInt32 = bgfx.STENCIL_TEST_NEVER
/**
 * @brief[zh-cn] 模板测试：始终
 *
 * @brief[en] Stenciltest: always
 */
public let STENCIL_TEST_ALWAYS: UInt32 = bgfx.STENCIL_TEST_ALWAYS
/**
 * @brief[zh-cn] 模板测试 bit offset
 *
 * @brief[en] Stenciltestbit offset
 */
public let STENCIL_TEST_SHIFT: UInt32 = bgfx.STENCIL_TEST_SHIFT
/**
 * @brief[zh-cn] 模板测试 bit mask
 *
 * @brief[en] Stenciltestbit mask
 */
public let STENCIL_TEST_MASK: UInt32 = bgfx.STENCIL_TEST_MASK
/**
 * @brief[zh-cn] 模板函数参考值 bit offset
 *
 * @brief[en] Stencil function reference value bit offset
 */
public let STENCIL_FUNC_REF_SHIFT: UInt32 = bgfx.STENCIL_FUNC_REF_SHIFT
/**
 * @brief[zh-cn] 模板函数参考值 bit mask
 *
 * @brief[en] Stencil function reference value bit mask
 */
public let STENCIL_FUNC_REF_MASK: UInt32 = bgfx.STENCIL_FUNC_REF_MASK
/**
 * @brief[zh-cn] 模板函数mask bit offset
 *
 * @brief[en] stencilfunctionmaskbit offset
 */
public let STENCIL_FUNC_RMASK_SHIFT: UInt32 = bgfx.STENCIL_FUNC_RMASK_SHIFT
/**
 * @brief[zh-cn] 模板函数mask bit mask
 *
 * @brief[en] stencilfunctionmaskbit mask
 */
public let STENCIL_FUNC_RMASK_MASK: UInt32 = bgfx.STENCIL_FUNC_RMASK_MASK
/**
 * @brief[zh-cn] 模板操作：失败保持
 *
 * @brief[en] Stenciloperation: failkeep
 */
public let STENCIL_OP_FAIL_S_KEEP: UInt32 = bgfx.STENCIL_OP_FAIL_S_KEEP
/**
 * @brief[zh-cn] 模板操作：失败零
 *
 * @brief[en] Stenciloperation: failzero
 */
public let STENCIL_OP_FAIL_S_ZERO: UInt32 = bgfx.STENCIL_OP_FAIL_S_ZERO
/**
 * @brief[zh-cn] 模板操作：失败替换
 *
 * @brief[en] Stenciloperation: failreplace
 */
public let STENCIL_OP_FAIL_S_REPLACE: UInt32 = bgfx.STENCIL_OP_FAIL_S_REPLACE
/**
 * @brief[zh-cn] 模板操作：失败递增
 *
 * @brief[en] Stencil operation: fail increment
 */
public let STENCIL_OP_FAIL_S_INCR: UInt32 = bgfx.STENCIL_OP_FAIL_S_INCR
/**
 * @brief[zh-cn] 模板操作：失败递减
 *
 * @brief[en] Stencil operation: fail decrement
 */
public let STENCIL_OP_FAIL_S_DECR: UInt32 = bgfx.STENCIL_OP_FAIL_S_DECR
/**
 * @brief[zh-cn] 模板操作：失败递增饱和
 *
 * @brief[en] Stencil operation: fail incrementsaturate
 */
public let STENCIL_OP_FAIL_S_INCRSAT: UInt32 = bgfx.STENCIL_OP_FAIL_S_INCRSAT
/**
 * @brief[zh-cn] 模板操作：失败递减饱和
 *
 * @brief[en] Stencil operation: fail decrementsaturate
 */
public let STENCIL_OP_FAIL_S_DECRSAT: UInt32 = bgfx.STENCIL_OP_FAIL_S_DECRSAT
/**
 * @brief[zh-cn] 模板操作：失败inverted
 *
 * @brief[en] Stenciloperation: failinverted
 */
public let STENCIL_OP_FAIL_S_INVERT: UInt32 = bgfx.STENCIL_OP_FAIL_S_INVERT
/**
 * @brief[zh-cn] 模板操作 bit offset
 *
 * @brief[en] Stenciloperationbit offset
 */
public let STENCIL_OP_FAIL_S_SHIFT: UInt32 = bgfx.STENCIL_OP_FAIL_S_SHIFT
/**
 * @brief[zh-cn] 模板操作 bit mask
 *
 * @brief[en] Stenciloperationbit mask
 */
public let STENCIL_OP_FAIL_S_MASK: UInt32 = bgfx.STENCIL_OP_FAIL_S_MASK
/**
 * @brief[zh-cn] 模板操作：深度失败保持
 *
 * @brief[en] Stenciloperation: depthfailkeep
 */
public let STENCIL_OP_FAIL_Z_KEEP: UInt32 = bgfx.STENCIL_OP_FAIL_Z_KEEP
/**
 * @brief[zh-cn] 模板操作：深度失败零
 *
 * @brief[en] Stenciloperation: depthfailzero
 */
public let STENCIL_OP_FAIL_Z_ZERO: UInt32 = bgfx.STENCIL_OP_FAIL_Z_ZERO
/**
 * @brief[zh-cn] 模板操作：深度失败替换
 *
 * @brief[en] Stenciloperation: depthfailreplace
 */
public let STENCIL_OP_FAIL_Z_REPLACE: UInt32 = bgfx.STENCIL_OP_FAIL_Z_REPLACE
/**
 * @brief[zh-cn] 模板操作：深度失败递增
 *
 * @brief[en] Stencil operation: depth-fail increment
 */
public let STENCIL_OP_FAIL_Z_INCR: UInt32 = bgfx.STENCIL_OP_FAIL_Z_INCR
/**
 * @brief[zh-cn] 模板操作：深度失败递减
 *
 * @brief[en] Stencil operation: depth-fail decrement
 */
public let STENCIL_OP_FAIL_Z_DECR: UInt32 = bgfx.STENCIL_OP_FAIL_Z_DECR
/**
 * @brief[zh-cn] 模板操作：深度失败递增饱和
 *
 * @brief[en] Stencil operation: depth-fail incrementsaturate
 */
public let STENCIL_OP_FAIL_Z_INCRSAT: UInt32 = bgfx.STENCIL_OP_FAIL_Z_INCRSAT
/**
 * @brief[zh-cn] 模板操作：深度失败递减饱和
 *
 * @brief[en] Stencil operation: depth-fail decrementsaturate
 */
public let STENCIL_OP_FAIL_Z_DECRSAT: UInt32 = bgfx.STENCIL_OP_FAIL_Z_DECRSAT
/**
 * @brief[zh-cn] 模板操作：深度失败inverted
 *
 * @brief[en] Stenciloperation: depthfailinverted
 */
public let STENCIL_OP_FAIL_Z_INVERT: UInt32 = bgfx.STENCIL_OP_FAIL_Z_INVERT
/**
 * @brief[zh-cn] 模板操作 bit offset
 *
 * @brief[en] Stenciloperationbit offset
 */
public let STENCIL_OP_FAIL_Z_SHIFT: UInt32 = bgfx.STENCIL_OP_FAIL_Z_SHIFT
/**
 * @brief[zh-cn] 模板操作 bit mask
 *
 * @brief[en] Stenciloperationbit mask
 */
public let STENCIL_OP_FAIL_Z_MASK: UInt32 = bgfx.STENCIL_OP_FAIL_Z_MASK
/**
 * @brief[zh-cn] 模板操作：深度通过保持
 *
 * @brief[en] Stenciloperation: depthpasskeep
 */
public let STENCIL_OP_PASS_Z_KEEP: UInt32 = bgfx.STENCIL_OP_PASS_Z_KEEP
/**
 * @brief[zh-cn] 模板操作：深度通过零
 *
 * @brief[en] Stenciloperation: depthpasszero
 */
public let STENCIL_OP_PASS_Z_ZERO: UInt32 = bgfx.STENCIL_OP_PASS_Z_ZERO
/**
 * @brief[zh-cn] 模板操作：深度通过替换
 *
 * @brief[en] Stenciloperation: depthpassreplace
 */
public let STENCIL_OP_PASS_Z_REPLACE: UInt32 = bgfx.STENCIL_OP_PASS_Z_REPLACE
/**
 * @brief[zh-cn] 模板操作：深度通过递增
 *
 * @brief[en] Stencil operation: depth-pass increment
 */
public let STENCIL_OP_PASS_Z_INCR: UInt32 = bgfx.STENCIL_OP_PASS_Z_INCR
/**
 * @brief[zh-cn] 模板操作：深度通过递减
 *
 * @brief[en] Stencil operation: depth-pass decrement
 */
public let STENCIL_OP_PASS_Z_DECR: UInt32 = bgfx.STENCIL_OP_PASS_Z_DECR
/**
 * @brief[zh-cn] 模板操作：深度通过递增饱和
 *
 * @brief[en] Stencil operation: depth-pass incrementsaturate
 */
public let STENCIL_OP_PASS_Z_INCRSAT: UInt32 = bgfx.STENCIL_OP_PASS_Z_INCRSAT
/**
 * @brief[zh-cn] 模板操作：深度通过递减饱和
 *
 * @brief[en] Stencil operation: depth-pass decrementsaturate
 */
public let STENCIL_OP_PASS_Z_DECRSAT: UInt32 = bgfx.STENCIL_OP_PASS_Z_DECRSAT
/**
 * @brief[zh-cn] 模板操作：深度通过inverted
 *
 * @brief[en] Stenciloperation: depthpassinverted
 */
public let STENCIL_OP_PASS_Z_INVERT: UInt32 = bgfx.STENCIL_OP_PASS_Z_INVERT
/**
 * @brief[zh-cn] 模板操作 bit offset
 *
 * @brief[en] Stenciloperationbit offset
 */
public let STENCIL_OP_PASS_Z_SHIFT: UInt32 = bgfx.STENCIL_OP_PASS_Z_SHIFT
/**
 * @brief[zh-cn] 模板操作 bit mask
 *
 * @brief[en] Stenciloperationbit mask
 */
public let STENCIL_OP_PASS_Z_MASK: UInt32 = bgfx.STENCIL_OP_PASS_Z_MASK
/**
 * @brief[zh-cn] 模板maskfull set
 *
 * @brief[en] Stencilmaskfull set
 */
public let STENCIL_MASK: UInt32 = bgfx.STENCIL_MASK

// =============================================================================
// Texture - 纹理 flags
// =============================================================================
/**
 * @brief[zh-cn] 无Texture flag
 *
 * @brief[en] notextureflag
 */
public let TEXTURE_NONE: UInt64 = bgfx.TEXTURE_NONE
/**
 * @brief[zh-cn] 渲染目标纹理
 *
 * @brief[en] Renderdestinationtexture
 */
public let TEXTURE_RT: UInt64 = bgfx.TEXTURE_RT
/**
 * @brief[zh-cn] RT  bit offset
 *
 * @brief[en] RT bit offset
 */
public let TEXTURE_RT_SHIFT: UInt64 = bgfx.TEXTURE_RT_SHIFT
/**
 * @brief[zh-cn] RT  bit mask
 *
 * @brief[en] RT bit mask
 */
public let TEXTURE_RT_MASK: UInt64 = bgfx.TEXTURE_RT_MASK
/**
 * @brief[zh-cn] RT MSAA ×2
 *
 * @brief[en] RT MSAA ×2
 */
public let TEXTURE_RT_MSAA_X2: UInt64 = bgfx.TEXTURE_RT_MSAA_X2
/**
 * @brief[zh-cn] RT MSAA ×4
 *
 * @brief[en] RT MSAA ×4
 */
public let TEXTURE_RT_MSAA_X4: UInt64 = bgfx.TEXTURE_RT_MSAA_X4
/**
 * @brief[zh-cn] RT MSAA ×8
 *
 * @brief[en] RT MSAA ×8
 */
public let TEXTURE_RT_MSAA_X8: UInt64 = bgfx.TEXTURE_RT_MSAA_X8
/**
 * @brief[zh-cn] RT MSAA ×16
 *
 * @brief[en] RT MSAA ×16
 */
public let TEXTURE_RT_MSAA_X16: UInt64 = bgfx.TEXTURE_RT_MSAA_X16
/**
 * @brief[zh-cn] RT MSAA  bit offset
 *
 * @brief[en] RT MSAA bit offset
 */
public let TEXTURE_RT_MSAA_SHIFT: UInt64 = bgfx.TEXTURE_RT_MSAA_SHIFT
/**
 * @brief[zh-cn] RT MSAA  bit mask
 *
 * @brief[en] RT MSAA bit mask
 */
public let TEXTURE_RT_MSAA_MASK: UInt64 = bgfx.TEXTURE_RT_MSAA_MASK
/**
 * @brief[zh-cn] RT 只写
 *
 * @brief[en] RT write-only
 */
public let TEXTURE_RT_WRITE_ONLY: UInt64 = bgfx.TEXTURE_RT_WRITE_ONLY
/**
 * @brief[zh-cn] 计算写纹理
 *
 * @brief[en] Compute write texture
 */
public let TEXTURE_COMPUTE_WRITE: UInt64 = bgfx.TEXTURE_COMPUTE_WRITE
/**
 * @brief[zh-cn] MSAA 采样纹理
 *
 * @brief[en] MSAA samplingtexture
 */
public let TEXTURE_MSAA_SAMPLE: UInt64 = bgfx.TEXTURE_MSAA_SAMPLE
/**
 * @brief[zh-cn] sRGB 纹理
 *
 * @brief[en] sRGB texture
 */
public let TEXTURE_SRGB: UInt64 = bgfx.TEXTURE_SRGB
/**
 * @brief[zh-cn] 纹理回读
 *
 * @brief[en] Texture readback
 */
public let TEXTURE_READ_BACK: UInt64 = bgfx.TEXTURE_READ_BACK
/**
 * @brief[zh-cn] 纹理 blit 目标
 *
 * @brief[en] Texture blit destination
 */
public let TEXTURE_BLIT_DST: UInt64 = bgfx.TEXTURE_BLIT_DST
