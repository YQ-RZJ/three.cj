# Class
## class SkeletonData
```cj
public class SkeletonData
```
Skeleton runtime data

### func findJointIndex\(String\)
```cj
public func findJointIndex(name: String): Int
```
Finds a joint index by name; returns -1 if not found

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func init\(\)
```cj
public init()
```
Default constructor (empty skeleton)

### func init\(Array<SoaTransform>,Array<Int16>,Array<String>\)
```cj
public init(restPoses: Array < SoaTransform >, parents: Array < Int16 >, names: Array < String >)
```
Constructs from rest poses, parent indices and names

Parameter: 

|Name|Type|Describe|
|---|---|---|
|restPoses|Array<SoaTransform>||
|parents|Array<Int16>||
|names|Array<String>||

### func jointDepth\(Int\)
```cj
public func jointDepth(jointIndex: Int): Int
```
Returns the joint depth (number of edges to the root joint; the root joint is 0)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jointIndex|Int||

### func jointName\(Int\)
```cj
public func jointName(jointIndex: Int): String
```
Returns the joint name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jointIndex|Int||

### func jointParent\(Int\)
```cj
public func jointParent(jointIndex: Int): Int
```
Returns the parent joint index (-1 means root joint)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jointIndex|Int||

### func jointRestPoses\(\)
```cj
public func jointRestPoses(): Array < SoaTransform >
```
Returns the SoA rest pose array

### func maxDepth\(\)
```cj
public func maxDepth(): Int
```
Returns the maximum depth of the skeleton

### func numJoints\(\)
```cj
public func numJoints(): Int
```
Returns the number of joints

### func numSoaJoints\(\)
```cj
public func numSoaJoints(): Int
```
Returns the number of SoA blocks (4 joints per block)

### let MAX\_JOINTS
```cj
public static let MAX_JOINTS: Int = 1024
```
Maximum number of joints (consistent with ozz)

### let MAX\_SOA\_JOINTS
```cj
public static let MAX_SOA_JOINTS: Int = 256
```
Maximum number of SoA blocks

### let NO\_PARENT
```cj
public static let NO_PARENT: Int = - 1
```
No-parent marker

### var jointNames\_
```cj
public var jointNames_: Array < String >
```
Joint names

### var jointParents\_
```cj
public var jointParents_: Array < Int16 >
```
Parent joint indices (Int16, -1 means no parent)

### var jointRestPoses\_
```cj
public var jointRestPoses_: Array < SoaTransform >
```
SoA rest poses (length = (numJoints + 3) / 4)

### var numJoints\_
```cj
public var numJoints_: Int
```
Number of joints

