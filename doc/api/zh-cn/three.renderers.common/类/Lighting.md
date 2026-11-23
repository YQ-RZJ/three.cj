# 类
## class Lighting
```cj
public open class Lighting
```
光照信息聚合类

### func init\(\)
```cj
public init()
```
构造默认光照信息

### func reset\(\)
```cj
public func reset(): Unit
```
重置光照信息，清空所有光源列表

### var ambient
```cj
public var ambient: Vector3
```
环境光颜色

### var directional
```cj
public var directional: ArrayList < Vector3 >
```
方向光列表

### var point
```cj
public var point: ArrayList < Vector3 >
```
点光源列表

### var spot
```cj
public var spot: ArrayList < Vector3 >
```
聚光灯列表

