# 类
## class UiMenuItem
```cj
public class UiMenuItem <: UiWidget
```
菜单项控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制菜单项

返回: 

- 菜单项是否被点击

### func init\(String,String,Bool,Bool\)
```cj
public init(label!: String, shortcut!: String = "", selected!: Bool = false, enabled!: Bool = true)
```
构造菜单项

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|菜单项标签|
|shortcut|String|快捷键提示文本（默认空字符串）|
|selected|Bool|是否选中（默认 false）|
|enabled|Bool|是否可用（默认 true）|

### func onClick\(\(\)\->Unit\)
```cj
public func onClick(callback:() -> Unit): UiMenuItem
```
设置点击回调

参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->Unit|点击时调用的回调函数|

返回: 

- 当前实例，支持链式调用

