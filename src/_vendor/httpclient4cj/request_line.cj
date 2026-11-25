/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 * The file declares the RequestLine class.
 */

protected package three._vendor.httpclient4cj

class RequestLine {
    public static func get(request: Request): String {
        let result: StringBuilder = StringBuilder()
        result.append("${request.getMethod()} ")
        let u = request.getUrl()
        let rawPath = if (u.rawPath.size > 0) {
            u.rawPath
        } else {
            "/"
        }
        let rawQuery = match (u.query) {
            case Some(v) => "?${v}"
            case _ => ""
        }
        let arr = "${rawPath}${rawQuery}".toUtf8Array()
        result.appendFromUtf8(arr)
        result.append(" HTTP/1.1")
        return result.toString()
    }
}
