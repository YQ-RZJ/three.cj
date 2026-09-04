# 类
## class Scene
```cj
public class Scene <: Object3D & IScene
```
场景，场景图根节点

### func clone\(\)
```cj
public override func clone(): Object3D
```
返回一个与本实例值相同的新场景实例

返回: 

- 新场景实例

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定场景实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 返回 this

### func init\(\)
```cj
public init()
```
构造一个新的场景

### prop backgroundJson: String
```cj
public open mut prop backgroundJson: String
```


### prop environmentJson: String
```cj
public open mut prop environmentJson: String
```


### prop fogExp2Json: String
```cj
public open mut prop fogExp2Json: String
```


### prop fogJson: String
```cj
public open mut prop fogJson: String
```


### prop overrideMaterialJson: String
```cj
public open mut prop overrideMaterialJson: String
```


### var backgroundBlurriness
```cj
public var backgroundBlurriness: Float64
```
背景模糊度（0=清晰，1=完全模糊），默认 0

### var backgroundIntensity
```cj
public var backgroundIntensity: Float64
```
背景强度（乘法因子），默认 1

### var backgroundRotation
```cj
public var backgroundRotation: Euler
```
背景旋转（Euler 角度），默认 Identity

### var background
```cj
public var background: Option < IBackground >
```
背景：Some(Color)/Some(Texture)/Some(CubeTexture) 或 None（无背景），默认 None

### var environmentIntensity
```cj
public var environmentIntensity: Float64
```
环境贴图强度，默认 1

### var environmentNode
```cj
public var environmentNode: Option < Any >
```
环境节点（运行时由 NodeManager 注入），渲染器用该节点替代 scene.environment 计算环境光照

### var environmentRotation
```cj
public var environmentRotation: Euler
```
环境贴图旋转，默认 Identity

### var environment
```cj
public var environment: Option < Texture >
```
环境贴图（Texture/CubeTexture），默认 None

### var fogExp2
```cj
public var fogExp2: Option < FogExp2 >
```
雾（指数雾，与 fog 互斥）

### var fog
```cj
public var fog: Option < Fog >
```
雾（线性雾）

### var overrideMaterial
```cj
public var overrideMaterial: Option < Material >
```
覆盖材质（所有场景物体的材质被替换为此材质），默认 None

