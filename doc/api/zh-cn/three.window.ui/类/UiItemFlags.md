# 类
## class UiItemFlags
```cj
public class UiItemFlags <: UiWidget
```
项级开关容器（PushItemFlag/PopItemFlag 包裹内容）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染项级开关容器

返回: 

- 控件交互结果，本控件恒为 false

### func init\(Int32,Bool,\(\)\->Unit\)
```cj
public init(option!: Int32, enabled!: Bool, content!:() -> Unit)
```
构造项级开关容器

参数: 

|名称|类型|描述|
|---|---|---|
|option|Int32|ImGuiItemFlags 选项|
|enabled|Bool|是否启用|
|content|()->Unit|容器内控件渲染回调|

