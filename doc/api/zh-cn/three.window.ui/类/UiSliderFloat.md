# 类
## class UiSliderFloat
```cj
public class UiSliderFloat <: UiWidget
```
浮点滑块控件

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


参数: 

|名称|类型|描述|
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


参数: 

|名称|类型|描述|
|---|---|---|
|v|Float32||

