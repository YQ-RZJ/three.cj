# 类
## class UiTreeNodeEx
```cj
public class UiTreeNodeEx <: UiWidget
```
扩展树节点控件（支持标志位）

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
public func withContent(content:() -> Unit): UiTreeNodeEx
```


参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit||

