# 类
## class UiInputDouble
```cj
public class UiInputDouble <: UiWidget
```
双精度输入框控件

### func draw\(\)
```cj
public override func draw(): Bool
```


### func getValue\(\)
```cj
public func getValue(): Float64
```


### func init\(String,CPointer<Float64>,Float64,Float64,String\)
```cj
public init(label!: String, value!: CPointer < Float64 >, step!: Float64 = 0.1, stepFast!: Float64 = 1.0, format!: String = "%.6f")
```


参数: 

|名称|类型|描述|
|---|---|---|
|label|String||
|value|CPointer<Float64>||
|step|Float64||
|stepFast|Float64||
|format|String||

