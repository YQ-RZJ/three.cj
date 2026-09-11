# 类
## class UiAcceptDragDropPayload
```cj
public class UiAcceptDragDropPayload <: UiWidget
```
接受拖放数据控件

### func draw\(\)
```cj
public override func draw(): Bool
```
尝试接受拖放数据

返回: 

- 是否成功接受数据

### func init\(String,Int32\)
```cj
public init(`type`!: String, flags!: Int32 = 0)
```
构造拖放数据接受控件

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|String|期望的数据类型标识|
|flags|Int32|接受标志（默认 0）|

### func onAccept\(\(\)\->Unit\)
```cj
public func onAccept(callback:() -> Unit): UiAcceptDragDropPayload
```
设置接受成功时的回调

参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->Unit|回调函数|

返回: 

- 当前实例，支持链式调用

