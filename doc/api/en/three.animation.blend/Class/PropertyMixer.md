# Class
## class PropertyMixer
```cj
public class PropertyMixer
```
Property mixer that buffers scene graph properties and allows weighted accumulation

### func apply\(Int64\)
```cj
public func apply(accuIndex: Int64): Unit
```
Applies the state of the accu<i> region to the binding when it differs from the original value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|accuIndex|Int64|Accumulation index|

### func init\(PropertyBinding,String,Int64\)
```cj
public init(binding: PropertyBinding, typeName: String, valueSize: Int64)
```
Constructs a new property mixer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|binding|PropertyBinding|Property binding|
|typeName|String|Keyframe track type name|
|valueSize|Int64|Keyframe track value size|

### var cumulativeWeightAdditive
```cj
public var cumulativeWeightAdditive: Float64
```
Cumulative additive weight

### var cumulativeWeight
```cj
public var cumulativeWeight: Float64
```
Cumulative weight

### var referenceCount
```cj
public var referenceCount: Int64
```
Number of keyframe tracks referencing this property binding

### var useCount
```cj
public var useCount: Int64
```
Number of active keyframe tracks using this property binding

