/**
 * @file httpclient4cj CFFI 函数声明
 * @brief tlsbridge C API 的所有 foreign 函数声明
 * @note 错误处理通过 ExceptionDataS 结构体传递，C 层填充错误信息。
 */
protected package three._vendor.httpclient4cj.tls

// =============================================================================
// 初始化与生命周期
// =============================================================================

foreign func CJ_TLS_DYN_SslInit(exception: CPointer<ExceptionDataS>): Int32

foreign func CJ_TLS_DYN_CreateContext(exception: CPointer<ExceptionDataS>): CPointer<Unit>
foreign func CJ_TLS_DYN_FreeContext(ctx: CPointer<Unit>): Unit

foreign func CJ_TLS_DYN_CreateSsl(ctx: CPointer<Unit>, exception: CPointer<ExceptionDataS>): CPointer<Unit>
foreign func CJ_TLS_DYN_FreeSsl(ssl: CPointer<Unit>): Unit

// =============================================================================
// TLS 握手与 I/O
// =============================================================================

foreign func CJ_TLS_DYN_SslHandshake(ssl: CPointer<Unit>, exception: CPointer<ExceptionDataS>): Int32
foreign func CJ_TLS_DYN_SslRead(ssl: CPointer<Unit>, buf: CPointer<Byte>, num: Int32, exception: CPointer<ExceptionDataS>): Int32
foreign func CJ_TLS_DYN_SslWrite(ssl: CPointer<Unit>, buf: CPointer<Byte>, num: Int32, exception: CPointer<ExceptionDataS>): Int32
foreign func CJ_TLS_DYN_SslShutdown(ssl: CPointer<Unit>, exception: CPointer<ExceptionDataS>): Int32

// =============================================================================
// TLS 配置
// =============================================================================

@FastNative
foreign func CJ_TLS_DYN_SetHostName(ssl: CPointer<Unit>, hostname: CString, exception: CPointer<ExceptionDataS>): Int32
@FastNative
foreign func CJ_TLS_DYN_SetHostNameForVerify(ssl: CPointer<Unit>, hostname: CString, exception: CPointer<ExceptionDataS>): Int32
@FastNative
foreign func CJ_TLS_DYN_SetClientAlpnProtocols(ssl: CPointer<Unit>, protocols: CString, exception: CPointer<ExceptionDataS>): Int32
@FastNative
foreign func CJ_TLS_DYN_GetAlpnSelected(ssl: CPointer<Unit>, exception: CPointer<ExceptionDataS>): CString
@FastNative
foreign func CJ_TLS_DYN_SetTrustAll(ssl: CPointer<Unit>, trustAll: Bool, exception: CPointer<ExceptionDataS>): Int32
@FastNative
foreign func CJ_TLS_DYN_SetClientVerifyMode(ssl: CPointer<Unit>, mode: Int32, exception: CPointer<ExceptionDataS>): Int32
@FastNative
foreign func CJ_TLS_DYN_SetCipherList(ctx: CPointer<Unit>, ciphers: CString, exception: CPointer<ExceptionDataS>): Int32
@FastNative
foreign func CJ_TLS_DYN_SetCipherSuites(ctx: CPointer<Unit>, ciphers: CString, exception: CPointer<ExceptionDataS>): Int32
@FastNative
foreign func CJ_TLS_DYN_GetVersion(ssl: CPointer<Unit>, exception: CPointer<ExceptionDataS>): CString
@FastNative
foreign func CJ_TLS_DYN_SetProtoVersions(ctx: CPointer<Unit>, minVer: Int32, maxVer: Int32, exception: CPointer<ExceptionDataS>): Int32
foreign func CJ_TLS_DYN_Add_CA(ctx: CPointer<Unit>, caCert: CPointer<Byte>, length: Int64, exception: CPointer<ExceptionDataS>): Int32
@FastNative
foreign func CJ_TLS_DYN_SetSecurityLevel(ctx: CPointer<Unit>, level: Int32, exception: CPointer<ExceptionDataS>): Int32

// =============================================================================
// BIO 桥接
// =============================================================================

@FastNative
foreign func CJ_TLS_BIO_GetMethod(exception: CPointer<ExceptionDataS>): CPointer<Unit>

@FastNative
foreign func CJ_TLS_BIO_Map(bio: CPointer<Unit>, pointer: CPointer<Byte>, length: Int64, eof: Int32, exception: CPointer<ExceptionDataS>): Int32
@FastNative
foreign func CJ_TLS_BIO_Unmap(bio: CPointer<Unit>, eof: Int32, exception: CPointer<ExceptionDataS>): Int32

// =============================================================================
// 错误处理
// =============================================================================

@FastNative
foreign func ExceptionClear(exception: CPointer<ExceptionDataS>): Unit
@FastNative
foreign func HandleError(exception: CPointer<ExceptionDataS>, fallback: CString): Unit
@FastNative
foreign func HandleAlertError(exception: CPointer<ExceptionDataS>, description: CString, `type`: CString): Unit

// =============================================================================
// 会话管理
// =============================================================================

foreign func InitBioWithPem(pem: CPointer<Byte>, length: Int64, exception: CPointer<ExceptionDataS>): CPointer<Unit>