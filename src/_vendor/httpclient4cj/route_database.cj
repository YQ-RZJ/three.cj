/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 * The file declares the Address class.
 */

protected package three._vendor.httpclient4cj

class RouteDatabase {
    public var mutex: Mutex = Mutex()
    private let failedRoutes: HashSet<Route> = HashSet<Route>()

    public func failed(failedRoute: Route): Unit {
        synchronized(mutex) {
            failedRoutes.add(failedRoute)
        }
    }

    public func connected(route: Route): Unit {
        synchronized(mutex) {
            failedRoutes.remove(route)
        }
    }

    public func shouldPostpone(route: Route): Bool {
        synchronized(mutex) {
            return failedRoutes.contains(route)
        }
    }
}
