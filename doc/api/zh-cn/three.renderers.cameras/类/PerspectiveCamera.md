# 类
## class PerspectiveCamera
```cj
public open class PerspectiveCamera <: Camera
```
透视投影相机

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

### func getEffectiveFOV\(\)
```cj
public func getEffectiveFOV(): Float64
```
获取考虑 zoom 后的有效视场角

返回: 

- 有效视场角（度）

### func getFilmHeight\(\)
```cj
public func getFilmHeight(): Float64
```
获取胶片高度

返回: 

- 胶片高度

### func getFilmWidth\(\)
```cj
public func getFilmWidth(): Float64
```
获取胶片宽度

返回: 

- 胶片宽度

### func getFocalLength\(\)
```cj
public func getFocalLength(): Float64
```
获取焦距

返回: 

- 焦距

### func getViewBounds\(Float64,Vector2,Vector2\)
```cj
public func getViewBounds(distance: Float64, minTarget: Vector2, maxTarget: Vector2): Unit
```
获取指定距离处的视图边界

参数: 

|名称|类型|描述|
|---|---|---|
|distance|Float64|距离minTarget 最小目标向量maxTarget 最大目标向量|
|minTarget|Vector2||
|maxTarget|Vector2||

### func getViewSize\(Float64,Vector2\)
```cj
public func getViewSize(distance: Float64, target: Vector2): Vector2
```
获取指定距离处的视图尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|distance|Float64|距离target 目标向量|
|target|Vector2||

返回: 

- 视图尺寸

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(fov!: Float64 = 50.0, aspect!: Float64 = 1.0, near!: Float64 = 0.1, far!: Float64 = 2000.0)
```
构造透视投影相机

参数: 

|名称|类型|描述|
|---|---|---|
|fov|Float64|垂直视场角（度），默认 50aspect 宽高比，默认 1near 近裁剪面距离，默认 0.1far 远裁剪面距离，默认 2000|
|aspect|Float64||
|near|Float64||
|far|Float64||

### func setFocalLength\(Float64\)
```cj
public func setFocalLength(focalLength: Float64): Unit
```
根据焦距设置视场角

参数: 

|名称|类型|描述|
|---|---|---|
|focalLength|Float64|焦距|

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

### var aspect
```cj
public var aspect: Float64
```
宽高比

### var filmGauge
```cj
public var filmGauge: Float64
```
胶片尺寸（毫米）

### var filmOffset
```cj
public var filmOffset: Float64
```
胶片偏移

### var focus
```cj
public var focus: Float64
```
焦距

### var fov
```cj
public var fov: Float64
```
垂直视场角（度）

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

