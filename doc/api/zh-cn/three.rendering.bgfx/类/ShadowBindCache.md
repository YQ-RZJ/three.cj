# 类
## class ShadowBindCache
```cj
public class ShadowBindCache
```
帧级阴影绑定缓存

### func init\(\)
```cj
public init()
```


### var dirMatUniform
```cj
public var dirMatUniform: UniformHandle = UniformHandle()
```
方向光阴影矩阵 uniform 句柄

### var dirMats
```cj
public var dirMats: Array < Float32 >= Array < Float32 >()
```
方向光阴影矩阵（bias 已预乘），长度 = dirSlots.size * 16

### var dirParamUniform
```cj
public var dirParamUniform: UniformHandle = UniformHandle()
```
方向光逐光源参数 uniform 句柄

### var dirParams
```cj
public var dirParams: Array < Float32 >= Array < Float32 >()
```
方向光逐光源参数 [bias, normalBias, 0, 0]，长度 = dirSlots.size * 4

### var dirSamplerFlags
```cj
public var dirSamplerFlags: UInt32 = 0
```
方向光 sampler 的比较/各向异性标志（VSM 时为普通采样标志）

### var dirSampler
```cj
public var dirSampler: UniformHandle = UniformHandle()
```
方向光阴影贴图 sampler 句柄

### var dirSlots
```cj
public var dirSlots: ArrayList < ShadowSlot >= ArrayList < ShadowSlot >()
```
分类后的方向光 slot（按 lightId 升序，帧间稳定）

### var mapSizeUniform
```cj
public var mapSizeUniform: UniformHandle = UniformHandle()
```
阴影贴图尺寸 uniform 句柄

### var mapSize
```cj
public var mapSize: Array < Float32 >= Array < Float32 >(4, { _ =>
    0.0f32
})
```
阴影贴图尺寸 [size, size, size, 0]

### var pointLightPos
```cj
public var pointLightPos: Array < Float32 >= Array < Float32 >()
```
点光源位置 [x, y, z, 0]，长度 = pointSlots.size * 4

### var pointNearFar
```cj
public var pointNearFar: Array < Float32 >= Array < Float32 >()
```
点光源近远平面 [near, far, 0, 0]，长度 = pointSlots.size * 4

### var pointParamUniform
```cj
public var pointParamUniform: UniformHandle = UniformHandle()
```
点光源逐光源参数 uniform 句柄

### var pointParams
```cj
public var pointParams: Array < Float32 >= Array < Float32 >()
```
点光源逐光源参数 [bias, 0, 0, 0]，长度 = pointSlots.size * 4

### var pointPosUniform
```cj
public var pointPosUniform: UniformHandle = UniformHandle()
```
点光源位置 uniform 句柄

### var pointRangeUniform
```cj
public var pointRangeUniform: UniformHandle = UniformHandle()
```
点光源近远平面 uniform 句柄

### var pointSampler
```cj
public var pointSampler: UniformHandle = UniformHandle()
```
点光源阴影贴图 sampler 句柄

### var pointSlots
```cj
public var pointSlots: ArrayList < ShadowSlot >= ArrayList < ShadowSlot >()
```
分类后的点光源 slot

### var shadowParamsUniform
```cj
public var shadowParamsUniform: UniformHandle = UniformHandle()
```
全局阴影参数 uniform 句柄

### var shadowParams
```cj
public var shadowParams: Array < Float32 >= Array < Float32 >(4, { _ =>
    0.0f32
})
```
全局阴影参数 [intensity, bias, normalBias, radius]

### var spotMatUniform
```cj
public var spotMatUniform: UniformHandle = UniformHandle()
```
聚光灯阴影矩阵 uniform 句柄

### var spotMats
```cj
public var spotMats: Array < Float32 >= Array < Float32 >()
```
聚光灯阴影矩阵（bias 已在生成侧预乘），长度 = spotSlots.size * 16

### var spotParamUniform
```cj
public var spotParamUniform: UniformHandle = UniformHandle()
```
聚光灯逐光源参数 uniform 句柄

### var spotParams
```cj
public var spotParams: Array < Float32 >= Array < Float32 >()
```
聚光灯逐光源参数，长度 = spotSlots.size * 4

### var spotSampler
```cj
public var spotSampler: UniformHandle = UniformHandle()
```
聚光灯阴影贴图 sampler 句柄

### var spotSlots
```cj
public var spotSlots: ArrayList < ShadowSlot >= ArrayList < ShadowSlot >()
```
分类后的聚光灯 slot

### var valid
```cj
public var valid: Bool = false
```
缓存是否有效（beginFrame 时置 false）

