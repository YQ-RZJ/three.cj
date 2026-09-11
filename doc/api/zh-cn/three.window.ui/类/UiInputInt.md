# 类
## class UiInputInt
```cj
public class UiInputInt <: UiWidget
```
整数输入框控件

### func draw\(\)
```cj
public override func draw(): Bool
```


### func getValue\(\)
```cj
public func getValue(): Int32
```


### func init\(String,CPointer<Int32>,Int32,Int32\)
```cj
public init(label!: String, value!: CPointer < Int32 >, step!: Int32 = 1, stepFast!: Int32 = 100)
```


参数: 

|名称|类型|描述|
|---|---|---|
|label|String||
|value|CPointer<Int32>||
|step|Int32||
|stepFast|Int32||

