# 类
## class UiInputText
```cj
public class UiInputText <: UiWidget
```
文本输入框控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染文本输入框

返回: 

- 本次输入内容是否发生变化

### func getText\(\)
```cj
public func getText(): String
```
获取输入文本

### func init\(String,UIntNative,String,Int32\)
```cj
public init(label!: String, bufSize!: UIntNative = UIntNative(256), hint!: String = "", flags!: Int32 = 0)
```
构造文本输入框

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签|
|bufSize|UIntNative|缓冲区大小（字节），默认 256|
|hint|String|占位提示文本|
|flags|Int32|输入标志|

### func setText\(String\)
```cj
public func setText(text: String): Unit
```
设置输入文本

参数: 

|名称|类型|描述|
|---|---|---|
|text|String||

