# Class
## class UiChildWindow
```cj
public class UiChildWindow
```
Child window widget (class form of BeginChild/EndChild)

### func begin\(\)
```cj
public func begin(): Bool
```
Begins the child window (ImGui BeginChild)

Return: 

- Whether the child window is visible

### func create\(String,Float32,Float32\)
```cj
public static func create(id: String, w!: Float32 = 0.0, h!: Float32 = 0.0): UiChildWindow
```
Creates a child window

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|String|Child window ID|
|w|Float32|Width|
|h|Float32|Height|

Return: 

- Child window instance

### func draw\(\(\)\->Unit\)
```cj
public func draw(content:() -> Unit): Bool
```
Automatically manages begin/end with a closure

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Render callback for widgets inside the child window|

Return: 

- Whether the child window is visible

### func end\(\)
```cj
public func end(): Unit
```
Ends the child window (ImGui EndChild)

### func init\(String,Float32,Float32,Int32,Int32\)
```cj
public init(id!: String, w!: Float32 = 0.0, h!: Float32 = 0.0, childFlags!: Int32 = 0, windowFlags!: Int32 = 0)
```
Constructs a child window

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|String|Child window ID (unique within the parent window)|
|w|Float32|Width (0=remaining width)|
|h|Float32|Height (0=remaining height)|
|childFlags|Int32|ImGuiChildFlags|
|windowFlags|Int32|ImGuiWindowFlags|

