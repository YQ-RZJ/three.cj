# 类
## class UiItemQuery
```cj
public class UiItemQuery
```
控件状态查询——在 draw() 之后调用，获取交互状态

### func getItemID\(\)
```cj
public static func getItemID(): UInt32
```
获取上一个控件的 ID

返回: 

- 控件 ID

### func getItemRectMax\(\)
```cj
public static func getItemRectMax(): Vector2
```
获取上一个控件的矩形最大点

返回: 

- 矩形最大点

### func getItemRectMin\(\)
```cj
public static func getItemRectMin(): Vector2
```
获取上一个控件的矩形最小点

返回: 

- 矩形最小点

### func getItemRectSize\(\)
```cj
public static func getItemRectSize(): Vector2
```
获取上一个控件的尺寸

返回: 

- 控件尺寸

### func isAnyItemActive\(\)
```cj
public static func isAnyItemActive(): Bool
```
任一控件是否激活

返回: 

- 是否有任一控件激活

### func isAnyItemFocused\(\)
```cj
public static func isAnyItemFocused(): Bool
```
任一控件是否获得焦点

返回: 

- 是否有任一控件获得焦点

### func isAnyItemHovered\(\)
```cj
public static func isAnyItemHovered(): Bool
```
任一控件是否悬停

返回: 

- 是否有任一控件悬停

### func isItemActivated\(\)
```cj
public static func isItemActivated(): Bool
```
上一个控件是否被激活

返回: 

- 是否被激活

### func isItemActive\(\)
```cj
public static func isItemActive(): Bool
```
上一个控件是否激活（被点击/拖动）

返回: 

- 是否激活

### func isItemClicked\(Int32\)
```cj
public static func isItemClicked(mouseButton!: Int32 = 0): Bool
```
上一个控件是否被点击

参数: 

|名称|类型|描述|
|---|---|---|
|mouseButton|Int32|鼠标按钮（0=左 1=右 2=中，默认 0）|

返回: 

- 是否被点击

### func isItemDeactivatedAfterEdit\(\)
```cj
public static func isItemDeactivatedAfterEdit(): Bool
```
上一个控件是否在编辑后被停用

返回: 

- 是否在编辑后被停用

### func isItemDeactivated\(\)
```cj
public static func isItemDeactivated(): Bool
```
上一个控件是否被停用

返回: 

- 是否被停用

### func isItemEdited\(\)
```cj
public static func isItemEdited(): Bool
```
上一个控件是否被编辑

返回: 

- 是否被编辑

### func isItemFocused\(\)
```cj
public static func isItemFocused(): Bool
```
上一个控件是否获得焦点

返回: 

- 是否获得焦点

### func isItemHovered\(Int32\)
```cj
public static func isItemHovered(flags!: Int32 = 0): Bool
```
上一个控件是否悬停

参数: 

|名称|类型|描述|
|---|---|---|
|flags|Int32|ImGui 悬停标志（默认 0）|

返回: 

- 是否悬停

### func isItemToggledOpen\(\)
```cj
public static func isItemToggledOpen(): Bool
```
上一个控件是否被切换展开/折叠

返回: 

- 是否被切换展开/折叠

### func isItemVisible\(\)
```cj
public static func isItemVisible(): Bool
```
上一个控件是否可见

返回: 

- 是否可见

### func popID\(\)
```cj
public static func popID(): Unit
```
弹出 ID

### func pushIDInt\(Int32\)
```cj
public static func pushIDInt(intID: Int32): Unit
```
压入整数 ID

参数: 

|名称|类型|描述|
|---|---|---|
|intID|Int32|要压入的整数 ID|

### func pushID\(String\)
```cj
public static func pushID(strID: String): Unit
```
压入字符串 ID

参数: 

|名称|类型|描述|
|---|---|---|
|strID|String|要压入的字符串 ID|

### func setItemDefaultFocus\(\)
```cj
public static func setItemDefaultFocus(): Unit
```
设置默认焦点到上一个控件

### func setKeyboardFocusHere\(Int32\)
```cj
public static func setKeyboardFocusHere(offset!: Int32 = 0): Unit
```
将键盘焦点设置到下一个控件

参数: 

|名称|类型|描述|
|---|---|---|
|offset|Int32|偏移量（0=下一个，-1=上一个）|

### func setNextItemAllowOverlap\(\)
```cj
public static func setNextItemAllowOverlap(): Unit
```
设置下一个控件允许重叠

