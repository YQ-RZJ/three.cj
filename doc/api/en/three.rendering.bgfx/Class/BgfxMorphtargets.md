# Class
## class BgfxMorphtargets
```cj
public class BgfxMorphtargets
```
bgfx morph target management

### func disposeAll\(\)
```cj
public func disposeAll(): Unit
```
Disposes all morph targets

### func dispose\(Int64\)
```cj
public func dispose(geometryId: Int64): Unit
```
Disposes morph target

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64|Geometry ID|

### func get\(Int64,Int64\)
```cj
public func get(geometryId: Int64, count: Int64): MorphTargetInfo
```
Gets morph target info

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64|Geometry IDcount Morph target count|
|count|Int64||

Return: 

- Morph target info

### func init\(\)
```cj
public init()
```


### func update\(Int64,Array<Float32>\)
```cj
public func update(geometryId: Int64, weights: Array < Float32 >): Unit
```
Updates morph target weights

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64|Geometry IDweights Weights array|
|weights|Array<Float32>||

