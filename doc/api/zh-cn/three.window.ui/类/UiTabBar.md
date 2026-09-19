# 类
## class UiTabBar
```cj
public class UiTabBar <: UiWidget
```
标签栏容器控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制标签栏

返回: 

- 是否发生交互（当前实现恒返回 false）

### func init\(String,Int32,\(\)\->Unit\)
```cj
public init(id!: String, flags!: Int32 = 0, content!:() -> Unit)
```
构造标签栏容器

参数: 

|名称|类型|描述|
|---|---|---|
|id|String|标签栏 ID|
|flags|Int32|标签栏标志（默认 0）|
|content|()->Unit|子内容绘制闭包|

