# 类
## class ClippingContext
```cj
public open class ClippingContext
```
裁剪平面上下文，管理局部裁剪平面集合

### func addPlane\(Plane\)
```cj
public func addPlane(plane: Plane): Unit
```
添加裁剪平面

参数: 

|名称|类型|描述|
|---|---|---|
|plane|Plane|裁剪平面|

### func init\(\)
```cj
public init()
```
构造默认裁剪上下文

### func intersectPlanes\(\)
```cj
public func intersectPlanes(): Unit
```
计算平面交集（占位方法）

### var localClippingEnabled
```cj
public var localClippingEnabled: Bool
```
是否启用局部裁剪

### var planes
```cj
public var planes: ArrayList < Plane >
```
裁剪平面列表

