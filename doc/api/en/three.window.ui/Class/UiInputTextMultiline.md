# Class
## class UiInputTextMultiline
```cj
public class UiInputTextMultiline <: UiWidget
```
Multiline text input widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the multiline text input

Return: 

- Whether the input text changed this frame

### func getText\(\)
```cj
public func getText(): String
```
Returns the input text

### func init\(String,UIntNative,Float32,Float32,Int32\)
```cj
public init(label!: String, bufSize!: UIntNative = UIntNative(1024), w!: Float32 = 0.0, h!: Float32 = 0.0, flags!: Int32 = 0)
```
Constructs a multiline text input widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Label text|
|bufSize|UIntNative|Buffer size in bytes, defaults to 1024|
|w|Float32|Width (0=auto)|
|h|Float32|Height (0=about 6 text lines)|
|flags|Int32|Input flags|

### func setText\(String\)
```cj
public func setText(text: String): Unit
```
Sets the input text

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String||

