# 类
## class UiColorButton
```cj
public class UiColorButton <: UiWidget
```
颜色按钮控件（显示色块，可点击）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染颜色按钮

返回: 

- 本次是否被点击

### func init\(String,Float32,Float32,Float32,Float32,Int32,Float32,Float32\)
```cj
public init(desc: String, r: Float32, g: Float32, b: Float32, a!: Float32 = 1.0f32, flags!: Int32 = 0, w!: Float32 = 0.0f32, h!: Float32 = 0.0f32)
```
构造颜色按钮控件

参数: 

|名称|类型|描述|
|---|---|---|
|desc|String|按钮描述文本（ID 命名用）|
|r|Float32|红色分量（0.0~1.0）|
|g|Float32|绿色分量（0.0~1.0）|
|b|Float32|蓝色分量（0.0~1.0）|
|a|Float32|透明度分量（默认 1.0）|
|flags|Int32|ImGui 颜色按钮标志（默认 0）|
|w|Float32|按钮宽度（默认 0.0 表示自动）|
|h|Float32|按钮高度（默认 0.0 表示自动）|

