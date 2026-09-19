# 类
## class UiSetTabItemClosed
```cj
public class UiSetTabItemClosed <: UiWidget
```
关闭指定标签页控件

### func draw\(\)
```cj
public override func draw(): Bool
```
关闭指定标签页

返回: 

- 是否发生交互（当前实现恒返回 false）

### func init\(String\)
```cj
public init(tabOrWindowLabel: String)
```
构造关闭标签页控件

参数: 

|名称|类型|描述|
|---|---|---|
|tabOrWindowLabel|String|标签页或窗口标识|

