# 类
## class OrthographicCamera
```cj
public open class OrthographicCamera <: Camera
```
正交投影相机

### func clearViewOffset\(\)
```cj
public func clearViewOffset(): Unit
```
清除视口偏移

### func copy\(Object3D,Bool\)
```cj
public open override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定源相机的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 本实例

### func init\(Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public init(left!: Float64 = - 1.0, right!: Float64 = 1.0, top!: Float64 = 1.0, bottom!: Float64 = - 1.0, near!: Float64 = 0.1, far!: Float64 = 2000.0)
```
构造正交投影相机

参数: 

|名称|类型|描述|
|---|---|---|
|left|Float64|视锥左边界，默认 -1right 视锥右边界，默认 1top 视锥上边界，默认 1bottom 视锥下边界，默认 -1near 近裁剪面距离，默认 0.1far 远裁剪面距离，默认 2000|
|right|Float64||
|top|Float64||
|bottom|Float64||
|near|Float64||
|far|Float64||

### func setViewOffset\(Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func setViewOffset(fullWidth: Float64, fullHeight: Float64, x: Float64, y: Float64, width: Float64, height: Float64): Unit
```
设置视口偏移

参数: 

|名称|类型|描述|
|---|---|---|
|fullWidth|Float64|全视口宽度fullHeight 全视口高度x 视口偏移 Xy 视口偏移 Ywidth 视口宽度height 视口高度|
|fullHeight|Float64||
|x|Float64||
|y|Float64||
|width|Float64||
|height|Float64||

### func updateProjectionMatrix\(\)
```cj
public func updateProjectionMatrix(): Unit
```
更新投影矩阵

### var bottom
```cj
public var bottom: Float64
```
视锥下边界

### var left
```cj
public var left: Float64
```
视锥左边界

### var right
```cj
public var right: Float64
```
视锥右边界

### var top
```cj
public var top: Float64
```
视锥上边界

### var view
```cj
public var view: Option < CameraView >
```
多视口裁剪配置（VR/多显示器），用具体类型 CameraView 以满足 fastjson 宏约束

### var zoom
```cj
public var zoom: Float64
```
缩放因子

