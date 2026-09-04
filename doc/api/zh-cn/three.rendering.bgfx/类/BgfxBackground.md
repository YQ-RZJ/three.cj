# 类
## class BgfxBackground
```cj
public class BgfxBackground
```
bgfx 背景渲染

### func init\(\)
```cj
public init()
```


### func render\(ViewId,Float32,Float32,Float32,Float32,Bool\)
```cj
public func render(viewId: ViewId, r: Float32, g: Float32, b: Float32, a: Float32, forceClear: Bool): Unit
```
渲染背景

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|ViewId|bgfx 视图 IDr 背景颜色 R 分量 (0-1)g 背景颜色 G 分量 (0-1)b 背景颜色 B 分量 (0-1)a 背景颜色 A 分量 (0-1)forceClear 是否强制清除|
|r|Float32||
|g|Float32||
|b|Float32||
|a|Float32||
|forceClear|Bool||

