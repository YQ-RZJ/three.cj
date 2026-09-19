# 类
## class UiSetNextItemOpen
```cj
public class UiSetNextItemOpen <: UiWidget
```
设置下一个树节点打开状态

### func draw\(\)
```cj
public override func draw(): Bool
```
设置下一个树节点的打开状态

返回: 

- 恒为 false（无交互）

### func init\(Bool,Int32\)
```cj
public init(isOpen!: Bool = true, cond!: Int32 = 0)
```
构造树节点状态设置控件

参数: 

|名称|类型|描述|
|---|---|---|
|isOpen|Bool|下一个树节点是否打开（默认 true）|
|cond|Int32|生效条件（ImGui 条件枚举值，默认 0 表示总是生效）|

