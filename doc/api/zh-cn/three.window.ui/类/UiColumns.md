# 类
## class UiColumns
```cj
public class UiColumns <: UiWidget
```
列布局容器

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染列布局（开始列组、渲染内容、结束列组）

返回: 

- 控件交互结果，本控件恒为 false

### func init\(Int32,String,Bool,\(\)\->Unit\)
```cj
public init(count!: Int32 = 2, id!: String = "", border!: Bool = false, content!:() -> Unit)
```
构造列布局容器

参数: 

|名称|类型|描述|
|---|---|---|
|count|Int32|列数，默认 2|
|id|String|列组标识（用于区分多个列组），默认空字符串|
|border|Bool|是否绘制列分隔边框，默认 false|
|content|()->Unit|列内控件渲染回调|

