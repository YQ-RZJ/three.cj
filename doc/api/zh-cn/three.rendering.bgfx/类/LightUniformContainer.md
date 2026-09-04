# 类
## class LightUniformContainer
```cj
public class LightUniformContainer
```
多光源 uniform 容器

### func init\(\)
```cj
public init()
```


### func reset\(\)
```cj
public func reset(): Unit
```
重置所有 uniform 数据

### func setDirLight\(Int64,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public func setDirLight(index: Int64, dirX: Float32, dirY: Float32, dirZ: Float32, colorR: Float32, colorG: Float32, colorB: Float32, intensity: Float32): Unit
```
写入一个方向光的 uniform 数据

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|光源索引dirX 方向 X 分量dirY 方向 Y 分量dirZ 方向 Z 分量colorR 颜色 R 分量colorG 颜色 G 分量colorB 颜色 B 分量intensity 光照强度|
|dirX|Float32||
|dirY|Float32||
|dirZ|Float32||
|colorR|Float32||
|colorG|Float32||
|colorB|Float32||
|intensity|Float32||

### func setHemiLight\(Int64,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public func setHemiLight(index: Int64, dirX: Float32, dirY: Float32, dirZ: Float32, skyR: Float32, skyG: Float32, skyB: Float32, intensity: Float32, grR: Float32, grG: Float32, grB: Float32): Unit
```
写入一个半球光的 uniform 数据

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64||
|dirX|Float32||
|dirY|Float32||
|dirZ|Float32||
|skyR|Float32||
|skyG|Float32||
|skyB|Float32||
|intensity|Float32||
|grR|Float32||
|grG|Float32||
|grB|Float32||

### func setPointLight\(Int64,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public func setPointLight(index: Int64, posX: Float32, posY: Float32, posZ: Float32, distance: Float32, colorR: Float32, colorG: Float32, colorB: Float32, intensity: Float32, decay: Float32): Unit
```
写入一个点光源的 uniform 数据

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64||
|posX|Float32||
|posY|Float32||
|posZ|Float32||
|distance|Float32||
|colorR|Float32||
|colorG|Float32||
|colorB|Float32||
|intensity|Float32||
|decay|Float32||

### func setSpotLight\(Int64,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public func setSpotLight(index: Int64, posX: Float32, posY: Float32, posZ: Float32, distance: Float32, colorR: Float32, colorG: Float32, colorB: Float32, intensity: Float32, dirX: Float32, dirY: Float32, dirZ: Float32, angleCos: Float32, angle: Float32, penumbra: Float32, decay: Float32): Unit
```
写入一个聚光源的 uniform 数据

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64||
|posX|Float32||
|posY|Float32||
|posZ|Float32||
|distance|Float32||
|colorR|Float32||
|colorG|Float32||
|colorB|Float32||
|intensity|Float32||
|dirX|Float32||
|dirY|Float32||
|dirZ|Float32||
|angleCos|Float32||
|angle|Float32||
|penumbra|Float32||
|decay|Float32||

### let MAX\_DIR\_LIGHTS
```cj
public static let MAX_DIR_LIGHTS: Int64 = 4
```
方向光最大数量

### let MAX\_DIR\_SHADOW\_LIGHTS
```cj
public static let MAX_DIR_SHADOW_LIGHTS: Int64 = 4
```
方向光阴影最大数量

### let MAX\_HEMI\_LIGHTS
```cj
public static let MAX_HEMI_LIGHTS: Int64 = 4
```
半球光最大数量

### let MAX\_POINT\_LIGHTS
```cj
public static let MAX_POINT_LIGHTS: Int64 = 4
```
点光源最大数量

### let MAX\_POINT\_SHADOW\_LIGHTS
```cj
public static let MAX_POINT_SHADOW_LIGHTS: Int64 = 4
```
点光源阴影最大数量

### let MAX\_SPOT\_LIGHTS
```cj
public static let MAX_SPOT_LIGHTS: Int64 = 4
```
聚光源最大数量

### let MAX\_SPOT\_SHADOW\_LIGHTS
```cj
public static let MAX_SPOT_SHADOW_LIGHTS: Int64 = 4
```
聚光灯阴影最大数量

### var ambientColor
```cj
public var ambientColor: Array < Float32 >
```
环境光颜色

### var dirLightColors
```cj
public var dirLightColors: Array < Float32 >
```
方向光颜色数组

### var dirLightDirections
```cj
public var dirLightDirections: Array < Float32 >
```
方向光方向数组

### var hemiLightDirections
```cj
public var hemiLightDirections: Array < Float32 >
```
半球光方向数组

### var hemiLightGroundColors
```cj
public var hemiLightGroundColors: Array < Float32 >
```
半球光地面颜色数组

### var hemiLightSkyColors
```cj
public var hemiLightSkyColors: Array < Float32 >
```
半球光天空颜色数组

### var numDirLights
```cj
public var numDirLights: Int64 = 0
```
当前方向光数量

### var numDirShadowLights
```cj
public var numDirShadowLights: Int64 = 0
```
方向光阴影数量

### var numHemiLights
```cj
public var numHemiLights: Int64 = 0
```
当前半球光数量

### var numPointLights
```cj
public var numPointLights: Int64 = 0
```
当前点光源数量

### var numPointShadowLights
```cj
public var numPointShadowLights: Int64 = 0
```
点光源阴影数量

### var numSpotLights
```cj
public var numSpotLights: Int64 = 0
```
当前聚光源数量

### var numSpotShadowLights
```cj
public var numSpotShadowLights: Int64 = 0
```
聚光灯阴影数量

### var pointLightColors
```cj
public var pointLightColors: Array < Float32 >
```
点光源颜色数组

### var pointLightParams
```cj
public var pointLightParams: Array < Float32 >
```
点光源参数数组

### var pointLightPositions
```cj
public var pointLightPositions: Array < Float32 >
```
点光源位置数组

### var spotLightColors
```cj
public var spotLightColors: Array < Float32 >
```
聚光源颜色数组

### var spotLightDirections
```cj
public var spotLightDirections: Array < Float32 >
```
聚光源方向数组

### var spotLightParams
```cj
public var spotLightParams: Array < Float32 >
```
聚光源参数数组

### var spotLightPositions
```cj
public var spotLightPositions: Array < Float32 >
```
聚光源位置数组

