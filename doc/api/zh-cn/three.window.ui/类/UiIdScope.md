# 类
## class UiIdScope
```cj
public class UiIdScope <: UiWidget
```
ID 命名空间作用域控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染 ID 作用域内的控件（PushID/PopID 包裹内容）

返回: 

- 控件交互结果，本控件恒为 false

### func init\(String,\(\)\->Unit\)
```cj
public init(id!: String, content!:() -> Unit)
```
构造 ID 作用域

参数: 

|名称|类型|描述|
|---|---|---|
|id|String|命名空间标识|
|content|()->Unit|作用域内控件渲染回调|

