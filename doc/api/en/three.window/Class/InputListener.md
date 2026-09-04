# Class
## class InputListener
```cj
public open class InputListener
```
Input listener base class

### func ==\(InputListener\)
```cj
public operator func ==(other: InputListener): Bool
```
Reference comparison (for precise removal via removeInputListener)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|InputListener|The listener to compare with|

Return: 

- Whether the two listeners refer to the same instance

### func init\(\)
```cj
public init()
```
Constructs a listener (automatically allocates a unique ID)

### func onKeyEvent\(KeyEvent\)
```cj
public open func onKeyEvent(evt: KeyEvent): Unit
```
Keyboard event callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|evt|KeyEvent|The keyboard event|

### func onMouseButton\(MouseButtonEvent\)
```cj
public open func onMouseButton(evt: MouseButtonEvent): Unit
```
Mouse button callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|evt|MouseButtonEvent|The mouse button event|

### func onMouseMotion\(MouseMotionEvent\)
```cj
public open func onMouseMotion(evt: MouseMotionEvent): Unit
```
Mouse motion callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|evt|MouseMotionEvent|The mouse motion event|

### func onMouseWheel\(MouseWheelEvent\)
```cj
public open func onMouseWheel(evt: MouseWheelEvent): Unit
```
Mouse wheel callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|evt|MouseWheelEvent|The mouse wheel event|

### func onTouchEvent\(TouchEvent\)
```cj
public open func onTouchEvent(evt: TouchEvent): Unit
```
Touch event callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|evt|TouchEvent|The touch event|

### func onWindowEvent\(WindowEvent\)
```cj
public open func onWindowEvent(evt: WindowEvent): Unit
```
Window event callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|evt|WindowEvent|The window event|

