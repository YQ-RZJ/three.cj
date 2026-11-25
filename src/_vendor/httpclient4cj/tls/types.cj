/**
 * @file httpclient4cj 类型定义
 * @brief tlsbridge C API 的结构体和常量定义
 */
protected package three._vendor.httpclient4cj.tls

// =============================================================================
// C 兼容结构体
// =============================================================================

/**
 * @brief C 层异常数据结构体
 * @explain tlsbridge C 函数通过此结构体向 Cangjie 层传递错误信息。
 */
@C public struct ExceptionDataS {
    var message: CPointer<Byte> = CPointer<Byte>()
    var constMessage: CPointer<Byte> = CPointer<Byte>()
}

// =============================================================================
// TLS 状态码
// =============================================================================

/**
 * @brief TLS 操作返回码
 * @explain 对应 C 层的 CJTLS_EOF / CJTLS_FAIL / CJTLS_NEED_READ / CJTLS_NEED_WRITE / CJTLS_OK
 */
public enum TlsStatus {
    | Eof
    | Fail
    | NeedRead
    | NeedWrite
    | Ok

    public static func fromValue(v: Int32): TlsStatus {
        return match (v) {
            case 0 => TlsStatus.Eof
            case -1 => TlsStatus.Fail
            case -2 => TlsStatus.NeedRead
            case -3 => TlsStatus.NeedWrite
            case 1 => TlsStatus.Ok
            case _ => TlsStatus.Fail
        }
    }

    public func value(): Int32 {
        return match (this) {
            case Eof => 0
            case Fail => -1
            case NeedRead => -2
            case NeedWrite => -3
            case Ok => 1
        }
    }
}

// =============================================================================
// TLS 异常类型
// =============================================================================

/**
 * @brief TLS 操作异常
 * @explain 当 TLS 握手、读写或关闭操作失败时抛出。
 */
public class TlsException <: Exception {
    public init(message: String) {
        super(message)
    }

    public init(message: String, cause: Exception) {
        // super(message, cause) ohos cj 1.1.0 不支持
        super(message)
    }
}

// =============================================================================
// 证书验证模式
// =============================================================================

/**
 * @brief 证书验证模式
 * @explain 控制 TLS 连接时对服务器证书的验证策略。
 */
public enum CertificateVerifyMode {
    | TrustAll
    | Verify

    public static func fromValue(v: Int32): CertificateVerifyMode {
        return match (v) {
            case 0 => CertificateVerifyMode.TrustAll
            case 1 => CertificateVerifyMode.Verify
            case _ => CertificateVerifyMode.TrustAll
        }
    }

    public func value(): Int32 {
        return match (this) {
            case TrustAll => 0
            case Verify => 1
        }
    }
}

// =============================================================================
// TLS 密码套件
// =============================================================================

/**
 * @brief TLS 密码套件信息
 */
public struct TlsCipherSuite {
    public var name: String = ""
}