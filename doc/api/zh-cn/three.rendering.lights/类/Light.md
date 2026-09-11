# 类
## class Light
```cj
public open class Light <: Object3D
```
光源抽象基类，所有具体光源类型继承本类

### func copy\(Object3D,Bool\)
```cj
public open func copy(source: Object3D, recursive: Bool): Object3D
```
复制另一个光源实例的值到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 自身引用

### func dispose\(\)
```cj
public open func dispose(): Unit
```
释放 GPU 资源

### func init\(UInt32,Float64\)
```cj
public init(hex: UInt32, intensity!: Float64 = 1.0)
```
构造一个新的光源（以 UInt32 颜色值构造）

参数: 

|名称|类型|描述|
|---|---|---|
|hex|UInt32|颜色十六进制值intensity 光源强度，默认 1|
|intensity|Float64||

### func init\(Color,Float64\)
```cj
public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0)
```
构造一个新的光源

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|光源颜色，默认 0xffffffintensity 光源强度，默认 1|
|intensity|Float64||

### var color
```cj
public var color: Color
```
光源颜色

### var intensity
```cj
public var intensity: Float64
```
光源强度，默认 1

