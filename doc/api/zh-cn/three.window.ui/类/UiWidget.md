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


### func init\(String\)
```cj
public init(id!: String)
```


参数: 

|名称|类型|描述|
|---|---|---|
|id|String||

