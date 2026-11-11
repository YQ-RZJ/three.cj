# 类
## class UiInvisibleButton
```cj
public class UiInvisibleButton <: UiWidget
```
透明命中区控件（InvisibleButton）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染透明命中区

返回: 

- 本次是否被点击

### func init\(String,Float32,Float32,Int32\)
```cj
public init(id!: String, w!: Float32, h!: Float32, flags!: Int32 = 0)
```
构造透明命中区

参数: 

|名称|类型|描述|
|---|---|---|
|id|String|命中区 ID|
|w|Float32|宽度|
|h|Float32|高度|
|flags|Int32|ImGuiButtonFlags|

