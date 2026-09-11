# 类
## class BlendLayer
```cj
public class BlendLayer
```
混合层

### func init\(\)
```cj
public init()
```


### func set\(Float32,Array<SoaTransform>,?Array<Float32>\)
```cj
public func set(weight: Float32, transforms: Array < SoaTransform >, jointWeights!:?Array < Float32 >= None): Unit
```
设置层数据

参数: 

|名称|类型|描述|
|---|---|---|
|weight|Float32||
|transforms|Array<SoaTransform>||
|jointWeights|?Array<Float32>||

### var jointWeights
```cj
public var jointWeights:?Array < Float32 >
```
逐关节权重（可选）

### var transforms
```cj
public var transforms: Array < SoaTransform >
```
该层的关节变换数组

### var weight
```cj
public var weight: Float32
```
层权重 [0, 1]

