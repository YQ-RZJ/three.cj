/**
 * @file httpclient4cj.compress.zlib zlib 压缩/解压缩
 * @brief 提供与 stdx.compress.zlib 兼容的 DecompressInputStream 和 GzipFormat
 */
protected package three._vendor.httpclient4cj.compress

internal import std.io.InputStream

// =============================================================================
// zlib C API 常量
// =============================================================================
let Z_OK: Int32 = 0
let Z_STREAM_END: Int32 = 1
let Z_NEED_DICT: Int32 = 2
let Z_ERRNO: Int32 = -1
let Z_STREAM_ERROR: Int32 = -2
let Z_DATA_ERROR: Int32 = -3
let Z_MEM_ERROR: Int32 = -4
let Z_BUF_ERROR: Int32 = -5
let Z_VERSION_ERROR: Int32 = -6

let Z_NO_FLUSH: Int32 = 0
let Z_FINISH: Int32 = 4

let Z_DEFLATED: Int32 = 8
let MAX_WBITS: Int32 = 15
let GZIP_WINDOW_BITS: Int32 = MAX_WBITS + 16  // 31 for gzip format

// =============================================================================
// z_stream 结构体（C 兼容）
// =============================================================================

@C
public struct z_stream {
    var next_in: CPointer<Byte> = CPointer<Byte>()
    var avail_in: Int32 = 0
    var total_in: Int64 = 0
    var next_out: CPointer<Byte> = CPointer<Byte>()
    var avail_out: Int32 = 0
    var total_out: Int64 = 0
    var msg: CPointer<Byte> = CPointer<Byte>()
    var state: CPointer<Unit> = CPointer<Unit>()
    var zalloc: CPointer<Unit> = CPointer<Unit>()
    var zfree: CPointer<Unit> = CPointer<Unit>()
    var opaque: CPointer<Unit> = CPointer<Unit>()
    var data_type: Int32 = 0
    var adler: Int64 = 0
    var reserved: Int64 = 0
}

// =============================================================================
// zlib C API 声明
// =============================================================================

foreign func inflateInit2_(strm: CPointer<z_stream>, windowBits: Int32, version: CPointer<Byte>, stream_size: Int32): Int32
foreign func inflate(strm: CPointer<z_stream>, flush: Int32): Int32
foreign func inflateEnd(strm: CPointer<z_stream>): Int32

// =============================================================================
// GzipFormat 类型
// =============================================================================

/**
 * @brief GZIP 压缩格式枚举
 * @explain 与 stdx.compress.zlib.WrapType.GzipFormat 兼容
 */
public enum GzipFormat {
    | GzipFormat
}

// =============================================================================
// DecompressInputStream 类
// =============================================================================

/**
 * @brief GZIP 解压缩输入流
 * @explain 使用 zlib inflate 实现 GZIP 解压缩。
 *         与 stdx.compress.zlib.DecompressInputStream 兼容。
 */
public class DecompressInputStream {
    // 使用单元素数组存储 z_stream 结构体，通过 acquireArrayRawData 获取 CPointer<z_stream>
    private var strmArr: Array<z_stream> = Array<z_stream>(1, repeat: z_stream())
    private var initialized: Bool = false
    private var input: Option<InputStream> = None
    private var bufLen: Int64
    private var finished: Bool = false
    private var inData: Array<Byte> = Array<Byte>(0, repeat: 0)
    private var inPos: Int64 = 0
    private var inLen: Int64 = 0
    private var outBuf: Array<Byte> = Array<Byte>(0, repeat: 0)
    private var outPos: Int64 = 0
    private var outLen: Int64 = 0
    private var eof: Bool = false

    /**
     * @brief 创建 GZIP 解压缩流
     * @param inputStream 输入数据源（InputStream）
     * @param wrap 压缩格式（GzipFormat）
     * @param bufLen 缓冲区大小
     * @throws Exception 如果初始化失败
     */
    public init(inputStream: InputStream, wrap: GzipFormat, bufLen: Int64) {
        this.input = Some(inputStream)
        this.bufLen = bufLen
        this.inData = Array<Byte>(bufLen, repeat: 0)
        this.outBuf = Array<Byte>(bufLen, repeat: 0)

        // 初始化 zlib inflate stream for gzip format
        let version = "1.2.13\0".toArray()
        let versionHandle = unsafe { acquireArrayRawData(version) }
        let versionPtr = versionHandle.pointer
        let strmHandle = unsafe { acquireArrayRawData(strmArr) }
        let ret = unsafe { inflateInit2_(strmHandle.pointer, GZIP_WINDOW_BITS, versionPtr, Int32(112)) }
        unsafe { releaseArrayRawData(strmHandle) }
        unsafe { releaseArrayRawData(versionHandle) }
        if (ret != Z_OK) {
            throw Exception("Failed to initialize zlib inflate: ${ret}")
        }
        initialized = true
    }

    /**
     * @brief 读取解压缩后的数据
     * @param buffer 输出缓冲区
     * @return 实际读取的字节数，-1 表示已读完
     * @throws Exception 如果解压缩失败
     */
    public func read(buffer: Array<Byte>): Int64 {
        if (finished) {
            return -1
        }

        // 如果输出缓冲区还有数据，先从缓存取
        if (outPos < outLen) {
            let remaining = outLen - outPos
            let toCopy = if (remaining < buffer.size) { remaining } else { buffer.size }
            for (i in 0..toCopy) {
                buffer[i] = outBuf[outPos + i]
            }
            outPos += toCopy
            if (outPos >= outLen) {
                outPos = 0
                outLen = 0
            }
            return toCopy
        }

        // 否则执行解压缩
        return decompress(buffer)
    }

    /**
     * @brief 执行 GZIP 解压缩
     * @param buffer 输出缓冲区
     * @return 解压缩后的数据长度
     */
    private func decompress(buffer: Array<Byte>): Int64 {
        if (finished) {
            return -1
        }

        var result: Int64 = -1
        while (true) {
            // 如果输入数据已耗尽，从输入流读取更多数据
            if (inPos >= inLen) {
                if (eof) {
                    finished = true
                    cleanup()
                    result = -1
                    break
                }

                // 从输入流读取数据
                if (!input.isSome()) {
                    finished = true
                    cleanup()
                    result = -1
                    break
                }
                var stream: InputStream = input.getOrThrow({=> Exception("No input stream")})

                var n: Int64 = stream.read(inData)
                if (n <= 0) {
                    eof = true
                    // 仍有未处理的数据，但可能输入已空
                    if (inLen == 0) {
                        finished = true
                        cleanup()
                        result = -1
                        break
                    }
                } else {
                    inLen = n
                    inPos = 0
                }
            }

            // 设置 zlib 输入（通过临时变量修改，再写回数组）
            let inHandle = unsafe { acquireArrayRawData(inData) }
            var s = strmArr[0]
            unsafe {
                s.next_in = inHandle.pointer + inPos
            }
            s.avail_in = Int32(inLen - inPos)

            // 设置 zlib 输出
            let outHandle = unsafe { acquireArrayRawData(buffer) }
            unsafe {
                s.next_out = outHandle.pointer
            }
            s.avail_out = Int32(buffer.size)
            strmArr[0] = s

            // 执行 inflate
            let strmHandle = unsafe { acquireArrayRawData(strmArr) }
            let flush = if (eof) { Z_FINISH } else { Z_NO_FLUSH }
            let ret = unsafe { inflate(strmHandle.pointer, flush) }
            unsafe { releaseArrayRawData(strmHandle) }
            unsafe { releaseArrayRawData(inHandle) }
            unsafe { releaseArrayRawData(outHandle) }

            if (ret != Z_OK && ret != Z_STREAM_END && ret != Z_BUF_ERROR) {
                cleanup()
                throw Exception("zlib inflate failed: ${ret}")
            }

            // 读取更新后的 z_stream 字段
            let s2 = strmArr[0]
            let availIn = s2.avail_in
            let availOut = s2.avail_out

            // 计算已处理的输入字节数
            let processedIn = (inLen - inPos) - Int64(availIn)
            inPos += processedIn

            // 计算已输出的字节数
            let producedOut = buffer.size - Int64(availOut)
            if (producedOut > 0) {
                // 如果输出没有完全填满 buffer，缓存剩余数据
                if (producedOut < buffer.size) {
                    outBuf = buffer.clone()
                    outLen = producedOut
                    outPos = producedOut
                }
                if (ret == Z_STREAM_END) {
                    finished = true
                    cleanup()
                }
                result = producedOut
                break
            }

            // 没有输出，继续循环
            if (ret == Z_STREAM_END) {
                finished = true
                cleanup()
                result = -1
                break
            }
        }
        return result
    }

    /**
     * @brief 清理 zlib 资源
     */
    private func cleanup(): Unit {
        if (initialized) {
            let strmHandle = unsafe { acquireArrayRawData(strmArr) }
            unsafe { inflateEnd(strmHandle.pointer) }
            unsafe { releaseArrayRawData(strmHandle) }
            initialized = false
        }
    }
}