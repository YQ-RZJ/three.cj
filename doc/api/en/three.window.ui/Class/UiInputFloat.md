# Class
## class UiInputFloat
```cj
public class UiInputFloat <: UiWidget
```
Float input widget

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
public init(label!: String, value!: CPointer < Float32 >, step!: Float32 = 0.1, stepFast!: Float32 = 1.0, format!: String = "%.3f")
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||
|value|CPointer<Float32>||
|step|Float32||
|stepFast|Float32||
|format|String||

### func setValue\(Float32\)
```cj
public func setValue(v: Float32): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float32||

