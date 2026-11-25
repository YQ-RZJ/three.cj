/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 * The file declares the Connection class.
 */

protected package three._vendor.httpclient4cj

/**
 * The class is ConnectionPool
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class ConnectionPool {
    // 通知机制 - 新{
    @When[cjc_version >= "1.0.0"]
    public let mutex: Mutex = Mutex()
    @When[cjc_version >= "1.0.0"]
    private let condition: Condition = synchronized(mutex) { mutex.condition() }
    @When[cjc_version >= "1.0.0"]
    private func mtxNotifyAll() { condition.notifyAll() }
    @When[cjc_version >= "1.0.0"]
    private func mtxWait(timeout!: Duration = Duration.Max) { condition.wait(timeout: timeout) }
    // }
    // 通知机制 - 旧{
    @When[cjc_version < "1.0.0"]
    public let mutex: Monitor = Monitor()
    @When[cjc_version < "1.0.0"]
    private func mtxNotifyAll() { mutex.notifyAll() }
    @When[cjc_version < "1.0.0"]
    private func mtxWait(timeout!: Duration = Duration.Max) { mutex.wait(timeout: timeout) }
    // }

    /* var member connections type is ConcurrentQueue<Connection> */
    private var connections: ConcurrentQueue<Connection> = ConcurrentQueue(mutex)

    /** var member maxIdleConnections type is Int64 */
    private let maxIdleConnections: Int64
    var cleanupRunning: Bool = false
    private let keepAliveDurationNs: Duration
    let routeDatabase: RouteDatabase = RouteDatabase()

    /**
     * The Function is init constructor
     *
     * @param maxIdleConnections of Int64
     * @since 0.29.3
     */
    public init(maxIdleConnections!: Int64 = 5, keepAliveDurationNs!: Duration = Duration.minute * 5) {
        this.maxIdleConnections = maxIdleConnections
        this.keepAliveDurationNs = keepAliveDurationNs
    }

    /*
     * The Function is connectionBecameIdle
     *
     * @param connection of Connection
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    func connectionBecameIdle(connection: Connection): Bool {
        let conn = connection

        if (connection.noNewExchanges || maxIdleConnections == 0) {
            var index = -1
            var removeIndex = -1
            for (i in 0..connections.size()) {
                index++
                if (refEq(connections.get(i), conn)) {
                    removeIndex = index
                    break
                }
            }
            if (removeIndex != -1) {
                connections.remove(at: removeIndex)
            }
            return true
        } else {
            // Awake the cleanup thread
            mutex.lock()
            mtxNotifyAll()
            mutex.unlock()
            return false
        }
    }

    /*
     * The Function is transmitterAcquirePooledConnection
     *
     * @param address of Address
     * @param transmitter of Transmitter
     * @param requireMultiplexed of Bool, and the Default value is false
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    func transmitterAcquirePooledConnection(
        address: Address,
        transmitter: Transmitter,
        routeSelector: Option<RouteSelector>,
        requireMultiplexed!: Bool = false
    ): Bool {
        for (i in 0..connections.size()) {
            if (requireMultiplexed && !connections.get(i).isMultiplexed()) {
                continue
            }
            if (!connections.get(i).isEligible(address, routeSelector)) {
                continue
            }
            transmitter.acquireConnectionNoEvents(connections.get(i))
            return true
        }

        return false
    }

    /**
     * The Function is connectionCount
     *
     * @return Type of Int64
     * @since 0.30.4
     */
    public func connectionCount(): Int64 {
        synchronized(mutex) {
            return connections.size()
        }
    }

    /**
     * The Function is idleConnectionCount
     *
     * @return Type of Int64
     * @since 0.30.4
     */
    public func idleConnectionCount(): Int64 {
        var total = 0

        for (i in 0..connections.size()) {
            if (connections.get(i).getTransmitters().size == 0) {
                total++
            }
        }
        return total
    }

    /**
     * The Function is evictAll
     *
     * @return Type of Unit
     * @since 0.30.4
     */
    public func evictAll(): Unit {
        let evictedConnections: ArrayList<Connection> = ArrayList<Connection>()
        synchronized(mutex) {
            connections.removeIf(
                {
                    connection: Connection =>
                    if (connection.getTransmitters().size == 0) {
                        connection.noNewExchanges = true
                        evictedConnections.add(connection)
                        return true
                    }
                    return false
                }
            )
        }
        for (i in 0..evictedConnections.size) {
            Util.closeQuietly(evictedConnections[i].getSocket())
        }
    }

    func put(connection: Connection) {
        if (!cleanupRunning) {
            cleanupRunning = true
            spawnCleanup()
        }
        connections.add(connection)
    }

    func spawnCleanup() {
        spawn {
            while (true) {
                let waitNanos = cleanup(DateTime.now())
                if (waitNanos == -1) {
                    return
                }
                synchronized(mutex) {
                    if (waitNanos > 0) {
                        mtxWait(timeout: Duration.nanosecond * waitNanos)
                    }
                }
            }
        }
    }

    func cleanup(now: DateTime): Int64 {
        var longestIdleDurationNs: Duration = Duration.nanosecond * 0
        var idleConnectionCount = 0
        var inUseConnectionCount = 0
        var longestIdleConnection: Option<Connection> = None
        var remove = 0
        synchronized(this.mutex) {
            let it = connections.iterator()
            var index = 0
            while (true) {
                match (it.next()) {
                    case Some(conn) =>
                        if (pruneAndGetAllocationCount(conn, now) > 0) {
                            inUseConnectionCount++
                            index++
                            continue
                        }
                        let idleDurationNs: Duration = now - conn.idleAtNanos
                        idleConnectionCount++
                        if (idleDurationNs > longestIdleDurationNs) {
                            longestIdleDurationNs = idleDurationNs
                            longestIdleConnection = conn
                            remove = index
                        }

                    case None => break
                }
                index++
            }

            // weather the connection is ready to be evicted
            if (longestIdleDurationNs >= keepAliveDurationNs || idleConnectionCount > this.maxIdleConnections) {
                connections.remove(at: remove)
            } else if (idleConnectionCount > 0) {
                // wait for next time
                return (keepAliveDurationNs - longestIdleDurationNs).toNanoseconds()
            } else if (inUseConnectionCount > 0) {
                return keepAliveDurationNs.toNanoseconds()
            } else {
                cleanupRunning = false
                return -1
            }
        }

        match (longestIdleConnection) {
            case Some(conn) => Util.closeQuietly(conn.getSocket())
            case None => ()
        }
        return 0
    }

    private func pruneAndGetAllocationCount(connection: Connection, _: DateTime): Int64 {
        let transmitters = connection.transmitters
        let indexArray = ArrayList<Int64>()

        for (i in 0..transmitters.size) {
            let transmitter = transmitters[i]
            if (transmitter.ref == false) {
                indexArray.add(i)
            }
        }

        for (i in 0..indexArray.size) {
            transmitters.remove(at: indexArray[i])
            connection.noNewExchanges = true
        }

        return transmitters.size
    }

    public func connectFailed(failedRoute: Route): Unit {
        routeDatabase.failed(failedRoute)
    }
}
