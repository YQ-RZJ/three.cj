/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */
protected package three._vendor.httpclient4cj

let SOCK_ADDR_IPV4_LEN: Int64 = 4
let SOCK_ADDR_IPV6_LEN: Int64 = 16

public func resolveDomain(domain: String): ArrayList<IPAddress> {
    // 使用std的dns解析能力 去除系统api依赖
    let ips = IPAddress.resolve(domain)
    ArrayList(ips)
}
