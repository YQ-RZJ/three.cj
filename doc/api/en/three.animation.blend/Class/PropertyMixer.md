# Class
## class PropertyMixer
```cj
public class PropertyMixer
```
Property mixer that buffers scene graph properties and allows weighted accumulation

### func accumulateAdditive\(Float64\)
```cj
public func accumulateAdditive(weight: Float64): Unit
```
Accumulates data from the 'incoming' region into the add (additive) region

Parameter: 

|Name|Type|Describe|
|---|---|---|
|weight|Float64|Weight|

### func accumulate\(Int64,Float64\)
```cj
public func accumulate(accuIndex: Int64, weight: Float64): Unit
```
Accumulates data from the 'incoming' region into the accu<i> region

Parameter: 

|Name|Type|Describe|
|---|---|---|
|accuIndex|Int64|Accumulation index (0 or 1)|
|weight|Float64|Weight|

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

### func restoreOriginalState\(\)
```cj
public func restoreOriginalState(): Unit
```
Restores the state previously saved via saveOriginalState to the binding

### func saveOriginalState\(\)
```cj
public func saveOriginalState(): Unit
```
Remembers the original state of the bound property and copies it into the two accumulation regions

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

