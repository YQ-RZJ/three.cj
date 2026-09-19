# 类
## class UiWidget
```cj
public open class UiWidget
```
ImGui 控件基类

### func draw\(\)
```cj
public open func draw(): Bool
```
渲染控件（子类重写）

返回: 

- 控件交互结果（点击/值变化等），具体含义由子类定义

### func getId\(\)
```cj
public func getId(): String
```
获取控件 ID

### func init\(\)
```cj
public init()
```
构造不带 ID 的控件

### func init\(String\)
```cj
public init(id!: String)
```
构造带 ID 的控件

参数: 

|名称|类型|描述|
|---|---|---|
|id|String|控件 ID（用于 ImGui PushID/PopID 命名空间隔离）|

