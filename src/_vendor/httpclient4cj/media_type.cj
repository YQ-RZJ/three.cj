/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 * The file declares the all interfaces.
 */

protected package three._vendor.httpclient4cj

public class MediaType <: ToString {
    private static let TOKEN: String = "([a-zA-Z0-9-!#$%&'*+.^_`{|}~]+)"
    private static let QUOTED: String = "\"([^\"]*)\""

    private let string: String
    private let mediaType: String
    private let subtype: String
    private let charset: String

    private init(string: String, mediaType: String, subtype: String, charset: String) {
        this.string = string
        this.mediaType = mediaType
        this.subtype = subtype
        this.charset = charset
    }

    public static func get(string: String): MediaType {
        let typeSubtype: Regex = Regex("^" + TOKEN + "/" + TOKEN)
        var mediaType: String = ""
        var subtype: String = ""
        var end = 0
        match (typeSubtype.find(string, group: true)) {
            case None => throw IllegalArgumentException("No subtype found for: \"${string}\"")
            case Some(data) =>
                mediaType = data.matchString(1).toLower()
                subtype = data.matchString(2).toLower()
                end = data.matchPosition(2).end
        }

        let parameter: Regex = Regex(";\\s*(?:" + TOKEN + "=(?:" + TOKEN + "|" + QUOTED + "))?")
        var charset = ""
        var s = end
        for (_ in end..string.size) {
            if (s == string.size) {
                break
            }
            match (parameter.find(string[s..], group: true)) {
                case None => throw IllegalArgumentException(
                    "Parameter is not formatted correctly: \"${string.substring(s)}\" for: \"${string}\"")
                case Some(data) =>
                    s += data.matchPosition(0).end
                    let name = data.matchString(1).toLower()
                    if (name == "" || !equalsIgnoreCase(name, "charset")) {
                        continue
                    }
                    var charsetParameter: String
                    let token = try {
                        data.matchString(2).toLower()
                    } catch (e: Exception) {
                        ""
                    }

                    if (token != "") {
                        if (token.startsWith("'") && token.endsWith("'") && token.size > 2) {
                            charsetParameter = token.substring(1, token.size - 2)
                        } else {
                            charsetParameter = token
                        }
                    } else {
                        charsetParameter = data.matchString(3)
                    }

                    if (charset != "" && !equalsIgnoreCase(charsetParameter, charset)) {
                        throw IllegalArgumentException(
                            "Multiple charsets defined: \"${charset}\" and: \"${charsetParameter}\" for: \"${string}\"")
                    }

                    charset = charsetParameter
            }
        }
        return MediaType(string, mediaType, subtype, charset)
    }

    public static func parse(string: String): Option<MediaType> {
        try {
            return get(string)
        } catch (e: Exception) {
            return Option<MediaType>.None
        }
    }

    public func getType(): String {
        return mediaType
    }
    public func getSubtype(): String {
        return subtype
    }

    public func getCharset(): String {
        return charset
    }

    public func toString(): String {
        return string
    }
}
