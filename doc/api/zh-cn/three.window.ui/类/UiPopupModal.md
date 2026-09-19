# 类
## class UiPopupModal
```cj
public class UiPopupModal <: UiWidget
```
模态弹出窗口控件（阻塞交互）

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制模态弹出窗口

返回: 

- 是否发生交互（当前实现恒返回 false）

### func init\(String,\(\)\->Unit,Int32\)
```cj
public init(name!: String, content!:() -> Unit, flags!: Int32 = 0)
```
构造模态弹出窗口（不绑定外部打开状态）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|窗口名称|
|content|()->Unit|子内容绘制闭包|
|flags|Int32|模态窗口标志（默认 0）|

### func init\(String,PtrArray<Int32>,\(\)\->Unit,Int32\)
```cj
public init(name!: String, open!: PtrArray < Int32 >, content!:() -> Unit, flags!: Int32 = 0)
```
构造绑定外部打开状态的模态弹出窗口

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|窗口名称|
|open|PtrArray<Int32>|外部打开状态指针（点击关闭按钮时写入 0）|
|content|()->Unit|子内容绘制闭包|
|flags|Int32|模态窗口标志（默认 0）|

