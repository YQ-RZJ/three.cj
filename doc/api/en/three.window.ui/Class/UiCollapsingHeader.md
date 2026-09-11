# Class
## class UiCollapsingHeader
```cj
public class UiCollapsingHeader <: UiWidget
```
Collapsing header widget

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String,Int32\)
```cj
public init(label!: String, flags!: Int32 = 0)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||
|flags|Int32||

### func withContent\(\(\)\->Unit\)
```cj
public func withContent(content:() -> Unit): UiCollapsingHeader
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit||

