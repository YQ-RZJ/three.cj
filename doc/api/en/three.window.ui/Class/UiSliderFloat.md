# Class
## class UiSliderFloat
```cj
public class UiSliderFloat <: UiWidget
```
Float slider widget

### func draw\(\)
```cj
public override func draw(): Bool
```


### func getValue\(\)
```cj
public func getValue(): Float32
```


### func init\(String,CPointer<Float32>,Float32,Float32,String\)
```cj
public init(label!: String, value!: CPointer < Float32 >, min!: Float32 = 0.0, max!: Float32 = 1.0, format!: String = "%.3f")
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||
|value|CPointer<Float32>||
|min|Float32||
|max|Float32||
|format|String||

### func setValue\(Float32\)
```cj
public func setValue(v: Float32): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float32||

