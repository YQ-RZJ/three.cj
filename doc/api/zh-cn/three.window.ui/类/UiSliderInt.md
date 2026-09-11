# 类
## class UiSliderInt
```cj
public class UiSliderInt <: UiWidget
```
整数滑块控件

### func draw\(\)
```cj
public override func draw(): Bool
```


### func getValue\(\)
```cj
public func getValue(): Int32
```


### func init\(String,CPointer<Int32>,Int32,Int32,String\)
```cj
public init(label!: String, value!: CPointer < Int32 >, min!: Int32 = 0, max!: Int32 = 100, format!: String = "%d")
```


参数: 

|名称|类型|描述|
|---|---|---|
|label|String||
|value|CPointer<Int32>||
|min|Int32||
|max|Int32||
|format|String||

### func setValue\(Int32\)
```cj
public func setValue(v: Int32): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Int32||

