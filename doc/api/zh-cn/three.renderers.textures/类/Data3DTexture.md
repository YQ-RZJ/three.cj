# 类
## class Data3DTexture
```cj
public open class Data3DTexture <: Texture
```
3D 数据纹理类

### func init\(Array<UInt8>,Int64,Int64,Int64\)
```cj
public init(data: Array < UInt8 >, width: Int64, height: Int64, depth: Int64)
```
构造一个新的 3D 数据纹理

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|像素数组width 纹理宽度（像素）height 纹理高度（像素）depth 层数量|
|width|Int64||
|height|Int64||
|depth|Int64||

### var wrapR
```cj
public var wrapR: Int64
```
沿 R 维（层维）的环绕模式，默认 ClampToEdgeWrapping

