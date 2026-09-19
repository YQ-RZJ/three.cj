# 类
## class UiTabItem
```cj
public class UiTabItem <: UiWidget
```
标签页控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制标签页

返回: 

- 是否发生交互（当前实现恒返回 false）

### func init\(String,\(\)\->Unit,Int32\)
```cj
public init(label!: String, content!:() -> Unit, flags!: Int32 = 0)
```
构造标签页（不绑定外部打开状态）

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签页标题|
|content|()->Unit|子内容绘制闭包|
|flags|Int32|标签页标志（默认 0）|

### func init\(String,PtrArray<Int32>,\(\)\->Unit,Int32\)
```cj
public init(label!: String, open!: PtrArray < Int32 >, content!:() -> Unit, flags!: Int32 = 0)
```
构造绑定外部打开状态的标签页

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签页标题|
|open|PtrArray<Int32>|外部打开状态指针（关闭时写入 0）|
|content|()->Unit|子内容绘制闭包|
|flags|Int32|标签页标志（默认 0）|

