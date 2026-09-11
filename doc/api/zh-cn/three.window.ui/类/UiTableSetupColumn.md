# 类
## class UiTableSetupColumn
```cj
public class UiTableSetupColumn <: UiWidget
```
表格列设置控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制列设置

返回: 

- 是否完成绘制

### func init\(String,Int32,Float32,UInt32\)
```cj
public init(label!: String, flags!: Int32 = 0, initWidthOrWeight!: Float32 = 0.0, userId!: UInt32 = 0)
```
构造表格列设置

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|列标签|
|flags|Int32|列标志（默认 0）|
|initWidthOrWeight|Float32|初始宽度或权重（默认 0.0）|
|userId|UInt32|用户自定义 ID（默认 0）|

