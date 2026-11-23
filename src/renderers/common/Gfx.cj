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
 * @file[zh-cn] Gfx GPU API 词表包锚点（声明位于 three.renderers._gfx 子包）
 * @brief[zh-cn] 重导出 protected 子包 gfx 的全部句柄/枚举/描述/旗标类型
 * @explain[zh-cn] gfx 为零依赖叶子词表包（句柄/枚举/描述等值类型），protected 包 +
 * 经本包 public import 重导出，外部使用方经 three.renderers.common 访问。
 *
 * @file[en] Gfx GPU API vocabulary package anchor (declared in the three.renderers._gfx subpackage)
 * @brief[en] Re-exports all handle/enum/desc/flag types of the protected gfx subpackage
 * @explain[en] gfx is a zero-dependency leaf vocabulary package (handles/enums/descs as value types), a protected package re-exported via this package's public imports; external consumers access it through three.renderers.common.
 */
package three.renderers.common

public import three.renderers._gfx.GfxAccess
public import three.renderers._gfx.GfxAttrib
public import three.renderers._gfx.GfxAttribType
public import three.renderers._gfx.GfxAttachmentDesc
public import three.renderers._gfx.GfxAttributeDesc
public import three.renderers._gfx.GfxBackbufferRatio
public import three.renderers._gfx.GfxBufferFlag
public import three.renderers._gfx.GfxCapsSummary
public import three.renderers._gfx.GfxClearFlag
public import three.renderers._gfx.GfxDynamicIndexBufferHandle
public import three.renderers._gfx.GfxDynamicVertexBufferHandle
public import three.renderers._gfx.GfxFrameBufferHandle
public import three.renderers._gfx.GfxIndexBufferHandle
public import three.renderers._gfx.GfxIndirectBufferHandle
public import three.renderers._gfx.GfxOcclusionQueryHandle
public import three.renderers._gfx.GfxProgramHandle
public import three.renderers._gfx.GfxRendererType
public import three.renderers._gfx.GfxResetFlag
public import three.renderers._gfx.GfxSamplerFlag
public import three.renderers._gfx.GfxShaderHandle
public import three.renderers._gfx.GfxState
public import three.renderers._gfx.GfxStatsSummary
public import three.renderers._gfx.GfxStencilFlag
public import three.renderers._gfx.GfxTextureFlag
public import three.renderers._gfx.GfxTextureFormat
public import three.renderers._gfx.GfxTextureHandle
public import three.renderers._gfx.GfxUniformDesc
public import three.renderers._gfx.GfxUniformHandle
public import three.renderers._gfx.GfxUniformType
public import three.renderers._gfx.GfxVertexLayoutHandle
public import three.renderers._gfx.GfxVertexBufferHandle
public import three.renderers._gfx.GfxViewMode
