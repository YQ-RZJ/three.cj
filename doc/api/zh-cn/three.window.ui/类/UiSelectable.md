# 类
## class UiSelectable
```cj
public class UiSelectable <: UiWidget
```
可选项控件

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String,Bool,Int32\)
```cj
public init(label!: String, selected!: Bool = false, flags!: Int32 = 0)
```


参数: 

|名称|类型|描述|
|---|---|---|
|label|String||
|selected|Bool||
|flags|Int32||

### func isSelected\(\)
```cj
public func isSelected(): Bool
```


### func setSelected\(Bool\)
```cj
public func setSelected(v: Bool): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Bool||

