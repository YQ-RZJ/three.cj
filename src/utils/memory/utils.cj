/**
 * @file[zh-cn] utils 智能指针与作用域守卫工具包
 * @brief[zh-cn] 为 bgfx4cj CFFI 项目提供智能指针包装，防止野指针和内存泄漏
 * @explain[zh-cn] 本包提供以下工具：
 * - UniquePtr<T>  : 独占所有权智能指针（类似 C++ unique_ptr）
 * - SharedPtr<T>  : 引用计数共享智能指针（类似 C++ shared_ptr），
 * 使用 std.sync.Mutex + synchronized 保证线程安全
 * - ScopeGuard    : RAII 作用域守卫，离开作用域时自动执行清理回调
 * - AutoFreePtr<T>: 自动释放包装，专用于 LibC.malloc 分配的内存
 *
 * @file[en] utils  Smart-pointer and scope-guard utilities
 * @brief[en] Provides smart-pointer wrappers for the bgfx4cj CFFI project to prevent
 * dangling pointers and memory leaks
 * @explain[en] This package provides:
 * - UniquePtr<T>  : exclusive-ownership smart pointer (like C++ unique_ptr)
 * - SharedPtr<T>  : reference-counted shared smart pointer (like C++ shared_ptr),
 * thread-safe via std.sync.Mutex + synchronized
 * - ScopeGuard    : RAII scope guard that runs a cleanup callback on scope exit
 * - AutoFreePtr<T>: auto-free wrapper for memory allocated by LibC.malloc
 *
 * @note[zh-cn] 所有类均提供 ~init 终结器，GC 回收时会自动释放遗漏的指针资源，
 * 作为 dispose() 手动调用的安全兜底。数学运算相关工具函数已移入
 * three.core.math.utils，日志相关已移入 Logger（logger.cj）。
 * @note[en] All classes provide a ~init finalizer that frees missed pointer resources on
 * GC collection, as a safety net for manual dispose() calls. Math utilities moved
 * to three.core.math.utils and logging to Logger (logger.cj).
 * @package three.utils.memory
 */
package three.utils.memory

import std.sync.*

// =============================================================================
// UniquePtr<T> — 独占所有权智能指针
// =============================================================================

/**
 * @brief[zh-cn] 独占所有权智能指针
 * @explain[zh-cn] 包装一个 CPointer<T>，在 dispose() 时调用 deleter 释放。
 * 不支持复制（独占所有权），可通过 move() 转移所有权。
 * ~init 终结器在 GC 回收时自动释放，作为安全兜底。
 * @param[zh-cn] T 指针指向的类型，须满足 CType 约束
 *
 * @brief[en] Exclusive-ownership smart pointer
 * @explain[en] Wraps a CPointer<T> and frees it via deleter on dispose().
 * Copying is not supported (exclusive ownership); ownership can be
 * transferred via move(). The ~init finalizer frees automatically on
 * GC collection as a safety net.
 * @param[en] T Pointed-to type, must satisfy the CType constraint
 */
public class UniquePtr<T> where T <: CType {
    private var ptr: CPointer<T>
    private var owned: Bool
    private var deleter: (CPointer<T>) -> Unit

    /**
     * @brief[zh-cn] 构造一个空 UniquePtr
     *
     * @brief[en] Constructs an empty UniquePtr
     */
    public init() {
        this.ptr = CPointer<T>()
        this.owned = false
        this.deleter = { p: CPointer<T> => unsafe { LibC.free(p) } }
    }

    /**
     * @brief[zh-cn] 构造 UniquePtr 包装一个指针（使用默认 LibC.free 释放）
     * @param[zh-cn] p 要管理的指针
     *
     * @brief[en] Constructs a UniquePtr wrapping a pointer (released via default LibC.free)
     * @param[en] p The pointer to manage
     */
    public init(p: CPointer<T>) {
        this.ptr = p
        this.owned = true
        this.deleter = { p: CPointer<T> => unsafe { LibC.free(p) } }
    }

    /**
     * @brief[zh-cn] 构造 UniquePtr 包装一个指针（使用自定义释放函数）
     * @param[zh-cn] p 要管理的指针
     * deleter 自定义释放函数
     *
     * @brief[en] Constructs a UniquePtr wrapping a pointer (with a custom deleter)
     * @param[en] p The pointer to manage
     * deleter Custom deleter function
     */
    public init(p: CPointer<T>, deleter: (CPointer<T>) -> Unit) {
        this.ptr = p
        this.owned = true
        this.deleter = deleter
    }

    /**
     * @brief[zh-cn] 终结器：GC 回收时自动释放，防止遗漏
     *
     * @brief[en] Finalizer: frees automatically on GC collection to prevent leaks
     */
    ~init() {
        if (this.owned && !this.ptr.isNull()) {
            this.deleter(this.ptr)
        }
    }

    /**
     * @brief[zh-cn] 获取原始指针（不转移所有权）
     * @return[zh-cn] 原始 CPointer<T>
     *
     * @brief[en] Returns the raw pointer (ownership is not transferred)
     * @return[en] The raw CPointer<T>
     */
    public func get(): CPointer<T> {
        return this.ptr
    }

    /**
     * @brief[zh-cn] 检查是否持有有效指针
     * @return[zh-cn] true 表示持有有效指针
     *
     * @brief[en] Checks whether a valid pointer is held
     * @return[en] true if a valid pointer is held
     */
    public func isValid(): Bool {
        return this.owned && !this.ptr.isNull()
    }

    /**
     * @brief[zh-cn] 释放所有权，返回原始指针（不再管理其生命周期）
     * @return[zh-cn] 原始 CPointer<T>
     *
     * @brief[en] Releases ownership and returns the raw pointer (lifecycle no longer managed)
     * @return[en] The raw CPointer<T>
     */
    public func release(): CPointer<T> {
        this.owned = false
        return this.ptr
    }

    /**
     * @brief[zh-cn] 重置为管理新的指针（旧指针会被释放）
     * @param[zh-cn] p 新指针
     *
     * @brief[en] Resets to manage a new pointer (the old pointer is freed)
     * @param[en] p The new pointer
     */
    public func reset(p: CPointer<T>): Unit {
        if (this.owned && !this.ptr.isNull()) {
            this.deleter(this.ptr)
        }
        this.ptr = p
        this.owned = true
        this.deleter = { p: CPointer<T> => unsafe { LibC.free(p) } }
    }

    /**
     * @brief[zh-cn] 重置为管理新的指针，使用自定义释放函数
     * @param[zh-cn] p 新指针
     * deleter 新释放函数
     *
     * @brief[en] Resets to manage a new pointer with a custom deleter
     * @param[en] p The new pointer
     * deleter The new deleter
     */
    public func reset(p: CPointer<T>, deleter: (CPointer<T>) -> Unit): Unit {
        if (this.owned && !this.ptr.isNull()) {
            this.deleter(this.ptr)
        }
        this.ptr = p
        this.owned = true
        this.deleter = deleter
    }

    /**
     * @brief[zh-cn] 转移所有权到新的 UniquePtr
     * @return[zh-cn] 新的 UniquePtr 持有原所有权
     *
     * @brief[en] Transfers ownership to a new UniquePtr
     * @return[en] A new UniquePtr holding the original ownership
     */
    public func move(): UniquePtr<T> {
        let p = this.ptr
        let d = this.deleter
        this.owned = false
        this.ptr = CPointer<T>()
        return UniquePtr<T>(p, d)
    }

    /**
     * @brief[zh-cn] 释放管理的指针（手动调用，~init 作为兜底）
     *
     * @brief[en] Frees the managed pointer (manual call; ~init is the fallback)
     */
    public func dispose(): Unit {
        if (this.owned && !this.ptr.isNull()) {
            this.deleter(this.ptr)
            this.ptr = CPointer<T>()
            this.owned = false
        }
    }
}

// =============================================================================
// SharedPtr<T> — 引用计数共享智能指针
// =============================================================================

/**
 * @brief[zh-cn] 引用计数共享智能指针
 * @explain[zh-cn] 多个 SharedPtr 共享同一指针，内部维护引用计数。
 * 使用 std.sync.Mutex + synchronized 保证 refCount 操作线程安全。
 * 当最后一个 SharedPtr 被 dispose 时，调用 deleter 释放指针。
 * @param[zh-cn] T 指针指向的类型，须满足 CType 约束
 *
 * @brief[en] Reference-counted shared smart pointer
 * @explain[en] Multiple SharedPtr instances share the same pointer; a reference count is
 * maintained internally. Thread safety is ensured via std.sync.Mutex + synchronized.
 * When the last SharedPtr is disposed, the deleter frees the pointer.
 * @param[en] T Pointed-to type, must satisfy the CType constraint
 */
public class SharedPtr<T> where T <: CType {
    private var ptr: CPointer<T>
    private var refCount: CPointer<Int64>
    private var mtx: Mutex
    private var deleter: (CPointer<T>) -> Unit

    /**
     * @brief[zh-cn] 构造一个空 SharedPtr
     *
     * @brief[en] Constructs an empty SharedPtr
     */
    public init() {
        this.ptr = CPointer<T>()
        this.refCount = CPointer<Int64>()
        this.mtx = Mutex()
        this.deleter = { p: CPointer<T> => unsafe { LibC.free(p) } }
    }

    /**
     * @brief[zh-cn] 构造 SharedPtr 包装一个指针（使用默认 LibC.free 释放）
     * @param[zh-cn] p 要管理的指针
     *
     * @brief[en] Constructs a SharedPtr wrapping a pointer (released via default LibC.free)
     * @param[en] p The pointer to manage
     */
    public init(p: CPointer<T>) {
        this.ptr = p
        this.mtx = Mutex()
        this.deleter = { p: CPointer<T> => unsafe { LibC.free(p) } }
        this.refCount = unsafe { LibC.malloc<Int64>() }
        unsafe { this.refCount.write(1) }
    }

    /**
     * @brief[zh-cn] 构造 SharedPtr 包装一个指针（使用自定义释放函数）
     * @param[zh-cn] p 要管理的指针
     * deleter 自定义释放函数
     *
     * @brief[en] Constructs a SharedPtr wrapping a pointer (with a custom deleter)
     * @param[en] p The pointer to manage
     * deleter Custom deleter function
     */
    public init(p: CPointer<T>, deleter: (CPointer<T>) -> Unit) {
        this.ptr = p
        this.mtx = Mutex()
        this.deleter = deleter
        this.refCount = unsafe { LibC.malloc<Int64>() }
        unsafe { this.refCount.write(1) }
    }

    /**
     * @brief[zh-cn] 复制构造：共享所有权，引用计数 +1（线程安全）
     * @param[zh-cn] other 源 SharedPtr
     *
     * @brief[en] Copy constructor: shares ownership, increments the reference count (thread-safe)
     * @param[en] other The source SharedPtr
     */
    public init(other: SharedPtr<T>) {
        this.ptr = other.ptr
        this.refCount = other.refCount
        this.mtx = other.mtx
        this.deleter = other.deleter
        // 线程安全：synchronized 块自动加锁/解锁
        if (!other.refCount.isNull()) {
            synchronized(this.mtx) {
                unsafe {
                    let old = this.refCount.read()
                    this.refCount.write(old + 1)
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 终结器：GC 回收时自动释放引用
     *
     * @brief[en] Finalizer: releases the reference automatically on GC collection
     */
    ~init() {
        if (this.refCount.isNull()) {
            return
        }
        let needFree = synchronized(this.mtx) {
            let old = unsafe { this.refCount.read() }
            unsafe { this.refCount.write(old - 1) }
            old == 1
        }
        if (needFree) {
            if (!this.ptr.isNull()) {
                this.deleter(this.ptr)
            }
            unsafe { LibC.free(this.refCount) }
        }
    }

    /**
     * @brief[zh-cn] 获取原始指针（不增加引用计数）
     * @return[zh-cn] 原始 CPointer<T>
     *
     * @brief[en] Returns the raw pointer (without incrementing the reference count)
     * @return[en] The raw CPointer<T>
     */
    public func get(): CPointer<T> {
        return this.ptr
    }

    /**
     * @brief[zh-cn] 检查是否持有有效指针
     * @return[zh-cn] true 表示持有有效指针
     *
     * @brief[en] Checks whether a valid pointer is held
     * @return[en] true if a valid pointer is held
     */
    public func isValid(): Bool {
        return !this.ptr.isNull() && !this.refCount.isNull()
    }

    /**
     * @brief[zh-cn] 获取当前引用计数（线程安全）
     * @return[zh-cn] 引用计数
     *
     * @brief[en] Returns the current reference count (thread-safe)
     * @return[en] The reference count
     */
    public func useCount(): Int64 {
        if (this.refCount.isNull()) {
            return 0
        }
        return synchronized(this.mtx) {
            unsafe { this.refCount.read() }
        }
    }

    /**
     * @brief[zh-cn] 释放当前引用（手动调用，~init 作为兜底）
     *
     * @brief[en] Releases the current reference (manual call; ~init is the fallback)
     */
    public func dispose(): Unit {
        this.releaseRef()
        this.ptr = CPointer<T>()
        this.refCount = CPointer<Int64>()
    }

    /**
     * @brief[zh-cn] 减少引用计数，归零时释放指针
     *
     * @brief[en] Decrements the reference count and frees the pointer when it reaches zero
     */
    private func releaseRef(): Unit {
        if (this.refCount.isNull()) {
            return
        }
        let needFree = synchronized(this.mtx) {
            let old = unsafe { this.refCount.read() }
            unsafe { this.refCount.write(old - 1) }
            old == 1
        }
        if (needFree) {
            if (!this.ptr.isNull()) {
                this.deleter(this.ptr)
                this.ptr = CPointer<T>()
            }
            unsafe { LibC.free(this.refCount) }
            this.refCount = CPointer<Int64>()
        }
    }

    /**
     * @brief[zh-cn] 重置为管理新的指针（旧指针引用计数 -1）
     * @param[zh-cn] p 新指针
     *
     * @brief[en] Resets to manage a new pointer (decrements the old reference count)
     * @param[en] p The new pointer
     */
    public func reset(p: CPointer<T>): Unit {
        this.releaseRef()
        this.ptr = p
        this.mtx = Mutex()
        this.deleter = { p: CPointer<T> => unsafe { LibC.free(p) } }
        this.refCount = unsafe { LibC.malloc<Int64>() }
        unsafe { this.refCount.write(1) }
    }

    /**
     * @brief[zh-cn] 重置为管理新的指针，使用自定义释放函数
     * @param[zh-cn] p 新指针
     * deleter 新释放函数
     *
     * @brief[en] Resets to manage a new pointer with a custom deleter
     * @param[en] p The new pointer
     * deleter The new deleter
     */
    public func reset(p: CPointer<T>, deleter: (CPointer<T>) -> Unit): Unit {
        this.releaseRef()
        this.ptr = p
        this.mtx = Mutex()
        this.deleter = deleter
        this.refCount = unsafe { LibC.malloc<Int64>() }
        unsafe { this.refCount.write(1) }
    }
}

// =============================================================================
// ScopeGuard — RAII 作用域守卫
// =============================================================================

/**
 * @brief[zh-cn] RAII 作用域守卫
 * @explain[zh-cn] 在创建时保存一个清理回调，在 dispose() 时执行。
 * 用于确保在作用域退出时执行必要的清理操作。
 * ~init 终结器在 GC 回收时自动执行，防止遗漏。
 *
 * @brief[en] RAII scope guard
 * @explain[en] Stores a cleanup callback at creation and runs it on dispose(). It is
 * used to guarantee required cleanup runs when a scope is exited. The ~init
 * finalizer runs automatically on GC collection to prevent misses.
 */
public class ScopeGuard {
    private var callback: () -> Unit
    private var active: Bool

    /**
     * @brief[zh-cn] 构造 ScopeGuard
     * @param[zh-cn] callback 离开作用域时要执行的清理函数
     *
     * @brief[en] Constructs a ScopeGuard
     * @param[en] callback The cleanup function to run on scope exit
     */
    public init(callback: () -> Unit) {
        this.callback = callback
        this.active = true
    }

    /**
     * @brief[zh-cn] 终结器：GC 回收时自动执行清理（如果未被取消）
     *
     * @brief[en] Finalizer: runs the cleanup automatically on GC collection (if not dismissed)
     */
    ~init() {
        if (this.active) {
            this.active = false
            this.callback()
        }
    }

    /**
     * @brief[zh-cn] 取消执行清理回调
     *
     * @brief[en] Cancels the cleanup callback
     */
    public func dismiss(): Unit {
        this.active = false
    }

    /**
     * @brief[zh-cn] 执行清理回调（如果未被取消）
     *
     * @brief[en] Runs the cleanup callback (if not dismissed)
     */
    public func dispose(): Unit {
        if (this.active) {
            this.active = false
            this.callback()
        }
    }
}

// =============================================================================
// AutoFreePtr<T> — 自动释放指针包装
// =============================================================================

/**
 * @brief[zh-cn] 自动释放指针包装
 * @explain[zh-cn] 专用于 LibC.malloc 分配的内存，dispose() 时自动调用 LibC.free。
 * 相比 UniquePtr 更轻量，适合简单场景。
 * ~init 终结器在 GC 回收时自动释放，防止遗漏。
 * @param[zh-cn] T 指针指向的类型，须满足 CType 约束
 *
 * @brief[en] Auto-free pointer wrapper
 * @explain[en] Specifically for memory allocated by LibC.malloc; dispose() automatically
 * calls LibC.free. Lighter than UniquePtr, suitable for simple use cases.
 * The ~init finalizer frees automatically on GC collection to prevent leaks.
 * @param[en] T Pointed-to type, must satisfy the CType constraint
 */
public class AutoFreePtr<T> where T <: CType {
    private var ptr: CPointer<T>

    /**
     * @brief[zh-cn] 构造空 AutoFreePtr
     *
     * @brief[en] Constructs an empty AutoFreePtr
     */
    public init() {
        this.ptr = CPointer<T>()
    }

    /**
     * @brief[zh-cn] 构造 AutoFreePtr 包装一个指针
     * @param[zh-cn] p 要管理的指针
     *
     * @brief[en] Constructs an AutoFreePtr wrapping a pointer
     * @param[en] p The pointer to manage
     */
    public init(p: CPointer<T>) {
        this.ptr = p
    }

    /**
     * @brief[zh-cn] 终结器：GC 回收时自动释放
     *
     * @brief[en] Finalizer: frees automatically on GC collection
     */
    ~init() {
        if (!this.ptr.isNull()) {
            unsafe { LibC.free(this.ptr) }
        }
    }

    /**
     * @brief[zh-cn] 获取原始指针
     * @return[zh-cn] CPointer<T>
     *
     * @brief[en] Returns the raw pointer
     * @return[en] CPointer<T>
     */
    public func get(): CPointer<T> {
        return this.ptr
    }

    /**
     * @brief[zh-cn] 检查是否持有有效指针
     * @return[zh-cn] true 表示非空
     *
     * @brief[en] Checks whether a valid pointer is held
     * @return[en] true if not null
     */
    public func isValid(): Bool {
        return !this.ptr.isNull()
    }

    /**
     * @brief[zh-cn] 释放所有权，返回原始指针（不再管理）
     * @return[zh-cn] 原始 CPointer<T>
     *
     * @brief[en] Releases ownership and returns the raw pointer (no longer managed)
     * @return[en] The raw CPointer<T>
     */
    public func release(): CPointer<T> {
        let p = this.ptr
        this.ptr = CPointer<T>()
        return p
    }

    /**
     * @brief[zh-cn] 自动调用 LibC.free 释放指针
     *
     * @brief[en] Automatically calls LibC.free to release the pointer
     */
    public func dispose(): Unit {
        if (!this.ptr.isNull()) {
            unsafe { LibC.free(this.ptr) }
            this.ptr = CPointer<T>()
        }
    }
}

// =============================================================================
// 便捷工厂函数
// =============================================================================

/**
 * @brief[zh-cn] 创建 UniquePtr 的便捷函数（使用默认 LibC.free 释放）
 * @param[zh-cn] p 指针
 * @return[zh-cn] UniquePtr<T>
 *
 * @brief[en] Convenience factory for UniquePtr (released via default LibC.free)
 * @param[en] p The pointer
 * @return[en] UniquePtr<T>
 */
public func makeUnique<T>(p: CPointer<T>): UniquePtr<T> where T <: CType {
    return UniquePtr<T>(p)
}

/**
 * @brief[zh-cn] 创建 UniquePtr 的便捷函数（使用自定义释放函数）
 * @param[zh-cn] p 指针
 * deleter 释放函数
 * @return[zh-cn] UniquePtr<T>
 *
 * @brief[en] Convenience factory for UniquePtr (with a custom deleter)
 * @param[en] p The pointer
 * deleter Deleter function
 * @return[en] UniquePtr<T>
 */
public func makeUnique<T>(p: CPointer<T>, deleter: (CPointer<T>) -> Unit): UniquePtr<T> where T <: CType {
    return UniquePtr<T>(p, deleter)
}

/**
 * @brief[zh-cn] 创建 SharedPtr 的便捷函数（使用默认 LibC.free 释放）
 * @param[zh-cn] p 指针
 * @return[zh-cn] SharedPtr<T>
 *
 * @brief[en] Convenience factory for SharedPtr (released via default LibC.free)
 * @param[en] p The pointer
 * @return[en] SharedPtr<T>
 */
public func makeShared<T>(p: CPointer<T>): SharedPtr<T> where T <: CType {
    return SharedPtr<T>(p)
}

/**
 * @brief[zh-cn] 创建 SharedPtr 的便捷函数（使用自定义释放函数）
 * @param[zh-cn] p 指针
 * deleter 释放函数
 * @return[zh-cn] SharedPtr<T>
 *
 * @brief[en] Convenience factory for SharedPtr (with a custom deleter)
 * @param[en] p The pointer
 * deleter Deleter function
 * @return[en] SharedPtr<T>
 */
public func makeShared<T>(p: CPointer<T>, deleter: (CPointer<T>) -> Unit): SharedPtr<T> where T <: CType {
    return SharedPtr<T>(p, deleter)
}

/**
 * @brief[zh-cn] 创建 ScopeGuard 的便捷函数
 * @param[zh-cn] callback 清理回调
 * @return[zh-cn] ScopeGuard
 *
 * @brief[en] Convenience factory for ScopeGuard
 * @param[en] callback Cleanup callback
 * @return[en] ScopeGuard
 */
public func makeScopeGuard(callback: () -> Unit): ScopeGuard {
    return ScopeGuard(callback)
}

/**
 * @brief[zh-cn] 创建 AutoFreePtr 的便捷函数
 * @param[zh-cn] p 指针
 * @return[zh-cn] AutoFreePtr<T>
 *
 * @brief[en] Convenience factory for AutoFreePtr
 * @param[en] p The pointer
 * @return[en] AutoFreePtr<T>
 */
public func makeAutoFree<T>(p: CPointer<T>): AutoFreePtr<T> where T <: CType {
    return AutoFreePtr<T>(p)
}
