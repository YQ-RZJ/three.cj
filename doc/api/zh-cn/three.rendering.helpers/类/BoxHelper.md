# 类
## class BoxHelper
```cj
public class BoxHelper <: LineSegments
```
包围盒辅助对象，用于可视化 Object3D 的轴对齐包围盒

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
复制另一个包围盒辅助对象

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 自身引用

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(\)
```cj
public init()
```
构造包围盒辅助对象

### func init\(Object3D,UInt32\)
```cj
public init(object: Object3D, color!: UInt32 = 0xffff00)
```


参数: 

|名称|类型|描述|
|---|---|---|
|object|Object3D||
|color|UInt32||

### func setFromObject\(Object3D\)
```cj
public func setFromObject(object: Object3D): BoxHelper
```
更换监视的对象并刷新包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|object|Object3D|新的监视对象|

返回: 

- 自身引用

### func update\(\)
```cj
public func update(): Unit
```
更新包围盒顶点数据

### var object
```cj
public var object: Object3D
```
請监视的对象

