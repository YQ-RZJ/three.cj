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
 * @file[zh-cn] LuaHotReload Lua 脚本热更新（three.script.hotreload 子包）
 * @brief[zh-cn] Lua 脚本热更新，支持运行时重新加载 Lua 脚本文件
 * @explain[zh-cn] 支持运行时重新加载 Lua 脚本文件（无需重启宿主程序）。
 * 设计要点：
 * - 基于文件内容哈希（而非 mtime）检测变更，跨平台稳定。
 * - reload 失败时保留旧脚本继续运行（错误回滚，不中断宿主）。
 * - 每次 reload 前自动调用可选 onBeforeReload / onAfterReload 回调（用于保存/恢复状态）。
 *
 * @file[en] LuaHotReload  Lua script hot reload (three.script.hotreload sub-package)
 * @brief[en] Lua script hot reload; reloads Lua script files at runtime
 * @explain[en] Supports reloading Lua script files at runtime without restarting the host.
 * Design notes:
 * - Change detection is based on content hash (not mtime) for cross-platform stability.
 * - On reload failure the old script keeps running (error rollback, host keeps running).
 * - Optional onBeforeReload / onAfterReload callbacks are invoked around every reload
 * (for saving/restoring state).
 *
 * @example[zh-cn] 创建热更新器并轮询变更
 * @example[en] Creating a hot reloader and polling for changes
 * let hr = LuaHotReload(vm, "game/config.lua")
 * hr.load()                 // 首次加载并执行
 * // ... 运行中编辑 config.lua ...
 * let changed = hr.poll()   // 检测文件变化并自动重新加载
 */
package three.script.hotreload

import std.fs.{File, Path as FsPath}
import std.collection.*
import three.script.vm.*
import three.utils.log.*
import three.utils.log.macros.*

/**
 * @brief[zh-cn] Lua 脚本热更新器
 * @explain[zh-cn] 监听指定脚本文件，基于内容哈希检测变更并自动重新加载，失败时回滚到旧脚本。
 *
 * @brief[en] Lua script hot reloader
 * @explain[en] Watches a script file, detects changes by content hash and reloads automatically,
 * rolling back to the old script on failure.
 */
public class LuaHotReload {
    /// 目标虚拟机
    private var _vm: LuaVM

    /// 脚本文件路径
    private var _path: String

    /// 上次成功加载的内容哈希（空 = 尚未加载）
    private var _lastHash: String = ""

    /// 是否已成功加载过
    private var _loaded: Bool = false

    /// 最近一次加载/重新加载是否成功
    private var _lastReloadOk: Bool = false

    /// reload 前回调（可选）
    private var _onBefore: Option<() -> Unit> = None

    /// reload 后回调（可选）
    private var _onAfter: Option<() -> Unit> = None

    /**
     * @brief[zh-cn] 构造热更新器
     * @param[zh-cn] vm   目标虚拟机（脚本在此执行）
     * path Lua 脚本文件路径（相对当前工作目录）
     *
     * @brief[en] Constructs a hot reloader
     * @param[en] vm   The target virtual machine (where the script runs)
     * path The Lua script file path (relative to the current working directory)
     */
    public init(vm: LuaVM, path: String) {
        this._vm = vm
        this._path = path
    }

    /**
     * @brief[zh-cn] 脚本路径
     *
     * @brief[en] The script path
     */
    public prop path: String {
        get() { this._path }
    }

    /**
     * @brief[zh-cn] 是否已成功加载过
     *
     * @brief[en] Whether the script has been loaded successfully
     */
    public prop loaded: Bool {
        get() { this._loaded }
    }

    /**
     * @brief[zh-cn] 最近一次 reload 是否成功
     *
     * @brief[en] Whether the last reload succeeded
     */
    public prop lastReloadOk: Bool {
        get() { this._lastReloadOk }
    }

    /**
     * @brief[zh-cn] 注册 reload 前回调（如保存场景状态）
     * @param[zh-cn] cb reload 前执行的回调
     *
     * @brief[en] Registers a callback invoked before reload (e.g. saving scene state)
     * @param[en] cb The callback executed before reload
     */
    public func setBeforeReload(cb: () -> Unit): Unit {
        this._onBefore = Some(cb)
    }

    /**
     * @brief[zh-cn] 注册 reload 后回调（如刷新场景状态）
     * @param[zh-cn] cb reload 后执行的回调
     *
     * @brief[en] Registers a callback invoked after reload (e.g. refreshing scene state)
     * @param[en] cb The callback executed after reload
     */
    public func setAfterReload(cb: () -> Unit): Unit {
        this._onAfter = Some(cb)
    }

    /**
     * @brief[zh-cn] 首次加载并执行脚本文件
     * @return[zh-cn] 是否加载成功
     *
     * @brief[en] Loads and executes the script file for the first time
     * @return[en] Whether the load succeeded
     */
    public func load(): Bool {
        let ok = this._reloadInternal()
        this._loaded = ok
        return ok
    }

    /**
     * @brief[zh-cn] 立即重新加载（无论是否变化）
     * @return[zh-cn] 是否重新加载成功
     *
     * @brief[en] Reloads immediately (regardless of whether the file changed)
     * @return[en] Whether the reload succeeded
     */
    public func reload(): Bool {
        return this._reloadInternal()
    }

    /**
     * @brief[zh-cn] 轮询检测文件变更，变化则自动重新加载
     * @return[zh-cn] true = 检测到变化并已重新加载；false = 无变化或加载失败
     *
     * @brief[en] Polls for file changes and reloads automatically when changed
     * @return[en] true = a change was detected and the script was reloaded; false = no change or load failure
     */
    public func poll(): Bool {
        let hash = LuaHotReload._fileHash(this._path)
        if (hash == "") {
            // 文件不存在
            return false
        }
        if (hash != this._lastHash) {
            return this._reloadInternal()
        }
        return false
    }

    /**
     * @brief[zh-cn] 脚本文件当前是否存在
     *
     * @brief[en] Whether the script file currently exists
     */
    public prop exists: Bool {
        get() { LuaHotReload._fileHash(this._path) != "" }
    }

    // =========================================================================
    // 内部
    // =========================================================================

    /// 实际加载/重载逻辑
    private func _reloadInternal(): Bool {
        let src = LuaHotReload._readFile(this._path)
        if (src == "") {
            this._lastReloadOk = false
            return false
        }
        let hash = LuaHotReload._hashOf(src)
        match (this._onBefore) {
            case Some(cb) => cb()
            case None => ()
        }
        var ok = false
        try {
            this._vm.doString(src)
            ok = true
        } catch (e: LuaError) {
            // 脚本错误：保留旧脚本继续运行
            @LogError(["LuaHotReload", "脚本重新加载失败: " + e.message])
            ok = false
        } catch (_) {
            ok = false
        }
        this._lastReloadOk = ok
        if (ok) {
            this._lastHash = hash
        }
        match (this._onAfter) {
            case Some(cb) => cb()
            case None => ()
        }
        return ok
    }

    /// 读取文件内容（失败返回空串）
    private static func _readFile(path: String): String {
        try {
            let bytes = File.readFrom(FsPath(path))
            return String.fromUtf8(bytes)
        } catch (_) {
            return ""
        }
    }

    /// 简单字符串哈希（FNV-1a 64 位，十进制字符串可比较）
    /// @OverflowWrapping：FNV 乘法依赖 64 位截断，仓颉默认抛溢出异常，故回绕
    @OverflowWrapping
    private static func _hashOf(s: String): String {
        var h: UInt64 = 0xcbf29ce484222325
        for (c in s) {
            let b = UInt64(UInt32(c) & 0xFFu32)
            h = (h ^ b) * 0x100000001b3u64
        }
        return h.toString()
    }

    /// 文件内容哈希（不存在返回空串）
    private static func _fileHash(path: String): String {
        let src = LuaHotReload._readFile(path)
        if (src == "") { return "" }
        return LuaHotReload._hashOf(src)
    }
}
