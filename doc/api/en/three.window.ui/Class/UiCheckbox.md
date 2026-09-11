# Class
## class UiCheckbox
```cj
public class UiCheckbox <: UiWidget
```
Checkbox widget

### func draw\(\)
```cj
public override func draw(): Bool
```


### func getValue\(\)
```cj
public func getValue(): Int32
```
获取当前值（0=未选中，1=选中）

### func init\(String,CPointer<Int32>\)
```cj
public init(label!: String, value!: CPointer < Int32 >)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||
|value|CPointer<Int32>||

### func setValue\(Int32\)
```cj
public func setValue(v: Int32): Unit
```
设置值

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Int32||

