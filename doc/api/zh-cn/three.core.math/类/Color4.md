# 类
## class Color4
```cj
public class Color4 <: Color
```
带透明度分量的颜色类（RGBA，分量范围 [0, 1]）

### func clone4\(\)
```cj
public func clone4(): Color4
```
克隆（保留 alpha 分量）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>基类 clone() 返回 Color（丢失 alpha），需要保留 alpha 时请用本方法。</p>

返回: 

- 新的 Color4 实例

### func copy4\(Color4\)
```cj
public func copy4(c: Color4): Color4
```
从另一个 Color4 拷贝 RGBA

参数: 

|名称|类型|描述|
|---|---|---|
|c|Color4|源颜色|

返回: 

- 当前实例

### func init\(Color,Float64\)
```cj
public init(color: Color, a!: Float64 = 1.0)
```
从已有 Color 拷贝 RGB 并指定透明度

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|源颜色（提供 r/g/b）a 透明度分量（默认 1.0）|
|a|Float64||

### func init\(\)
```cj
public init()
```
构造白色不透明颜色

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(r: Float64, g: Float64, b: Float64, a!: Float64 = 1.0)
```
从 RGBA 分量构造

参数: 

|名称|类型|描述|
|---|---|---|
|r|Float64|红色分量g 绿色分量b 蓝色分量a 透明度分量（默认 1.0）|
|g|Float64||
|b|Float64||
|a|Float64||

### func init\(UInt32,Float64\)
```cj
public init(hex: UInt32, a!: Float64 = 1.0)
```
从十六进制值构造（0xRRGGBB，SRGB 输入自动转到工作颜色空间）

参数: 

|名称|类型|描述|
|---|---|---|
|hex|UInt32|颜色十六进制值a 透明度分量（默认 1.0）|
|a|Float64||

### func setAlpha\(Float64\)
```cj
public func setAlpha(a: Float64): Color4
```
设置透明度分量

参数: 

|名称|类型|描述|
|---|---|---|
|a|Float64|透明度分量（[0, 1]）|

返回: 

- 当前实例（链式调用）

### var a
```cj
public var a: Float64
```
透明度分量（[0, 1]；0=全透明，1=不透明）

