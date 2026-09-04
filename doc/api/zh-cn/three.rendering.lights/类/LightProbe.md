# 类
## class LightProbe
```cj
public class LightProbe <: Light
```
光照探针，用球面调和描述场景光照环境的光源

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
复制另一个光照探针实例的值到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 自身引用

### func init\(SphericalHarmonics3,Float64\)
```cj
public init(sh!: SphericalHarmonics3 = SphericalHarmonics3(), intensity!: Float64 = 1.0)
```
构造一个新的光照探针

参数: 

|名称|类型|描述|
|---|---|---|
|sh|SphericalHarmonics3|球面调和系数，默认空 SH3intensity 光源强度，默认 1|
|intensity|Float64||

### var sh
```cj
public var sh: SphericalHarmonics3
```
球面调和系数，描述场景光照环境

