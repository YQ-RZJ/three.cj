/**
 * @file httpclient4cj TLS 安全包装
 * @brief tlsbridge C API 的仓颉安全包装类
 * @explain 本文件提供 TlsSocket、TlsClientConfig 等安全包装类，
 *         封装了 tlsbridge C 层 API，提供与 stdx.net.tls 兼容的接口。
 */
protected package three._vendor.httpclient4cj.tls

import std.net.TcpSocket

// =============================================================================
// TLS 客户端配置
// =============================================================================

/**
 * @brief TLS 客户端配置
 */
public class TlsClientConfig {
    public var verifyMode: CertificateVerifyMode = CertificateVerifyMode.TrustAll
    public var supportedAlpnProtocols: Array<String> = Array<String>()
    public var serverName: String = ""
    public var cipherList: String = ""
    public var minProtocolVersion: Int32 = 0
    public var maxProtocolVersion: Int32 = 0
    public var securityLevel: Int32 = 1

    public init() {}
}

// =============================================================================
// TLS Socket
// =============================================================================

/**
 * @brief TLS Socket 包装类
 * @explain 包装 TCP Socket 并在其上建立 TLS 加密层。
 *         提供与 stdx.net.tls.TlsSocket 兼容的接口。
 */
public class TlsSocket {
    private let tcpSocket: TcpSocket
    private var sslCtx: CPointer<Unit>
    private var ssl: CPointer<Unit>
    private var closed: Bool = false
    private var _readTimeout: Option<Duration> = Option<Duration>.None
    private var _writeTimeout: Option<Duration> = Option<Duration>.None

    private init(tcpSocket: TcpSocket, sslCtx: CPointer<Unit>, ssl: CPointer<Unit>) {
        this.tcpSocket = tcpSocket
        this.sslCtx = sslCtx
        this.ssl = ssl
    }

    /**
     * @brief 创建 TLS 客户端连接
     * @param tcpSocket 已连接的 TCP socket
     * @param clientConfig TLS 客户端配置
     * @return TlsSocket 创建好的 TLS socket 实例
     * @throws TlsException 如果创建 SSL 上下文或 SSL 对象失败
     */
    public static func client(tcpSocket: TcpSocket, clientConfig: TlsClientConfig): TlsSocket {
        var ex = ExceptionDataS()
        let result = unsafe { CJ_TLS_DYN_SslInit(inout ex) }
        if (result != 1) {
            throw TlsException("Failed to initialize SSL")
        }

        var ex2 = ExceptionDataS()
        let ctx = unsafe { CJ_TLS_DYN_CreateContext(inout ex2) }
        if (ctx.isNull()) {
            throw TlsException("Failed to create SSL context")
        }

        var ex3 = ExceptionDataS()
        let ssl = unsafe { CJ_TLS_DYN_CreateSsl(ctx, inout ex3) }
        if (ssl.isNull()) {
            unsafe { CJ_TLS_DYN_FreeContext(ctx) }
            throw TlsException("Failed to create SSL object")
        }

        // 配置 SNI
        if (!clientConfig.serverName.isEmpty()) {
            var ex4 = ExceptionDataS()
            var ex5 = ExceptionDataS()
            unsafe {
                let cstr = LibC.mallocCString(clientConfig.serverName)
                let r1 = CJ_TLS_DYN_SetHostName(ssl, cstr, inout ex4)
                if (r1 != 1) {
                    CJ_TLS_DYN_FreeSsl(ssl); CJ_TLS_DYN_FreeContext(ctx)
                    LibC.free(cstr)
                    throw TlsException("Failed to set SNI hostname")
                }
                let r2 = CJ_TLS_DYN_SetHostNameForVerify(ssl, cstr, inout ex5)
                LibC.free(cstr)
                if (r2 != 1) {
                    CJ_TLS_DYN_FreeSsl(ssl); CJ_TLS_DYN_FreeContext(ctx)
                    throw TlsException("Failed to set hostname for verification")
                }
            }
        }

        // 配置证书验证模式
        var ex6 = ExceptionDataS()
        let mode = clientConfig.verifyMode.value()
        let r3 = unsafe { CJ_TLS_DYN_SetClientVerifyMode(ssl, mode, inout ex6) }
        if (r3 != 1) {
            unsafe { CJ_TLS_DYN_FreeSsl(ssl); CJ_TLS_DYN_FreeContext(ctx) }
            throw TlsException("Failed to set verify mode")
        }

        // 配置 TrustAll
        if (clientConfig.verifyMode.value() == CertificateVerifyMode.TrustAll.value()) {
            var ex7 = ExceptionDataS()
            let r4 = unsafe { CJ_TLS_DYN_SetTrustAll(ssl, true, inout ex7) }
            if (r4 != 1) {
                unsafe { CJ_TLS_DYN_FreeSsl(ssl); CJ_TLS_DYN_FreeContext(ctx) }
                throw TlsException("Failed to set trust all")
            }
        }

        // 配置 ALPN 协议
        if (clientConfig.supportedAlpnProtocols.size > 0) {
            let alpnStr = String.join(clientConfig.supportedAlpnProtocols, delimiter: ",")
            var ex8 = ExceptionDataS()
            unsafe {
                let cstr = LibC.mallocCString(alpnStr)
                let r5 = CJ_TLS_DYN_SetClientAlpnProtocols(ssl, cstr, inout ex8)
                LibC.free(cstr)
                if (r5 != 1) {
                    CJ_TLS_DYN_FreeSsl(ssl); CJ_TLS_DYN_FreeContext(ctx)
                    throw TlsException("Failed to set ALPN protocols")
                }
            }
        }

        return TlsSocket(tcpSocket, ctx, ssl)
    }

    /**
     * @brief 获取底层 TCP socket
     */
    public prop socket: TcpSocket {
        get() {
            return tcpSocket
        }
    }

    /**
     * @brief 获取或设置读超时
     */
    public mut prop readTimeout: Option<Duration> {
        get() {
            return _readTimeout
        }
        set(value) {
            _readTimeout = value
        }
    }

    /**
     * @brief 获取或设置写超时
     */
    public mut prop writeTimeout: Option<Duration> {
        get() {
            return _writeTimeout
        }
        set(value) {
            _writeTimeout = value
        }
    }

    /**
     * @brief 执行 TLS 握手
     * @throws TlsException 如果握手失败
     */
    public func handshake(): Unit {
        if (closed) {
            throw TlsException("Socket is closed")
        }
        var ex = ExceptionDataS()
        let result = unsafe { CJ_TLS_DYN_SslHandshake(ssl, inout ex) }
        let status = TlsStatus.fromValue(result)
        match (status) {
            case TlsStatus.Ok => ()
            case TlsStatus.NeedRead =>
                var rawBuf = Array<Byte>(4096, repeat: 0)
                var ex2 = ExceptionDataS()
                var rawData = tcpSocket.read(rawBuf)
                if (rawData > 0) {
                    unsafe {
                        var handle = acquireArrayRawData(rawBuf)
                        CJ_TLS_BIO_Map(ssl, handle.pointer, Int64(rawData), 0, inout ex2)
                        releaseArrayRawData(handle)
                    }
                }
                var ex3 = ExceptionDataS()
                let retry = unsafe { CJ_TLS_DYN_SslHandshake(ssl, inout ex3) }
                if (retry != 1) {
                    throw TlsException("TLS handshake failed")
                }
            case _ => throw TlsException("TLS handshake failed with status: ${result}")
        }
    }

    /**
     * @brief 执行 TLS 握手（带超时）
     * @param timeout 超时时间
     * @throws TlsException 如果握手失败
     */
    public func handshake(timeout: Duration): Unit {
        tcpSocket.readTimeout = timeout
        handshake()
    }

    /**
     * @brief 从 TLS 连接读取数据
     * @param buffer 接收数据的缓冲区
     * @return Int64 实际读取的字节数
     * @throws TlsException 如果读取失败
     */
    public func read(buffer: Array<Byte>): Int64 {
        if (closed) {
            throw TlsException("Socket is closed")
        }
        var ex = ExceptionDataS()
        var result: Int32 = 0
        unsafe {
            var handle = acquireArrayRawData(buffer)
            result = CJ_TLS_DYN_SslRead(ssl, handle.pointer, Int32(buffer.size), inout ex)
            releaseArrayRawData(handle)
        }
        let status = TlsStatus.fromValue(result)
        match (status) {
            case TlsStatus.Ok => return Int64(result)
            case TlsStatus.Eof => return 0
            case TlsStatus.NeedRead =>
                var rawBuf = Array<Byte>(4096, repeat: 0)
                var rawData = tcpSocket.read(rawBuf)
                if (rawData > 0) {
                    var ex2 = ExceptionDataS()
                    unsafe {
                        var rawHandle = acquireArrayRawData(rawBuf)
                        CJ_TLS_BIO_Map(ssl, rawHandle.pointer, Int64(rawData), 0, inout ex2)
                        releaseArrayRawData(rawHandle)
                    }
                    var ex3 = ExceptionDataS()
                    var retry: Int32 = 0
                    unsafe {
                        var bufHandle = acquireArrayRawData(buffer)
                        retry = CJ_TLS_DYN_SslRead(ssl, bufHandle.pointer, Int32(buffer.size), inout ex3)
                        releaseArrayRawData(bufHandle)
                    }
                    return Int64(retry)
                }
                return 0
            case _ => throw TlsException("TLS read failed with status: ${result}")
        }
    }

    /**
     * @brief 向 TLS 连接写入数据
     * @param buffer 要写入的数据
     * @throws TlsException 如果写入失败
     */
    public func write(buffer: Array<Byte>): Unit {
        if (closed) {
            throw TlsException("Socket is closed")
        }
        var ex = ExceptionDataS()
        var result: Int32 = 0
        unsafe {
            var handle = acquireArrayRawData(buffer)
            result = CJ_TLS_DYN_SslWrite(ssl, handle.pointer, Int32(buffer.size), inout ex)
            releaseArrayRawData(handle)
        }
        if (result < 0) {
            throw TlsException("TLS write failed with status: ${result}")
        }
    }

    /**
     * @brief 关闭 TLS 连接
     */
    public func close(): Unit {
        if (!closed) {
            closed = true
            var ex = ExceptionDataS()
            unsafe { CJ_TLS_DYN_SslShutdown(ssl, inout ex) }
            unsafe { CJ_TLS_DYN_FreeSsl(ssl) }
            unsafe { CJ_TLS_DYN_FreeContext(sslCtx) }
            tcpSocket.close()
        }
    }

    /**
     * @brief 检查 TLS 连接是否已关闭
     * @return Bool 如果已关闭返回 true
     */
    public func isClosed(): Bool {
        return closed
    }
}