# 类
## class UiImageButton
```cj
public class UiImageButton <: UiWidget
```
图片按钮控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染图片按钮

返回: 

- 本次是否被点击

### func init\(String,UInt64,Vector2\)
```cj
public init(strId!: String, texId!: UInt64, size!: Vector2 = Vector2(64.0, 64.0))
```
构造图片按钮控件

参数: 

|名称|类型|描述|
|---|---|---|
|strId|String|按钮字符串 ID（ImGui ID 命名用）|
|texId|UInt64|纹理 ID（bgfx 纹理句柄值）|
|size|Vector2|按钮显示尺寸（默认 64x64）|

