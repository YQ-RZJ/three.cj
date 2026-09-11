# Class
## class RawJoint
```cj
public class RawJoint
```
Offline skeleton joint definition

### func init\(String,Int\)
```cj
public init(name: String, parentIndex: Int)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|parentIndex|Int||

### var localRotation
```cj
public var localRotation: QuaternionF
```
Local rest-pose rotation (quaternion)

### var localScale
```cj
public var localScale: Vector3F
```
Local rest-pose scale

### var localTranslation
```cj
public var localTranslation: Vector3F
```
Local rest-pose translation

### var name
```cj
public var name: String
```
Joint name

### var parentIndex
```cj
public var parentIndex: Int
```
Parent joint index, -1 for the root joint

