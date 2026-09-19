# 类
## class UiMenu
```cj
public class UiMenu <: UiWidget
```
下拉菜单控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制下拉菜单

返回: 

- 是否发生交互（当前实现恒返回 false）

### func init\(String,Bool,\(\)\->Unit\)
```cj
public init(label!: String, enabled!: Bool = true, content!:() -> Unit)
```
构造下拉菜单

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|菜单标签|
|enabled|Bool|是否可用（默认 true）|
|content|()->Unit|子内容绘制闭包|

