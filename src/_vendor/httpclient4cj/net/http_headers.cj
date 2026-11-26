/**
 * @file httpclient4cj.net HttpHeaders 类型
 * @brief 提供与 stdx.net.http.HttpHeaders 兼容的 HTTP 头部类型
 */
protected package three._vendor.httpclient4cj.net



/**
 * @brief HTTP 头部集合
 * @explain 提供与 stdx.net.http.HttpHeaders 兼容的接口。
 *         存储 HTTP 头部名称到值的映射，支持添加、删除、获取和迭代。
 */
public class HttpHeaders <: Iterable<(String, Collection<String>)> {
    private let fields = HashMap<String, ArrayList<String>>()

    public init() {}

    /**
     * @brief 添加头部字段
     * @param name 头部名称
     * @param value 头部值
     */
    public func add(name: String, value: String): Unit {
        if (fields.contains(name)) {
            var list = fields.get(name).getOrThrow({=> Exception("")})
            list.add(value)
        } else {
            var list = ArrayList<String>()
            list.add(value)
            fields.add(name, list)
        }
    }

    /**
     * @brief 删除头部字段
     * @param name 头部名称
     */
    public func del(name: String): Unit {
        fields.remove(name)
    }

    /**
     * @brief 获取头部字段值列表
     * @param name 头部名称
     * @return 值列表（Collection<String>）
     */
    public func get(name: String): Collection<String> {
        if (fields.contains(name)) {
            return fields.get(name).getOrThrow({=> Exception("")})
        }
        return ArrayList<String>()
    }

    /**
     * @brief 设置头部字段（替换已有值）
     * @param name 头部名称
     * @param value 头部值
     */
    public func set(name: String, value: String): Unit {
        var list = ArrayList<String>()
        list.add(value)
        fields.add(name, list)
    }

    /**
     * @brief 返回迭代器
     * @return Iterator<(String, Collection<String>)>
     */
    public func iterator(): Iterator<(String, Collection<String>)> {
        return HttpHeadersIterator(this)
    }

    /**
     * @brief 获取内部 HashMap 的迭代器
     * @return Iterator<(String, ArrayList<String>)>
     */
    internal func innerIterator(): Iterator<(String, ArrayList<String>)> {
        return fields.iterator()
    }
}

/**
 * @brief HttpHeaders 迭代器包装类
 * @explain 将 HashMap<String, ArrayList<String>> 的迭代器转换为
 *         Iterator<(String, Collection<String>)>
 */
private class HttpHeadersIterator <: Iterator<(String, Collection<String>)> {
    private let inner: Iterator<(String, ArrayList<String>)>

    public init(headers: HttpHeaders) {
        this.inner = headers.innerIterator()
    }

    public func next(): Option<(String, Collection<String>)> {
        let n = inner.next()
        if (n.isSome()) {
            let (k, v) = n.getOrThrow({=> Exception("")})
            let pair: (String, Collection<String>) = (k, v)
            return Some(pair)
        }
        return Option<(String, Collection<String>)>.None
    }
}