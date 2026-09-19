# 类
## class UiDisabled
```cj
public class UiDisabled <: UiWidget
```
禁用状态容器

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染容器：内部控件按禁用状态执行

返回: 

- 恒为 false（无交互）

### func init\(Bool,\(\)\->Unit\)
```cj
public init(disabled!: Bool = true, content!:() -> Unit)
```
构造禁用状态容器

参数: 

|名称|类型|描述|
|---|---|---|
|disabled|Bool|是否禁用内部控件（默认 true）|
|content|()->Unit|容器内容闭包|

