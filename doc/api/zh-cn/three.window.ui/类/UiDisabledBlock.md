# 类
## class UiDisabledBlock
```cj
public class UiDisabledBlock <: UiWidget
```
禁用状态容器

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染禁用容器（BeginDisabled/EndDisabled 包裹内容）

返回: 

- 控件交互结果，本控件恒为 false

### func init\(Bool,\(\)\->Unit\)
```cj
public init(disabled!: Bool = true, content!:() -> Unit)
```
构造禁用状态容器

参数: 

|名称|类型|描述|
|---|---|---|
|disabled|Bool|是否启用禁用状态，默认 true|
|content|()->Unit|容器内控件渲染回调|

