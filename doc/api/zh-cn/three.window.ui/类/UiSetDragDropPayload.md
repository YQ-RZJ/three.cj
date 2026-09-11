# 类
## class UiSetDragDropPayload
```cj
public class UiSetDragDropPayload <: UiWidget
```
设置拖放数据控件

### func draw\(\)
```cj
public override func draw(): Bool
```
设置当前拖拽数据

返回: 

- 是否设置成功

### func init\(String,Int32\)
```cj
public init(`type`!: String, flags!: Int32 = 0)
```
构造拖放数据设置控件

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|String|数据类型标识|
|flags|Int32|拖放标志（默认 0）|

