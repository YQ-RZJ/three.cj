# 类
## class UiImage
```cj
public class UiImage <: UiWidget
```
图片显示控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染图片

返回: 

- 恒为 false（无交互）

### func init\(UInt64,Vector2\)
```cj
public init(texId!: UInt64, size!: Vector2 = Vector2(64.0, 64.0))
```
构造图片显示控件

参数: 

|名称|类型|描述|
|---|---|---|
|texId|UInt64|纹理 ID（bgfx 纹理句柄值）|
|size|Vector2|图片显示尺寸（默认 64x64）|

