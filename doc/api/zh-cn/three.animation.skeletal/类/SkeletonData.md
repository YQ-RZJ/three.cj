# 类
## class SkeletonData
```cj
public class SkeletonData
```
骨骼运行时数据

### func findJointIndex\(String\)
```cj
public func findJointIndex(name: String): Int
```
按名称查找关节索引，未找到返回 -1

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func init\(\)
```cj
public init()
```
默认构造（空骨骼）

### func init\(Array<SoaTransform>,Array<Int16>,Array<String>\)
```cj
public init(restPoses: Array < SoaTransform >, parents: Array < Int16 >, names: Array < String >)
```
从休息姿势、父索引和名称构造

参数: 

|名称|类型|描述|
|---|---|---|
|restPoses|Array<SoaTransform>||
|parents|Array<Int16>||
|names|Array<String>||

### func jointDepth\(Int\)
```cj
public func jointDepth(jointIndex: Int): Int
```
获取关节深度（到根关节的边数，根关节为 0）

参数: 

|名称|类型|描述|
|---|---|---|
|jointIndex|Int||

### func jointName\(Int\)
```cj
public func jointName(jointIndex: Int): String
```
获取关节名称

参数: 

|名称|类型|描述|
|---|---|---|
|jointIndex|Int||

### func jointParent\(Int\)
```cj
public func jointParent(jointIndex: Int): Int
```
获取父关节索引（-1 表示根关节）

参数: 

|名称|类型|描述|
|---|---|---|
|jointIndex|Int||

### func jointRestPoses\(\)
```cj
public func jointRestPoses(): Array < SoaTransform >
```
获取 SoA 休息姿势数组

### func maxDepth\(\)
```cj
public func maxDepth(): Int
```
获取骨骼的最大深度

### func numJoints\(\)
```cj
public func numJoints(): Int
```
关节数量

### func numSoaJoints\(\)
```cj
public func numSoaJoints(): Int
```
SoA 块数量（每块 4 个关节）

### let MAX\_JOINTS
```cj
public static let MAX_JOINTS: Int = 1024
```
最大关节数（与 ozz 一致）

### let MAX\_SOA\_JOINTS
```cj
public static let MAX_SOA_JOINTS: Int = 256
```
最大 SoA 块数

### let NO\_PARENT
```cj
public static let NO_PARENT: Int = - 1
```
无父关节标记

### var jointNames\_
```cj
public var jointNames_: Array < String >
```
关节名称

### var jointParents\_
```cj
public var jointParents_: Array < Int16 >
```
父关节索引（Int16，-1 表示无父关节）

### var jointRestPoses\_
```cj
public var jointRestPoses_: Array < SoaTransform >
```
SoA 休息姿势（长度 = (numJoints + 3) / 4）

### var numJoints\_
```cj
public var numJoints_: Int
```
关节数量

