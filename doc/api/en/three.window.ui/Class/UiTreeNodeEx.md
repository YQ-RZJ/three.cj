# Class
## class UiTreeNodeEx
```cj
public class UiTreeNodeEx <: UiWidget
```
Extended tree node widget (with flags support)

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
public func withContent(content:() -> Unit): UiTreeNodeEx
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit||

