# Class
## class LocalToModelJob
```cj
public class LocalToModelJob
```
Local-to-model space conversion job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
Runs the local-to-model space conversion

Return: 

- true on success

### func validate\(\)
```cj
public func validate(): Bool
```
Validates the inputs

### var fromExcluded
```cj
public var fromExcluded: Bool
```
Whether to exclude the `from` joint itself (only update its children)

### var from
```cj
public var from: Int
```
Starting joint index of the update (default 0 = update all)

### var input
```cj
public var input: Array < SoaTransform >
```
Input: local-space transforms

### var output
```cj
public var output: Array < Matrix4F >
```
Output: model-space 4x4 matrices

### var rootMatrix
```cj
public var rootMatrix:?Matrix4F
```
Optional root matrix (applied to the model-space result of all joints)

### var skeleton
```cj
public var skeleton:?SkeletonData
```
Skeleton hierarchy

### var to
```cj
public var to: Int
```
Ending joint index of the update (exclusive; <= 0 means update to the last joint)

