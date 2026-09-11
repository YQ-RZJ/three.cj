# 类
## class UiTableRow
```cj
public class UiTableRow <: UiWidget
```
表格行控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制表格行

返回: 

- 是否成功创建行

### func init\(\(\)\->Unit,Float32\)
```cj
public init(content!:() -> Unit, minRowHeight!: Float32 = 0.0)
```
构造表格行

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|行内容绘制闭包|
|minRowHeight|Float32|最小行高（默认 0.0）|

