# 类
## class InputListener
```cj
public open class InputListener
```
输入监听器基类

### func ==\(InputListener\)
```cj
public operator func ==(other: InputListener): Bool
```
引用比较（用于 removeInputListener 精确移除）

参数: 

|名称|类型|描述|
|---|---|---|
|other|InputListener|与之比较的监听器|

返回: 

- 两个监听器是否引用同一实例

### func init\(\)
```cj
public init()
```
构造监听器（自动分配唯一 ID）

### func onKeyEvent\(KeyEvent\)
```cj
public open func onKeyEvent(evt: KeyEvent): Unit
```
键盘事件回调

参数: 

|名称|类型|描述|
|---|---|---|
|evt|KeyEvent|键盘事件|

### func onMouseButton\(MouseButtonEvent\)
```cj
public open func onMouseButton(evt: MouseButtonEvent): Unit
```
鼠标按键回调

参数: 

|名称|类型|描述|
|---|---|---|
|evt|MouseButtonEvent|鼠标按键事件|

### func onMouseMotion\(MouseMotionEvent\)
```cj
public open func onMouseMotion(evt: MouseMotionEvent): Unit
```
鼠标移动回调

参数: 

|名称|类型|描述|
|---|---|---|
|evt|MouseMotionEvent|鼠标移动事件|

### func onMouseWheel\(MouseWheelEvent\)
```cj
public open func onMouseWheel(evt: MouseWheelEvent): Unit
```
鼠标滚轮回调

参数: 

|名称|类型|描述|
|---|---|---|
|evt|MouseWheelEvent|鼠标滚轮事件|

### func onTouchEvent\(TouchEvent\)
```cj
public open func onTouchEvent(evt: TouchEvent): Unit
```
触摸事件回调

参数: 

|名称|类型|描述|
|---|---|---|
|evt|TouchEvent|触摸事件|

### func onWindowEvent\(WindowEvent\)
```cj
public open func onWindowEvent(evt: WindowEvent): Unit
```
窗口事件回调

参数: 

|名称|类型|描述|
|---|---|---|
|evt|WindowEvent|窗口事件|

