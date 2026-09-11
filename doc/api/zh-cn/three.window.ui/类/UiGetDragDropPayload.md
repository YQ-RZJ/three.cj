# 类
## class UiGetDragDropPayload
```cj
public class UiGetDragDropPayload <: UiWidget
```
获取拖放数据控件

### func draw\(\)
```cj
public override func draw(): Bool
```
获取当前拖拽数据

返回: 

- 是否存在有效拖拽数据

### func init\(String\)
```cj
public init(`type`!: String = "")
```
构造拖放数据获取控件

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|String|数据类型标识（默认空字符串）|

