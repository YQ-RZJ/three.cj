# 类
## class RawJoint
```cj
public class RawJoint
```
离线骨骼关节定义

### func init\(String,Int\)
```cj
public init(name: String, parentIndex: Int)
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|parentIndex|Int||

### var localRotation
```cj
public var localRotation: QuaternionF
```
局部休息姿势旋转（四元数）

### var localScale
```cj
public var localScale: Vector3F
```
局部休息姿势缩放

### var localTranslation
```cj
public var localTranslation: Vector3F
```
局部休息姿势平移

### var name
```cj
public var name: String
```
关节名称

### var parentIndex
```cj
public var parentIndex: Int
```
父关节索引，根关节为 -1

