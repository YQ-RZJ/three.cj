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
 * @file[zh-cn] ShaderCompiler  着色器编译器
 * @brief[zh-cn] 使用专用大栈线程进行 shader 编译，避免栈溢出。
 *
 * @file[en] ShaderCompiler  Shader compiler
 * @brief[en] Dedicated large-stack thread for shader compilation, prevents stack overflow.
 */
package three.rendering.shaders

import std.collection.*
import three.core.thread.{ Mutex, Condition, SThread }
import three.utils.log.Logger
import bgfx4cj.shaderc.{ sc_compile_cj, ScOptions, ScResult }

// =============================================================================
// ShaderCompileJob — 单个 shader 编译任务
// =============================================================================

/**
 * @brief[zh-cn] 着色器编译任务
 * @explain[zh-cn] 封装一次 sc_compile 调用的全部输入输出。
 * 所有 C 指针由调用方分配并保持有效，直到任务完成。
 * 通过 waitFor() 阻塞等待 worker 线程完成编译。
 *
 * @brief[en] Shader compilation job
 * @explain[en] Wraps all input/output for one sc_compile call.
 * All C pointers are allocated by the caller and remain valid until the job completes.
 * Use waitFor() to block until the worker thread finishes compilation.
 */
public class ShaderCompileJob {
    /**
     * @brief[zh-cn] 日志标签
     *
     * @brief[en] Log label
     */
    public let label: String
    /**
     * @brief[zh-cn] varying 定义 C 指针
     *
     * @brief[en] Varying definitions C pointer
     */
    public let varyingPtr: CPointer<Unit>
    /**
     * @brief[zh-cn] varying 定义大小
     *
     * @brief[en] Varying definitions size
     */
    public let varyingSize: UInt32
    /**
     * @brief[zh-cn] shader 源码 C 指针
     *
     * @brief[en] Shader source C pointer
     */
    public let srcPtr: CPointer<Unit>
    /**
     * @brief[zh-cn] shader 源码大小
     *
     * @brief[en] Shader source size
     */
    public let srcSize: UInt32
    /**
     * @brief[zh-cn] 编译选项 C 指针
     *
     * @brief[en] Compile options C pointer
     */
    public let optionsPtr: CPointer<ScOptions>
    /**
     * @brief[zh-cn] 编译结果 C 指针
     *
     * @brief[en] Compile result C pointer
     */
    public let resultPtr: CPointer<ScResult>

    /**
     * @brief[zh-cn] sc_compile 返回值（-999 表示尚未完成）
     *
     * @brief[en] sc_compile return value (-999 means not yet completed)
     */
    public var compileResult: Int32 = -999

    // 同步原语
    private let _mutex = Mutex()
    private let _cnd = Condition()
    private var _done: Bool = false

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] label 日志标签
     * @param[zh-cn] varyingPtr varying 定义 C 指针
     * @param[zh-cn] varyingSize varying 定义大小
     * @param[zh-cn] srcPtr shader 源码 C 指针
     * @param[zh-cn] srcSize shader 源码大小
     * @param[zh-cn] optionsPtr 编译选项 C 指针
     * @param[zh-cn] resultPtr 编译结果 C 指针
     *
     * @brief[en] Constructor
     * @param[en] label Log label
     * @param[en] varyingPtr Varying definitions C pointer
     * @param[en] varyingSize Varying definitions size
     * @param[en] srcPtr Shader source C pointer
     * @param[en] srcSize Shader source size
     * @param[en] optionsPtr Compile options C pointer
     * @param[en] resultPtr Compile result C pointer
     */
    public init(
        label: String,
        varyingPtr: CPointer<Unit>,
        varyingSize: UInt32,
        srcPtr: CPointer<Unit>,
        srcSize: UInt32,
        optionsPtr: CPointer<ScOptions>,
        resultPtr: CPointer<ScResult>
    ) {
        this.label = label
        this.varyingPtr = varyingPtr
        this.varyingSize = varyingSize
        this.srcPtr = srcPtr
        this.srcSize = srcSize
        this.optionsPtr = optionsPtr
        this.resultPtr = resultPtr
    }

    /**
     * @brief[zh-cn] 阻塞等待编译完成
     *
     * @brief[en] Block until compilation completes
     */
    public func waitFor(): Unit {
        this._mutex.lock()
        while (!this._done) {
            this._cnd.wait(this._mutex)
        }
        this._mutex.unlock()
    }

    /**
     * @brief[zh-cn] 内部：标记任务完成并唤醒等待者
     *
     * @brief[en] Internal: mark job as done and wake up waiters
     */
    internal func signalDone(): Unit {
        this._mutex.lock()
        this._done = true
        this._cnd.broadcast()
        this._mutex.unlock()
    }
}

// =============================================================================
// ShaderCompiler — 单 worker 大栈 shader 编译器
// =============================================================================

/**
 * @brief[zh-cn] 着色器编译器
 * @explain[zh-cn] 使用专用大栈线程进行 shader 编译，避免 glslang/glsl-optimizer 栈溢出（默认 1MB 不够）。
 * 单 worker 模式——glslang/glsl-optimizer 的 C 库非线程安全，多 worker 需串行化无增益。
 *
 * 生命周期：
 * - start() → 启动 worker 线程
 * - stop() → 等待当前任务完成，**join worker 线程**，释放全部线程资源
 * - start() again → 可随时重新启动（如游戏中途需要编译新 shader）
 * - restart() → stop() + start() 快捷方式
 *
 * @brief[en] Shader compiler
 * @explain[en] Compiles shaders on a dedicated large-stack worker thread to avoid
 * glslang/glsl-optimizer stack overflow (the default 1MB stack is not enough).
 * Single-worker mode — the glslang/glsl-optimizer C libraries are not thread-safe,
 * so multiple workers would require serialization and provide no benefit.
 *
 * Lifecycle:
 * - start() → starts the worker thread
 * - stop() → waits for the current job, **joins the worker thread**, releases all thread resources
 * - start() again → can be restarted at any time (e.g. new shaders needed mid-game)
 * - restart() → shortcut for stop() + start()
 */
public class ShaderCompiler {
    /**
     * @brief[zh-cn] 默认线程栈大小（8MB，远超 glslang 典型栈需求）
     *
     * @brief[en] Default thread stack size (8MB, far exceeding typical glslang stack requirements)
     */
    public static let DEFAULT_STACK_SIZE: Int64 = 8 * 1024 * 1024

    // 任务队列
    private static let _mutex = Mutex()
    private static let _queue = ArrayList<ShaderCompileJob>()
    private static let _hasWork = Condition()
    private static var _running = false
    private static var _worker: SThread<Unit> = SThread({ => })

    // 进度统计
    private static var _totalSubmitted: Int64 = 0
    private static var _totalCompleted: Int64 = 0
    private static var _totalErrors: Int64 = 0

    /**
     * @brief[zh-cn] 启动编译器
     * @param[zh-cn] stackSize worker 栈大小（默认 8MB）
     * @note 可多次调用：先 stop() 再 start() 可重新启动，释放旧线程资源
     *
     * @brief[en] Start the compiler
     * @param[en] stackSize Worker stack size (default 8MB)
     * @note May be called multiple times: stop() then start() restarts and releases old thread resources
     */
    public static func start(stackSize!: Int64 = DEFAULT_STACK_SIZE): Unit {
        if (_running) { return }
        _running = true
        Logger.info(["ShaderCompiler", "Starting worker, stack=${stackSize.toString()}"])
        _worker = SThread({ => _workerLoop() }, "shader-compiler", stackSize)
    }

    /**
     * @brief[zh-cn] 停止编译器
     * @explain[zh-cn] 设置停止标志，唤醒 worker 退出，然后 join 等待 worker 线程结束。
     * 调用后所有线程资源被释放。可后续通过 start() 重新启动。
     *
     * @brief[en] Stop the compiler
     * @explain[en] Sets the stop flag, wakes the worker to exit, then joins the worker thread.
     * After this call, all thread resources are released. Can be restarted via start() later.
     */
    public static func stop(): Unit {
        if (!_running) { return }
        _running = false
        _mutex.lock()
        _hasWork.broadcast()
        _mutex.unlock()
        // 等待 worker 线程结束
        _worker.join()
        Logger.info(["ShaderCompiler", "Stopped. Total: ${_totalCompleted.toString()}/${_totalSubmitted.toString()}, errors: ${_totalErrors.toString()}"])
    }

    /**
     * @brief[zh-cn] 重启编译器（先停止再启动）
     * @param[zh-cn] stackSize worker 栈大小（默认 8MB）
     * @note 适合游戏中途需要重新编译 shader 时调用，释放旧线程后再创建新线程
     *
     * @brief[en] Restart the compiler (stop then start)
     * @param[en] stackSize Worker stack size (default 8MB)
     * @note Releases old thread then creates a new one, suitable for mid-game shader compilation
     */
    public static func restart(stackSize!: Int64 = DEFAULT_STACK_SIZE): Unit {
        stop()
        start(stackSize: stackSize)
    }

    /**
     * @brief[zh-cn] 提交编译任务
     * @param[zh-cn] job 编译任务
     *
     * @brief[en] Submit a compilation job
     * @param[en] job Compilation job
     */
    public static func submit(job: ShaderCompileJob): Unit {
        _mutex.lock()
        _queue.add(job)
        _totalSubmitted += 1
        _hasWork.signal()
        _mutex.unlock()
    }

    /**
     * @brief[zh-cn] 获取已提交的任务总数
     * @return[zh-cn] 已提交总数
     *
     * @brief[en] Gets the total number of submitted tasks
     * @return[en] Total submitted
     */
    public static func totalSubmitted(): Int64 {
        return _totalSubmitted
    }

    /**
     * @brief[zh-cn] 获取已完成的任务数
     * @return[zh-cn] 已完成数
     *
     * @brief[en] Gets the number of completed tasks
     * @return[en] Number completed
     */
    public static func totalCompleted(): Int64 {
        return _totalCompleted
    }

    /**
     * @brief[zh-cn] 获取编译失败数
     * @return[zh-cn] 失败数
     *
     * @brief[en] Gets the number of compilation failures
     * @return[en] Failure count
     */
    public static func totalErrors(): Int64 {
        return _totalErrors
    }

    /**
     * @brief[zh-cn] 是否正在运行
     * @return[zh-cn] 正在运行返回 true
     *
     * @brief[en] Whether the compiler is running
     * @return[en] True if running
     */
    public static func isRunning(): Bool {
        return _running
    }

    /**
     * @brief[zh-cn] 获取编译进度（0.0 ~ 1.0）
     * @return[zh-cn] 进度百分比，无任务时返回 1.0
     *
     * @brief[en] Get compilation progress (0.0 ~ 1.0)
     * @return[en] Progress ratio, returns 1.0 if no jobs submitted
     */
    public static func progress(): Float64 {
        let total = _totalSubmitted
        if (total == 0) { return 1.0 }
        return Float64(_totalCompleted) / Float64(total)
    }

    /**
     * @brief[zh-cn] Worker 线程主循环
     * @explain[zh-cn] 从队列中取任务，执行 sc_compile_cj，标记完成。
     * 使用 Condition 等待，无忙等。_running=false 时退出。
     *
     * @brief[en] Worker thread main loop
     * @explain[en] Takes jobs from the queue, runs sc_compile_cj and marks them complete.
     * Waits on a Condition with no busy polling; exits when _running=false.
     */
    private static func _workerLoop(): Unit {
        Logger.debug(["ShaderCompiler", "Worker started"])
        while (_running) {
            var jobOpt: Option<ShaderCompileJob> = Option<ShaderCompileJob>.None
            _mutex.lock()
            while (_queue.size == 0 && _running) {
                _hasWork.wait(_mutex)
            }
            if (!_running) {
                _mutex.unlock()
                break
            }
            if (_queue.size > 0) {
                jobOpt = Option<ShaderCompileJob>.Some(_queue.remove(at: Int64(0)))
            }
            _mutex.unlock()

            match (jobOpt) {
                case Some(job) =>
                    Logger.debug(["ShaderCompiler", "Compiling ${job.label} ..."])
                    let ret = sc_compile_cj(
                        job.varyingPtr, job.varyingSize,
                        job.srcPtr, job.srcSize,
                        job.optionsPtr, job.resultPtr
                    )
                    job.compileResult = ret

                    _mutex.lock()
                    _totalCompleted += 1
                    if (ret != 0) {
                        _totalErrors += 1
                        Logger.error(["ShaderCompiler", "${job.label} failed: ${ret.toString()}"])
                    }
                    _mutex.unlock()

                    job.signalDone()
                    Logger.debug(["ShaderCompiler", "${job.label} done, ret=${ret.toString()}"])
                case None => ()
            }
        }
        Logger.debug(["ShaderCompiler", "Worker stopped"])
    }
}