# 类
## class PointLight
```cj
public class PointLight <: Light
```
从某点向各方向均匀照射的光源

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定点光源实例的值复制到本实例

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

### func init\(Color,Float64,Float64,Float64\)
```cj
public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0, distance!: Float64 = 0.0, decay!: Float64 = 2.0)
```
构造一个新的点光源

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|光源颜色，默认0xffffffintensity 光源强度，默认1distance 光线照射范围，默认0decay 物理衰减系数，默认2|
|intensity|Float64||
|distance|Float64||
|decay|Float64||

### prop power: Float64
```cj
public mut prop power: Float64
```
直接访问点光源功率（流明）

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

### var shadow
```cj
public var shadow: PointLightShadow
```
阴影配置对象

