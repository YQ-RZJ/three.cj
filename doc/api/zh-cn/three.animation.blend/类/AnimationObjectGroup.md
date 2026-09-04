# 类
## class AnimationObjectGroup
```cj
public class AnimationObjectGroup
```
动画对象组，允许一组对象共享同一个动画

### func add\(Array<Object3D>\)
```cj
public func add(objects: Array < Object3D >): Unit
```
添加任意数量的对象到此动画组

参数: 

|名称|类型|描述|
|---|---|---|
|objects|Array<Object3D>|要添加的 3D 对象数组|

### func init\(Array<Object3D>\)
```cj
public init(objects!: Array < Object3D >= Array < Object3D >())
```
构造一个新的动画对象组

参数: 

|名称|类型|描述|
|---|---|---|
|objects|Array<Object3D>|初始加入组的 Object3D 对象数组，默认为空|

### func remove\(Array<Object3D>\)
```cj
public func remove(objects: Array < Object3D >): Unit
```
从此动画组中移除任意数量的对象

参数: 

|名称|类型|描述|
|---|---|---|
|objects|Array<Object3D>|要移除的 3D 对象数组|

### func uncache\(Array<Object3D>\)
```cj
public func uncache(objects: Array < Object3D >): Unit
```
释放传入的 3D 对象的所有内存资源

参数: 

|名称|类型|描述|
|---|---|---|
|objects|Array<Object3D>|要取消缓存的 3D 对象数组|

### var stats
```cj
public var stats: HashMap < String, Any >
```
统计信息

### var uuid
```cj
public var uuid: String
```
组唯一标识符

