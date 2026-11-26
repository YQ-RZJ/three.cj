/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file The file declares the ConcurrentQueue class.
 */

protected package three._vendor.httpclient4cj

/**
 * The class is ConcurrentQueue<T>
 * @since
 */
class ConcurrentQueue<T> <: Iterable<T> {
    private let maxQueueMemory: Int64

    private var list: ArrayList<T> = ArrayList<T>(32)

    // 通知机制 - 新{
    @When[cjc_version >= "1.0.0"]
    private let m: Mutex
    // }
    // 通知机制 - 旧{
    @When[cjc_version < "1.0.0"]
    private let m: Monitor
    // }

    /**
     * The Function is init constructor
     *
     *
     * @since 29.3
     */
    @When[cjc_version >= "1.0.0"]
    public init(mutex: Mutex) {
        this.m = mutex
        this.maxQueueMemory = 1024
    }

    @When[cjc_version < "1.0.0"]
    public init(mutex: Monitor) {
        this.m = mutex
        this.maxQueueMemory = 1024
    }

    public func iterator(): Iterator<T> {
        return list.iterator()
    }

    /**
     * The Function is add
     *
     * @param The param is item of T
     *
     * @since
     */
    public func add(item: T): Unit {
        m.lock()
        try {
            this.list.add(item)
        } finally {
            m.unlock()
        }
    }

    public func get(index: Int64): T {
        synchronized(m) {
            return list[index]
        }
    }

    public func remove(at!: Int64): ?T {
        synchronized(m) {
            list.remove(at: at)
        }
    }

    public func removeIf(predicate: (T) -> Bool): Unit {
        synchronized(m) {
            list.removeIf(predicate)
        }
    }

    public func size(): Int64 {
        synchronized(m) {
            list.size
        }
    }

    public func toArrayList(): ArrayList<T> {
        synchronized(m) {
            return ArrayList<T>(list)
        }
    }
}
