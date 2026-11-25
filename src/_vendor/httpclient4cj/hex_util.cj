/**
 * @file
 * 内部实现的 hex 工具函数，替代 stdx.encoding.hex.toHexString
 */
protected package three._vendor.httpclient4cj

let HEX_ENCODE_CHARS = "0123456789abcdef".toArray()

/**
 * Converts the UInt8 collection to a hex character string.
 * @param data Array<Byte> 输入字节数组
 * @return hex 编码字符串
 */
public func toHexString(data: Array<Byte>): String {
    var chrLen: Int64 = data.size
    if (chrLen <= 0) {
        return ""
    }
    var chs: Array<UInt8> = Array<UInt8>(chrLen * 2, repeat: 0)
    var index: Int64 = 0
    for (i in 0..chrLen) {
        chs[index] = HEX_ENCODE_CHARS[Int64(((data[i] & 0xf0) >> 4))]
        index++
        chs[index] = HEX_ENCODE_CHARS[Int64((data[i] & 0x0f))]
        index++
    }
    return unsafe { String.fromUtf8Unchecked(chs) }
}