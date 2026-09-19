# 类
## class UiGroup
```cj
public class UiGroup <: UiWidget
```
分组容器控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染分组容器（BeginGroup/EndGroup 包裹内容）

返回: 

- 控件交互结果，本控件恒为 false

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
构造分组容器

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|组内控件渲染回调|

