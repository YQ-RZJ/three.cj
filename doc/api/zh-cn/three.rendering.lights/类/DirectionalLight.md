# 类
## class DirectionalLight
```cj
public class DirectionalLight <: Light
```
方向光，从特定方向平行照射场景的光源

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
复制另一个方向光实例的值到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 自身引用

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(Color,Float64\)
```cj
public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0)
```
构造一个新的方向光

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|光源颜色，默认 0xffffffintensity 光源强度，默认 1|
|intensity|Float64||

### var shadow
```cj
public var shadow: DirectionalLightShadow
```
阴影配置对象

### var target
```cj
public var target: Object3D
```
光源指向的目标对象

