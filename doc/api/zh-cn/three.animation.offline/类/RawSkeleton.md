# 类
## class RawSkeleton
```cj
public class RawSkeleton
```
离线骨骼数据

### func addJoint\(String,Int\)
```cj
public func addJoint(name: String, parentIndex: Int): RawJoint
```
添加关节

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|关节名称|
|parentIndex|Int|父关节索引（根关节为 -1）|

返回: 

- 新创建的关节

### func init\(\)
```cj
public init()
```


### func numJoints\(\)
```cj
public func numJoints(): Int
```
获取关节数量

### func validate\(\)
```cj
public func validate(): Bool
```
验证骨骼数据合法性

返回: 

- true 表示数据合法

### let MAX\_JOINTS
```cj
public static let MAX_JOINTS: Int = 1024
```
最大关节数（与 ozz 一致）

### var joints
```cj
public var joints: ArrayList < RawJoint >
```
关节列表

