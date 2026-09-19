# 类
## class UiText
```cj
public class UiText <: UiWidget
```
文本显示控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染文本

返回: 

- 恒为 false（文本无交互）

### func getText\(\)
```cj
public func getText(): String
```
获取显示文本

### func init\(String\)
```cj
public init(text!: String)
```
构造文本显示控件

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|要显示的文本|

### func setText\(String\)
```cj
public func setText(text: String): Unit
```
设置显示文本

参数: 

|名称|类型|描述|
|---|---|---|
|text|String||

