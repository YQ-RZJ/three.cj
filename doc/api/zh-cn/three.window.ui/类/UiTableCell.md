# 类
## class UiTableCell
```cj
public class UiTableCell <: UiWidget
```
表格单元格控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制表格单元格

返回: 

- 是否完成绘制

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
构造表格单元格

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|单元格内容绘制闭包|

