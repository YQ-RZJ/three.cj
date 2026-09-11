# 类
## class UiCollapsingHeader
```cj
public class UiCollapsingHeader <: UiWidget
```
折叠标题控件

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String,Int32\)
```cj
public init(label!: String, flags!: Int32 = 0)
```


参数: 

|名称|类型|描述|
|---|---|---|
|label|String||
|flags|Int32||

### func withContent\(\(\)\->Unit\)
```cj
public func withContent(content:() -> Unit): UiCollapsingHeader
```


参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit||

