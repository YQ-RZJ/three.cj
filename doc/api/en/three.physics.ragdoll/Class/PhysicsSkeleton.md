# Class
## class PhysicsSkeleton
```cj
public class PhysicsSkeleton <: IReleasable
```
Ragdoll skeleton: joint hierarchy (name + parent joint index)

### func addJoint\(String,Int64\)
```cj
public func addJoint(name: String, parentIndex!: Int64 = - 1): Int64
```
Adds a joint

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|The joint name (unique; used for pose mapping/debug)parentIndex The parent joint index; -1 (default) means a root joint|
|parentIndex|Int64||

Return: 

- The index of the new joint

### func init\(\)
```cj
public init()
```
Creates an empty skeleton

### func jointName\(Int64\)
```cj
public func jointName(index: Int64): String
```
Gets the name of a joint

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|The joint index|

Return: 

- The joint name; an empty string for an invalid index

### func jointParentIndex\(Int64\)
```cj
public func jointParentIndex(index: Int64): Int64
```
Gets the parent joint index of a joint

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|The joint index|

Return: 

- The parent joint index; -1 for a root joint or invalid index

### func release\(\)
```cj
public func release(): Bool
```
releases the underlying skeleton handle

### prop jointCount: Int64
```cj
public prop jointCount: Int64
```
The number of joints

### prop releasable: Bool
```cj
public prop releasable: Bool
```
Whether the skeleton is valid (created successfully and not disposed)

