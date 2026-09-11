# Class
## class UiInputText
```cj
public class UiInputText <: UiWidget
```
Text input widget

### func draw\(\)
```cj
public override func draw(): Bool
```


### func getBufPtr\(\)
```cj
public func getBufPtr(): CPointer < Int8 >
```
获取缓冲区指针（高级用法）

### func getText\(\)
```cj
public func getText(): String
```
Returns the input text

### func init\(String,UIntNative,String,Int32\)
```cj
public init(label!: String, bufSize!: UIntNative = UIntNative(256), hint!: String = "", flags!: Int32 = 0)
```
Constructs a text input widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Label text|
|bufSize|UIntNative|Buffer size in bytes, defaults to 256|
|hint|String|Placeholder hint text|
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

