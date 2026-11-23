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
 * @file[zh-cn] renderers_shaders three.renderers.shaders 包的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 绑定着色器代码块库、材质变体生成器、内置 uniform 库、采样 stage 表与异步编译设施
 * @explain[zh-cn] ShaderChunks：define(name, source) 注册代码块、get(name) 读取（缺失返回 nil）、
 * resolve(source) 递归展开 #include <name>；ShaderVariant：按材质实际纹理组合生成
 * 变体键与 #define 数组（getVariantKey / getDefines / getActiveTextureFlags）；
 * UniformsLib：initialize() 注册内置 uniform 代码块；SamplerStages：stage 常量（MAX_*_SHADOW /
 * STAGE_*）、dynamicShadowEnd / getPlaceholderReplacements / applyPlaceholders / validate；
 * ShaderCompiler：DEFAULT_STACK_SIZE 与 start / stop / restart / submit / 统计 / progress；
 * ShaderCompileJob：label / varyingSize / srcSize / compileResult / waitFor()（构造为 protected，
 * 任务实例由引擎内部创建，Lua 侧只做只读查询与等待）。
 *
 * @file[en] renderers_shaders  Lua bindings of the three.renderers.shaders package
 * (three.script.prebind)
 * @brief[en] Binds the shader chunk library, the material variant generator, the built-in uniform
 * library, the sampler stage table and the asynchronous compilation facilities
 * @explain[en] ShaderChunks: define(name, source) registers a chunk, get(name) reads it (nil when
 * missing) and resolve(source) expands #include <name> recursively; ShaderVariant generates the
 * variant key and #define array from the material's actual texture combination
 * (getVariantKey / getDefines / getActiveTextureFlags);
 * UniformsLib: initialize() registers the built-in uniform chunks; SamplerStages: stage constants
 * (MAX_*_SHADOW / STAGE_*), dynamicShadowEnd / getPlaceholderReplacements / applyPlaceholders /
 * validate; ShaderCompiler: DEFAULT_STACK_SIZE plus start / stop / restart / submit / statistics /
 * progress; ShaderCompileJob: label / varyingSize / srcSize / compileResult / waitFor() (its
 * constructor is protected, so job instances are created internally by the engine and Lua only
 * performs read-only queries and waits).
 */
package three.script.prebind

import three.renderers.shaders.{ShaderChunks, ShaderVariant, UniformsLib, SamplerStages, ShaderCompiler, 
    ShaderCompileJob}
import three.renderers.materials.Material
import std.collection.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ShaderChunks 的 Lua 绑定（纯静态，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.renderers.shaders.ShaderChunks）
 *
 * @brief[en] Installs the Lua binding of ShaderChunks (pure static, no constructor)
 * @param[en] vm The target virtual machine (namespace table at three.renderers.shaders.ShaderChunks)
 */
public func installShaderChunks(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.shaders.ShaderChunks")
    // ===== 注册代码块 =====
    b.staticMethod("define") {
        args =>
            ShaderChunks.define(prebindStr(args, 0), prebindStr(args, 1))
            Array<LuaValue>()
    }
    // ===== 读取代码块（缺失返回 nil，不抛异常） =====
    b.staticMethod("get") {
        args => try {
            [LuaValue.of(ShaderChunks.get(prebindStr(args, 0)))]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    // ===== 展开 #include <name> =====
    b.staticMethod("resolve") {
        args => [LuaValue.of(ShaderChunks.resolve(prebindStr(args, 0)))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ShaderVariant 的 Lua 绑定（纯静态，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.renderers.shaders.ShaderVariant）
 *
 * @brief[en] Installs the Lua binding of ShaderVariant (pure static, no constructor)
 * @param[en] vm The target virtual machine (namespace table at three.renderers.shaders.ShaderVariant)
 */
public func installShaderVariant(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.shaders.ShaderVariant")
    // ===== 变体键（材质 kind + 激活纹理标记） =====
    b.staticMethod("getVariantKey") {
        args => [LuaValue.of(ShaderVariant.getVariantKey(prebindAs<Material>(args, 0)))]
    }
    // ===== #define 标志数组（可直接传给 IShaderProgram.compile） =====
    b.staticMethod("getDefines") {
        args => [LuaValue.of(ShaderVariant.getDefines(prebindAs<Material>(args, 0)))]
    }
    // ===== 激活纹理标记（大写名称） =====
    b.staticMethod("getActiveTextureFlags") {
        args => [LuaValue.of(ShaderVariant.getActiveTextureFlags(prebindAs<Material>(args, 0)))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UniformsLib 的 Lua 绑定（纯静态，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.renderers.shaders.UniformsLib）
 *
 * @brief[en] Installs the Lua binding of UniformsLib (pure static, no constructor)
 * @param[en] vm The target virtual machine (namespace table at three.renderers.shaders.UniformsLib)
 */
public func installUniformsLib(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.shaders.UniformsLib")
    // ===== 注册内置 uniform 代码块（重复调用为覆盖写） =====
    b.staticMethod("initialize") {
        _ =>
            UniformsLib.initialize()
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 SamplerStages 的 Lua 绑定（纯静态，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.renderers.shaders.SamplerStages）
 *
 * @brief[en] Installs the Lua binding of SamplerStages (pure static, no constructor)
 * @param[en] vm The target virtual machine (namespace table at three.renderers.shaders.SamplerStages)
 */
public func installSamplerStages(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.shaders.SamplerStages")
    // ===== shadow 数组段上限 =====
    b.staticMethod("MAX_DIR_SHADOW") {_ => [LuaValue.of(SamplerStages.MAX_DIR_SHADOW)]}
    b.staticMethod("MAX_SPOT_SHADOW") {_ => [LuaValue.of(SamplerStages.MAX_SPOT_SHADOW)]}
    b.staticMethod("MAX_POINT_SHADOW") {_ => [LuaValue.of(SamplerStages.MAX_POINT_SHADOW)]}
    // ===== 固定段 stage（UInt8 以整数返回） =====
    b.staticMethod("STAGE_FIXED_BASE") {_ => [LuaValue.of(Int64(SamplerStages.STAGE_FIXED_BASE))]}
    b.staticMethod("STAGE_MAP") {_ => [LuaValue.of(Int64(SamplerStages.STAGE_MAP))]}
    b.staticMethod("STAGE_ROUGHNESS_MAP") {_ => [LuaValue.of(Int64(SamplerStages.STAGE_ROUGHNESS_MAP))]}
    b.staticMethod("STAGE_METALNESS_MAP") {_ => [LuaValue.of(Int64(SamplerStages.STAGE_METALNESS_MAP))]}
    b.staticMethod("STAGE_NORMAL_MAP") {_ => [LuaValue.of(Int64(SamplerStages.STAGE_NORMAL_MAP))]}
    b.staticMethod("STAGE_AO_MAP") {_ => [LuaValue.of(Int64(SamplerStages.STAGE_AO_MAP))]}
    b.staticMethod("STAGE_EMISSIVE_MAP") {_ => [LuaValue.of(Int64(SamplerStages.STAGE_EMISSIVE_MAP))]}
    b.staticMethod("STAGE_ENV_MAP") {_ => [LuaValue.of(Int64(SamplerStages.STAGE_ENV_MAP))]}
    b.staticMethod("STAGE_DFGLUT") {_ => [LuaValue.of(Int64(SamplerStages.STAGE_DFGLUT))]}
    b.staticMethod("STAGE_SHADOW_BLIT") {_ => [LuaValue.of(Int64(SamplerStages.STAGE_SHADOW_BLIT))]}
    // ===== 动态 shadow 段终止 stage =====
    b.staticMethod("dynamicShadowEnd") {
        args => [LuaValue.of(
            Int64(SamplerStages.dynamicShadowEnd(prebindInt(args, 0), prebindInt(args, 1), prebindInt(args, 2))))]
    }
    // ===== 占位符映射（返回 [[占位符, stage], ...]） =====
    b.staticMethod("getPlaceholderReplacements") {
        _ =>
            let items = ArrayList<LuaValue>()
            for ((placeholder, value) in SamplerStages.getPlaceholderReplacements()) {
                items.add(LuaValue.Array([LuaValue.of(placeholder), LuaValue.of(value)]))
            }
            [LuaValue.Array(items.toArray())]
    }
    // ===== 源码占位符替换 =====
    b.staticMethod("applyPlaceholders") {
        args => [LuaValue.of(SamplerStages.applyPlaceholders(prebindStr(args, 0)))]
    }
    // ===== stage 分配校验 =====
    b.staticMethod("validate") {
        args => [LuaValue.of(
            SamplerStages.validate(numDir: prebindInt(args, 0), numSpot: prebindInt(args, 1),
                numPoint: prebindInt(args, 2)))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ShaderCompiler 的 Lua 绑定（纯静态，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.renderers.shaders.ShaderCompiler）
 *
 * @brief[en] Installs the Lua binding of ShaderCompiler (pure static, no constructor)
 * @param[en] vm The target virtual machine (namespace table at three.renderers.shaders.ShaderCompiler)
 */
public func installShaderCompiler(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.shaders.ShaderCompiler")
    // ===== 默认 worker 栈大小 =====
    b.staticMethod("DEFAULT_STACK_SIZE") {_ => [LuaValue.of(ShaderCompiler.DEFAULT_STACK_SIZE)]}
    // ===== 生命周期 =====
    b.staticMethod("start") {
        args =>
            ShaderCompiler.start(stackSize: prebindInt(args, 0, default: ShaderCompiler.DEFAULT_STACK_SIZE))
            Array<LuaValue>()
    }
    b.staticMethod("stop") {
        _ =>
            ShaderCompiler.stop()
            Array<LuaValue>()
    }
    b.staticMethod("restart") {
        args =>
            ShaderCompiler.restart(stackSize: prebindInt(args, 0, default: ShaderCompiler.DEFAULT_STACK_SIZE))
            Array<LuaValue>()
    }
    // ===== 任务提交（任务实例由引擎内部创建） =====
    b.staticMethod("submit") {
        args =>
            ShaderCompiler.submit(prebindAs<ShaderCompileJob>(args, 0))
            Array<LuaValue>()
    }
    // ===== 统计与进度 =====
    b.staticMethod("totalSubmitted") {_ => [LuaValue.of(ShaderCompiler.totalSubmitted())]}
    b.staticMethod("totalCompleted") {_ => [LuaValue.of(ShaderCompiler.totalCompleted())]}
    b.staticMethod("totalErrors") {_ => [LuaValue.of(ShaderCompiler.totalErrors())]}
    b.staticMethod("isRunning") {_ => [LuaValue.of(ShaderCompiler.isRunning())]}
    b.staticMethod("progress") {_ => [LuaValue.of(ShaderCompiler.progress())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ShaderCompileJob 的 Lua 绑定（构造为 protected，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.shaders.ShaderCompileJob）
 *
 * @brief[en] Installs the Lua binding of ShaderCompileJob (its constructor is protected; no `new`)
 * @param[en] vm The target virtual machine (class table at three.renderers.shaders.ShaderCompileJob)
 */
public func installShaderCompileJob(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.shaders.ShaderCompileJob")
    // ===== 只读描述信息 =====
    b.property("label", getter: Some({ref => LuaValue.of(ref.cast<ShaderCompileJob>().label)}))
    b.property("varyingSize", getter: Some({ref => LuaValue.of(Int64(ref.cast<ShaderCompileJob>().varyingSize))}))
    b.property("srcSize", getter: Some({ref => LuaValue.of(Int64(ref.cast<ShaderCompileJob>().srcSize))}))
    // ===== 编译结果（-999 表示尚未完成） =====
    b.property("compileResult", getter: Some({ref => LuaValue.of(Int64(ref.cast<ShaderCompileJob>().compileResult))}),
        setter: Some({ref, v => ref.cast<ShaderCompileJob>().compileResult = Int32(v.intValue())}))
    // ===== 阻塞等待编译完成 =====
    b.method("waitFor") {
        ref, _ =>
            ref.cast<ShaderCompileJob>().waitFor()
            Array<LuaValue>()
    }
    b.install(vm)
}
