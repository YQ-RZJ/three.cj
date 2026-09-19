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
 * @file[zh-cn] ShaderLibs  着色器库
 * @brief[zh-cn] 定义 Three.js ShaderLib 的 bgfx 实现
 *
 * @file[en] ShaderLibs  Shader library
 * @brief[en] Define the bgfx implementation of Three.js ShaderLib
 * @note[en] bgfx shaders require precompiled .bin files, or offline compilation with the shaderc tool.
 * At runtime an empty shader is created as a placeholder; in practice precompiled .bin files must be loaded.
 * To enable dynamic shader compilation, the full libshaderc library must be linked.
 *
 * @note[zh-cn] bgfx 着色器需要预编译的 .bin 文件，或使用 shaderc 工具离线编译。
 * 运行时创建空着色器作为占位，实际需加载预编译的 .bin 文件。
 * Ignore: Level 8 着色器加载范围，空着色器占位合理。
 * 要启用动态 shader 编译，需要链接完整的 libshaderc 库。
 */
package three.rendering.shaders

import std.collection.*
import three.rendering.interfaces.IShaderProgram
import bgfx4cj.bgfx.*
import bgfx4cj.shaderc.*
import three.utils.log.*
import three.utils.log.macros.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.core.thread.bgfxCallMtx
import three.rendering.shaders.ShaderLib.*
import three.rendering.shaders.ShaderChunk.*

// ===== 跨平台着色器编译配置 =====
// 使用 @When 条件编译在编译期根据目标平台选择对应的 shader 编译参数
// 与 ThreeRenderer.cj 中的 DEFAULT_RENDERER_TYPE 保持一致

// Windows: Direct3D11 → HLSL（使用 D3DCompiler 动态库）
@When[os == "Windows"]
public let SHADER_PLATFORM: String = "windows"
@When[os == "Windows"]
public let SHADER_PROFILE: String = "s_5_0"

// Linux (gnu): Vulkan → SPIR-V
@When[os == "Linux" && env == "gnu"]
public let SHADER_PLATFORM: String = "linux"
@When[os == "Linux" && env == "gnu"]
public let SHADER_PROFILE: String = "spirv"

// Linux (android): OpenGLES → ESSL（renderer_gl 用 glShaderSource 加载 GLSL 文本，
// SPIR-V 二进制会被驱动当文本解析导致崩溃，故不能用 spirv profile）
@When[os == "Linux" && env == "android"]
public let SHADER_PLATFORM: String = "android"
@When[os == "Linux" && env == "android"]
public let SHADER_PROFILE: String = "300_es"

// Linux (ohos): OpenGLES → ESSL（同上）
@When[os == "Linux" && env == "ohos"]
public let SHADER_PLATFORM: String = "android"
@When[os == "Linux" && env == "ohos"]
public let SHADER_PROFILE: String = "300_es"

// macOS / iOS: Metal
@When[os == "macOS" || os == "iOS"]
public let SHADER_PLATFORM: String = "osx"
@When[os == "macOS" || os == "iOS"]
public let SHADER_PROFILE: String = "metal"

// 兜底：其他平台 → SPIR-V
@When[
    os != "Windows" && 
    (os != "Linux" || (env != "gnu" && env != "android" && env != "ohos")) &&
    os != "macOS" && 
    os != "iOS"
]
public let SHADER_PLATFORM: String = "windows"
@When[
    os != "Windows" && 
    (os != "Linux" || (env != "gnu" && env != "android" && env != "ohos")) &&
    os != "macOS" && 
    os != "iOS"
]
public let SHADER_PROFILE: String = "spirv"

// ===== 着色器语言宏定义（跨平台） =====
// 参照 Three.js/src/renderers/shaders/ShaderLib.js 和 shaderc.cpp
// 用于 shaderc 编译时正确设置 BGFX_SHADER_LANGUAGE_* 宏
// Windows: Direct3D11 → HLSL (s_5_0 profile id = 500)
@When[os == "Windows"]
public let SHADER_LANGUAGE_DEFINE: String = "BGFX_SHADER_LANGUAGE_HLSL=500"
// Linux (gnu): Vulkan → SPIR-V
@When[os == "Linux" && env == "gnu"]
public let SHADER_LANGUAGE_DEFINE: String = "BGFX_SHADER_LANGUAGE_SPIRV=1"
// Linux (android): OpenGLES → ESSL（与 SHADER_PROFILE=300_es 一致）
@When[os == "Linux" && env == "android"]
public let SHADER_LANGUAGE_DEFINE: String = "BGFX_SHADER_LANGUAGE_ESSL=300"
// Linux (ohos): OpenGLES → ESSL（与 SHADER_PROFILE=300_es 一致）
@When[os == "Linux" && env == "ohos"]
public let SHADER_LANGUAGE_DEFINE: String = "BGFX_SHADER_LANGUAGE_ESSL=300"
// macOS / iOS: Metal
@When[os == "macOS" || os == "iOS"]
public let SHADER_LANGUAGE_DEFINE: String = "BGFX_SHADER_LANGUAGE_METAL=1"
// 兜底：其他平台 → SPIR-V
@When[
    os != "Windows" && 
    (os != "Linux" || (env != "gnu" && env != "android" && env != "ohos")) &&
    os != "macOS" && 
    os != "iOS"
]
public let SHADER_LANGUAGE_DEFINE: String = "BGFX_SHADER_LANGUAGE_SPIRV=1"

/**
 * @brief[zh-cn] 着色器程序定义，包含顶点和片段着色器源码
 * @explain[zh-cn] 2026-08-20：implements IShaderProgram（interfaces 包）——供 materials/Material 回调以接口持有，避免 materials↔shaders 循环依赖
 *
 * @brief[en] Shader program definition containing vertex and fragment shader sources
 * @explain[en] 2026-08-20: implements IShaderProgram (interfaces package) — allows materials/Material to hold reference by interface, avoiding materials↔shaders circular dependency
 */
public class ShaderProgram <: IShaderProgram {
    /**
     * @brief[zh-cn] 着色器程序名称
     *
     * @brief[en] Shader program name
     */
    public var name: String
    /**
     * @brief[zh-cn] 顶点着色器原始源码
     *
     * @brief[en] Vertex shader raw source
     */
    public var vertexShader: String
    /**
     * @brief[zh-cn] 片段着色器原始源码
     *
     * @brief[en] Fragment shader raw source
     */
    public var fragmentShader: String
    /**
     * @brief[zh-cn] 顶点着色器 bgfx 解析后源码
     *
     * @brief[en] Vertex shader bgfx resolved source
     */
    public var vertexShaderBgfx: String
    /**
     * @brief[zh-cn] 片段着色器 bgfx 解析后源码
     *
     * @brief[en] Fragment shader bgfx resolved source
     */
    public var fragmentShaderBgfx: String
    /**
     * @brief[zh-cn] varying 定义源码（.sc 格式）
     *
     * @brief[en] Varying definition source (.sc format)
     */
    public var varyingDef: String
    /**
     * @brief[zh-cn] 顶点着色器 bgfx 句柄
     *
     * @brief[en] Vertex shader bgfx handle
     */
    public var vshHandle: ShaderHandle
    /**
     * @brief[zh-cn] 片段着色器 bgfx 句柄
     *
     * @brief[en] Fragment shader bgfx handle
     */
    public var fshHandle: ShaderHandle
    /**
     * @brief[zh-cn] bgfx 程序句柄
     *
     * @brief[en] bgfx program handle
     */
    public var programHandle: ProgramHandle

    /**
     * @brief[zh-cn] 构造着色器程序
     * @param[zh-cn] name 着色器程序名称
     * vertexShader 顶点着色器源码
     * fragmentShader 片段着色器源码
     * varyingDef varying 定义（.sc 格式），默认为空
     *
     * @brief[en] Construct a shader program
     * @param[en] name Shader program name
     * vertexShader Vertex shader source
     * fragmentShader Fragment shader source
     * varyingDef Varying definition (.sc format), default empty
     */
    public init(name: String, vertexShader: String, fragmentShader: String, varyingDef!: String = "") {
        this.name = name
        this.vertexShader = vertexShader
        this.fragmentShader = fragmentShader
        this.varyingDef = varyingDef
        // 延迟 resolve：构造函数只保存源码，不执行昂贵的 ShaderChunks.resolve()
        // 字符串处理（ShaderLibs.initialize() 注册 19 个 shader 会串行耗时 ~3 秒，
        // 阻塞 initBgfx 首帧——OHOS 上黑屏/系统开屏持续显示）。resolve 延迟到
        // 首次 get()/compileBgfx() 时按需执行（_ensureResolved 幂等），只 resolve
        // 场景实际用到的 shader，行为不变。
        this.vertexShaderBgfx = ""
        this.fragmentShaderBgfx = ""
        this.vshHandle = ShaderHandle(65535u16)
        this.fshHandle = ShaderHandle(65535u16)
        this.programHandle = ProgramHandle(65535u16)
    }

    /**
     * 把三个句柄重置为无效（强制 compileBgfxWithDefines 重编译）。
     * 供 postprocessing 等外部层调用，避免其直接构造 bgfx 原生句柄。
     */
    public func resetHandles(): Unit {
        this.vshHandle = ShaderHandle(65535u16)
        this.fshHandle = ShaderHandle(65535u16)
        this.programHandle = ProgramHandle(65535u16)
    }

    /**
     * 从基类 ShaderProgram 创建变体，直接复用已解析的 bgfx 着色器源码，
     * 避免每帧重复执行 ShaderChunks.resolve() 的昂贵字符串处理。
     */
    public static func createVariant(name: String, base: ShaderProgram): ShaderProgram {
        base._ensureResolved()  // 延迟 resolve：确保 base 源码已解析（variant 复制 resolve 后源码）
        let sp = ShaderProgram._empty()  // 内部构造，仅设 name/handles
        sp.name = name
        sp.vertexShader = base.vertexShader
        sp.fragmentShader = base.fragmentShader
        sp.varyingDef = base.varyingDef
        sp.vertexShaderBgfx = base.vertexShaderBgfx
        sp.fragmentShaderBgfx = base.fragmentShaderBgfx
        sp.vshHandle = ShaderHandle(65535u16)
        sp.fshHandle = ShaderHandle(65535u16)
        sp.programHandle = ProgramHandle(65535u16)
        return sp
    }

    // 内部无参构造，供 createVariant 使用以避免重复 chunk resolve
    private static func _empty(): ShaderProgram {
        return ShaderProgram("_empty", "", "")
    }

    /**
     * @param[zh-cn] label 日志标签（如 "VS" / "FS"）
     * @param[zh-cn] shaderType 着色器类型（Vertex / Fragment）
     * @param[zh-cn] shaderSource 着色器源码
     * @param[zh-cn] varyingDefPtr varying 定义的 C 指针
     * @param[zh-cn] varyingDefSize varying 定义的字节大小
     * @param[zh-cn] profile profile C 字符串指针
     * @param[zh-cn] platform platform C 字符串指针
     * @param[zh-cn] defines defines 数组指针
     * @param[zh-cn] numDefines defines 数量
     * @return[zh-cn] 编译成功返回 bgfx shader handle，失败返回无效 handle（idx=65535）
     *
     * 通用着色器编译方法，封装 VS/FS 共用的编译流程
     *
     * @param[en] label Log label (e.g. "VS" / "FS")
     * @param[en] shaderType Shader type (Vertex / Fragment)
     * @param[en] shaderSource Shader source code
     * @param[en] varyingDefPtr C pointer to varying definitions
     * @param[en] varyingDefSize Byte size of varying definitions
     * @param[en] profile Profile C string pointer
     * @param[en] platform Platform C string pointer
     * @param[en] defines Defines array pointer
     * @param[en] numDefines Number of defines
     * @return[en] Returns bgfx shader handle on success, invalid handle (idx=65535) on failure
     */
    private static func _compileShader(
        label: String,
        shaderType: ScType,
        shaderSource: String,
        varyingDefPtr: CPointer<Unit>,
        varyingDefSize: UInt32,
        profile: CPointer<UInt8>,
        platform: CPointer<UInt8>,
        defines: CPointer<CPointer<UInt8>>,
        numDefines: UInt32
    ): ShaderHandle {
        @LogDebug(["shader", "${label} source length: " + shaderSource.size.toString()])

        // 源码字符串 → C 字节数组（null-terminated）
        let srcBytes = shaderSource.toArray()
        let srcPtrHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(srcBytes.size + 1)) })
        let srcPtr = srcPtrHolder.get()
        unsafe {
            for (i in 0..srcBytes.size) { (srcPtr + i).write(srcBytes[i]) }
            (srcPtr + Int64(srcBytes.size)).write(0u8)
        }

        // 设置编译选项
        var options = ScOptions()
        options.shaderType = shaderType.value()
        options.profile = profile
        options.platform = platform
        options.defines = defines
        options.numDefines = numDefines

        let optionsPtrHolder = AutoFreePtr<ScOptions>(unsafe { LibC.malloc<ScOptions>() })
        let optionsPtr = optionsPtrHolder.get()
        unsafe { optionsPtr.write(options) }

        let resultPtrHolder = AutoFreePtr<ScResult>(unsafe { LibC.malloc<ScResult>() })
        let resultPtr = resultPtrHolder.get()

        @LogDebug(["shader", "${label} about to compile: srcSize=" + srcBytes.size.toString() + " varyingSize=" + varyingDefSize.toString() + " numDefines=" + numDefines.toString() + " shaderType=" + shaderType.value().toString()])

        // 通过 ShaderCompiler 的大栈线程编译，避免 glslang/glsl-optimizer 栈溢出
        let job = ShaderCompileJob(
            label, varyingDefPtr, varyingDefSize,
            CPointer<Unit>(srcPtr), UInt32(srcBytes.size + 1),
            CPointer<ScOptions>(optionsPtr), CPointer<ScResult>(resultPtr)
        )
        ShaderCompiler.submit(job)
        job.waitFor()
        let ret = job.compileResult

        @LogDebug(["shader", "compile ${label}: ret=" + ret.toString()])

        var handle = ShaderHandle(65535u16)

        if (ret == 0) {
            let resultVal = unsafe { resultPtr.read() }
            @LogDebug(["shader", "${label} compiled: size=" + resultVal.size.toString()])
            @LogDebug(["shader", "about to call bgfx_create_shader_cj(${label}) ..."])
            let memBuf = BgfxMemory(CPointer<Unit>(resultVal.data), UInt32(resultVal.size))
            bgfxCallMtx.lock()
            try {
                handle = bgfx_create_shader_cj(memBuf.get())
            } finally {
                bgfxCallMtx.unlock()
            }
            @LogDebug(["shader", "bgfx_create_shader_cj(${label}) done: handle=" + handle.idx.toString()])
            sc_result_free_cj(resultPtr)
        } else {
            @LogError(["shader", "${label} compilation FAILED: ret=" + ret.toString()])
            let errResult = unsafe { resultPtr.read() }
            if (errResult.message.isNotNull()) {
                let msgBytes = ArrayList<UInt8>()
                var i = 0
                while (true) {
                    let c = unsafe { (errResult.message + i).read() }
                    if (c == 0u8) { break }
                    msgBytes.add(c)
                    i += 1
                }
                let msg = String(Array<Rune>(msgBytes.size, { idx => Rune(Int32(msgBytes[idx])) }))
                @LogError(["shader", "${label} error: " + msg])
            }
        }

        // 释放本方法分配的临时内存
        optionsPtrHolder.dispose()
        resultPtrHolder.dispose()
        srcPtrHolder.dispose()

        return handle
    }

    public func resolveShaders(): Unit {
        // ★占位符注入：把 chunk 中 SAMPLER2D/SAMPLERCUBE 的 __STAGE_XXX__ 占位符
        // 替换为 SamplerStages 中的实际 stage 数字，确保着色器端 reg 与后端
        // bgfx_set_texture_cj 的 stage 始终一致（全局 stage 分配器统一管理）。
        let vsResolved = ShaderChunks.resolve(this.vertexShader)
        let fsResolved = ShaderChunks.resolve(this.fragmentShader)
        this.vertexShaderBgfx = SamplerStages.applyPlaceholders(vsResolved)
        this.fragmentShaderBgfx = SamplerStages.applyPlaceholders(fsResolved)
    }

    // 延迟 resolve（幂等）：源码未解析时执行完整解析（替换 bgfx_shader.sh 内联 +
    // chunk resolve + 占位符注入，即构造函数原逻辑）。构造函数不再立即 resolve，
    // 避免 ShaderLibs.initialize() 全量注册耗时（OHOS initBgfx 首帧黑屏 ~3 秒的根因）；
    // 首次 get()/compileBgfx() 时按需触发，只 resolve 场景实际用到的 shader。
    // protected：内部方法不对 API 层公开；ShaderLibs.get()（同包跨类）与 createVariant
    //（同类静态）均可访问。
    protected func _ensureResolved(): Unit {
        if (this.vertexShaderBgfx == "") {
            let vsProcessed = this.vertexShader.replace("#include <bgfx_shader.sh>", BGFX_SHADER_SOURCE)
            let fsProcessed = this.fragmentShader.replace("#include <bgfx_shader.sh>", BGFX_SHADER_SOURCE)
            let vsResolved = ShaderChunks.resolve(vsProcessed)
            let fsResolved = ShaderChunks.resolve(fsProcessed)
            this.vertexShaderBgfx = SamplerStages.applyPlaceholders(vsResolved)
            this.fragmentShaderBgfx = SamplerStages.applyPlaceholders(fsResolved)
        }
    }

    /**
     * @param[zh-cn] extraDefines 额外的 #define 标志数组（如 "USE_MAP=1"）；默认空（仅含跨平台语言宏定义）
     *
     * 编译 bgfx shader（带变体 #define 标志）
     * 使用 libshaderc 动态编译 GLSL 源码为 bgfx 二进制 shader
     *
     * @param[en] extraDefines Extra #define flag array (e.g. "USE_MAP=1"); default empty (only cross-platform language macro definitions)
     */
    public func compileBgfx(extraDefines!: Array<String> = Array<String>()): Unit {
        // 延迟 resolve：确保源码已解析（构造函数不再立即 resolve）
        this._ensureResolved()
        // 使用着色器自带的 varying def（.sc 格式）或默认 def（旧版 chunk 格式）
        let varyingDef = if (this.varyingDef != "") { this.varyingDef } else { "vec3 a_position  : POSITION;\n" }
        let varyingDefBytes = varyingDef.toArray()
        let varyingDefHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(varyingDefBytes.size + 1)) })
        let varyingDefPtr = varyingDefHolder.get()
        unsafe {
            for (i in 0..varyingDefBytes.size) { (varyingDefPtr + i).write(varyingDefBytes[i]) }
            (varyingDefPtr + Int64(varyingDefBytes.size)).write(0u8)
        }

        // 准备跨平台编译参数（VS/FS 共用）
        let profileStr = SHADER_PROFILE
        let profileBytes = profileStr.toArray()
        let profilePtrHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(profileBytes.size + 1)) })
        let profilePtr = profilePtrHolder.get()
        unsafe {
            for (i in 0..profileBytes.size) { (profilePtr + i).write(profileBytes[i]) }
            (profilePtr + Int64(profileBytes.size)).write(0u8)
        }
        let platformStr = SHADER_PLATFORM
        let platformBytes = platformStr.toArray()
        let platformPtrHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(platformBytes.size + 1)) })
        let platformPtr = platformPtrHolder.get()
        unsafe {
            for (i in 0..platformBytes.size) { (platformPtr + i).write(platformBytes[i]) }
            (platformPtr + Int64(platformBytes.size)).write(0u8)
        }

        // 设置着色器语言宏定义 + 变体 #define 标志
        // 第 0 个：跨平台语言定义（SHADER_LANGUAGE_DEFINE）
        // 第 1..N 个：变体标志（USE_MAP=1, USE_NORMALMAP=1, ...）
        let langDefineStr = SHADER_LANGUAGE_DEFINE
        let langDefineBytes = langDefineStr.toArray()
        let langDefinePtrHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(langDefineBytes.size + 1)) })
        let langDefinePtr = langDefinePtrHolder.get()
        unsafe {
            for (i in 0..langDefineBytes.size) { (langDefinePtr + i).write(langDefineBytes[i]) }
            (langDefinePtr + Int64(langDefineBytes.size)).write(0u8)
        }
        let numExtraDefines = UInt32(extraDefines.size)
        let totalDefines = 1u32 + numExtraDefines
        // 诊断：打印编译 defines，确认 USE_UV/USE_MAP 传入
        var defsDiag = ""
        for (d in extraDefines) { defsDiag += d + ";" }
        @LogDebug(["defsDiag", "numDefines=${totalDefines.toString()} defs=${defsDiag}"])
        let definesArrHolder = AutoFreePtr<CPointer<UInt8>>(unsafe { LibC.malloc<CPointer<UInt8>>(count: Int64(totalDefines)) })
        let definesArr = definesArrHolder.get()
        unsafe { definesArr.write(CPointer<UInt8>(langDefinePtr)) }
        // 把 Array<String> 变体标志逐个转换为 C 字符串，指针存入 definesArr（第 1..N 个）
        let extraStrHolders = ArrayList<AutoFreePtr<UInt8>>()
        for (i in 0..extraDefines.size) {
            let bytes = extraDefines[i].toArray()
            let strHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(bytes.size + 1)) })
            let strPtr = strHolder.get()
            unsafe {
                for (j in 0..bytes.size) { (strPtr + Int64(j)).write(bytes[j]) }
                (strPtr + Int64(bytes.size)).write(0u8)
            }
            extraStrHolders.add(strHolder)
            unsafe { (definesArr + Int64(1) + i).write(CPointer<UInt8>(strPtr)) }
        }

        // VS 诊断：打印源码预览和 UV 赋值链路
        let vsSrc = this.vertexShaderBgfx
        let vsDebug = if (vsSrc.size > 100) { vsSrc[0..100] } else { vsSrc }
        @LogDebug(["shader", "VS source preview: " + vsDebug.replace("\n", "\\n")])
        let vsLinesDiag = vsSrc.split("\n")
        for (li in 0..vsLinesDiag.size) {
            let vline = vsLinesDiag[li]
            if (vline.contains("v_mapUv") || vline.contains("vUv") || vline.contains("MAP_UV") || vline.contains("uv_vertex") || vline.contains("a_texcoord0")) {
                @LogDebug(["vs-dbg", "L${li.toString()}: ${vline}"])
            }
        }

        // FS 诊断：打印方向光循环相关片段
        let fsSrc = this.fragmentShaderBgfx
        let fsLines = fsSrc.split("\n")
        for (li in 0..fsLines.size) {
            let line = fsLines[li]
            if (line.contains("u_lightDir") || line.contains("NUM_DIR_LIGHTS") || line.contains("RE_Direct") || line.contains("directionalLight") || line.contains("unroll") || line.contains("v_normal") || line.contains("geometryNormal") || line.contains("texture2D") || line.contains("SAMPLER2D") || line.contains("vMapUv") || line.contains("USE_MAP")) {
                @LogDebug(["fs-dbg", "L${li.toString()}: ${line}"])
            }
        }

        // 编译顶点着色器和片段着色器（并行提交，利用 ShaderCompiler 并发加速）
        // 准备 VS 和 FS 各自的编译参数
        let vsSrcBytes = this.vertexShaderBgfx.toArray()
        let vsSrcHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(vsSrcBytes.size + 1)) })
        let vsSrcPtr = vsSrcHolder.get()
        unsafe {
            for (i in 0..vsSrcBytes.size) { (vsSrcPtr + i).write(vsSrcBytes[i]) }
            (vsSrcPtr + Int64(vsSrcBytes.size)).write(0u8)
        }
        let fsSrcBytes = this.fragmentShaderBgfx.toArray()
        let fsSrcHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(fsSrcBytes.size + 1)) })
        let fsSrcPtr = fsSrcHolder.get()
        unsafe {
            for (i in 0..fsSrcBytes.size) { (fsSrcPtr + i).write(fsSrcBytes[i]) }
            (fsSrcPtr + Int64(fsSrcBytes.size)).write(0u8)
        }
        var vsOptions = ScOptions()
        vsOptions.shaderType = ScType.Vertex.value()
        vsOptions.profile = CPointer<UInt8>(profilePtr)
        vsOptions.platform = CPointer<UInt8>(platformPtr)
        vsOptions.defines = CPointer<CPointer<UInt8>>(definesArr)
        vsOptions.numDefines = totalDefines
        var fsOptions = ScOptions()
        fsOptions.shaderType = ScType.Fragment.value()
        fsOptions.profile = CPointer<UInt8>(profilePtr)
        fsOptions.platform = CPointer<UInt8>(platformPtr)
        fsOptions.defines = CPointer<CPointer<UInt8>>(definesArr)
        fsOptions.numDefines = totalDefines
        let vsOptHolder = AutoFreePtr<ScOptions>(unsafe { LibC.malloc<ScOptions>() })
        let vsOptPtr = vsOptHolder.get()
        unsafe { vsOptPtr.write(vsOptions) }
        let fsOptHolder = AutoFreePtr<ScOptions>(unsafe { LibC.malloc<ScOptions>() })
        let fsOptPtr = fsOptHolder.get()
        unsafe { fsOptPtr.write(fsOptions) }
        let vsResultHolder = AutoFreePtr<ScResult>(unsafe { LibC.malloc<ScResult>() })
        let vsResultPtr = vsResultHolder.get()
        let fsResultHolder = AutoFreePtr<ScResult>(unsafe { LibC.malloc<ScResult>() })
        let fsResultPtr = fsResultHolder.get()

        // 创建并提交 VS、FS 编译任务（并行编译）
        let vsJob = ShaderCompileJob(
            "VS", CPointer<Unit>(varyingDefPtr), UInt32(varyingDefBytes.size + 1),
            CPointer<Unit>(vsSrcPtr), UInt32(vsSrcBytes.size + 1),
            CPointer<ScOptions>(vsOptPtr), CPointer<ScResult>(vsResultPtr)
        )
        let fsJob = ShaderCompileJob(
            "FS", CPointer<Unit>(varyingDefPtr), UInt32(varyingDefBytes.size + 1),
            CPointer<Unit>(fsSrcPtr), UInt32(fsSrcBytes.size + 1),
            CPointer<ScOptions>(fsOptPtr), CPointer<ScResult>(fsResultPtr)
        )
        ShaderCompiler.submit(vsJob)
        ShaderCompiler.submit(fsJob)

        // 等待两个任务完成
        vsJob.waitFor()
        fsJob.waitFor()

        // 处理 VS 编译结果
        if (vsJob.compileResult == 0) {
            let vsResultVal = unsafe { vsResultPtr.read() }
            @LogDebug(["shader", "VS compiled: size=" + vsResultVal.size.toString()])
            let vsMemBuf = BgfxMemory(CPointer<Unit>(vsResultVal.data), UInt32(vsResultVal.size))
            this.vshHandle = bgfx_create_shader_cj(vsMemBuf.get())
            @LogDebug(["shader", "VS bgfx handle: " + this.vshHandle.idx.toString()])
            sc_result_free_cj(vsResultPtr)
        } else {
            @LogError(["shader", "VS compilation FAILED: ret=" + vsJob.compileResult.toString()])
        }
        // 处理 FS 编译结果
        if (fsJob.compileResult == 0) {
            let fsResultVal = unsafe { fsResultPtr.read() }
            @LogDebug(["shader", "FS compiled: size=" + fsResultVal.size.toString()])
            let fsMemBuf = BgfxMemory(CPointer<Unit>(fsResultVal.data), UInt32(fsResultVal.size))
            this.fshHandle = bgfx_create_shader_cj(fsMemBuf.get())
            @LogDebug(["shader", "FS bgfx handle: " + this.fshHandle.idx.toString()])
            sc_result_free_cj(fsResultPtr)
        } else {
            @LogError(["shader", "FS compilation FAILED: ret=" + fsJob.compileResult.toString()])
        }

        // 统一释放本函数分配的全部内存（AutoFreePtr.dispose 即时释放，
        // 即使遗漏 GC 终结器也会兜底；此处显式释放避免等待 GC）。
        varyingDefHolder.dispose()
        profilePtrHolder.dispose(); platformPtrHolder.dispose(); langDefinePtrHolder.dispose()
        definesArrHolder.dispose()
        for (h in extraStrHolders) { h.dispose() }
        vsSrcHolder.dispose(); fsSrcHolder.dispose()
        vsOptHolder.dispose(); fsOptHolder.dispose()
        vsResultHolder.dispose(); fsResultHolder.dispose()

        // 创建 bgfx program
        if (this.vshHandle.idx != 65535u16 && this.fshHandle.idx != 65535u16) {
            @LogDebug(["shader", "about to call bgfx_create_program_cj ..."])
            bgfxCallMtx.lock()
            try {
                this.programHandle = bgfx_create_program_cj(this.vshHandle, this.fshHandle, true)
            } finally {
                bgfxCallMtx.unlock()
            }
            @LogDebug(["shader", "Program created: idx=" + this.programHandle.idx.toString()])
        } else {
            @LogError(["shader", "Program creation SKIPPED: vs=" + this.vshHandle.idx.toString() + " fs=" + this.fshHandle.idx.toString()])
        }
    }
}

/**
 * @brief[zh-cn] 着色器库，管理所有材质类型的着色器程序
 *
 * @brief[en] Shader library managing shader programs for all material types
 */
public class ShaderLibs {
    private static var programs: HashMap<String, ShaderProgram> = HashMap<String, ShaderProgram>()

    /**
     * @param[zh-cn] name 着色器程序名称
     * @return[zh-cn] 着色器程序（若不存在返回 None）
     *
     * @brief[en] Get shader program by name (resolves source on first call)
     * @param[en] name Shader program name
     * @return[en] Shader program (None if not found)
     */
    public static func get(name: String): ?ShaderProgram {
        let p = programs.get(name)
        // 延迟 resolve：首次 get 时按需解析源码（ShaderLibs.initialize() 不再全量 resolve）
        match (p) {
            case Some(sp) => sp._ensureResolved()
            case None => ()
        }
        return p
    }

    /**
     * @brief[zh-cn] 初始化所有着色器程序，注册 ShaderChunk 和材质着色器
     *
     * @brief[en] Initialize all shader programs, register ShaderChunks and material shaders
     */
    public static func initialize(): Unit {
        ShaderChunks.initialize()
        // 启动 shader 编译器（专用大栈线程，避免编译大 shader 时栈溢出）
        ShaderCompiler.start()

        // 1. meshbasic - 基础材质（无光照），对照 three.js ShaderLib/meshbasic.glsl.js
        // 方案 A：shell 头部 $input/$output 用 #if defined(USE_*) 守护，fcpp 预处理器先跑删死分支，
        // 只剩激活的 $ 行连续被 $ 解析器扫描；body 改回 #include <chunk> 风格真正复用 chunk（对齐 three.js）。
        // 变量命名以 Three.js 为准（chunk body 实际统一用下划线 v_uv/v_mapUv 等，弃驼峰 vUv/vMapUv）。
        let basicVS = """
$input a_position
$input a_texcoord0
#if defined( USE_UV ) || defined( USE_ANISOTROPY )
$output v_uv
#endif
#ifdef USE_MAP
$output v_mapUv
#endif
#ifdef USE_ALPHAMAP
$output v_alphaMapUv
#endif
#ifdef USE_LIGHTMAP
$output v_lightMapUv
#endif
#ifdef USE_AOMAP
$output v_aoMapUv
#endif
#ifdef USE_BUMPMAP
$output v_bumpMapUv
#endif
#ifdef USE_NORMALMAP
$output v_normalMapUv
#endif
#ifdef USE_DISPLACEMENTMAP
$output v_displacementMapUv
#endif
#ifdef USE_EMISSIVEMAP
$output v_emissiveMapUv
#endif
#ifdef USE_METALNESSMAP
$output v_metalnessMapUv
#endif
#ifdef USE_ROUGHNESSMAP
$output v_roughnessMapUv
#endif
#ifdef USE_ANISOTROPYMAP
$output v_anisotropyMapUv
#endif
#ifdef USE_CLEARCOATMAP
$output v_clearcoatMapUv
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
$output v_clearcoatNormalMapUv
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
$output v_clearcoatRoughnessMapUv
#endif
#ifdef USE_IRIDESCENCEMAP
$output v_iridescenceMapUv
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
$output v_iridescenceThicknessMapUv
#endif
#ifdef USE_SHEEN_COLORMAP
$output v_sheenColorMapUv
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
$output v_sheenRoughnessMapUv
#endif
#ifdef USE_SPECULARMAP
$output v_specularMapUv
#endif
#ifdef USE_SPECULAR_COLORMAP
$output v_specularColorMapUv
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
$output v_specularIntensityMapUv
#endif
#ifdef USE_TRANSMISSIONMAP
$output v_transmissionMapUv
#endif
#ifdef USE_THICKNESSMAP
$output v_thicknessMapUv
#endif
$output v_worldPos
$output v_viewPos
#if defined( USE_ENVMAP ) && !defined( ENV_WORLDPOS )
$output v_reflect
#endif
#if defined( USE_FOG )
$output v_fogDepth
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$output v_fragDepth
$output v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$output v_clipPosition
#endif
#if defined( USE_ALPHAHASH )
$output v_position
#endif

#include <bgfx_shader.sh>

// chunk pars：对照 three.js meshbasic.vert pars 段
#include <common>
#include <uv_pars_vertex>
#include <envmap_pars_vertex>
#include <fog_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main()
{
    #include <uv_vertex>
    #include <begin_vertex>
    #include <project_vertex>
    #include <logdepthbuf_vertex>
    #include <clipping_planes_vertex>

    #include <worldpos_vertex>
    #include <envmap_vertex>
    #include <fog_vertex>
}
"""
        // basic 片段：对照 three.js meshbasic.frag 的 #include 顺序
        // diffuse/opacity → chunk pars → main → chunk body → outgoingLight → envmap/output/tm/colorspace/fog/premult/dither
        let basicFS = """
#if defined( USE_UV ) || defined( USE_ANISOTROPY )
$input v_uv
#endif
#ifdef USE_MAP
$input v_mapUv
#endif
#ifdef USE_ALPHAMAP
$input v_alphaMapUv
#endif
#ifdef USE_LIGHTMAP
$input v_lightMapUv
#endif
#ifdef USE_AOMAP
$input v_aoMapUv
#endif
#ifdef USE_BUMPMAP
$input v_bumpMapUv
#endif
#ifdef USE_NORMALMAP
$input v_normalMapUv
#endif
#ifdef USE_DISPLACEMENTMAP
$input v_displacementMapUv
#endif
#ifdef USE_EMISSIVEMAP
$input v_emissiveMapUv
#endif
#ifdef USE_METALNESSMAP
$input v_metalnessMapUv
#endif
#ifdef USE_ROUGHNESSMAP
$input v_roughnessMapUv
#endif
#ifdef USE_ANISOTROPYMAP
$input v_anisotropyMapUv
#endif
#ifdef USE_CLEARCOATMAP
$input v_clearcoatMapUv
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
$input v_clearcoatNormalMapUv
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
$input v_clearcoatRoughnessMapUv
#endif
#ifdef USE_IRIDESCENCEMAP
$input v_iridescenceMapUv
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
$input v_iridescenceThicknessMapUv
#endif
#ifdef USE_SHEEN_COLORMAP
$input v_sheenColorMapUv
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
$input v_sheenRoughnessMapUv
#endif
#ifdef USE_SPECULARMAP
$input v_specularMapUv
#endif
#ifdef USE_SPECULAR_COLORMAP
$input v_specularColorMapUv
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
$input v_specularIntensityMapUv
#endif
#ifdef USE_TRANSMISSIONMAP
$input v_transmissionMapUv
#endif
#ifdef USE_THICKNESSMAP
$input v_thicknessMapUv
#endif
$input v_worldPos
$input v_viewPos
#if defined( USE_ENVMAP ) && !defined( ENV_WORLDPOS )
$input v_reflect
#endif
#if defined( USE_FOG )
$input v_fogDepth
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$input v_fragDepth
$input v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$input v_clipPosition
#endif
#if defined( USE_ALPHAHASH )
$input v_position
#endif

#include <bgfx_shader.sh>

uniform vec4 u_color;
uniform vec4 u_opacity;

// chunk pars：对照 three.js meshbasic.frag pars 段
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
#include <colorspace_pars_fragment>

void main()
{
    vec4 diffuseColor = vec4(u_color.rgb, u_opacity.x);

    #include <clipping_planes_fragment>

    #include <logdepthbuf_fragment>
    #include <map_fragment>
    #include <color_fragment>
    #include <alphamap_fragment>
    #include <alphatest_fragment>
    #include <alphahash_fragment>
    #include <specularmap_fragment>

    // accumulation（baked indirect lighting only）
    vec3 reflectedLight_indirectDiffuse = vec3_splat(0.0);
    #ifdef USE_LIGHTMAP
        reflectedLight_indirectDiffuse += texture2D(u_lightMap, v_lightMapUv).rgb * u_lightMapIntensity.x * (1.0 / 3.14159);
    #else
        reflectedLight_indirectDiffuse += vec3_splat(1.0);
    #endif

    #include <aomap_fragment>
    reflectedLight_indirectDiffuse *= diffuseColor.rgb;

    vec3 outgoingLight = reflectedLight_indirectDiffuse;

    #include <envmap_fragment>
    #include <opaque_fragment>
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
    #include <fog_fragment>
    #include <premultiplied_alpha_fragment>
    #include <dithering_fragment>
}
"""
        // varyingDef：每个变量配类型 + TEXCOORDn 槽 + 默认值。UV 系多但运行时互斥，复用 TEXCOORD1-15。
        // 非 UV 的 v_worldPos/v_reflect/v_fogDepth/v_clipPosition/v_position 各占固定槽避免冲突。
        let basicVaryingDef = """
vec3 a_position : POSITION;
vec2 a_texcoord0 : TEXCOORD0;
vec3 v_worldPos : TEXCOORD0 = vec3(0.0, 0.0, 0.0);
vec3 v_viewPos : TEXCOORD2 = vec3(0.0, 0.0, 0.0);
vec2 v_uv : TEXCOORD3 = vec2(0.0, 0.0);
vec3 v_reflect : TEXCOORD6 = vec3(0.0, 0.0, 0.0);
float v_fogDepth : TEXCOORD7 = 0.0;
float v_fragDepth : TEXCOORD8 = 0.0;
float v_isPerspective : TEXCOORD9 = 0.0;
vec3 v_clipPosition : TEXCOORD10 = vec3(0.0, 0.0, 0.0);
vec3 v_position : TEXCOORD11 = vec3(0.0, 0.0, 0.0);
// UV map varyings — 与主要 varyings 互斥复用槽位
vec2 v_mapUv : TEXCOORD4 = vec2(0.0, 0.0);
vec2 v_alphaMapUv : TEXCOORD5 = vec2(0.0, 0.0);
vec2 v_lightMapUv : TEXCOORD4 = vec2(0.0, 0.0);
vec2 v_aoMapUv : TEXCOORD5 = vec2(0.0, 0.0);
vec2 v_bumpMapUv : TEXCOORD6 = vec2(0.0, 0.0);
vec2 v_normalMapUv : TEXCOORD7 = vec2(0.0, 0.0);
vec2 v_displacementMapUv : TEXCOORD8 = vec2(0.0, 0.0);
vec2 v_emissiveMapUv : TEXCOORD9 = vec2(0.0, 0.0);
vec2 v_metalnessMapUv : TEXCOORD10 = vec2(0.0, 0.0);
vec2 v_roughnessMapUv : TEXCOORD11 = vec2(0.0, 0.0);
vec2 v_anisotropyMapUv : TEXCOORD12 = vec2(0.0, 0.0);
vec2 v_clearcoatMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_clearcoatNormalMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_clearcoatRoughnessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_iridescenceMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_iridescenceThicknessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_sheenColorMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_sheenRoughnessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_specularMapUv : TEXCOORD15 = vec2(0.0, 0.0);
vec2 v_specularColorMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_specularIntensityMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_transmissionMapUv : TEXCOORD15 = vec2(0.0, 0.0);
vec2 v_thicknessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
"""
        programs.add("basic", ShaderProgram("basic", basicVS, basicFS, varyingDef: basicVaryingDef))

        // 2. meshlambert - Lambert 漫反射光照，对照 three.js ShaderLib/meshlambert.glsl.js
        // 比 basic 多 normal 路径（VS 输出 v_normal，FS 用 N·L 漫反射）与 lights_* chunk
        // 裁剪：morphtarget/skinning/batching/color 路径无 CPU 绑定，不引用
        let lambertVS = """
$input a_position
$input a_normal
$input a_texcoord0
#if defined( USE_UV ) || defined( USE_ANISOTROPY )
$output v_uv
#endif
#ifdef USE_MAP
$output v_mapUv
#endif
#ifdef USE_ALPHAMAP
$output v_alphaMapUv
#endif
#ifdef USE_LIGHTMAP
$output v_lightMapUv
#endif
#ifdef USE_AOMAP
$output v_aoMapUv
#endif
#ifdef USE_BUMPMAP
$output v_bumpMapUv
#endif
#ifdef USE_NORMALMAP
$output v_normalMapUv
#endif
#ifdef USE_DISPLACEMENTMAP
$output v_displacementMapUv
#endif
#ifdef USE_EMISSIVEMAP
$output v_emissiveMapUv
#endif
#ifdef USE_METALNESSMAP
$output v_metalnessMapUv
#endif
#ifdef USE_ROUGHNESSMAP
$output v_roughnessMapUv
#endif
#ifdef USE_ANISOTROPYMAP
$output v_anisotropyMapUv
#endif
#ifdef USE_CLEARCOATMAP
$output v_clearcoatMapUv
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
$output v_clearcoatNormalMapUv
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
$output v_clearcoatRoughnessMapUv
#endif
#ifdef USE_IRIDESCENCEMAP
$output v_iridescenceMapUv
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
$output v_iridescenceThicknessMapUv
#endif
#ifdef USE_SHEEN_COLORMAP
$output v_sheenColorMapUv
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
$output v_sheenRoughnessMapUv
#endif
#ifdef USE_SPECULARMAP
$output v_specularMapUv
#endif
#ifdef USE_SPECULAR_COLORMAP
$output v_specularColorMapUv
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
$output v_specularIntensityMapUv
#endif
#ifdef USE_TRANSMISSIONMAP
$output v_transmissionMapUv
#endif
#ifdef USE_THICKNESSMAP
$output v_thicknessMapUv
#endif
$output v_worldPos
$output v_viewPos
#if defined( USE_ENVMAP ) && !defined( ENV_WORLDPOS )
$output v_reflect
#endif
$output v_normal
#if defined( USE_TANGENT )
$output v_tangent
$output v_bitangent
#endif
#if defined( USE_FOG )
$output v_fogDepth
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$output v_fragDepth
$output v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$output v_clipPosition
#endif
#if defined( USE_ALPHAHASH )
$output v_position
#endif
#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA ) || defined( USE_INSTANCING_COLOR ) || defined( USE_BATCHING_COLOR )
$output v_color
#endif
#if NUM_SPOT_LIGHT_COORDS > 0
$output vSpotLightCoord
#endif
#if NUM_DIR_LIGHT_SHADOWS > 0
$output vDirectionalShadowCoord
#endif
#if NUM_POINT_LIGHT_SHADOWS > 0

#endif

#include <bgfx_shader.sh>

uniform mat3 u_normalMatrix;

// chunk pars：对照 three.js meshlambert.vert pars 段
#include <common>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main()
{
    #include <uv_vertex>
    #include <beginnormal_vertex>
    #include <defaultnormal_vertex>
    #include <normal_vertex>

    #include <begin_vertex>
    #include <displacementmap_vertex>
    #include <project_vertex>
    #include <logdepthbuf_vertex>
    #include <clipping_planes_vertex>

    #include <worldpos_vertex>
    #include <shadowmap_vertex>
    #include <envmap_vertex>
    #include <fog_vertex>
}
"""
        // lambert 片段：对照 three.js meshlambert.frag 的 #include 顺序
        let lambertFS = """
#if defined( USE_UV ) || defined( USE_ANISOTROPY )
$input v_uv
#endif
#ifdef USE_MAP
$input v_mapUv
#endif
#ifdef USE_ALPHAMAP
$input v_alphaMapUv
#endif
#ifdef USE_LIGHTMAP
$input v_lightMapUv
#endif
#ifdef USE_AOMAP
$input v_aoMapUv
#endif
#ifdef USE_BUMPMAP
$input v_bumpMapUv
#endif
#ifdef USE_NORMALMAP
$input v_normalMapUv
#endif
#ifdef USE_DISPLACEMENTMAP
$input v_displacementMapUv
#endif
#ifdef USE_EMISSIVEMAP
$input v_emissiveMapUv
#endif
#ifdef USE_METALNESSMAP
$input v_metalnessMapUv
#endif
#ifdef USE_ROUGHNESSMAP
$input v_roughnessMapUv
#endif
#ifdef USE_ANISOTROPYMAP
$input v_anisotropyMapUv
#endif
#ifdef USE_CLEARCOATMAP
$input v_clearcoatMapUv
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
$input v_clearcoatNormalMapUv
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
$input v_clearcoatRoughnessMapUv
#endif
#ifdef USE_IRIDESCENCEMAP
$input v_iridescenceMapUv
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
$input v_iridescenceThicknessMapUv
#endif
#ifdef USE_SHEEN_COLORMAP
$input v_sheenColorMapUv
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
$input v_sheenRoughnessMapUv
#endif
#ifdef USE_SPECULARMAP
$input v_specularMapUv
#endif
#ifdef USE_SPECULAR_COLORMAP
$input v_specularColorMapUv
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
$input v_specularIntensityMapUv
#endif
#ifdef USE_TRANSMISSIONMAP
$input v_transmissionMapUv
#endif
#ifdef USE_THICKNESSMAP
$input v_thicknessMapUv
#endif
$input v_worldPos
$input v_viewPos
#if defined( USE_ENVMAP ) && !defined( ENV_WORLDPOS )
$input v_reflect
#endif
$input v_normal
#if defined( USE_TANGENT )
$input v_tangent
$input v_bitangent
#endif
#if defined( USE_FOG )
$input v_fogDepth
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$input v_fragDepth
$input v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$input v_clipPosition
#endif
#if defined( USE_ALPHAHASH )
$input v_position
#endif
#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA )
$input v_color
#endif
#if NUM_SPOT_LIGHT_COORDS > 0
$input vSpotLightCoord
#endif
#if NUM_DIR_LIGHT_SHADOWS > 0
$input vDirectionalShadowCoord
#endif
#if NUM_POINT_LIGHT_SHADOWS > 0

#endif

#include <bgfx_shader.sh>

uniform vec4 u_color;
uniform vec4 u_opacity;
uniform vec4 u_emissive;
uniform vec4 u_ambientColor;
uniform vec4 u_lightDir[NUM_DIR_LIGHTS_MAX];
uniform vec4 u_lightColor[NUM_DIR_LIGHTS_MAX];
uniform vec4 u_pointPosition[NUM_POINT_LIGHTS_MAX];
uniform vec4 u_pointColor[NUM_POINT_LIGHTS_MAX];
uniform vec4 u_pointParams[NUM_POINT_LIGHTS_MAX];
// bgfx4cj: SpotLight 独立 uniform（在 lambert uniform 段补充，与 point 同级；lambert 也 include lights_fragment_begin）
uniform vec4 u_spotPosition[NUM_SPOT_LIGHTS_MAX];
uniform vec4 u_spotColor[NUM_SPOT_LIGHTS_MAX];
uniform vec4 u_spotDirection[NUM_SPOT_LIGHTS_MAX];
uniform vec4 u_spotParams[NUM_SPOT_LIGHTS_MAX];
// bgfx4cj: HemisphereLight 独立 uniform（lambert 也 include lights_fragment_begin，
// 半球光循环按 u_hemi* 数组构造 struct，与点光/聚光/方向光改造一致）
uniform vec4 u_hemiSkyColor[NUM_HEMI_LIGHTS_MAX];
uniform vec4 u_hemiGroundColor[NUM_HEMI_LIGHTS_MAX];
uniform vec4 u_hemiDirection[NUM_HEMI_LIGHTS_MAX];
uniform vec4 u_cameraPos;

// chunk pars：对照 three.js meshlambert.frag pars 段
#include <common>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <cube_uv_reflection_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_lambert_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
#include <colorspace_pars_fragment>

void main()
{
    vec4 diffuseColor = vec4(u_color.rgb, u_opacity.x);
    #include <clipping_planes_fragment>

    vec3 reflectedLight_directDiffuse = vec3_splat(0.0);
    vec3 reflectedLight_indirectDiffuse = vec3_splat(0.0);
    vec3 reflectedLight_directSpecular = vec3_splat(0.0);
    vec3 reflectedLight_indirectSpecular = vec3_splat(0.0);
    vec3 totalEmissiveRadiance = u_emissive.rgb;

    ReflectedLight reflectedLight;
    reflectedLight.directDiffuse = vec3_splat(0.0);
    reflectedLight.indirectDiffuse = vec3_splat(0.0);
    reflectedLight.directSpecular = vec3_splat(0.0);
    reflectedLight.indirectSpecular = vec3_splat(0.0);

    #include <logdepthbuf_fragment>
    #include <map_fragment>
    #include <color_fragment>
    #include <alphamap_fragment>
    #include <alphatest_fragment>
    #include <alphahash_fragment>
    #include <specularmap_fragment>
    #include <normal_fragment_begin>
    #include <normal_fragment_maps>
    #include <emissivemap_fragment>

    // accumulation
    #include <lights_lambert_fragment>
    #include <lights_fragment_begin>
    #include <lights_fragment_maps>
    #include <lights_fragment_end>

    // modulation
    #include <aomap_fragment>

    vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;

    #include <envmap_fragment>
    #include <opaque_fragment>
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
    #include <fog_fragment>
    #include <premultiplied_alpha_fragment>
    #include <dithering_fragment>
}
"""
        let lambertVaryingDef = """
vec3 a_position : POSITION;
vec3 a_normal : NORMAL;
vec2 a_texcoord0 : TEXCOORD0;
vec3 v_worldPos : TEXCOORD0 = vec3(0.0, 0.0, 0.0);
vec3 v_viewPos : TEXCOORD2 = vec3(0.0, 0.0, 0.0);
vec3 v_normal : TEXCOORD1 = vec3(0.0, 0.0, 0.0);
vec2 v_uv : TEXCOORD3 = vec2(0.0, 0.0);
vec3 v_tangent : TEXCOORD4 = vec3(0.0, 0.0, 0.0);
vec3 v_bitangent : TEXCOORD5 = vec3(0.0, 0.0, 0.0);
vec3 v_reflect : TEXCOORD6 = vec3(0.0, 0.0, 0.0);
float v_fogDepth : TEXCOORD7 = 0.0;
float v_fragDepth : TEXCOORD8 = 0.0;
float v_isPerspective : TEXCOORD9 = 0.0;
vec3 v_clipPosition : TEXCOORD10 = vec3(0.0, 0.0, 0.0);
vec3 v_position : TEXCOORD11 = vec3(0.0, 0.0, 0.0);
vec4 v_color : TEXCOORD12 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 vSpotLightCoord : TEXCOORD13 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 vDirectionalShadowCoord : TEXCOORD14 = vec4(0.0, 0.0, 0.0, 0.0);
 = vec4(0.0, 0.0, 0.0, 0.0);
// UV map varyings — 与主要 varyings 互斥复用槽位
vec2 v_mapUv : TEXCOORD4 = vec2(0.0, 0.0);
vec2 v_alphaMapUv : TEXCOORD5 = vec2(0.0, 0.0);
vec2 v_lightMapUv : TEXCOORD4 = vec2(0.0, 0.0);
vec2 v_aoMapUv : TEXCOORD5 = vec2(0.0, 0.0);
vec2 v_bumpMapUv : TEXCOORD6 = vec2(0.0, 0.0);
vec2 v_normalMapUv : TEXCOORD7 = vec2(0.0, 0.0);
vec2 v_displacementMapUv : TEXCOORD8 = vec2(0.0, 0.0);
vec2 v_emissiveMapUv : TEXCOORD9 = vec2(0.0, 0.0);
vec2 v_metalnessMapUv : TEXCOORD10 = vec2(0.0, 0.0);
vec2 v_roughnessMapUv : TEXCOORD11 = vec2(0.0, 0.0);
vec2 v_anisotropyMapUv : TEXCOORD12 = vec2(0.0, 0.0);
vec2 v_clearcoatMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_clearcoatNormalMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_clearcoatRoughnessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_iridescenceMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_iridescenceThicknessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_sheenColorMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_sheenRoughnessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_specularMapUv : TEXCOORD15 = vec2(0.0, 0.0);
vec2 v_specularColorMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_specularIntensityMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_transmissionMapUv : TEXCOORD15 = vec2(0.0, 0.0);
vec2 v_thicknessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
"""
        programs.add("lambert", ShaderProgram("lambert", lambertVS, lambertFS, varyingDef: lambertVaryingDef))

        // 3. meshphong - Phong 高光光照
        // uniform 声明严格对齐 ThreeRenderer.cj 渲染管线注册的 uniform：
        //   u_color(Vec4,1) u_cameraPos(Vec4,1) u_shininess(Vec4,1)
        //   u_lightDir(Vec4,4) u_lightColor(Vec4,4)      方向光
        //   u_pointPosition(Vec4,4) u_pointColor(Vec4,4) u_pointParams(Vec4,4)  点光源
        //   u_ambientColor(Vec4,1)                         环境光
        //   receiveShadow(Vec4,1) directionalShadowMap(Sampler) directionalShadowMatrix(Mat4)  阴影
        // 3. meshphong - Phong 高光光照，对照 three.js ShaderLib/meshphong.glsl.js
        // 比 lambert 多 v_viewPos 与 lights_phong_*（specular + shininess）
        let phongVS = """
$input a_position
$input a_normal
$input a_texcoord0
#if defined( USE_UV ) || defined( USE_ANISOTROPY )
$output v_uv
#endif
#ifdef USE_MAP
$output v_mapUv
#endif
#ifdef USE_ALPHAMAP
$output v_alphaMapUv
#endif
#ifdef USE_LIGHTMAP
$output v_lightMapUv
#endif
#ifdef USE_AOMAP
$output v_aoMapUv
#endif
#ifdef USE_BUMPMAP
$output v_bumpMapUv
#endif
#ifdef USE_NORMALMAP
$output v_normalMapUv
#endif
#ifdef USE_DISPLACEMENTMAP
$output v_displacementMapUv
#endif
#ifdef USE_EMISSIVEMAP
$output v_emissiveMapUv
#endif
#ifdef USE_METALNESSMAP
$output v_metalnessMapUv
#endif
#ifdef USE_ROUGHNESSMAP
$output v_roughnessMapUv
#endif
#ifdef USE_ANISOTROPYMAP
$output v_anisotropyMapUv
#endif
#ifdef USE_CLEARCOATMAP
$output v_clearcoatMapUv
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
$output v_clearcoatNormalMapUv
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
$output v_clearcoatRoughnessMapUv
#endif
#ifdef USE_IRIDESCENCEMAP
$output v_iridescenceMapUv
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
$output v_iridescenceThicknessMapUv
#endif
#ifdef USE_SHEEN_COLORMAP
$output v_sheenColorMapUv
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
$output v_sheenRoughnessMapUv
#endif
#ifdef USE_SPECULARMAP
$output v_specularMapUv
#endif
#ifdef USE_SPECULAR_COLORMAP
$output v_specularColorMapUv
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
$output v_specularIntensityMapUv
#endif
#ifdef USE_TRANSMISSIONMAP
$output v_transmissionMapUv
#endif
#ifdef USE_THICKNESSMAP
$output v_thicknessMapUv
#endif
$output v_worldPos
#if defined( USE_ENVMAP ) && !defined( ENV_WORLDPOS )
$output v_reflect
#endif
$output v_normal
#if defined( USE_TANGENT )
$output v_tangent
$output v_bitangent
#endif
$output v_viewPos
#if defined( USE_FOG )
$output v_fogDepth
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$output v_fragDepth
$output v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$output v_clipPosition
#endif
#if defined( USE_ALPHAHASH )
$output v_position
#endif
#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA ) || defined( USE_INSTANCING_COLOR ) || defined( USE_BATCHING_COLOR )
$output v_color
#endif
#if NUM_SPOT_LIGHT_COORDS > 0
$output vSpotLightCoord
#endif
#if NUM_DIR_LIGHT_SHADOWS > 0
$output vDirectionalShadowCoord
#endif
#if NUM_POINT_LIGHT_SHADOWS > 0

#endif

#include <bgfx_shader.sh>

uniform mat3 u_normalMatrix;

// chunk pars：对照 three.js meshphong.vert pars 段
#include <common>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main()
{
    #include <uv_vertex>
    #include <beginnormal_vertex>
    #include <defaultnormal_vertex>
    #include <normal_vertex>

    #include <begin_vertex>
    #include <displacementmap_vertex>
    #include <project_vertex>
    #include <logdepthbuf_vertex>
    #include <clipping_planes_vertex>

    #include <worldpos_vertex>
    #include <shadowmap_vertex>
    #include <envmap_vertex>
    #include <fog_vertex>
}
"""
        // phong 片段：对照 three.js meshphong.frag 的 #include 顺序
        let phongFS = """
#if defined( USE_UV ) || defined( USE_ANISOTROPY )
$input v_uv
#endif
#ifdef USE_MAP
$input v_mapUv
#endif
#ifdef USE_ALPHAMAP
$input v_alphaMapUv
#endif
#ifdef USE_LIGHTMAP
$input v_lightMapUv
#endif
#ifdef USE_AOMAP
$input v_aoMapUv
#endif
#ifdef USE_BUMPMAP
$input v_bumpMapUv
#endif
#ifdef USE_NORMALMAP
$input v_normalMapUv
#endif
#ifdef USE_DISPLACEMENTMAP
$input v_displacementMapUv
#endif
#ifdef USE_EMISSIVEMAP
$input v_emissiveMapUv
#endif
#ifdef USE_METALNESSMAP
$input v_metalnessMapUv
#endif
#ifdef USE_ROUGHNESSMAP
$input v_roughnessMapUv
#endif
#ifdef USE_ANISOTROPYMAP
$input v_anisotropyMapUv
#endif
#ifdef USE_CLEARCOATMAP
$input v_clearcoatMapUv
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
$input v_clearcoatNormalMapUv
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
$input v_clearcoatRoughnessMapUv
#endif
#ifdef USE_IRIDESCENCEMAP
$input v_iridescenceMapUv
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
$input v_iridescenceThicknessMapUv
#endif
#ifdef USE_SHEEN_COLORMAP
$input v_sheenColorMapUv
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
$input v_sheenRoughnessMapUv
#endif
#ifdef USE_SPECULARMAP
$input v_specularMapUv
#endif
#ifdef USE_SPECULAR_COLORMAP
$input v_specularColorMapUv
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
$input v_specularIntensityMapUv
#endif
#ifdef USE_TRANSMISSIONMAP
$input v_transmissionMapUv
#endif
#ifdef USE_THICKNESSMAP
$input v_thicknessMapUv
#endif
$input v_worldPos
#if defined( USE_ENVMAP ) && !defined( ENV_WORLDPOS )
$input v_reflect
#endif
$input v_normal
#if defined( USE_TANGENT )
$input v_tangent
$input v_bitangent
#endif
$input v_viewPos
#if defined( USE_FOG )
$input v_fogDepth
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$input v_fragDepth
$input v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$input v_clipPosition
#endif
#if defined( USE_ALPHAHASH )
$input v_position
#endif
#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA )
$input v_color
#endif
#if NUM_SPOT_LIGHT_COORDS > 0
$input vSpotLightCoord
#endif
#if NUM_DIR_LIGHT_SHADOWS > 0
$input vDirectionalShadowCoord
#endif
#if NUM_POINT_LIGHT_SHADOWS > 0

#endif

#include <bgfx_shader.sh>

uniform vec4 u_color;
uniform vec4 u_opacity;
uniform vec4 u_emissive;
uniform vec4 u_specular;
uniform vec4 u_shininess;
uniform vec4 u_cameraPos;
uniform vec4 u_ambientColor;
uniform vec4 u_lightDir[NUM_DIR_LIGHTS_MAX];
uniform vec4 u_lightColor[NUM_DIR_LIGHTS_MAX];
uniform vec4 u_pointPosition[NUM_POINT_LIGHTS_MAX];
uniform vec4 u_pointColor[NUM_POINT_LIGHTS_MAX];
uniform vec4 u_pointParams[NUM_POINT_LIGHTS_MAX];
// bgfx4cj: SpotLight 独立 uniform（在 phong uniform 段补充，与 point 同级）
uniform vec4 u_spotPosition[NUM_SPOT_LIGHTS_MAX];
uniform vec4 u_spotColor[NUM_SPOT_LIGHTS_MAX];
uniform vec4 u_spotDirection[NUM_SPOT_LIGHTS_MAX];
uniform vec4 u_spotParams[NUM_SPOT_LIGHTS_MAX];
// bgfx4cj: HemisphereLight 独立 uniform（phong 也 include lights_fragment_begin）
uniform vec4 u_hemiSkyColor[NUM_HEMI_LIGHTS_MAX];
uniform vec4 u_hemiGroundColor[NUM_HEMI_LIGHTS_MAX];
uniform vec4 u_hemiDirection[NUM_HEMI_LIGHTS_MAX];

// chunk pars：对照 three.js meshphong.frag pars 段
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <cube_uv_reflection_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_phong_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
#include <colorspace_pars_fragment>

void main()
{
    vec4 diffuseColor = vec4(u_color.rgb, u_opacity.x);
    #include <clipping_planes_fragment>

    vec3 reflectedLight_directDiffuse = vec3_splat(0.0);
    vec3 reflectedLight_indirectDiffuse = vec3_splat(0.0);
    vec3 reflectedLight_directSpecular = vec3_splat(0.0);
    vec3 reflectedLight_indirectSpecular = vec3_splat(0.0);
    vec3 totalEmissiveRadiance = u_emissive.rgb;

    ReflectedLight reflectedLight;
    reflectedLight.directDiffuse = vec3_splat(0.0);
    reflectedLight.indirectDiffuse = vec3_splat(0.0);
    reflectedLight.directSpecular = vec3_splat(0.0);
    reflectedLight.indirectSpecular = vec3_splat(0.0);

    #include <logdepthbuf_fragment>
    #include <map_fragment>
    #include <color_fragment>
    #include <alphamap_fragment>
    #include <alphatest_fragment>
    #include <alphahash_fragment>
    #include <specularmap_fragment>
    #include <normal_fragment_begin>
    #include <normal_fragment_maps>
    #include <emissivemap_fragment>

    // accumulation
    #include <lights_phong_fragment>
    #include <lights_fragment_begin>
    #include <lights_fragment_maps>
    #include <lights_fragment_end>

    // modulation
    #include <aomap_fragment>

    vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;

    #include <envmap_fragment>
    #include <opaque_fragment>
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
    #include <fog_fragment>
    #include <premultiplied_alpha_fragment>
    #include <dithering_fragment>
}
"""
        let phongVaryingDef = """
vec3 a_position : POSITION;
vec3 a_normal : NORMAL;
vec2 a_texcoord0 : TEXCOORD0;
vec3 v_worldPos : TEXCOORD0 = vec3(0.0, 0.0, 0.0);
vec3 v_normal : TEXCOORD1 = vec3(0.0, 0.0, 0.0);
vec3 v_viewPos : TEXCOORD2 = vec3(0.0, 0.0, 0.0);
vec2 v_uv : TEXCOORD3 = vec2(0.0, 0.0);
vec3 v_tangent : TEXCOORD4 = vec3(0.0, 0.0, 0.0);
vec3 v_bitangent : TEXCOORD5 = vec3(0.0, 0.0, 0.0);
vec3 v_reflect : TEXCOORD6 = vec3(0.0, 0.0, 0.0);
float v_fogDepth : TEXCOORD7 = 0.0;
float v_fragDepth : TEXCOORD8 = 0.0;
float v_isPerspective : TEXCOORD9 = 0.0;
vec3 v_clipPosition : TEXCOORD10 = vec3(0.0, 0.0, 0.0);
vec3 v_position : TEXCOORD11 = vec3(0.0, 0.0, 0.0);
vec4 v_color : TEXCOORD12 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 vSpotLightCoord : TEXCOORD13 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 vDirectionalShadowCoord : TEXCOORD14 = vec4(0.0, 0.0, 0.0, 0.0);
 = vec4(0.0, 0.0, 0.0, 0.0);
// UV map varyings — 运行时互斥于主要 varyings（同 TEXCOORD 编号但不同时激活），
// 此处单独列一份，实际由 shader 的 $output/$input #if 守卫决定激活哪些。
vec2 v_mapUv : TEXCOORD4 = vec2(0.0, 0.0);
vec2 v_alphaMapUv : TEXCOORD5 = vec2(0.0, 0.0);
vec2 v_lightMapUv : TEXCOORD4 = vec2(0.0, 0.0);
vec2 v_aoMapUv : TEXCOORD5 = vec2(0.0, 0.0);
vec2 v_bumpMapUv : TEXCOORD6 = vec2(0.0, 0.0);
vec2 v_normalMapUv : TEXCOORD7 = vec2(0.0, 0.0);
vec2 v_displacementMapUv : TEXCOORD8 = vec2(0.0, 0.0);
vec2 v_emissiveMapUv : TEXCOORD9 = vec2(0.0, 0.0);
vec2 v_metalnessMapUv : TEXCOORD10 = vec2(0.0, 0.0);
vec2 v_roughnessMapUv : TEXCOORD11 = vec2(0.0, 0.0);
vec2 v_anisotropyMapUv : TEXCOORD12 = vec2(0.0, 0.0);
vec2 v_clearcoatMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_clearcoatNormalMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_clearcoatRoughnessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_iridescenceMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_iridescenceThicknessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_sheenColorMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_sheenRoughnessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_specularMapUv : TEXCOORD15 = vec2(0.0, 0.0);
vec2 v_specularColorMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_specularIntensityMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_transmissionMapUv : TEXCOORD15 = vec2(0.0, 0.0);
vec2 v_thicknessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
"""
        programs.add("phong", ShaderProgram("phong", phongVS, phongFS, varyingDef: phongVaryingDef))

        // 4. meshstandard - PBR (Metallic-Roughness) 材质
        // 顶点着色器：输出位置、法线、UV
        // 4. meshstandard - PBR (Metallic-Roughness) 材质，对照 three.js ShaderLib/meshphysical.glsl.js（standard 与 physical 共用 vert/frag）
        // 顶点着色器：输出位置、法线、UV
        // 裁剪：morphtarget/skinning/batching/color 路径无 CPU 绑定，不引用
        let standardVS = """
$input a_position
$input a_normal
$input a_texcoord0
#if defined( USE_UV ) || defined( USE_ANISOTROPY )
$output v_uv
#endif
#ifdef USE_MAP
$output v_mapUv
#endif
#ifdef USE_ALPHAMAP
$output v_alphaMapUv
#endif
#ifdef USE_LIGHTMAP
$output v_lightMapUv
#endif
#ifdef USE_AOMAP
$output v_aoMapUv
#endif
#ifdef USE_BUMPMAP
$output v_bumpMapUv
#endif
#ifdef USE_NORMALMAP
$output v_normalMapUv
#endif
#ifdef USE_DISPLACEMENTMAP
$output v_displacementMapUv
#endif
#ifdef USE_EMISSIVEMAP
$output v_emissiveMapUv
#endif
#ifdef USE_METALNESSMAP
$output v_metalnessMapUv
#endif
#ifdef USE_ROUGHNESSMAP
$output v_roughnessMapUv
#endif
#ifdef USE_ANISOTROPYMAP
$output v_anisotropyMapUv
#endif
#ifdef USE_CLEARCOATMAP
$output v_clearcoatMapUv
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
$output v_clearcoatNormalMapUv
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
$output v_clearcoatRoughnessMapUv
#endif
#ifdef USE_IRIDESCENCEMAP
$output v_iridescenceMapUv
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
$output v_iridescenceThicknessMapUv
#endif
#ifdef USE_SHEEN_COLORMAP
$output v_sheenColorMapUv
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
$output v_sheenRoughnessMapUv
#endif
#ifdef USE_SPECULARMAP
$output v_specularMapUv
#endif
#ifdef USE_SPECULAR_COLORMAP
$output v_specularColorMapUv
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
$output v_specularIntensityMapUv
#endif
#ifdef USE_TRANSMISSIONMAP
$output v_transmissionMapUv
#endif
#ifdef USE_THICKNESSMAP
$output v_thicknessMapUv
#endif
$output v_worldPos
$output v_normal
#if defined( USE_TANGENT )
$output v_tangent
$output v_bitangent
#endif
$output v_viewPos
#if defined( USE_FOG )
$output v_fogDepth
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$output v_fragDepth
$output v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$output v_clipPosition
#endif
#if defined( USE_ALPHAHASH )
$output v_position
#endif
#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA ) || defined( USE_INSTANCING_COLOR ) || defined( USE_BATCHING_COLOR )
$output v_color
#endif
#if NUM_SPOT_LIGHT_COORDS > 0
$output vSpotLightCoord
#endif
#if NUM_DIR_LIGHT_SHADOWS > 0
$output vDirectionalShadowCoord
#endif
#if NUM_POINT_LIGHT_SHADOWS > 0

#endif

#include <bgfx_shader.sh>

uniform mat3 u_normalMatrix;

// chunk pars：对照 three.js meshphysical.vert pars 段
#include <common>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main()
{
#include <uv_vertex>
#include <color_vertex>

    #include <beginnormal_vertex>
    #include <defaultnormal_vertex>
    #include <normal_vertex>

    #include <begin_vertex>
    #include <displacementmap_vertex>
    #include <project_vertex>
    #include <logdepthbuf_vertex>
    #include <clipping_planes_vertex>

    #include <worldpos_vertex>
    #include <shadowmap_vertex>
    #include <fog_vertex>
}
"""
        // 片段着色器：PBR Metallic-Roughness，对照 three.js meshphysical.frag 的 #include 顺序
        // USE_TRANSMISSION 的 vWorldPosition 路径在 bgfx4cj 无绑定，裁剪
        let standardFS = """
#if defined( USE_UV ) || defined( USE_ANISOTROPY )
$input v_uv
#endif
#ifdef USE_MAP
$input v_mapUv
#endif
#ifdef USE_ALPHAMAP
$input v_alphaMapUv
#endif
#ifdef USE_LIGHTMAP
$input v_lightMapUv
#endif
#ifdef USE_AOMAP
$input v_aoMapUv
#endif
#ifdef USE_BUMPMAP
$input v_bumpMapUv
#endif
#ifdef USE_NORMALMAP
$input v_normalMapUv
#endif
#ifdef USE_DISPLACEMENTMAP
$input v_displacementMapUv
#endif
#ifdef USE_EMISSIVEMAP
$input v_emissiveMapUv
#endif
#ifdef USE_METALNESSMAP
$input v_metalnessMapUv
#endif
#ifdef USE_ROUGHNESSMAP
$input v_roughnessMapUv
#endif
#ifdef USE_ANISOTROPYMAP
$input v_anisotropyMapUv
#endif
#ifdef USE_CLEARCOATMAP
$input v_clearcoatMapUv
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
$input v_clearcoatNormalMapUv
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
$input v_clearcoatRoughnessMapUv
#endif
#ifdef USE_IRIDESCENCEMAP
$input v_iridescenceMapUv
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
$input v_iridescenceThicknessMapUv
#endif
#ifdef USE_SHEEN_COLORMAP
$input v_sheenColorMapUv
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
$input v_sheenRoughnessMapUv
#endif
#ifdef USE_SPECULARMAP
$input v_specularMapUv
#endif
#ifdef USE_SPECULAR_COLORMAP
$input v_specularColorMapUv
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
$input v_specularIntensityMapUv
#endif
#ifdef USE_TRANSMISSIONMAP
$input v_transmissionMapUv
#endif
#ifdef USE_THICKNESSMAP
$input v_thicknessMapUv
#endif
$input v_worldPos
$input v_normal
#if defined( USE_TANGENT )
$input v_tangent
$input v_bitangent
#endif
$input v_viewPos
#if defined( USE_FOG )
$input v_fogDepth
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$input v_fragDepth
$input v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$input v_clipPosition
#endif
#if defined( USE_ALPHAHASH )
$input v_position
#endif
#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA )
$input v_color
#endif
#if NUM_SPOT_LIGHT_COORDS > 0
$input vSpotLightCoord
#endif
#if NUM_DIR_LIGHT_SHADOWS > 0
$input vDirectionalShadowCoord
#endif
#if NUM_POINT_LIGHT_SHADOWS > 0

#endif

#define STANDARD

#include <bgfx_shader.sh>

uniform vec4 u_color;
uniform vec4 u_opacity;
uniform vec4 u_emissive;
uniform vec4 u_roughness;
uniform vec4 u_metalness;
uniform vec4 u_cameraPos;
uniform vec4 u_ambientColor;
uniform vec4 u_lightDir[NUM_DIR_LIGHTS_MAX];
uniform vec4 u_lightColor[NUM_DIR_LIGHTS_MAX];
uniform vec4 u_pointPosition[NUM_POINT_LIGHTS_MAX];
uniform vec4 u_pointColor[NUM_POINT_LIGHTS_MAX];
uniform vec4 u_pointParams[NUM_POINT_LIGHTS_MAX];
uniform vec4 u_spotPosition[NUM_SPOT_LIGHTS_MAX];
uniform vec4 u_spotColor[NUM_SPOT_LIGHTS_MAX];
uniform vec4 u_spotDirection[NUM_SPOT_LIGHTS_MAX];
uniform vec4 u_spotParams[NUM_SPOT_LIGHTS_MAX];
uniform vec4 u_hemiSkyColor[NUM_HEMI_LIGHTS_MAX];
uniform vec4 u_hemiGroundColor[NUM_HEMI_LIGHTS_MAX];
uniform vec4 u_hemiDirection[NUM_HEMI_LIGHTS_MAX];
uniform vec4 u_envMapIntensity;
uniform vec4 u_useEnvMap;
// 环境贴图（用 bgfx SAMPLERCUBE 宏声明：GLSL 分支展开为 uniform samplerCube，
// HLSL 分支展开为 SamplerState+TextureCube+static BgfxSamplerCube，避免裸 samplerCube 在 HLSL 下 type mismatch）
SAMPLERCUBE(u_envMap, __STAGE_ENV_MAP__);
uniform vec4 shCoefficients[9];

// chunk pars：对照 three.js meshphysical.frag pars 段
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <cube_uv_reflection_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <fog_pars_fragment>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_physical_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <roughnessmap_pars_fragment>
#include <metalnessmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
#include <colorspace_pars_fragment>

// PBR 辅助函数（F_Schlick / D_GGX / V_SmithGGXCorrelated / BRDF_Lambert /
// EnvironmentBRDF / getShIrradianceAt / computeMultiscattering / getTangentFrame）
#include <bgfx_pbr_pars>

void main()
{
    vec4 diffuseColor = vec4(u_color.rgb, u_opacity.x);
    #include <clipping_planes_fragment>

    vec3 reflectedLight_directDiffuse = vec3_splat(0.0);
    vec3 reflectedLight_indirectDiffuse = vec3_splat(0.0);
    vec3 reflectedLight_directSpecular = vec3_splat(0.0);
    vec3 reflectedLight_indirectSpecular = vec3_splat(0.0);
    vec3 totalEmissiveRadiance = u_emissive.rgb;

    ReflectedLight reflectedLight;
    reflectedLight.directDiffuse = vec3_splat(0.0);
    reflectedLight.indirectDiffuse = vec3_splat(0.0);
    reflectedLight.directSpecular = vec3_splat(0.0);
    reflectedLight.indirectSpecular = vec3_splat(0.0);

    #include <logdepthbuf_fragment>
    #include <map_fragment>
    #include <color_fragment>
    #include <alphamap_fragment>
    #include <alphatest_fragment>
    #include <alphahash_fragment>
    // 对照 three.js meshphysical.glsl.js 的 `uniform float roughness/metalness;`：
    // Three.cj 以 u_roughness/u_metalness（vec4）传入，此处补局部变量供
    // roughnessmap_fragment / metalnessmap_fragment 引用（否则 HLSL 下 undeclared 'roughness'）
    float roughness = u_roughness.x;
    float metalness = u_metalness.x;
    #include <roughnessmap_fragment>
    #include <metalnessmap_fragment>
    #include <normal_fragment_begin>
    #include <normal_fragment_maps>
    #include <emissivemap_fragment>

    // accumulation
    #include <lights_physical_fragment>
    #include <lights_fragment_begin>
    #include <lights_fragment_maps>
    #include <lights_fragment_end>

    // modulation
    #include <aomap_fragment>

    vec3 totalDiffuse = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse;
    vec3 totalSpecular = reflectedLight.directSpecular + reflectedLight.indirectSpecular;

    vec3 outgoingLight = totalDiffuse + totalSpecular + totalEmissiveRadiance;

    #include <opaque_fragment>
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
    #include <fog_fragment>
    #include <premultiplied_alpha_fragment>
    #include <dithering_fragment>
}
"""
        let standardVaryingDef = """
vec3 a_position : POSITION;
vec3 a_normal : NORMAL;
vec2 a_texcoord0 : TEXCOORD0;
vec3 v_worldPos : TEXCOORD0 = vec3(0.0, 0.0, 0.0);
vec3 v_normal : TEXCOORD1 = vec3(0.0, 0.0, 0.0);
vec3 v_viewPos : TEXCOORD2 = vec3(0.0, 0.0, 0.0);
vec2 v_uv : TEXCOORD3 = vec2(0.0, 0.0);
vec3 v_tangent : TEXCOORD4 = vec3(0.0, 0.0, 0.0);
vec3 v_bitangent : TEXCOORD5 = vec3(0.0, 0.0, 0.0);
float v_fogDepth : TEXCOORD7 = 0.0;
float v_fragDepth : TEXCOORD8 = 0.0;
float v_isPerspective : TEXCOORD9 = 0.0;
vec3 v_clipPosition : TEXCOORD10 = vec3(0.0, 0.0, 0.0);
vec3 v_position : TEXCOORD11 = vec3(0.0, 0.0, 0.0);
vec4 v_color : TEXCOORD12 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 vSpotLightCoord : TEXCOORD13 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 vDirectionalShadowCoord : TEXCOORD14 = vec4(0.0, 0.0, 0.0, 0.0);
 = vec4(0.0, 0.0, 0.0, 0.0);
// UV map varyings — 与主要 varyings 互斥复用槽位
vec2 v_mapUv : TEXCOORD4 = vec2(0.0, 0.0);
vec2 v_alphaMapUv : TEXCOORD5 = vec2(0.0, 0.0);
vec2 v_lightMapUv : TEXCOORD4 = vec2(0.0, 0.0);
vec2 v_aoMapUv : TEXCOORD5 = vec2(0.0, 0.0);
vec2 v_bumpMapUv : TEXCOORD6 = vec2(0.0, 0.0);
vec2 v_normalMapUv : TEXCOORD7 = vec2(0.0, 0.0);
vec2 v_displacementMapUv : TEXCOORD8 = vec2(0.0, 0.0);
vec2 v_emissiveMapUv : TEXCOORD9 = vec2(0.0, 0.0);
vec2 v_metalnessMapUv : TEXCOORD10 = vec2(0.0, 0.0);
vec2 v_roughnessMapUv : TEXCOORD11 = vec2(0.0, 0.0);
vec2 v_anisotropyMapUv : TEXCOORD12 = vec2(0.0, 0.0);
vec2 v_clearcoatMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_clearcoatNormalMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_clearcoatRoughnessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_iridescenceMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_iridescenceThicknessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_sheenColorMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_sheenRoughnessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_specularMapUv : TEXCOORD15 = vec2(0.0, 0.0);
vec2 v_specularColorMapUv : TEXCOORD13 = vec2(0.0, 0.0);
vec2 v_specularIntensityMapUv : TEXCOORD14 = vec2(0.0, 0.0);
vec2 v_transmissionMapUv : TEXCOORD15 = vec2(0.0, 0.0);
vec2 v_thicknessMapUv : TEXCOORD14 = vec2(0.0, 0.0);
"""
        programs.add("standard", ShaderProgram("standard", standardVS, standardFS, varyingDef: standardVaryingDef))

        // 5. meshphysical - 物理材质（复用 standard PBR 着色器）
        programs.add("physical", ShaderProgram("physical", standardVS, standardFS, varyingDef: standardVaryingDef))

        // 6. meshmatcap - Matcap 材质
        // 对照 three.js ShaderLib/meshmatcap.glsl.js：
        //   VS 输出 vViewPosition，FS 用 viewDir 与法线构造正交基 x/y，
        //   matcapUV = vec2(dot(x, normal), dot(y, normal)) * 0.495 + 0.5；
        //   无 matcap 贴图时（测试场景无贴图）用默认渐变 mix(0.2, 0.8, uv.y)。
        // ★VS/FS 必须用同一组 varying：matcap 复用 normalVS（输出 v_normal/v_viewPos），
        //   FS 的 $input 声明与 normalFS 完全一致（含条件项），否则 bgfx program 链接失败
        //   （bgfx_create_program 返回 65535，VS/FS varying 集合不一致）。
        let matcapFS = """
$input v_normal
$input v_viewPos
#if defined( USE_TANGENT )
$input v_tangent
$input v_bitangent
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$input v_fragDepth
$input v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$input v_clipPosition
#endif

#include <bgfx_shader.sh>
uniform vec4 u_color;
uniform vec4 u_opacity;
void main()
{
    vec4 diffuseColor = vec4(u_color.rgb, u_opacity.x);
    // 对照 three.js meshmatcap.frag：viewDir 与 normal 构造正交基计算 matcapUV
    vec3 viewDir = normalize(v_viewPos);
    vec3 x = normalize(vec3(viewDir.z, 0.0, -viewDir.x));
    vec3 y = cross(viewDir, x);
    vec2 uv = vec2(dot(x, v_normal), dot(y, v_normal)) * 0.495 + 0.5;
    // 无 matcap 贴图时默认渐变（对照 three.js：vec4(vec3(mix(0.2, 0.8, uv.y)), 1.0)）
    vec3 matcapColor = vec3_splat(mix(0.2, 0.8, uv.y));
    vec3 outgoingLight = diffuseColor.rgb * matcapColor;
    gl_FragColor = vec4(outgoingLight, diffuseColor.a);
}
"""
        // matcap 注册移到 normalVS/normalVaryingDef 定义之后（见 7. meshnormal 块后）
        // programs.add("matcap", ShaderProgram("matcap", normalVS, matcapFS, varyingDef: normalVaryingDef))

        // 7. meshnormal - 法线可视化，对照 three.js ShaderLib/meshnormal.glsl.js
        // 使用专用 VS（只输出 v_normal，不输出 v_worldPos），避免与 lambertVS 的 HLSL link 问题
        // 裁剪：envmap/worldpos/shadowmap/color/bumping/normalmap 路径，材质本质就是输出原始法线
        let normalVS = """
$input a_position
$input a_normal
$output v_normal
$output v_viewPos
#if defined( USE_TANGENT )
$output v_tangent
$output v_bitangent
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$output v_fragDepth
$output v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$output v_clipPosition
#endif

#include <bgfx_shader.sh>

uniform mat3 u_normalMatrix;

// chunk pars：对照 three.js meshnormal.vert pars 段
#include <common>
#include <normal_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main()
{
    #include <beginnormal_vertex>
    #include <defaultnormal_vertex>
    #include <normal_vertex>

    #include <begin_vertex>
    #include <project_vertex>
    #include <logdepthbuf_vertex>
    #include <clipping_planes_vertex>
}
"""
        // normal 片段：对照 three.js meshnormal.frag 的 #include 顺序
        // 法线可视化本质：normalize(vNormal) * 0.5 + 0.5 写 rgb，opacity 写 a
        let normalFS = """
$input v_normal
$input v_viewPos
#if defined( USE_TANGENT )
$input v_tangent
$input v_bitangent
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$input v_fragDepth
$input v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$input v_clipPosition
#endif

#include <bgfx_shader.sh>

uniform vec4 u_opacity;

// chunk pars：对照 three.js meshnormal.frag pars 段
#include <dithering_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
#include <colorspace_pars_fragment>

void main()
{
    vec3 vNormal = normalize(v_normal);

    #include <clipping_planes_fragment>
    #include <logdepthbuf_fragment>

    vec3 outgoingLight = vNormal * 0.5 + 0.5;
    vec4 diffuseColor = vec4(u_opacity.rgb, u_opacity.x);

    #include <opaque_fragment>
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
    #include <premultiplied_alpha_fragment>
    #include <dithering_fragment>
}
"""
        let normalVaryingDef = """
vec3 a_position : POSITION;
vec3 a_normal : NORMAL;
vec3 v_normal : TEXCOORD1 = vec3(0.0, 0.0, 0.0);
vec3 v_viewPos : TEXCOORD2 = vec3(0.0, 0.0, 0.0);
vec3 v_tangent : TEXCOORD4 = vec3(0.0, 0.0, 0.0);
vec3 v_bitangent : TEXCOORD5 = vec3(0.0, 0.0, 0.0);
float v_fragDepth : TEXCOORD8 = 0.0;
float v_isPerspective : TEXCOORD9 = 0.0;
vec3 v_clipPosition : TEXCOORD10 = vec3(0.0, 0.0, 0.0);
"""
        programs.add("normal", ShaderProgram("normal", normalVS, normalFS, varyingDef: normalVaryingDef))

        // 6b. meshmatcap - Matcap 材质（注册移到 normalVS/normalVaryingDef 定义之后）
        // 对照 three.js ShaderLib/meshmatcap.glsl.js：
        //   VS 输出 vViewPosition，FS 用 viewDir 与法线构造正交基 x/y，
        //   matcapUV = vec2(dot(x, normal), dot(y, normal)) * 0.495 + 0.5；
        //   无 matcap 贴图时（测试场景无贴图）用默认渐变 mix(0.2, 0.8, uv.y)。
        // ★VS/FS 必须用同一组 varying：matcap 复用 normalVS（输出 v_normal/v_viewPos），
        //   FS 的 $input 声明与 normalFS 完全一致（含条件项），否则 bgfx program 链接失败
        //   （bgfx_create_program 返回 65535，VS/FS varying 集合不一致）。
        programs.add("matcap", ShaderProgram("matcap", normalVS, matcapFS, varyingDef: normalVaryingDef))

        // 8. meshtoon - 卡通着色
        // 对照 three.js ShaderLib/meshtoon.glsl.js：
        //   toon 光照本质 = NdotL → getGradientIrradiance（无 gradientMap 时 smoothstep 分阶）
        //   将连续漫反射量化为两档（阴影区/亮区），产生卡通硬边。
        // ★VS/FS 必须用同一组 varying：toon 复用 normalVS（输出 v_normal/v_viewPos），
        //   FS 的 $input 声明与 normalFS 完全一致（含条件项），否则 bgfx program 链接失败
        //   （bgfx_create_program 返回 65535，VS/FS varying 集合不一致）。
        let toonFS = """
$input v_normal
$input v_viewPos
#if defined( USE_TANGENT )
$input v_tangent
$input v_bitangent
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$input v_fragDepth
$input v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$input v_clipPosition
#endif

#include <bgfx_shader.sh>
uniform vec4 u_color;
uniform vec4 u_opacity;
uniform vec4 u_ambientColor;
uniform vec4 u_lightDir[NUM_DIR_LIGHTS_MAX];
uniform vec4 u_lightColor[NUM_DIR_LIGHTS_MAX];
void main()
{
    vec4 diffuseColor = vec4(u_color.rgb, u_opacity.x);
    vec3 normal = normalize(v_normal);
    // 环境光基础
    vec3 outgoingLight = diffuseColor.rgb * u_ambientColor.rgb;
    // 对每个方向光做卡通分阶（对照 three.js meshtoon getGradientIrradiance：
    //   coord = NdotL*0.5+0.5；无 gradientMap 时 smoothstep(0.0,1.0,coord)）
    for (int i = 0; i < NUM_DIR_LIGHTS_MAX; i++) {
        // u_lightDir 为光源→场景方向，取反得场景→光源方向
        vec3 lightDir = normalize(-u_lightDir[i].xyz);
        float dotNL = saturate(dot(normal, lightDir));
        float coord = dotNL * 0.5 + 0.5;
        // 卡通两档分阶（硬边）：低于阈值压暗，高于阈值全亮
        float gradient = smoothstep(0.45, 0.55, coord);
        outgoingLight += diffuseColor.rgb * u_lightColor[i].rgb * gradient;
    }
    gl_FragColor = vec4(outgoingLight, diffuseColor.a);
}
"""
        programs.add("toon", ShaderProgram("toon", normalVS, toonFS, varyingDef: normalVaryingDef))

        // 9. MeshDepthMaterial - 深度材质
        let depthVS = """
$input a_position

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
}
"""
        let depthFS = """
#include <bgfx_shader.sh>

void main()
{
    // 将深度值写入颜色通道（用于阴影贴图采样）
    // bgfx 左手系 [0,1] NDC：gl_FragCoord.z 即为线性深度在 [0,1] 范围
    float d = gl_FragCoord.z;
    gl_FragColor = vec4(d, d, d, 1.0);
}
"""
        let depthVaryingDef = """
vec3 a_position : POSITION;
"""
        programs.add("depth", ShaderProgram("depth", depthVS, depthFS, varyingDef: depthVaryingDef))

        // 9a. Debug depthviz - 深度图可视化着色器（将线性深度映射为灰度颜色输出）
        let depthvizVS = """
$input a_position

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
}
"""
        let depthvizFS = """
#include <bgfx_shader.sh>

uniform vec4 u_cameraNearFar;

void main()
{
    // gl_FragCoord.z is in [0,1] for bgfx (left-handed, [0,1] Z)
    // Linearize: znear * zfar / (zfar + znear - z * (zfar - znear))
    // For [0,1] NDC depth, derive formula:
    // In bgfx left-handed VCS: z_eye in [-near, 0] (looking along +Z, so z_eye is negative toward positive Z)
    // Projection maps z_eye to NDC z in [0,1]
    // z_ndc = (1/z_eye - 1/far) / (1/near - 1/far)   -- reversed for bgfx [0,1]
    // Let's use simpler approach: just show gl_FragCoord.z directly
    
    // Method 1: Raw non-linear depth (good for seeing depth buffer distribution)
    // Method 2: Linear depth in world space normalized by far plane
    float near = u_cameraNearFar.x;
    float far = u_cameraNearFar.y;
    float zNDC = gl_FragCoord.z;
    // Linearize (for perspective projection, [0,1] NDC)
    float zLinear = (2.0 * near) / (far + near - zNDC * (far - near));
    // Normalize to [0,1] (near=white, far=black for intuitive visualization)
    float depth = 1.0 - zLinear;
    gl_FragColor = vec4(depth, depth, depth, 1.0);
}
"""
        let depthvizVaryingDef = """
vec3 a_position : POSITION;
"""
        programs.add("depthviz", ShaderProgram("depthviz", depthvizVS, depthvizFS, varyingDef: depthvizVaryingDef))

        // 10. MeshDistanceMaterial - 距离材质
        programs.add("distance", ShaderProgram("distance", depthVS, depthFS, varyingDef: depthVaryingDef))

        // 11. PointsMaterial - 点云材质
        // 对照 three.js ShaderLib/points.glsl.js：
        //   fragment 核心 = diffuseColor = vec4(diffuse, opacity)，输出颜色（非深度灰度）。
        // ★此前误注册为 depthVS/depthFS（深度着色器输出灰度）→ 点渲染为白色/灰度。
        // 点大小：three.js 用 gl_PointSize = size，但本引擎 shaderc 转 HLSL 后
        //   gl_PointSize 未声明（X3004，bgfx_shader.sh 无该宏映射），故 VS 不设置点大小，
        //   用 bgfx 默认点大小渲染（点可见；尺寸由后端 POINTS 图元决定）。
        // ★VS/FS 必须用同一组 varying：pointsVS 只变换位置（无 varying 输出），
        //   FS 无 $input，varying 集合一致（bgfx program 链接要求）。
        let pointsVS = """
$input a_position
#include <bgfx_shader.sh>
void main()
{
    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
}
"""
        let pointsFS = """
#include <bgfx_shader.sh>
uniform vec4 u_color;
uniform vec4 u_opacity;
void main()
{
    // 对照 three.js points.frag：gl_FragColor = vec4( diffuseColor.rgb, diffuseColor.a )
    gl_FragColor = vec4(u_color.rgb, u_opacity.x);
}
"""
        programs.add("points", ShaderProgram("points", pointsVS, pointsFS, varyingDef: depthVaryingDef))

        // 12. SpriteMaterial - 精灵材质
        // 对照 three.js ShaderLib/sprite.glsl.js：
        //   vertex 核心：mvPosition = modelViewMatrix[3]（平移列），
        //     scale = (length(modelMatrix[0].xyz), length(modelMatrix[1].xyz))，
        //     mvPosition.xy += (position.xy - (center - 0.5)) * scale（rotation=0 简化），
        //     gl_Position = projectionMatrix * mvPosition —— 广告牌始终朝向相机；
        //   fragment 核心 = diffuseColor = vec4(diffuse, opacity)；
        //   #ifdef USE_MAP 采样 map（map_fragment），输出 outgoingLight = diffuseColor.rgb。
        // ★此前误注册为 depthVS/depthFS（深度着色器输出灰度）→ SpriteMaterial 渲染全白。
        //  ★VS/FS 必须用同一组 varying（v_uv + 条件项），否则 bgfx program 链接失败（idx=65535）。
        let spriteVS = """
$input a_position
$input a_texcoord0
#if defined( USE_UV ) || defined( USE_MAP )
$output v_uv
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$output v_fragDepth
$output v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$output v_clipPosition
#endif
#include <bgfx_shader.sh>
void main()
{
    // 对照 three.js sprite.vert：广告牌 = 模型视图平移列 + 面片 xy 缩放
    //  bgfx 侧对应：modelViewMatrix[3] → mul(u_modelView, vec4(0,0,0,1)) 取平移列
    // ★不可直接写 u_modelView[3]：GLSL 列主序下 m[3] 取第 4 列（平移），
    //   而 shaderc 转 HLSL（行主序）后 m[3] 取第 4 行（非平移）→ mvPosition 错误、
    //   面片投影到错误位置不可见。矩阵乘法 mul() 语义在两种语言一致（同 depthVS 模式）。
    vec4 mvPosition = mul(u_modelView, vec4(0.0, 0.0, 0.0, 1.0));
    vec2 scale = vec2(
        length(mul(u_model[0], vec4(1.0, 0.0, 0.0, 0.0)).xyz),
        length(mul(u_model[0], vec4(0.0, 1.0, 0.0, 0.0)).xyz)
    );
    // center 默认 (0.5,0.5) 且 rotation=0（仓颉 SpriteMaterial 默认值），(position.xy - (center-0.5)) = position.xy
    // ★朝向修正：three.js 右手系相机看向 -Z，面片本地法线 +Z 恰好朝向相机；
    //   bgfx 左手系相机看向 +Z，法线 +Z 指向远离相机 → 背面朝相机被 FrontSide 剔除。
    //   绕 X 轴翻转面片（y 取反），法线变为 -Z 朝向相机，正面可见（非 DoubleSide 规避）。
    vec2 alignedPosition = vec2(a_position.x, -a_position.y) * scale;
    mvPosition.xy += alignedPosition;
    gl_Position = mul(u_proj, mvPosition);
    #if defined( USE_UV ) || defined( USE_MAP )
    v_uv = a_texcoord0;
    #endif
}
"""
        let spriteFS = """
#if defined( USE_UV ) || defined( USE_MAP )
$input v_uv
#endif
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
$input v_fragDepth
$input v_isPerspective
#endif
#if NUM_CLIPPING_PLANES > 0
$input v_clipPosition
#endif
#include <bgfx_shader.sh>
uniform vec4 u_color;
uniform vec4 u_opacity;
#ifdef USE_MAP
SAMPLER2D(map, __STAGE_MAP__);
#endif
void main()
{
    // 对照 three.js sprite.frag：diffuseColor = vec4(diffuse, opacity)
    vec4 diffuseColor = vec4(u_color.rgb, u_opacity.x);
    #ifdef USE_MAP
    // map_fragment：diffuseColor *= texture2D(map, vUv)
    diffuseColor *= texture2D(map, v_uv);
    #endif
    gl_FragColor = vec4(diffuseColor.rgb, diffuseColor.a);
}
"""
        programs.add("sprite", ShaderProgram("sprite", spriteVS, spriteFS, varyingDef: basicVaryingDef))

        // 13. ShadowMaterial - 阴影材质
        // 对照 three.js ShaderLib/shadow.glsl.js：
        //   fragment 核心 = gl_FragColor = vec4( shadowColor.rgb, shadowColor.a )，
        //   输出半透明阴影色（非深度灰度）。
        // ★此前误注册为 depthVS/depthFS（深度着色器输出灰度）→ 阴影渲染为白色。
        // VS 用 depthVS（只变换位置，无 varying 输出），FS 无 $input，varying 集合一致。
        let shadowFS = """
#include <bgfx_shader.sh>
uniform vec4 u_color;
uniform vec4 u_opacity;
void main()
{
    // 对照 three.js shadow.frag：输出 shadowColor（黑/半透明，由 blend 混合）
    gl_FragColor = vec4(u_color.rgb, u_opacity.x);
}
"""
        programs.add("shadow", ShaderProgram("shadow", depthVS, shadowFS, varyingDef: depthVaryingDef))

        // 14. LineDashedMaterial - 虚线材质
        // 对照 three.js ShaderLib/line_dashed.glsl.js：
        //   vertex 核心：vLineDistance = scale * lineDistance（沿线累积距离），
        //   fragment 核心：mod(vLineDistance, totalSize) > dashSize 则 discard。
        let linedashedVaryingDef = """
vec3 a_position : POSITION;
float a_lineDistance : TEXCOORD0;
float v_lineDistance : TEXCOORD0 = 0.0;
"""
        let linedashedVS = """
$input a_position a_lineDistance
$output v_lineDistance

#include <bgfx_shader.sh>

void main()
{
    v_lineDistance = a_lineDistance;
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
}
"""
        let linedashedFS = """
$input v_lineDistance

#include <bgfx_shader.sh>

uniform vec4 u_color;
uniform vec4 u_opacity;
uniform vec4 u_dashParams; // x = dashSize, y = totalSize (dashSize + gapSize)

void main()
{
    float d = mod(v_lineDistance, u_dashParams.y);
    if (d > u_dashParams.x) { discard; }
    gl_FragColor = vec4(u_color.rgb, u_opacity.x);
}
"""
        programs.add("linedashed", ShaderProgram("linedashed", linedashedVS, linedashedFS, varyingDef: linedashedVaryingDef))

        // 15. 背景/天空盒等辅助材质
        programs.add("background", ShaderProgram("background", basicVS, basicFS, varyingDef: basicVaryingDef))
        programs.add("cube", ShaderProgram("cube", basicVS, basicFS, varyingDef: basicVaryingDef))
        programs.add("equirect", ShaderProgram("equirect", basicVS, basicFS, varyingDef: basicVaryingDef))
        programs.add("backgroundCube", ShaderProgram("backgroundCube", basicVS, basicFS, varyingDef: basicVaryingDef))

        // VSM blur 着色器：对照 three.js ShaderLib/vsm.glsl.js
        //   - vertex：全屏三角形，gl_Position = vec4(position.xy, 0, 1)
        //   - fragment：5-tap 高斯模糊，输出 vec4(mean, std_dev, 0, 1)
        //     通过 HORIZONTAL_PASS define 区分垂直/水平两个 pass
        //   - 输入纹理 uniform：s_shadowPass（sampler2D）
        //   - uniform：u_resolution（vec2, 实际用 vec4 传递），u_radius（vec4.x）
        let vsmVS = """
$input a_position
$input a_texcoord0

#include <bgfx_shader.sh>

void main()
{
    // 全屏三角形：顶点 position 已是 NDC [-1, 1] 坐标
    gl_Position = vec4(a_position.xy, 0.0, 1.0);
}
"""
        let vsmFS = """
#include <bgfx_shader.sh>

SAMPLER2D(s_shadowPass, 0);

uniform vec4 u_resolution;  // x=width, y=height
uniform vec4 u_radius;      // x=radius (texel scale)

void main()
{
    // 对照 three.js vsm.glsl.js：VSM_SAMPLES = 5
    const float samples = 5.0;
    float mean = 0.0;
    float squared_mean = 0.0;

    float uvStride = samples <= 1.0 ? 0.0 : 2.0 / (samples - 1.0);
    float uvStart = samples <= 1.0 ? 0.0 : -1.0;

    vec2 res = u_resolution.xy;
    float radius = u_radius.x;

    for (float i = 0.0; i < samples; i += 1.0) {
        float uvOffset = uvStart + i * uvStride;

        #ifdef HORIZONTAL_PASS
            // 水平 pass：输入是 RG16F 的 vec2(mean, variance)
            vec2 distribution = texture2D(s_shadowPass, (gl_FragCoord.xy + vec2(uvOffset, 0.0) * radius) / res).rg;
            mean += distribution.x;
            squared_mean += distribution.y * distribution.y + distribution.x * distribution.x;
        #else
            // 垂直 pass：输入是 D32 原生深度纹理
            float depth = texture2D(s_shadowPass, (gl_FragCoord.xy + vec2(0.0, uvOffset) * radius) / res).r;
            mean += depth;
            squared_mean += depth * depth;
        #endif
    }

    mean = mean / samples;
    squared_mean = squared_mean / samples;

    float std_dev = sqrt(max(0.0, squared_mean - mean * mean));

    gl_FragColor = vec4(mean, std_dev, 0.0, 1.0);
}
"""
        let vsmVaryingDef = """
vec3 a_position : POSITION;
vec2 a_texcoord0 : TEXCOORD0;
"""
        programs.add("vsm", ShaderProgram("vsm", vsmVS, vsmFS, varyingDef: vsmVaryingDef))

        // ===== Debug 阴影管线可视化着色器（mode 4-8） =====

        // 16a. Debug lightdir - 光源方向可视化（mode 4）
        // 把 N·L 直接映射颜色：朝光面亮、背光面暗，无环境光，纯白底色
        // 用于验证方向光方向 u_lightDir[0] 是否正确传递
        let lightdirVS = """
$input a_position
$input a_normal
$output v_worldPos
$output v_normal

#include <bgfx_shader.sh>

uniform mat3 u_normalMatrix;

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    v_worldPos = worldPos.xyz;
    vec3 objectNormal = normalize(mul(u_normalMatrix, a_normal));
    v_normal = normalize(objectNormal);
    gl_Position = mul(u_viewProj, worldPos);
}
"""
        let lightdirFS = """
$input v_worldPos
$input v_normal

#include <bgfx_shader.sh>

uniform vec4 u_lightDir0;
uniform vec4 u_lightColor0;
uniform vec4 u_lightDir1;
uniform vec4 u_lightColor1;

void main()
{
    vec3 N = normalize(v_normal);
    vec3 L = normalize(u_lightDir0.xyz);
    float diff = max(dot(N, L), 0.0);
    // 朝光面=白(1)，背光面=黑(0)，半角度=灰
    // HLSL 不支持 float3(scalar)，用 float3(diff, diff, diff) 展开
    vec3 col = vec3(diff, diff, diff);
    gl_FragColor = vec4(col, 1.0);
}
"""
        let lightdirVaryingDef = """
vec3 a_position : POSITION;
vec3 a_normal : NORMAL;
vec3 v_worldPos : TEXCOORD0 = vec3(0.0, 0.0, 0.0);
vec3 v_normal : TEXCOORD1 = vec3(0.0, 0.0, 0.0);
"""
        programs.add("lightdir", ShaderProgram("lightdir", lightdirVS, lightdirFS, varyingDef: lightdirVaryingDef))

        // 16b. Debug shadowproj - shadowMatrix 投影 UV 可视化（mode 7）
        // 把 receiver 顶点经 directionalShadowMatrix 投影后的 xy 当颜色
        // 用于验证阴影矩阵是否正确把世界坐标变换到 [0,1]² 阴影 UV 空间
        let shadowprojVS = """
$input a_position

#include <bgfx_shader.sh>

uniform mat4 directionalShadowMatrix;

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    vec4 shadowCoord = mul(directionalShadowMatrix, worldPos);
    // 把阴影 UV (xy in [0,1]) 直接作为 NDC 位置（映射 [-1,1]）
    // 注意：directionalShadowMatrix 内含 bias 的 D3D11 Y-flip（-0.5），
    // 经过 round-trip ([0,1] → [-1,1]) 后 Y 被翻转。此处 negate Y 抵消，
    // 使最终方向与 lightViewProj 直接输出的 clip space 一致。
    gl_Position = vec4(shadowCoord.x * 2.0 - 1.0, -(shadowCoord.y * 2.0 - 1.0), 0.0, 1.0);
}
"""
        let shadowprojFS = """
#include <bgfx_shader.sh>

uniform mat4 directionalShadowMatrix;

void main()
{
    // 直接输出固定灰度，用顶点位置体现 UV 覆盖范围
    gl_FragColor = vec4(0.7, 0.7, 0.7, 1.0);
}
"""
        let shadowprojVaryingDef = """
vec3 a_position : POSITION;
"""
        programs.add("shadowproj", ShaderProgram("shadowproj", shadowprojVS, shadowprojFS, varyingDef: shadowprojVaryingDef))

        // 16c. Debug pcf - PCF 采样结果可视化（mode 8）
        // 绑定 shadowMap + shadowMatrix，PCF 采样后输出黑白二值
        // 用于验证 shadowMap 是否生成、PCF 采样坐标是否正确
        let pcfVS = """
$input a_position, a_normal
$output v_worldPos, v_worldNormal

#include <bgfx_shader.sh>

uniform mat4 directionalShadowMatrix;

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_worldPos = worldPos.xyz;
    // 传递世界法线用于 normalBias 偏移（对齐 shadowmap_vertex.cj 的 normalBias 逻辑）
    v_worldNormal = normalize(mul(u_model[0], vec4(a_normal, 0.0)).xyz);
}
"""
        let pcfFS = """
$input v_worldPos, v_worldNormal

#include <bgfx_shader.sh>

SAMPLER2D(directionalShadowMap, 0);
uniform mat4 directionalShadowMatrix;
uniform vec4 shadowParams;

float textureShadow(sampler2D shadow, vec3 uvw, float threshold)
{
    float storedDepth = texture2D(shadow, uvw.xy).x;
    // refDepth > storedDepth + threshold 才算在阴影中（caster 自身覆盖片元 storedDepth ≈ refDepth，
    // 阈值过小会 self-shadow acne 表现为白色区斑马纹；用 shadowParams.z 作为阈值）
    if (uvw.z > storedDepth + threshold) {
        return 0.0;  // 在阴影中
    }
    return 1.0;  // 不在阴影中
}

void main()
{
    // normalBias：沿世界法线偏移 shadowWorldPosition（对齐 shadowmap_vertex.cj:45）。
    // 法线偏移沿世界法线方向，棱线处相邻面自然连续，不产生接缝缝隙；
    // 对于背光面（法线背离光源），偏移方向指向光源→减小 shadowDepth→消除 caster 自身阴影。
    float normalBias = shadowParams.z;
    vec3 biasedWorldPos = v_worldPos + v_worldNormal * normalBias;
    vec4 shadowCoord = mul(directionalShadowMatrix, vec4(biasedWorldPos, 1.0));
    vec3 uvw = shadowCoord.xyz / shadowCoord.w;
    // 超出阴影 UV 范围 → 输出红，提示阴影矩阵边界问题
    if (uvw.x < 0.0 || uvw.x > 1.0 || uvw.y < 0.0 || uvw.y > 1.0) {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
        return;
    }
    float bias = shadowParams.y;
    float refDepth = uvw.z - bias;
    // 阴影比较阈值：用固定小阈值避免 caster 自身覆盖片元 storedDepth ≈ refDepth 时 self-shadow acne。
    // normalBias 已在 vertex 端沿法线偏移 worldPos，此处 threshold 只需覆盖残余精度误差。
    float threshold = 0.001;
    // 3x3 PCF
    float shadow = 0.0;
    vec2 texelSize = vec2(1.0 / 1024.0, 1.0 / 1024.0);
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y)) * texelSize;
            shadow += textureShadow(directionalShadowMap, vec3(uvw.xy + offset, refDepth), threshold);
        }
    }
    shadow /= 9.0;
    // 在阴影中=黑(0)，不在阴影中=白(1)
    gl_FragColor = vec4(shadow, shadow, shadow, 1.0);
}
"""
        let pcfVaryingDef = """
vec3 a_position : POSITION;
vec3 a_normal : NORMAL;
vec3 v_worldPos : TEXCOORD0 = vec3(0.0, 0.0, 0.0);
vec3 v_worldNormal : TEXCOORD1 = vec3(0.0, 1.0, 0.0);
"""
        programs.add("pcf", ShaderProgram("pcf", pcfVS, pcfFS, varyingDef: pcfVaryingDef))

        // 16d. Debug shadowmap-blit - 把 shadowMap 铺满屏幕（mode 6）
        // 用一个全屏四边形 + 简单 sampler2D 采样
        let shadowblitVS = """
$input a_position
$input a_texcoord0
$output v_blitUV

#include <bgfx_shader.sh>

void main()
{
    gl_Position = vec4(a_position.xy, 0.0, 1.0);
    v_blitUV = a_texcoord0;
}
"""
        let shadowblitFS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(shadowBlitSampler, __STAGE_SHADOW_BLIT__);

void main()
{
    vec4 c = texture2D(shadowBlitSampler, v_blitUV);
    gl_FragColor = c;
}
"""
        let shadowblitVaryingDef = """
vec3 a_position : POSITION;
vec2 a_texcoord0 : TEXCOORD0;
vec2 v_blitUV : TEXCOORD0 = vec2(0.0, 0.0);
"""
        programs.add("shadowblit", ShaderProgram("shadowblit", shadowblitVS, shadowblitFS, varyingDef: shadowblitVaryingDef))

        // ===== 后处理 shader 已迁移至 postprocessing/PostProcessingShaders.cj =====
        // copy/output/bloom/fxaa/smaa/ssao 系列注册已移出，由后处理 pass 内部注册表管理。
        // OutputShader：色调映射 + sRGB 色彩空间转换，OutputPass 专用。
        // 对照 three.js OutputShader.fragmentShader（含 7 种 ToneMapping + SRGB_TRANSFER）。
        // bgfx 无 three.js 的 tonemapping_pars_fragment/colorspace_pars_fragment shader chunk，
        // 故把 7 种 ToneMapping 函数体内联，sRGB OETF 用 sqrt 近似（人眼感知线性）。
        // （OutputShader FS 源码已迁移至 postprocessing/PostProcessingShaders.cj）

        // ===== 抗锯齿全屏 shader =====
        // 对照 three.js examples/jsm/shaders/{FXAAShader,SMAAShader}.js
        // （fxaa/smaa 系列 FS 源码已迁移至 postprocessing/PostProcessingShaders.cj，
        //   注册由 FXAAPass/SMAAPass 经 PostProcessingShaders.get 取用）

        // 16e. Debug shadowfrustum - 阴影相机视锥可视化（mode 5）
        // 与 shadowproj 共用思路，但 receiver 渲染为线框（line list 形式由 test 提供几何）
        // 这里给出一个简单的方法：把视锥顶点用 lightProj * lightView 变换后输出
        // 实际 sp_shadowfrustum 项目会用 LineSegments 几何直接绘制 box
        // 此 shader 保留兼容入口，与 shadowproj 一致
        programs.add("shadowfrustum", ShaderProgram("shadowfrustum", shadowprojVS, shadowprojFS, varyingDef: shadowprojVaryingDef))

        // ===== 17. 16-shadowmaps color_lighting 系列阴影程序 =====
        // 对照 _参考内容/bgfx-知识/examples/16-shadowmaps/
        //
        // 5 种 SmImpl × 3 种 SmType × 2 种 DepthImpl 的完整组合
        // 命名规范: shadow_color_<smimpl>_<smtype>_<depthimpl>
        //   smimpl: hard/pcf/pcss/vsm/esm
        //   smtype: single/omni/csm
        //   depthimpl: invz/linear
        //
        // varying.def.sc 定义：
        //   v_texcoord0(uv), v_texcoord1..4(cascade/omni coords),
        //   v_view, v_shadowcoord, v_position, v_normal, v_depth
        let colorLightingVaryingDef = """
vec2 v_texcoord0   : TEXCOORD0 = vec2(0.0, 0.0);
vec4 v_texcoord1   : TEXCOORD1 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 v_texcoord2   : TEXCOORD2 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 v_texcoord3   : TEXCOORD3 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 v_texcoord4   : TEXCOORD4 = vec4(0.0, 0.0, 0.0, 0.0);
vec3 v_view        : TEXCOORD5 = vec3(0.0, 0.0, 0.0);
vec4 v_shadowcoord : TEXCOORD6 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 v_position    : TEXCOORD7 = vec4(0.0, 0.0, 0.0, 0.0);
vec3 v_normal      : NORMAL    = vec3(0.0, 0.0, 1.0);
float v_depth      : FOG       = 0.0;

vec3 a_position  : POSITION;
vec4 a_normal    : NORMAL;
vec2 a_texcoord0 : TEXCOORD0;
"""
        // vertex 变体选择辅助函数（构造时指定 VS 源码字符串）
        // 注册 5 × 3 × 2 = 30 个组合
        // 先注册单光源 Single 变体
        _registerColorLightingVariants(programs, colorLightingVaryingDef)

        // packdepth pass 程序（用于 packdepth 渲染 pass）
        let packdepthVaryingDef = """
vec4 v_position   : TEXCOORD7 = vec4(0.0, 0.0, 0.0, 0.0);
float v_depth     : FOG       = 0.0;

vec3 a_position  : POSITION;
vec2 a_texcoord0 : TEXCOORD0;
"""
        // PackDepth pass: 深度值打包为 RGBA8（或 VSM depth+depth²）
        let packdepthVS = shadow_packdepth_vertex
        let packdepthFS = shadow_packdepth_fragment
        programs.add("packdepth", ShaderProgram("packdepth", packdepthVS, packdepthFS, varyingDef: packdepthVaryingDef))

        // reflector：GroundReflector 专用（对照 three.js GroundReflector.js 内嵌 ReflectorShader
        // 完整非简化移植，含 useDepthTexture / DISTANCE_ATTENUATION / FRESNEL defines）
        // uniforms: u_textureMatrix(mat4), tDiffuse(sampler0), tDepth(sampler1),
        //           u_color(vec4 rgb), u_maxDistance/u_opacity/u_fresnelCoe/u_virtualCameraNear/
        //           u_virtualCameraFar/u_resolution(vec4.x 或 xy), u_virtualCameraProjectionMatrix/
        //           u_virtualCameraProjectionMatrixInverse/u_virtualCameraMatrixWorld(mat4)
        let reflectorVaryingDef = """
vec4 v_uv          : TEXCOORD0 = vec4(0.0, 0.0, 0.0, 0.0);

vec3 a_position  : POSITION;
"""
        let reflectorVS = """
$input a_position
$output v_uv

#include <bgfx_shader.sh>

uniform mat4 u_textureMatrix;

void main()
{
    // v_uv = textureMatrix * vec4(position, 1.0)（对照 JS ReflectorShader VS）
    v_uv = mul(u_textureMatrix, vec4(a_position, 1.0));
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
}
"""
        let reflectorFS = """
$input v_uv

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
SAMPLER2D(tDepth, 1);

uniform vec4 u_color;         // rgb=color（反射贴图混合色）
uniform vec4 u_maxDistance;   // x=maxDistance（距离衰减上界）
uniform vec4 u_opacity;       // x=opacity
uniform vec4 u_fresnelCoe;    // x=fresnelCoe
uniform vec4 u_virtualCameraNear;  // x=near
uniform vec4 u_virtualCameraFar;   // x=far
uniform vec4 u_resolution;    // xy=resolution（反射 RT 尺寸）
uniform mat4 u_virtualCameraProjectionMatrix;
uniform mat4 u_virtualCameraProjectionMatrixInverse;
uniform mat4 u_virtualCameraMatrixWorld;

float blendOverlay(float base, float blend) {
    return (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)));
}
vec3 blendOverlay(vec3 base, vec3 blend) {
    return vec3(blendOverlay(base.r, blend.r), blendOverlay(base.g, blend.g), blendOverlay(base.b, blend.b));
}
float getDepth(vec2 uv) {
    return texture2D(tDepth, uv).x;
}
float getViewZ(float depth) {
    // bgfx 左手系 perspectiveDepthToViewZ：viewZ 为正，depth∈[0,1]（near→0, far→1）
    // 对照 Three.cj packing.cj（SSAO/GTAO 同款左手系反投影），
    // 与 three.js 右手系 packing 公式（负 viewZ）符号相反。
    return (u_virtualCameraNear.x * u_virtualCameraFar.x) / (u_virtualCameraFar.x - (u_virtualCameraFar.x - u_virtualCameraNear.x) * depth);
}
vec3 getViewPosition(vec2 uv, float depth, float clipW) {
    // ★bgfx 左手系差异（NDC z 范围）：JS/WebGL NDC z ∈ [-1,1]（depth 经 (d-0.5)*2 映射）；
    //   bgfx 左手系 NDC z ∈ [0,1]（near→0, far→1），depth 本身就是 NDC z，
    //   不能再乘 2 减 1（否则 viewPosition.z 重建错误 → worldPosition.y 反号/偏移 →
    //   `worldPosition.y > maxDistance` 全 discard → 地面完全透明不可见）。
    //   x/y 保持 JS 的 (uv-0.5)*2 → [-1,1]（uv 已按 bgfx gl_FragCoord 左上原点翻转 y）。
    vec4 clipPosition = vec4(uv.x * 2.0 - 1.0, uv.y * 2.0 - 1.0, depth, 1.0); // clip (bgfx NDC z 直接用 depth)
    clipPosition *= clipW; // clip
    return mul(u_virtualCameraProjectionMatrixInverse, clipPosition).xyz; // view
}

void main()
{
    vec4 base = texture2DProj(tDiffuse, v_uv);
#ifdef useDepthTexture
    // ★bgfx 差异（gl_FragCoord 原点）：JS/WebGL gl_FragCoord 原点在左下（y 向上）；
    //   bgfx（D3D/HLSL 后端）gl_FragCoord 原点在左上（y 向下）。
    //   useDepthTexture 分支用 gl_FragCoord 重建 viewPosition/worldPosition，
    //   若 y 方向不翻转，worldPosition.y 反号 → `worldPosition.y > maxDistance`
    //   误判（全 discard 或全不衰减）→ 地面不可见/衰减错误。
    //   故 uv.y 翻转：uv.y = 1.0 - uv.y（对照 WebGL 语义）。
    vec2 uv = (gl_FragCoord.xy - 0.5) / u_resolution.xy;
    uv.y = 1.0 - uv.y; // bgfx gl_FragCoord 左上原点 → 翻转 y 对齐 WebGL 左下
    uv.x = 1.0 - uv.x;
    float depth = texture2DProj(tDepth, v_uv).r;
    float viewZ = getViewZ(depth);
    float clipW = u_virtualCameraProjectionMatrix[2][3] * viewZ + u_virtualCameraProjectionMatrix[3][3];
    vec3 viewPosition = getViewPosition(uv, depth, clipW);
    vec3 worldPosition = mul(u_virtualCameraMatrixWorld, vec4(viewPosition, 1.0)).xyz;
    if (worldPosition.y > u_maxDistance.x) discard;
    float op = u_opacity.x;
#ifdef DISTANCE_ATTENUATION
    float ratio = 1.0 - (worldPosition.y / u_maxDistance.x);
    float attenuation = ratio * ratio;
    op = u_opacity.x * attenuation;
#endif
#ifdef FRESNEL
    op *= u_fresnelCoe.x;
#endif
    gl_FragColor = vec4(blendOverlay(base.rgb, u_color.rgb), op);
#else
    gl_FragColor = vec4(blendOverlay(base.rgb, u_color.rgb), 1.0);
#endif
}
"""
        programs.add("reflector", ShaderProgram("reflector", reflectorVS, reflectorFS, varyingDef: reflectorVaryingDef))

        // HBlur/VBlur pass 程序（VSM/ESM blur 复用）
        let blurVaryingDef = """
vec4 v_texcoord0   : TEXCOORD0 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 v_texcoord1   : TEXCOORD1 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 v_texcoord2   : TEXCOORD2 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 v_texcoord3   : TEXCOORD3 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 v_texcoord4   : TEXCOORD4 = vec4(0.0, 0.0, 0.0, 0.0);

vec3 a_position  : POSITION;
vec2 a_texcoord0 : TEXCOORD0;
"""
        // HBlur pass: 水平 9-tap Gaussian
        let hblurVS = shadow_blur_vertex
        let hblurFS = shadow_hblur_fragment
        programs.add("hblur", ShaderProgram("hblur", hblurVS, hblurFS, varyingDef: blurVaryingDef))
        // VBlur pass: 垂直 9-tap Gaussian
        let vblurVS = shadow_blur_vertex
        let vblurFS = shadow_vblur_fragment
        programs.add("vblur", ShaderProgram("vblur", vblurVS, vblurFS, varyingDef: blurVaryingDef))

        // ===== SSAO pass 已迁移至 postprocessing/PostProcessingShaders.cj =====
        // ssao/ssaoblur/ssaodepth/ssaoapply 系列注册已移出，由 SSAOPass 经
        // PostProcessingShaders.get 取用（normal 为渲染管线通用 shader，保留在本库）。
    }

    /**
     * 注册 16-shadowmaps color_lighting 系列所有变体程序。
     * 5 种 SmImpl × 3 种 SmType × 2 种 DepthImpl = 30 个程序。
     * 每个程序使用统一的 fragment header + main body，
     * 通过编译期 #define 切换变体。
     */
    private static func _registerColorLightingVariants(programs: HashMap<String, ShaderProgram>, varyingDef: String): Unit {
        // SmImpl 名称与对应的 #define 名称
        let implVariants = [
            ("hard",  "SM_HARD=1"),
            ("pcf",   "SM_PCF=1"),
            ("pcss",  "SM_PCSS=1"),
            ("vsm",   "SM_VSM=1"),
            ("esm",   "SM_ESM=1"),
        ]
        // SmType 名称与对应的 vertex/fragment 变体 + #define
        // fragment 变体: single=无额外定义, csm=SM_CSM=1, omni=SM_OMNI=1
        let typeVariants = [
            ("single", "", shadow_color_lighting_vertex_single),
            ("csm",    "SM_CSM=1", shadow_color_lighting_vertex_csm),
            ("omni",   "SM_OMNI=1", shadow_color_lighting_vertex_omni),
        ]
        // DepthImpl 名称与对应的 #define + smtype_single_linear/csm_linear/omni_linear 顶点变体
        let depthVariants = [
            ("invz", ""),
            ("linear", "SM_LINEAR=1"),
        ]
        // Linear 模式的顶点着色器覆盖
        let linearVSOverrides = HashMap<String, String>()
        linearVSOverrides.add("single_linear", shadow_color_lighting_vertex_single_linear)
        linearVSOverrides.add("csm_linear", shadow_color_lighting_vertex_csm_linear)
        linearVSOverrides.add("omni_linear", shadow_color_lighting_vertex_omni_linear)

        // 公共 fragment 源（header + main body）
        let commonFS = shadow_color_lighting_header + "\n" + shadow_color_lighting_main

        for ((implName, implDefine) in implVariants) {
            for ((typeName, typeDefine, vsBase) in typeVariants) {
                for ((depthName, depthDefine) in depthVariants) {
                    // 程序名: shadow_color_<impl>_<type>_<depth>
                    let progName = "shadow_color_${implName}_${typeName}_${depthName}"
                    // 前缀附加 define 定义
                    let prefixDefines = implDefine + (if (typeDefine != "") { "\n" + typeDefine } else { "" })
                    let allDefines = prefixDefines + (if (depthDefine != "") { "\n" + depthDefine } else { "" })
                    // 构造着色器源码（含 $input/$output 头 + #include <bgfx_shader.sh> + #include <shadow_common> + defines + color_lighting body）
                    // VS: varying def + bgfx_shader +所有 #define + color_lighting vertex body
                    let vsKey = typeName + "_" + depthName
                    let vsBody = match (linearVSOverrides.get(vsKey)) {
                        case Some(v) => v
                        case None => vsBase
                    }
                    let vsSource = "#define " + allDefines.replace("=", " ") + "\n" + vsBody
                    let fsSource = "#define " + allDefines.replace("=", " ") + "\n#include <shadow_common>\n" + commonFS
                    // 创建 ShaderProgram（varying def 使用统一的 colorLightingVaryingDef）
                    let program = ShaderProgram(progName, vsSource, fsSource, varyingDef: varyingDef)
                    programs.add(progName, program)
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 销毁着色器库，释放所有资源，停止编译器线程
     *
     * @brief[en] Destroy the shader library, release all resources, stop the compiler thread
     */
    public static func shutdown(): Unit {
        ShaderCompiler.stop()
    }
}

/**
 * @brief[zh-cn] 材质 Uniform 库
 *
 * @brief[en] Material uniform library
 */
public class UniformsLib {
    public static func initialize(): Unit {
        // common
        ShaderChunks.define("common_uniforms", """
uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_proj;
uniform mat4 u_viewProj;
uniform vec3 u_cameraPosition;
uniform float u_time;
""")
        // model
        ShaderChunks.define("model_uniforms", """
uniform mat4 u_model;
""")
        // normal
        ShaderChunks.define("normal_uniforms", """
uniform mat3 u_normalMatrix;
""")
        // fog
        ShaderChunks.define("fog_uniforms", """
uniform vec3 u_fogColor;
#ifdef FOG_EXP2
uniform float u_fogDensity;
#else
uniform float u_fogNear;
uniform float u_fogFar;
#endif
""")
        // lights
        ShaderChunks.define("lights_uniforms", """
struct DirectionalLight {
    vec3 direction;
    vec3 color;
};
#define NUM_DIR_LIGHTS 1
uniform DirectionalLight u_dirLights[NUM_DIR_LIGHTS];
""")
        // points
        ShaderChunks.define("points_uniforms", """
uniform float u_pointSize;
""")
    }
}

/**
 * @brief[zh-cn] Uniforms 工具函数
 *
 * @brief[en] Uniform utility functions
 */
public class UniformsUtils {
    public static func merge(base: Array<Float64>, extra: Array<Float64>): Array<Float64> {
        let result = Array<Float64>(base.size + extra.size, { _ => 0.0 })
        for (i in 0..base.size) { result[i] = base[i] }
        for (i in 0..extra.size) { result[base.size + i] = extra[i] }
        return result
    }

    public static func clone(uniforms: Array<Float64>): Array<Float64> {
        let result = Array<Float64>(uniforms.size, { _ => 0.0 })
        for (i in 0..uniforms.size) { result[i] = uniforms[i] }
        return result
    }
}