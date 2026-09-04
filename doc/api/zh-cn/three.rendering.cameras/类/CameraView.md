# 类
## class CameraView
```cj
public class CameraView
```
相机多视口裁剪配置

### func clone\(\)
```cj
public func clone(): CameraView
```
深拷贝

返回: 

- 新的 CameraView 实例

### func init\(Bool,Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public init(enabled: Bool, fullWidth: Float64, fullHeight: Float64, offsetX: Float64, offsetY: Float64, width: Float64, height: Float64)
```
构造相机视口配置

参数: 

|名称|类型|描述|
|---|---|---|
|enabled|Bool|是否启用fullWidth 全视口宽度fullHeight 全视口高度offsetX 视口偏移 XoffsetY 视口偏移 Ywidth 视口宽度height 视口高度|
|fullWidth|Float64||
|fullHeight|Float64||
|offsetX|Float64||
|offsetY|Float64||
|width|Float64||
|height|Float64||

### func init\(\)
```cj
public init()
```
无参构造（供 fastjson 反序列化使用）

### func toHashMap\(\)
```cj
public func toHashMap(): HashMap < String, Any >
```
转换为 HashMap（供手写 toJSON 兼容层输出 three.js view 对象结构）

返回: 

- 视口配置 HashMap

### var enabled
```cj
public var enabled: Bool
```
视口裁剪是否启用

### var fullHeight
```cj
public var fullHeight: Float64
```
全视口高度（像素）

### var fullWidth
```cj
public var fullWidth: Float64
```
全视口宽度（像素）

### var height
```cj
public var height: Float64
```
视口高度（像素）

### var offsetX
```cj
public var offsetX: Float64
```
视口偏移 X（像素）

### var offsetY
```cj
public var offsetY: Float64
```
视口偏移 Y（像素）

### var width
```cj
public var width: Float64
```
视口宽度（像素）

