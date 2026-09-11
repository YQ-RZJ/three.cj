# Class
## class UiSliderInt
```cj
public class UiSliderInt <: UiWidget
```
Integer slider widget

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


Parameter: 

|Name|Type|Describe|
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


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Int32||

