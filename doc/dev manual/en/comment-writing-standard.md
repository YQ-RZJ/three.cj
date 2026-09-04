# Cangjie Project Documentation Comment Standard (based on cjdoc)

> Goal: Make all **documentation comments (`/** ... */`)** in this project unified, standardized, correctly extractable by cjdoc, and bilingual (Chinese + English).

---

## 1. General Rules

| Rule | Description |
|---|---|
| Scope | Only **file header comments** and **comments directly preceding declarations** are extracted by cjdoc; **inline/line comments (`//` inside code) are unaffected** and do not need to be managed |
| Recommended format | Use `/** ... */` block comments uniformly; cjdoc also accepts `/* ... */` and `//` |
| Position | Must be placed immediately before the target declaration (no empty statements/code in between) |
| Language | Public APIs should always be bilingual (Chinese + English); private/internal members may be Chinese-only |
| Line prefix | Leading spaces and `*` at the start of each line are ignored, so aligned asterisks are safe |
| Escaping | Use `\@` for a literal `@`; use `\` to keep leading spaces on a line (if a line has no `*` prefix, leading spaces are preserved by default) |

---

## 2. Annotation Quick Reference

cjdoc provides 19 built-in annotations; all annotations can carry parameters (see 3.1 bilingual usage).

| Annotation | Meaning | Format | Applicable to |
|---|---|---|---|
| `@brief` | Brief description (one sentence) | `@brief one-sentence description` | All declarations |
| `@explain` | Detailed description (default annotation, multi-line) | `@explain detailed description` | File header / class / struct / enum / interface |
| `@file` | File description | `@file file-name file-description` | File header |
| `@intro` | Package-level overall introduction | `@intro introduction content` | File header |
| `@author` | Author | `@author author-name` | File header / class |
| `@version` | Version | `@version version-number` | File header / class |
| `@date` | Date | `@date date` | File header / class |
| `@since` | Version where the change was introduced | `@since version-number` | Declarations |
| `@see` | Reference link | `@see https://...` | File header / class / method |
| `@param` | Parameter description | `@param parameter-name parameter-description` | Function / method / constructor |
| `@return` | Return value description | `@return return-value-description` | Function / method |
| `@throws` | Thrown exception (equivalent to `@exception`) | `@throws exception-type exception-description` | Function / method |
| `@exception` | Alias of `@throws` | `@exception exception-type exception-description` | Function / method |
| `@note` | Note / tip | `@note note content` | Anywhere |
| `@warning` | Warning | `@warning warning content` | Anywhere |
| `@attention` | Things that need attention | `@attention attention points` | Anywhere |
| `@todo` | To-do items | `@todo todo content` | Anywhere |
| `@bug` | Known issues | `@bug issue description` | Anywhere |
| `@deprecated` | Deprecated usage | `@deprecated migration suggestion` | Declarations |
| `@example` | Usage example | `@example example-name` + newline + example code | File header / class / method |
| `@any-name` | Custom extension annotation (stored in `Comment.more`) | Same syntax as built-in annotations | Anywhere |

> Note: `@param`, `@file`, `@example`, and `@throws` are **two-part** (split by space/newline):
> - `@param parameter-name parameter-description`
> - `@file file-name file-description`
> - `@example example-name\n example content`
> - `@throws exception-type exception-description`

---

## 3. Bilingual Comment Conventions (Annotation Parameters)

cjdoc supports `@annotation-name[parameter]`; use the parameters `zh-cn` / `en` to write Chinese and English content separately, which can be filtered at generation time:

```cj
/**
 * @brief[zh-cn] 函数流程类
 *
 * @brief[en] Function workflow class
 */
```

A complete bilingual example with parameters, return value, and notes:

```cj
/**
 * @brief[zh-cn] 语法节点预处理函数
 * @param[zh-cn] id 唯一标识符
 * @param[zh-cn] decl 当前语法节点
 * @return[zh-cn] 返回解析后的注释对象
 * @attention[zh-cn] 本函数并发执行，注意线程安全
 *
 * @brief[en] Syntax node preprocessing function
 * @param[en] id Unique identifier
 * @param[en] decl Current syntax node
 * @return[en] Returns the parsed comment object
 * @attention[en] This function runs concurrently; mind thread safety
 */
```

## 4. Comment Templates by Declaration Type (Bilingual)

### 4.1 File-level documentation comment

Placed at the very top of the file, before the `package` declaration. Recommended content: `@file` (file name + description), `@brief`, `@explain` (multi-line details), and as needed `@author` / `@version` / `@date` / `@note` / `@see`.

```cj
/**
 * @file[zh-cn] bgfx 类型定义 bgfx C99 API 的枚举、句柄与结构体
 * @file[en] bgfx types  bgfx C99 API enums, handles and structs
 * @brief[zh-cn] 本文件包含 bgfx C API 的枚举、不透明句柄和 C 兼容结构体
 * @brief[en] This file contains bgfx C API enums, opaque handles and C-compatible structs
 * @explain[zh-cn] 详细说明文件职责、设计约定、注意事项（支持多行）。
 *         每行开头的 `*` 会被忽略。
 * @explain[en] Detailed description of the file's responsibility, design conventions
 *         and caveats (multi-line supported).
 * @author[zh-cn] 作者名
 * @author[en] Author Name
 * @version 1.0.0
 * @date 2026-08-28
 * @see https://github.com/bkaradzic/bgfx
 */
package bgfx4cj.bgfx
```

> Content guidelines:
> - `@file`: `file name` + `one sentence describing the purpose of the file`
> - `@brief`: one-sentence summary
> - `@explain`: responsibility, architectural position, design conventions, usage notes, etc.; multi-line allowed
> - `@note`: usage tips; `@see`: reference documentation/source link

### 4.2 Package-level introduction (`@intro`)

Used for an overall introduction of the current package; cjdoc aggregates it into the package list page:

```cj
/**
 * @intro[zh-cn] bgfx4cj 提供对 bgfx 渲染引擎、bx 基础库与 bimg 图像库的仓颉封装。
 * @intro[en] bgfx4cj provides Cangjie bindings for the bgfx renderer, bx base library
 *            and bimg image library.
 */
```

### 4.3 Class (`class`)

```cj
/**
 * @brief[zh-cn] 32 位 Adler 校验和哈希
 * @brief[en] 32-bit Adler checksum hash
 * @explain[zh-cn] 使用 Adler-32 算法计算数据校验和，比 CRC32 更快但碰撞率略高。
 *         适用于非加密场景的快速完整性检查。
 * @explain[en] Computes a data checksum with the Adler-32 algorithm. Faster than
 *         CRC32 but with a slightly higher collision rate. Suitable for fast
 *         non-cryptographic integrity checks.
 * @note[zh-cn] 提供流式（begin/add/end）与一次性计算两种用法。
 * @note[en] Supports both streaming (begin/add/end) and one-shot usage.
 */
public class HashAdler32 {
    ...
}
```

> Content guidelines: `@brief` (one sentence) + `@explain` (responsibility and use cases) + optional `@note` / `@see` / `@since`.

### 4.4 Struct (`struct`)

Struct comment and its **member variables**:

```cj
/** @brief[zh-cn] bimg::TextureInfo 的镜像结构 */
/** @brief[en] Mirror struct of bimg::TextureInfo */
@C
public struct TextureInfo {
    /** @brief[zh-cn] 纹理格式 */
    /** @brief[en] Texture format */
    public var format: UInt32 = 0
    /** @brief[zh-cn] 宽度（像素） */
    /** @brief[en] Width in pixels */
    public var width: UInt16 = 0
    ...
}
```

> Note: attribute macros such as `@C` do not affect comments. **Member variable** comments must also be placed immediately before the declaration.

### 4.5 Enum (`enum`) and enum members

```cj
/**
 * @brief[zh-cn] bgfx 渲染后端类型
 * @brief[en] bgfx renderer backend type
 * @explain[zh-cn] 指定使用哪个图形 API 进行渲染。
 * @explain[en] Specifies which graphics API is used for rendering.
 * @note[zh-cn] 并非所有平台都支持所有渲染器类型。
 * @note[en] Not all renderer types are supported on every platform.
 */
public enum RendererType {
    /** @brief[zh-cn] 空操作渲染器（不产生任何绘制调用） */
    /** @brief[en] No-op renderer (issues no draw calls) */
    | Noop
    /** @brief[zh-cn] Direct3D 12 */
    /** @brief[en] Direct3D 12 */
    | Direct3D12
    /** @brief[zh-cn] 枚举成员总数 */
    /** @brief[en] Total number of enum members */
    | Count

    /** @brief[zh-cn] 将枚举值转换为 UInt32 */
    /** @brief[en] Converts the enum value to UInt32 */
    public func value(): UInt32 { ... }

    /** @brief[zh-cn] 从 UInt32 转换回枚举值 */
    /** @brief[en] Converts a UInt32 back to the enum value */
    public static func fromValue(v: UInt32): RendererType { ... }
}
```

> Content guidelines: `@brief` + `@explain` on the enum body; one-sentence `@brief` on each **enum member**.

### 4.6 Interface (`interface`)

```cj
/**
 * @brief[zh-cn] 顶点数据源接口
 * @brief[en] Vertex data source interface
 * @explain[zh-cn] 抽象顶点缓冲的读取方式，便于统一渲染管线输入。
 * @explain[en] Abstracts vertex buffer access to unify render pipeline input.
 */
public interface VertexSource {
    /** @brief[zh-cn] 获取顶点数量 */
    /** @brief[en] Returns the number of vertices */
    public func count(): UInt32
    ...
}
```

### 4.7 Function / member method (`func`)

Core template for function comments (with parameters, return value, exceptions, and notes):

```cj
/**
 * @brief[zh-cn] 向顶点布局添加一个属性
 * @brief[en] Adds an attribute to a vertex layout
 * @param[zh-cn] `this` 对象实例指针
 * @param[zh-cn] attrib 属性类型
 * @param[zh-cn] normalized 是否归一化
 * @param[en] `this` Object instance pointer
 * @param[en] attrib Attribute type
 * @param[en] normalized Whether the value is normalized
 * @return[zh-cn] 返回修改后的顶点布局指针
 * @return[en] Returns the modified vertex layout pointer
 * @throws[zh-cn] IllegalStateException 当布局未处于声明状态时
 * @throws[en] IllegalStateException When the layout is not in declaration state
 * @note[zh-cn] 与 C API 行为一致
 * @note[en] Behaves identically to the C API
 */
public func bgfx_vertex_layout_add_cj(...): CPointer<VertexLayout> { ... }
```

> Content guidelines:
> - `@param`: **one line per parameter**, format `parameter-name parameter-description`; may be omitted when there is nothing to describe (but it is recommended to always write it)
> - `@return`: may be omitted for `void`/`Unit`; otherwise describe the meaning of the return value
> - `@throws`: exception type + triggering condition
> - `@note` / `@attention` / `@warning`: add usage notes as needed

### 4.8 Constructor (`init`)

```cj
/** @brief[zh-cn] 创建新的 CRC32 哈希实例，默认使用 IEEE 多项式 */
/** @brief[en] Creates a new CRC32 hash instance, defaulting to the IEEE polynomial */
public init() { ... }
```

Constructor with parameters:

```cj
/**
 * @brief[zh-cn] 以指定多项式创建实例
 * @brief[en] Creates an instance with the specified polynomial
 * @param[zh-cn] poly 多项式值
 * @param[en] poly The polynomial value
 */
public init(poly: UInt32) { ... }
```

### 4.9 Property (`prop`)

```cj
/**
 * @brief[zh-cn] 用于访问文件名称
 * @brief[en] Used to access the file name
 */
public open mut prop fileName: String {
    get() { _fileName }
    set(v) { _fileName = v }
}
```

> If the property is readable and writable, describe the semantics in `@brief`, or add `@param` to explain the setter value meaning.

### 4.10 Member variable / top-level variable (`var` / `let`)

```cj
/** @brief[zh-cn] 深度缓冲写入启用 */
/** @brief[en] Depth buffer write enable */
public let STATE_WRITE_Z: UInt64 = 0x0000004000000000

/** @brief[zh-cn] 写锁 */
/** @brief[en] Write lock */
public var writeMtx: Mutex
```

### 4.11 Constant (`const`)

```cj
/** @brief[zh-cn] bgfx API 版本号 */
/** @brief[en] bgfx API version number */
public const BGFX_API_VERSION: UInt32 = 129
```

### 4.12 Type alias (`typealias`)

```cj
/** @brief[zh-cn] 顶点属性数组类型 */
/** @brief[en] Vertex attribute array type */
public typealias VertexAttribs = Array<UInt32>
```

### 4.13 Macro (`macro`)

```cj
/** @brief[zh-cn] 计算字节对齐 */
/** @brief[en] Computes byte alignment */
public macro align_up(v: Int64, align: Int64): Int64 {
    ...
}
```

### 4.14 Extension (`extend`)

```cj
/**
 * @brief[zh-cn] 为 Vec3 提供便捷运算扩展
 * @brief[en] Provides convenience arithmetic extensions for Vec3
 */
public extend Vec3 {
    ...
}
```

---

## 5. Content Guidelines (What to Fill In for Each Item)

| Annotation | Content to fill in |
|---|---|
| `@file` | First part: file name; second part: one sentence on the file's responsibility |
| `@brief` | **One sentence** explaining "what it is / what it does", kept within 1 line |
| `@explain` | Responsibility, design intent, use cases, implementation conventions; multi-line allowed; **do not** repeat `@brief` |
| `@param` | First part: parameter name (must match the signature, including backtick parameters such as `` `this` ``); second part: meaning / valid range / default value |
| `@return` | Meaning of the return value; may be omitted for `Unit` |
| `@throws` / `@exception` | First part: exception type; second part: triggering condition and suggestion |
| `@note` | Supplementary usage notes (performance, threading, edge cases) |
| `@warning` | Warnings that may cause errors / data corruption |
| `@attention` | Things that must be paid attention to (concurrency, thread safety, etc.) |
| `@todo` | To-do task description |
| `@bug` | Known defects and their behavior |
| `@deprecated` | Deprecation reason + replacement |
| `@since` | Version since which the capability was introduced |
| `@see` | Reference link or related topic |
| `@example` | First part: example name; second part: runnable example code |
| `@intro` | Package-level overall introduction |

**General principles**:
1. `@brief` must always exist and stay short; `@explain` is where you elaborate.
2. List parameters one by one, in the same order as the signature; each `@param` on its own line.
3. When bilingual, the same annotation appears in pairs: `@x[zh-cn] ...` and `@x[en] ...`.
4. Do not write meaningless descriptions that merely repeat the identifier (e.g., `@param num 数量` is acceptable, `@param num num` is not).
5. Use `\@` to escape a literal `@` in content.
