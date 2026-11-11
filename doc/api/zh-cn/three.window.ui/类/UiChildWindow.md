# 类
## class UiChildWindow
```cj
public class UiChildWindow
```
子窗口控件（BeginChild/EndChild 的类形式）

### func begin\(\)
```cj
public func begin(): Bool
```
开始子窗口（ImGui BeginChild）

返回: 

- 子窗口是否可见

### func create\(String,Float32,Float32\)
```cj
public static func create(id: String, w!: Float32 = 0.0, h!: Float32 = 0.0): UiChildWindow
```
创建子窗口

参数: 

|名称|类型|描述|
|---|---|---|
|id|String|子窗口 ID|
|w|Float32|宽度|
|h|Float32|高度|

返回: 

- 子窗口实例

### func draw\(\(\)\->Unit\)
```cj
public func draw(content:() -> Unit): Bool
```
使用闭包自动管理 begin/end

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|子窗口内控件渲染回调|

返回: 

- 子窗口是否可见

### func end\(\)
```cj
public func end(): Unit
```
结束子窗口（ImGui EndChild）

### func init\(String,Float32,Float32,Int32,Int32\)
```cj
public init(id!: String, w!: Float32 = 0.0, h!: Float32 = 0.0, childFlags!: Int32 = 0, windowFlags!: Int32 = 0)
```
构造子窗口

参数: 

|名称|类型|描述|
|---|---|---|
|id|String|子窗口 ID（同一父窗口内需唯一）|
|w|Float32|宽度（0=使用剩余宽度）|
|h|Float32|高度（0=使用剩余高度）|
|childFlags|Int32|ImGuiChildFlags|
|windowFlags|Int32|ImGuiWindowFlags|

