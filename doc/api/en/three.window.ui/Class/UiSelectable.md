# Class
## class UiSelectable
```cj
public class UiSelectable <: UiWidget
```
Selectable widget

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String,Bool,Int32\)
```cj
public init(label!: String, selected!: Bool = false, flags!: Int32 = 0)
```


Parameter: 

|Name|Type|Describe|
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


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Bool||

