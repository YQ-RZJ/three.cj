# 类
## class UiTextLink
```cj
public class UiTextLink <: UiWidget
```
可点击链接文本控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染链接文本

返回: 

- 链接本次是否被点击

### func init\(String\)
```cj
public init(label!: String)
```
构造可点击链接文本控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|链接文本|

### func openURL\(\)
```cj
public func openURL(): Unit
```
打开链接对应的 URL（调用系统默认浏览器）

