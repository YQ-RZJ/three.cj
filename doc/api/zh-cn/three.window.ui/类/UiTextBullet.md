# 类
## class UiTextBullet
```cj
public class UiTextBullet <: UiWidget
```
圆点文本控件（BulletText）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染圆点文本

返回: 

- 恒为 false（该控件不返回交互状态）

### func init\(String\)
```cj
public init(text!: String)
```
构造圆点文本控件

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|文本内容|

