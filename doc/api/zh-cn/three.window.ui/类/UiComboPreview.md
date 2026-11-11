# 类
## class UiComboPreview
```cj
public class UiComboPreview <: UiWidget
```
Combo 下拉预览区控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染 Combo 预览区（BeginComboPreview/EndComboPreview 包裹内容）

返回: 

- 预览区是否可用（仅当处于 Combo 内部时为 true）

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
构造 Combo 预览区

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|预览内容渲染回调|

