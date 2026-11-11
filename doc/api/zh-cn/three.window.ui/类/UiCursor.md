# 类
## class UiCursor
```cj
public class UiCursor
```
光标定位、内容区查询、ID 栈与行高度量（全静态）

### func getContentRegionAvail\(\)
```cj
public static func getContentRegionAvail(): Vector2
```
获取当前内容区剩余可用空间（从光标处到内容区右下角）

返回: 

- 可用尺寸（逻辑像素；自适应尺寸控件的依据）

### func getCursorPos\(\)
```cj
public static func getCursorPos(): Vector2
```
获取窗口内容区内的光标位置（窗口相对坐标）

返回: 

- 窗口相对坐标（逻辑像素）

### func getCursorScreenPos\(\)
```cj
public static func getCursorScreenPos(): Vector2
```
获取下个控件将放置的屏幕坐标（窗口内容区左上 + 光标偏移）

返回: 

- 屏幕坐标（逻辑像素）

### func getFrameHeightWithSpacing\(\)
```cj
public static func getFrameHeightWithSpacing(): Float32
```
标准控件帧高度 + 垂直间距

返回: 

- 含间距的帧高度（逻辑像素）

### func getFrameHeight\(\)
```cj
public static func getFrameHeight(): Float32
```
标准控件帧高度（按钮/输入框等的默认高度）

返回: 

- 帧高度（逻辑像素；自绘控件与之对齐可保持视觉一致）

### func getTextLineHeightWithSpacing\(\)
```cj
public static func getTextLineHeightWithSpacing(): Float32
```
文本行高 + 垂直间距（ItemSpacing.y）

返回: 

- 含间距的行高（逻辑像素）

### func getTextLineHeight\(\)
```cj
public static func getTextLineHeight(): Float32
```
文本行高（FontSize + 少量余量）

返回: 

- 行高（逻辑像素）

### func popId\(\)
```cj
public static func popId(): Unit
```
弹出 ID 命名空间（与 pushId/pushIdInt 配对）

### func pushIdInt\(Int32\)
```cj
public static func pushIdInt(id: Int32): Unit
```
压入整数 ID 命名空间（与 popId 配对；循环内多用索引）

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int32|整数标识（如循环索引）|

### func pushId\(String\)
```cj
public static func pushId(id: String): Unit
```
压入字符串 ID 命名空间（与 popId 配对）

参数: 

|名称|类型|描述|
|---|---|---|
|id|String|命名空间标识|

### func setCursorPos\(Vector2\)
```cj
public static func setCursorPos(pos: Vector2): Unit
```
设置窗口内容区内的光标位置（窗口相对坐标）

参数: 

|名称|类型|描述|
|---|---|---|
|pos|Vector2|窗口相对坐标（逻辑像素）|

### func setCursorScreenPos\(Vector2\)
```cj
public static func setCursorScreenPos(pos: Vector2): Unit
```
设置下个控件的屏幕坐标（自由布局/overlay 绘制的落点）

参数: 

|名称|类型|描述|
|---|---|---|
|pos|Vector2|屏幕坐标（逻辑像素）|

