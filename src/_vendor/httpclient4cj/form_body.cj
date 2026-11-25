/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 * The file declares the FormBody class.
 */

protected package three._vendor.httpclient4cj

/**
 * @brief The class is Form - holds form key-value pairs for URL-encoded form data
 */
public class Form {
    private var pairs: ArrayList<(String, String)> = ArrayList<(String, String)>()

    public init() {}

    public func add(name: String, value: String): Unit {
        pairs.add((name, value))
    }

    public func toEncodeString(): String {
        let sb = StringBuilder()
        var first = true
        for (pair in pairs) {
            if (!first) {
                sb.append("&")
            }
            first = false
            sb.append(urlEncode(pair[0]))
            sb.append("=")
            sb.append(urlEncode(pair[1]))
        }
        return sb.toString()
    }

    private func urlEncode(s: String): String {
        var result = ""
        let hexChars = "0123456789ABCDEF"
        for (ch in s) {
            let code = ch as Int64
            let codeVal = if (code.isSome()) { code.getOrThrow() } else { 0 }
            if ((codeVal >= 65 && codeVal <= 90) || (codeVal >= 97 && codeVal <= 122) ||
                (codeVal >= 48 && codeVal <= 57) || codeVal == 45 || codeVal == 95 ||
                codeVal == 46 || codeVal == 126) {
                result += "${ch}"
            } else if (codeVal == 32) {
                result += "+"
            } else {
                let chStr = "${ch}"
                let bytes = chStr.toUtf8Array()
                for (b in bytes) {
                    let bVal = b as Int64
                    let bv = if (bVal.isSome()) { bVal.getOrThrow() } else { 0 }
                    let hi = (bv >> 4) & 0x0F
                    let lo = bv & 0x0F
                    result += "%"
                    result += "${Rune(hexChars[hi])}"
                    result += "${Rune(hexChars[lo])}"
                }
            }
        }
        return result
    }
}

/**
 * The class is FormBody
 * @author luoyukai4
 * @since 0.33.3
 */
public class FormBody <: RequestBody {
    private static let CONTENT_TYPE: MediaType = MediaType.get("application/x-www-form-urlencoded")
    private let form: Form

    init(form: Form) {
        this.form = form
    }

    public func contentType(): Option<MediaType> {
        return CONTENT_TYPE
    }

    public func getContentLength(): Int64 {
        return form.toEncodeString().size
    }

    public func writeTo(sink: Sink): Unit {
        sink.write(form.toEncodeString().toUtf8Array())
    }

    public static func builder(): FormBodyBuilder {
        return FormBodyBuilder()
    }

    public func get(): InputStream {
        let arr = ByteBuffer()
        arr.write(form.toEncodeString().toUtf8Array())
        return arr
    }
}

public class FormBodyBuilder <: Builder<FormBody> {
    private let form: Form = Form()

    init() {}

    public func build(): FormBody {
        return FormBody(form)
    }

    public func add(name: String, value: String): FormBodyBuilder {
        form.add(name, value)
        return this
    }
}
