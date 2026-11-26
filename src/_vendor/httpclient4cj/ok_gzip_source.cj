/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 * The file declares the OkGzipSource class.
 */

protected package three._vendor.httpclient4cj

internal import three._vendor.httpclient4cj.compress.*

public class OkGzipSource <: Source {
    private let base: ByteBuffer = ByteBuffer()
    private let gzip: DecompressInputStream = DecompressInputStream(base, GzipFormat.GzipFormat, 4096)
    private let source: Source
    private var hasMoreGzip: Bool = true

    public init(source: Source) {
        this.source = source
    }

    public func read(bytes: ByteBuffer, byteCount: Int64): Int64 {
        if (isClosed()) {
            return -1
        }

        if (hasMoreGzip) {
            hasMoreGzip = false
            while (true) {
                try {
                    let read = source.read(base, byteCount)
                    if (read <= 0) {
                        break
                    }
                } catch (e: EOFException) {
                    break
                }
            }
        }

        let arr = Array<Byte>(byteCount, repeat: 0)
        let read = gzip.read(arr)
        bytes.write(arr.slice(0, read))
        return read
    }

    public func close(): Unit {
        if (isClosed()) {
            return
        }

        source.close()
    }

    public func isClosed(): Bool {
        source.isClosed()
    }
}
