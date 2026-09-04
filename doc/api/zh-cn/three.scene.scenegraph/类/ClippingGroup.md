# 类
## class ClippingGroup
```cj
public class ClippingGroup <: Object3D
```
裁剪组，管理一组用于视锥体裁剪的子对象

### func addObject\(Object3D\)
```cj
public func addObject(object: Object3D): Unit
```
添加一个子对象（视作裁剪平面）

参数: 

|名称|类型|描述|
|---|---|---|
|object|Object3D|子对象|

### func clone\(\)
```cj
public override func clone(): Object3D
```
返回一个与本实例值相同的新裁剪组实例

返回: 

- 新裁剪组实例

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定裁剪组实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 返回 this

### func init\(\)
```cj
public init()
```
构造一个新的裁剪组

### func removeObject\(Object3D\)
```cj
public func removeObject(object: Object3D): Unit
```
移除一个子对象

参数: 

|名称|类型|描述|
|---|---|---|
|object|Object3D|要移除的子对象|

### var clipIntersection
```cj
public var clipIntersection: Bool
```
是否反转裁剪（保留平面外、裁掉平面内）

### var clipShadows
```cj
public var clipShadows: Bool
```
是否在阴影渲染时应用裁剪（仅主渲染裁剪）

### var clippingPlanes
```cj
public var clippingPlanes: ArrayList < Plane >
```
裁剪平面数组，每个子对象视为一个裁剪平面

### var enabled
```cj
public var enabled: Bool
```
是否启用裁剪

