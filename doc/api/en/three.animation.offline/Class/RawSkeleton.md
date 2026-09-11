# Class
## class RawSkeleton
```cj
public class RawSkeleton
```
Offline skeleton data

### func addJoint\(String,Int\)
```cj
public func addJoint(name: String, parentIndex: Int): RawJoint
```
Adds a joint

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|The joint name|
|parentIndex|Int|The parent joint index (-1 for the root joint)|

Return: 

- The newly created joint

### func init\(\)
```cj
public init()
```


### func numJoints\(\)
```cj
public func numJoints(): Int
```
Returns the number of joints

### func validate\(\)
```cj
public func validate(): Bool
```
Validates the skeleton data

Return: 

- true if the data is valid

### let MAX\_JOINTS
```cj
public static let MAX_JOINTS: Int = 1024
```
Maximum joint count (same as ozz)

### var joints
```cj
public var joints: ArrayList < RawJoint >
```
The joint list

