# 类
## class XRManager
```cj
public open class XRManager
```
XR 管理器类

### func getSession\(\)
```cj
public func getSession(): String
```
获取当前 XR 会话

返回: 

- 会话标识

### func init\(\)
```cj
public init()
```
构造器，默认 XR 未启用

### func isPresenting\(\)
```cj
public func isPresenting(): Bool
```
判断 XR 是否正在呈现

返回: 

- 是否正在呈现

### func setSession\(String\)
```cj
public func setSession(session: String): Unit
```
设置 XR 会话

参数: 

|名称|类型|描述|
|---|---|---|
|session|String|会话标识|

### var enabled
```cj
public var enabled: Bool
```
是否启用 XR

