# 类
## class UiMenuBar
```cj
public class UiMenuBar <: UiWidget
```
菜单栏容器控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制菜单栏

返回: 

- 是否发生交互（当前实现恒返回 false）

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
构造菜单栏容器

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|子内容绘制闭包|

