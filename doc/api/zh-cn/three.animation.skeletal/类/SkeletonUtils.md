# 类
## class SkeletonUtils
```cj
public class SkeletonUtils
```
骨骼工具函数

### func findJointIndex\(SkeletonData,String\)
```cj
public static func findJointIndex(skeleton: SkeletonData, name: String): Int
```
按名称查找关节索引

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|SkeletonData|骨骼|
|name|String|关节名称|

返回: 

- 关节索引，未找到返回 -1

### func getAncestors\(SkeletonData,Int\)
```cj
public static func getAncestors(skeleton: SkeletonData, jointIndex: Int): ArrayList < Int >
```
获取关节的祖先链（从自身到根，包含自身）

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|SkeletonData|骨骼|
|jointIndex|Int|关节索引|

返回: 

- 祖先链（从自身到根）

### func getChildren\(SkeletonData,Int\)
```cj
public static func getChildren(skeleton: SkeletonData, jointIndex: Int): ArrayList < Int >
```
获取关节的子关节列表

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|SkeletonData|骨骼|
|jointIndex|Int|父关节索引|

返回: 

- 直接子关节的索引列表

### func getJointDepth\(SkeletonData,Int\)
```cj
public static func getJointDepth(skeleton: SkeletonData, jointIndex: Int): Int
```
获取关节深度（到根关节的距离）

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|SkeletonData|骨骼|
|jointIndex|Int|关节索引|

返回: 

- 深度值（根关节为 0）

### func getLowestCommonAncestor\(SkeletonData,Int,Int\)
```cj
public static func getLowestCommonAncestor(skeleton: SkeletonData, jointA: Int, jointB: Int): Int
```
获取两个关节的最近公共祖先

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|SkeletonData|骨骼|
|jointA|Int|关节 A|
|jointB|Int|关节 B|

返回: 

- 最近公共祖先索引，如果没有公共祖先返回 -1

### func getPathToJoint\(SkeletonData,Int\)
```cj
public static func getPathToJoint(skeleton: SkeletonData, jointIndex: Int): Array < Int >
```
获取从根到指定关节的路径

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|SkeletonData|骨骼|
|jointIndex|Int|目标关节索引|

返回: 

- 路径数组（从根到目标关节，包含目标关节自身）

### func getRootJoints\(SkeletonData\)
```cj
public static func getRootJoints(skeleton: SkeletonData): ArrayList < Int >
```
获取所有根关节（无父关节的关节）

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|SkeletonData|骨骼|

返回: 

- 根关节索引列表

### func getStats\(SkeletonData\)
```cj
public static func getStats(skeleton: SkeletonData): String
```
获取骨骼的统计信息

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|SkeletonData|骨骼|

返回: 

- 字符串描述：关节数、最大深度、根关节数

### func getSubtree\(SkeletonData,Int\)
```cj
public static func getSubtree(skeleton: SkeletonData, rootIndex: Int): Array < Int >
```
获取子树中的所有关节索引（包含自身）

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|SkeletonData|骨骼|
|rootIndex|Int|子树根关节索引|

返回: 

- 子树中所有关节的索引（深度优先顺序）

### func isAncestor\(SkeletonData,Int,Int\)
```cj
public static func isAncestor(skeleton: SkeletonData, jointA: Int, jointB: Int): Bool
```
检查 jointA 是否是 jointB 的祖先

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|SkeletonData|骨骼|
|jointA|Int|可能的祖先关节|
|jointB|Int|可能的后代关节|

返回: 

- true 表示 jointA 是 jointB 的祖先（或就是 jointB 自身）

