# 类
## class HemisphereLight
```cj
public class HemisphereLight <: Light
```
半球光，从天顶与地底两方向照射的光源

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
复制另一个半球光实例的值到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 自身引用

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 GPU 资源

### func init\(Color,Color,Float64\)
```cj
public init(skyColor!: Color = Color(0xffffff), groundColor!: Color = Color(0x000000), intensity!: Float64 = 1.0)
```
构造一个新的半球光

参数: 

|名称|类型|描述|
|---|---|---|
|skyColor|Color|顶部方向光的颜色，默认 0xffffffgroundColor 底部方向光的颜色，默认 0x000000intensity 光源强度，默认 1|
|groundColor|Color||
|intensity|Float64||

### var groundColor
```cj
public var groundColor: Color
```
底部（地底）方向光的颜色

### var skyColor
```cj
public var skyColor: Color
```
顶部（天顶）方向光的颜色

