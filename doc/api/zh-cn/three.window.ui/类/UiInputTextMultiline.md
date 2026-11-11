# 类
## class UiInputTextMultiline
```cj
public class UiInputTextMultiline <: UiWidget
```
多行文本输入框控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染多行文本输入框

返回: 

- 本次输入内容是否发生变化

### func getText\(\)
```cj
public func getText(): String
```
获取输入文本

### func init\(String,UIntNative,Float32,Float32,Int32\)
```cj
public init(label!: String, bufSize!: UIntNative = UIntNative(1024), w!: Float32 = 0.0, h!: Float32 = 0.0, flags!: Int32 = 0)
```
构造多行文本输入框

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签|
|bufSize|UIntNative|缓冲区大小（字节），默认 1024|
|w|Float32|宽度（0=自动）|
|h|Float32|高度（0=约 6 行文本高度）|
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

