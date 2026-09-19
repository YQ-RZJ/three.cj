# 类
## class UiBullet
```cj
public class UiBullet <: UiWidget
```
项目符号控件（圆点 + 同行内容）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染项目符号及其后随内容

返回: 

- 控件交互结果，本控件恒为 false

### func init\(\)
```cj
public init()
```
构造项目符号控件

### func withContent\(\(\)\->Unit\)
```cj
public func withContent(content:() -> Unit): UiBullet
```
设置项目符号后随行的内容回调

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|内容渲染回调|

返回: 

- 返回自身（支持链式调用）

