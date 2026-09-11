# 类
## class UiCheckbox
```cj
public class UiCheckbox <: UiWidget
```
复选框控件

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


参数: 

|名称|类型|描述|
|---|---|---|
|label|String||
|value|CPointer<Int32>||

### func setValue\(Int32\)
```cj
public func setValue(v: Int32): Unit
```
设置值

参数: 

|名称|类型|描述|
|---|---|---|
|v|Int32||

