# 类
## class UiTable
```cj
public class UiTable <: UiWidget
```
表格容器控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制表格容器

返回: 

- 表格是否可见

### func init\(String,Int32,Int32,Vector2,Float32,\(\)\->Unit\)
```cj
public init(id!: String, columns!: Int32 = 1, flags!: Int32 = 0, outerSize!: Vector2 = Vector2(0.0, 0.0), innerWidth!: Float32 = 0.0, content!:() -> Unit)
```
构造表格容器

参数: 

|名称|类型|描述|
|---|---|---|
|id|String|表格标识|
|columns|Int32|列数（默认 1）|
|flags|Int32|表格标志（默认 0）|
|outerSize|Vector2|外部尺寸（默认 0, 0）|
|innerWidth|Float32|内部宽度（默认 0.0）|
|content|()->Unit|内容绘制闭包|

