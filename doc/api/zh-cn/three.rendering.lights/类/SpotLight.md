# 类
## class SpotLight
```cj
public open class SpotLight <: Light
```
从某点沿某方向以圆锥形照射的光源

### func copy\(Object3D,Bool\)
```cj
public open override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定聚光源实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 本实例

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放本实例分配的GPU相关资源，当实例不再使用时应调用

### func init\(Color,Float64,Float64,Float64,Float64,Float64\)
```cj
public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0, distance!: Float64 = 0.0, angle!: Float64 = PI / 3.0, penumbra!: Float64 = 0.0, decay!: Float64 = 2.0)
```
构造一个新的聚光源

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|光源颜色，默认0xffffffintensity 光源强度，默认1distance 光线照射范围，默认0angle 圆锥顶点角度（弧度），默认π/3penumbra 半影区大小，默认0decay 物理衰减系数，默认2|
|intensity|Float64||
|distance|Float64||
|angle|Float64||
|penumbra|Float64||
|decay|Float64||

### prop power: Float64
```cj
public mut prop power: Float64
```
直接访问聚光源功率（流明）

### var angle
```cj
public var angle: Float64
```
圆锥顶点处的角度（弧度），范围[0, π/2]，默认π/3

### var decay
```cj
public var decay: Float64
```
沿光线方向的物理衰减系数，1=稳定，2=真实世界，默认2

### var distance
```cj
public var distance: Float64
```
光线照射范围，0表示不衰减，默认0

### var map
```cj
public var map: Option < Texture >
```
调制聚光灯光的贴图，默认null

### var penumbra
```cj
public var penumbra: Float64
```
半影区大小，0=硬边圆锥，1=完全软边，默认0

### var shadow
```cj
public var shadow: SpotLightShadow
```
阴影配置对象

### var target
```cj
public var target: Object3D
```
光源指向的目标对象，影响光照方向

