# 类
## class PhysicsSkeleton
```cj
public class PhysicsSkeleton
```
布娃娃骨骼：关节层级（名称 + 父关节索引）

### func addJoint\(String,Int64\)
```cj
public func addJoint(name: String, parentIndex!: Int64 = - 1): Int64
```
添加一个关节

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|关节名称（唯一，用于姿态映射/调试）parentIndex 父关节索引；-1（默认）表示根关节|
|parentIndex|Int64||

返回: 

- 新关节的索引

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放底层骨骼句柄

### func init\(\)
```cj
public init()
```
创建空骨骼

### func jointName\(Int64\)
```cj
public func jointName(index: Int64): String
```
获取指定关节的名称

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|关节索引|

返回: 

- 关节名称；索引无效返回空串

### func jointParentIndex\(Int64\)
```cj
public func jointParentIndex(index: Int64): Int64
```
获取指定关节的父关节索引

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|关节索引|

返回: 

- 父关节索引；根关节或无效索引返回 -1

### prop jointCount: Int64
```cj
public prop jointCount: Int64
```
关节数量

