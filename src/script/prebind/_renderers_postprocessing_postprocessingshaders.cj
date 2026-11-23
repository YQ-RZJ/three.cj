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
 * @file[zh-cn] renderers_postprocessing_postprocessingshaders 后处理 shader 注册表
 * PostProcessingShaders 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.PostProcessingShaders 绑定为 Lua 类型
 * @explain[zh-cn] 仅暴露 initialize()（把全部后处理 shader 注册进内部表，幂等）作为 staticMethod。
 * 该注册表本身没有实例状态，也没有 public 字段。
 * 使用前提：initialize() 只填充内存中的 shader 源码注册表，不触达渲染后端；真正的编译由各 pass 在
 * 渲染线程内完成，因此初始化可在任何阶段安全调用。
 * 跳过成员及原因：
 * - get(name): ?IShaderProgram：IShaderProgram 为抽象层程序接口（实现持程序句柄与编译状态），
 *   没有 Lua 类型可往返，不对脚本暴露。
 *
 * @file[en] renderers_postprocessing_postprocessingshaders  Lua binding of the post-processing
 * shader registry (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.PostProcessingShaders as a Lua type
 * @explain[en] Exposes only initialize() (registers every post-processing shader into the internal
 * table, idempotent) as a staticMethod. The registry has no instance state and no public fields.
 * Precondition: initialize() only fills the in-memory shader source registry and does not reach
 * the render backend; actual compilation happens later in each pass on the render thread, so
 * initialization is safe at any time.
 * Skipped members and reasons:
 * - get(name): ?IShaderProgram: IShaderProgram is the abstract program interface (implementations
 *   hold a program handle and compile state) and has no Lua type to round-trip, so it is not exposed.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PostProcessingShaders 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到
 * three.renderers.postprocessing.PostProcessingShaders）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PostProcessingShaders
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.PostProcessingShaders)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPostProcessingShaders(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.PostProcessingShaders")
    b.staticMethod("initialize") {
        _ =>
            PostProcessingShaders.initialize()
            Array<LuaValue>()
    }
    b.install(vm)
}
