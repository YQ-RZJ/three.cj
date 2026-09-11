# Class
## class BlendLayer
```cj
public class BlendLayer
```
Blend layer

### func init\(\)
```cj
public init()
```


### func set\(Float32,Array<SoaTransform>,?Array<Float32>\)
```cj
public func set(weight: Float32, transforms: Array < SoaTransform >, jointWeights!:?Array < Float32 >= None): Unit
```
Sets the layer data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|weight|Float32||
|transforms|Array<SoaTransform>||
|jointWeights|?Array<Float32>||

### var jointWeights
```cj
public var jointWeights:?Array < Float32 >
```
Per-joint weights (optional)

### var transforms
```cj
public var transforms: Array < SoaTransform >
```
Joint transform array of this layer

### var weight
```cj
public var weight: Float32
```
Layer weight [0, 1]

