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
 * @file[zh-cn] GfxTypes 渲染后端句柄值类型
 * @brief[zh-cn] 引擎自有的 GPU 资源句柄（值语义 struct），抽象层契约的句柄底座
 * @explain[zh-cn] 句柄为 16 位索引的值语义 struct（零堆分配、按 idx 比较），
 * 是引擎抽象层（IRenderBackend 等）签名的资源标识底座。设计约束：
 * - 句柄是引擎自有类型，不引用任何后端绑定包的类型别名；
 * - idx == 0xFFFF 表示无效句柄（INVALID 静态成员 / isValid 属性）；
 * - 有效值仅由后端实现包与抽象层资源对象构造，其余代码只做比较与传递；
 * - 本包（three 根包）internal 声明使句柄对引擎全部子包可见、模块外不可见。
 *
 * @file[en] GfxTypes render backend handle value types
 * @brief[en] Engine-owned GPU resource handles (value-semantic structs), the handle base of the abstraction contract
 * @explain[en] Each handle is a value-semantic struct wrapping a 16-bit index
 * (zero heap allocation, compared by idx), serving as the resource identifier base
 * of the engine abstraction layer (IRenderBackend etc.). Design constraints:
 * - Handles are engine-owned types, never type aliases of backend binding packages;
 * - idx == 0xFFFF denotes an invalid handle (INVALID static member / isValid prop);
 * - Valid values are constructed only by the backend implementation package and
 * abstraction-layer resource objects; other code only compares and passes them;
 * - The internal declaration in this root package makes handles visible to all
 * engine subpackages and invisible outside the module.
 *
 * @package three
 */
protected package three.renderers._gfx

/**
 * @brief[zh-cn] 纹理句柄
 *
 * @brief[en] Texture handle
 */
public struct GfxTextureHandle <: Equatable<GfxTextureHandle> {
    /** @brief[zh-cn] 资源索引（0xFFFF = 无效） @brief[en] Resource index (0xFFFF = invalid) */
    protected let idx: UInt16

    protected init(idx: UInt16) {
        this.idx = idx
    }

    /** @brief[zh-cn] 无效句柄常量 @brief[en] The invalid-handle constant */
    public static let INVALID = GfxTextureHandle(0xFFFFu16)

    /** @brief[zh-cn] 是否为有效句柄 @brief[en] Whether this handle is valid */
    public prop isValid: Bool {
        get() {
            idx != 0xFFFFu16
        }
    }

    public operator func ==(other: GfxTextureHandle): Bool {
        idx == other.idx
    }

    public operator func !=(other: GfxTextureHandle): Bool {
        idx != other.idx
    }
}

/**
 * @brief[zh-cn] 帧缓冲句柄
 *
 * @brief[en] Frame buffer handle
 */
public struct GfxFrameBufferHandle <: Equatable<GfxFrameBufferHandle> {
    /** @brief[zh-cn] 资源索引（0xFFFF = 无效） @brief[en] Resource index (0xFFFF = invalid) */
    protected let idx: UInt16

    protected init(idx: UInt16) {
        this.idx = idx
    }

    /** @brief[zh-cn] 无效句柄常量 @brief[en] The invalid-handle constant */
    public static let INVALID = GfxFrameBufferHandle(0xFFFFu16)

    /** @brief[zh-cn] 是否为有效句柄 @brief[en] Whether this handle is valid */
    public prop isValid: Bool {
        get() {
            idx != 0xFFFFu16
        }
    }

    public operator func ==(other: GfxFrameBufferHandle): Bool {
        idx == other.idx
    }

    public operator func !=(other: GfxFrameBufferHandle): Bool {
        idx != other.idx
    }
}

/**
 * @brief[zh-cn] 着色器程序句柄（顶点+片段着色器链接产物）
 *
 * @brief[en] Shader program handle (linked vertex + fragment shader)
 */
public struct GfxProgramHandle <: Equatable<GfxProgramHandle> {
    /** @brief[zh-cn] 资源索引（0xFFFF = 无效） @brief[en] Resource index (0xFFFF = invalid) */
    protected let idx: UInt16

    protected init(idx: UInt16) {
        this.idx = idx
    }

    /** @brief[zh-cn] 无效句柄常量 @brief[en] The invalid-handle constant */
    public static let INVALID = GfxProgramHandle(0xFFFFu16)

    /** @brief[zh-cn] 是否为有效句柄 @brief[en] Whether this handle is valid */
    public prop isValid: Bool {
        get() {
            idx != 0xFFFFu16
        }
    }

    public operator func ==(other: GfxProgramHandle): Bool {
        idx == other.idx
    }

    public operator func !=(other: GfxProgramHandle): Bool {
        idx != other.idx
    }
}

/**
 * @brief[zh-cn] uniform 句柄
 *
 * @brief[en] Uniform handle
 */
public struct GfxUniformHandle <: Equatable<GfxUniformHandle> {
    /** @brief[zh-cn] 资源索引（0xFFFF = 无效） @brief[en] Resource index (0xFFFF = invalid) */
    protected let idx: UInt16

    protected init(idx: UInt16) {
        this.idx = idx
    }

    /** @brief[zh-cn] 无效句柄常量 @brief[en] The invalid-handle constant */
    public static let INVALID = GfxUniformHandle(0xFFFFu16)

    /** @brief[zh-cn] 是否为有效句柄 @brief[en] Whether this handle is valid */
    public prop isValid: Bool {
        get() {
            idx != 0xFFFFu16
        }
    }

    public operator func ==(other: GfxUniformHandle): Bool {
        idx == other.idx
    }

    public operator func !=(other: GfxUniformHandle): Bool {
        idx != other.idx
    }
}

/**
 * @brief[zh-cn] 着色器句柄
 *
 * @brief[en] Shader handle
 */
public struct GfxShaderHandle <: Equatable<GfxShaderHandle> {
    /** @brief[zh-cn] 资源索引（0xFFFF = 无效） @brief[en] Resource index (0xFFFF = invalid) */
    protected let idx: UInt16

    protected init(idx: UInt16) {
        this.idx = idx
    }

    /** @brief[zh-cn] 无效句柄常量 @brief[en] The invalid-handle constant */
    public static let INVALID = GfxShaderHandle(0xFFFFu16)

    /** @brief[zh-cn] 是否为有效句柄 @brief[en] Whether this handle is valid */
    public prop isValid: Bool {
        get() {
            idx != 0xFFFFu16
        }
    }

    public operator func ==(other: GfxShaderHandle): Bool {
        idx == other.idx
    }

    public operator func !=(other: GfxShaderHandle): Bool {
        idx != other.idx
    }
}

/**
 * @brief[zh-cn] 静态顶点缓冲句柄
 *
 * @brief[en] Static vertex buffer handle
 */
public struct GfxVertexBufferHandle <: Equatable<GfxVertexBufferHandle> {
    /** @brief[zh-cn] 资源索引（0xFFFF = 无效） @brief[en] Resource index (0xFFFF = invalid) */
    protected let idx: UInt16

    protected init(idx: UInt16) {
        this.idx = idx
    }

    /** @brief[zh-cn] 无效句柄常量 @brief[en] The invalid-handle constant */
    public static let INVALID = GfxVertexBufferHandle(0xFFFFu16)

    /** @brief[zh-cn] 是否为有效句柄 @brief[en] Whether this handle is valid */
    public prop isValid: Bool {
        get() {
            idx != 0xFFFFu16
        }
    }

    public operator func ==(other: GfxVertexBufferHandle): Bool {
        idx == other.idx
    }

    public operator func !=(other: GfxVertexBufferHandle): Bool {
        idx != other.idx
    }
}

/**
 * @brief[zh-cn] 静态索引缓冲句柄
 *
 * @brief[en] Static index buffer handle
 */
public struct GfxIndexBufferHandle <: Equatable<GfxIndexBufferHandle> {
    /** @brief[zh-cn] 资源索引（0xFFFF = 无效） @brief[en] Resource index (0xFFFF = invalid) */
    protected let idx: UInt16

    protected init(idx: UInt16) {
        this.idx = idx
    }

    /** @brief[zh-cn] 无效句柄常量 @brief[en] The invalid-handle constant */
    public static let INVALID = GfxIndexBufferHandle(0xFFFFu16)

    /** @brief[zh-cn] 是否为有效句柄 @brief[en] Whether this handle is valid */
    public prop isValid: Bool {
        get() {
            idx != 0xFFFFu16
        }
    }

    public operator func ==(other: GfxIndexBufferHandle): Bool {
        idx == other.idx
    }

    public operator func !=(other: GfxIndexBufferHandle): Bool {
        idx != other.idx
    }
}

/**
 * @brief[zh-cn] 顶点布局句柄
 *
 * @brief[en] Vertex layout handle
 */
public struct GfxVertexLayoutHandle <: Equatable<GfxVertexLayoutHandle> {
    /** @brief[zh-cn] 资源索引（0xFFFF = 无效） @brief[en] Resource index (0xFFFF = invalid) */
    protected let idx: UInt16

    protected init(idx: UInt16) {
        this.idx = idx
    }

    /** @brief[zh-cn] 无效句柄常量 @brief[en] The invalid-handle constant */
    public static let INVALID = GfxVertexLayoutHandle(0xFFFFu16)

    /** @brief[zh-cn] 是否为有效句柄 @brief[en] Whether this handle is valid */
    public prop isValid: Bool {
        get() {
            idx != 0xFFFFu16
        }
    }

    public operator func ==(other: GfxVertexLayoutHandle): Bool {
        idx == other.idx
    }

    public operator func !=(other: GfxVertexLayoutHandle): Bool {
        idx != other.idx
    }
}

/**
 * @brief[zh-cn] 动态顶点缓冲句柄
 *
 * @brief[en] Dynamic vertex buffer handle
 */
public struct GfxDynamicVertexBufferHandle <: Equatable<GfxDynamicVertexBufferHandle> {
    /** @brief[zh-cn] 资源索引（0xFFFF = 无效） @brief[en] Resource index (0xFFFF = invalid) */
    protected let idx: UInt16

    protected init(idx: UInt16) {
        this.idx = idx
    }

    /** @brief[zh-cn] 无效句柄常量 @brief[en] The invalid-handle constant */
    public static let INVALID = GfxDynamicVertexBufferHandle(0xFFFFu16)

    /** @brief[zh-cn] 是否为有效句柄 @brief[en] Whether this handle is valid */
    public prop isValid: Bool {
        get() {
            idx != 0xFFFFu16
        }
    }

    public operator func ==(other: GfxDynamicVertexBufferHandle): Bool {
        idx == other.idx
    }

    public operator func !=(other: GfxDynamicVertexBufferHandle): Bool {
        idx != other.idx
    }
}

/**
 * @brief[zh-cn] 动态索引缓冲句柄
 *
 * @brief[en] Dynamic index buffer handle
 */
public struct GfxDynamicIndexBufferHandle <: Equatable<GfxDynamicIndexBufferHandle> {
    /** @brief[zh-cn] 资源索引（0xFFFF = 无效） @brief[en] Resource index (0xFFFF = invalid) */
    protected let idx: UInt16

    protected init(idx: UInt16) {
        this.idx = idx
    }

    /** @brief[zh-cn] 无效句柄常量 @brief[en] The invalid-handle constant */
    public static let INVALID = GfxDynamicIndexBufferHandle(0xFFFFu16)

    /** @brief[zh-cn] 是否为有效句柄 @brief[en] Whether this handle is valid */
    public prop isValid: Bool {
        get() {
            idx != 0xFFFFu16
        }
    }

    public operator func ==(other: GfxDynamicIndexBufferHandle): Bool {
        idx == other.idx
    }

    public operator func !=(other: GfxDynamicIndexBufferHandle): Bool {
        idx != other.idx
    }
}

/**
 * @brief[zh-cn] 间接绘制缓冲句柄
 *
 * @brief[en] Indirect buffer handle
 */
public struct GfxIndirectBufferHandle <: Equatable<GfxIndirectBufferHandle> {
    /** @brief[zh-cn] 资源索引（0xFFFF = 无效） @brief[en] Resource index (0xFFFF = invalid) */
    protected let idx: UInt16

    protected init(idx: UInt16) {
        this.idx = idx
    }

    /** @brief[zh-cn] 无效句柄常量 @brief[en] The invalid-handle constant */
    public static let INVALID = GfxIndirectBufferHandle(0xFFFFu16)

    /** @brief[zh-cn] 是否为有效句柄 @brief[en] Whether this handle is valid */
    public prop isValid: Bool {
        get() {
            idx != 0xFFFFu16
        }
    }

    public operator func ==(other: GfxIndirectBufferHandle): Bool {
        idx == other.idx
    }

    public operator func !=(other: GfxIndirectBufferHandle): Bool {
        idx != other.idx
    }
}

/**
 * @brief[zh-cn] 遮挡查询句柄
 *
 * @brief[en] Occlusion query handle
 */
public struct GfxOcclusionQueryHandle <: Equatable<GfxOcclusionQueryHandle> {
    /** @brief[zh-cn] 资源索引（0xFFFF = 无效） @brief[en] Resource index (0xFFFF = invalid) */
    protected let idx: UInt16

    protected init(idx: UInt16) {
        this.idx = idx
    }

    /** @brief[zh-cn] 无效句柄常量 @brief[en] The invalid-handle constant */
    public static let INVALID = GfxOcclusionQueryHandle(0xFFFFu16)

    /** @brief[zh-cn] 是否为有效句柄 @brief[en] Whether this handle is valid */
    public prop isValid: Bool {
        get() {
            idx != 0xFFFFu16
        }
    }

    public operator func ==(other: GfxOcclusionQueryHandle): Bool {
        idx == other.idx
    }

    public operator func !=(other: GfxOcclusionQueryHandle): Bool {
        idx != other.idx
    }
}
