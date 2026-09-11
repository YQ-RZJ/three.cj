# Class
## class SkeletalTrackData
```cj
public class SkeletalTrackData
```
Skeletal animation user channel data

### func init\(\)
```cj
public init()
```


### func init\(String,TrackType,Array<Float32>,Array<Float32>,Array<Float32>,Array<Float32>,Int\)
```cj
public init(name!: String = "", trackType!: TrackType = TrackType.Float, times!: Array < Float32 >= Array < Float32 >(0, { _ =>
    0.0f32
}), floatValues!: Array < Float32 >= Array < Float32 >(0, { _ =>
    0.0f32
}), quatValues!: Array < Float32 >= Array < Float32 >(0, { _ =>
    0.0f32
}), float3Values!: Array < Float32 >= Array < Float32 >(0, { _ =>
    0.0f32
}), numKeyframes!: Int = 0)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|trackType|TrackType||
|times|Array<Float32>||
|floatValues|Array<Float32>||
|quatValues|Array<Float32>||
|float3Values|Array<Float32>||
|numKeyframes|Int||

### func sampleFloat3\(Float32\)
```cj
public func sampleFloat3(ratio: Float32): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|ratio|Float32||

### func sampleFloat\(Float32\)
```cj
public func sampleFloat(ratio: Float32): Float32
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|ratio|Float32||

### func sampleQuaternion\(Float32\)
```cj
public func sampleQuaternion(ratio: Float32): QuaternionF
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|ratio|Float32||

### var float3Values
```cj
public var float3Values: Array < Float32 >
```


### var floatValues
```cj
public var floatValues: Array < Float32 >
```


### var name
```cj
public var name: String
```


### var numKeyframes
```cj
public var numKeyframes: Int
```


### var quatValues
```cj
public var quatValues: Array < Float32 >
```


### var times
```cj
public var times: Array < Float32 >
```


### var trackType
```cj
public var trackType: TrackType
```


