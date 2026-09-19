# 类
## class UiMainMenuBar
```cj
public class UiMainMenuBar <: UiWidget
```
主菜单栏容器控件（全屏固定）

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制主菜单栏

返回: 

- 是否发生交互（当前实现恒返回 false）

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
构造主菜单栏容器

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|子内容绘制闭包|

