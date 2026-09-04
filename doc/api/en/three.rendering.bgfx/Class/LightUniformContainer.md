# Class
## class LightUniformContainer
```cj
public class LightUniformContainer
```
Multi-light uniform container

### func init\(\)
```cj
public init()
```


### func reset\(\)
```cj
public func reset(): Unit
```
Resets all uniform data

### func setDirLight\(Int64,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public func setDirLight(index: Int64, dirX: Float32, dirY: Float32, dirZ: Float32, colorR: Float32, colorG: Float32, colorB: Float32, intensity: Float32): Unit
```
Writes uniform data for one directional light

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Light indexdirX Direction X componentdirY Direction Y componentdirZ Direction Z componentcolorR Color R componentcolorG Color G componentcolorB Color B componentintensity Light intensity|
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
Writes uniform data for one hemisphere light

Parameter: 

|Name|Type|Describe|
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
Writes uniform data for one point light

Parameter: 

|Name|Type|Describe|
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
Writes uniform data for one spot light

Parameter: 

|Name|Type|Describe|
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
Max directional lights

### let MAX\_DIR\_SHADOW\_LIGHTS
```cj
public static let MAX_DIR_SHADOW_LIGHTS: Int64 = 4
```
Max directional shadow lights

### let MAX\_HEMI\_LIGHTS
```cj
public static let MAX_HEMI_LIGHTS: Int64 = 4
```
Max hemisphere lights

### let MAX\_POINT\_LIGHTS
```cj
public static let MAX_POINT_LIGHTS: Int64 = 4
```
Max point lights

### let MAX\_POINT\_SHADOW\_LIGHTS
```cj
public static let MAX_POINT_SHADOW_LIGHTS: Int64 = 4
```
Max point shadow lights

### let MAX\_SPOT\_LIGHTS
```cj
public static let MAX_SPOT_LIGHTS: Int64 = 4
```
Max spot lights

### let MAX\_SPOT\_SHADOW\_LIGHTS
```cj
public static let MAX_SPOT_SHADOW_LIGHTS: Int64 = 4
```
Max spot shadow lights

### var ambientColor
```cj
public var ambientColor: Array < Float32 >
```
Ambient light color

### var dirLightColors
```cj
public var dirLightColors: Array < Float32 >
```
Directional light colors array

### var dirLightDirections
```cj
public var dirLightDirections: Array < Float32 >
```
Directional light directions array

### var hemiLightDirections
```cj
public var hemiLightDirections: Array < Float32 >
```
Hemisphere light directions array

### var hemiLightGroundColors
```cj
public var hemiLightGroundColors: Array < Float32 >
```
Hemisphere light ground colors array

### var hemiLightSkyColors
```cj
public var hemiLightSkyColors: Array < Float32 >
```
Hemisphere light sky colors array

### var numDirLights
```cj
public var numDirLights: Int64 = 0
```
Current directional light count

### var numDirShadowLights
```cj
public var numDirShadowLights: Int64 = 0
```
Directional shadow light count

### var numHemiLights
```cj
public var numHemiLights: Int64 = 0
```
Current hemisphere light count

### var numPointLights
```cj
public var numPointLights: Int64 = 0
```
Current point light count

### var numPointShadowLights
```cj
public var numPointShadowLights: Int64 = 0
```
Point shadow light count

### var numSpotLights
```cj
public var numSpotLights: Int64 = 0
```
Current spot light count

### var numSpotShadowLights
```cj
public var numSpotShadowLights: Int64 = 0
```
Spot shadow light count

### var pointLightColors
```cj
public var pointLightColors: Array < Float32 >
```
Point light colors array

### var pointLightParams
```cj
public var pointLightParams: Array < Float32 >
```
Point light params array

### var pointLightPositions
```cj
public var pointLightPositions: Array < Float32 >
```
Point light positions array

### var spotLightColors
```cj
public var spotLightColors: Array < Float32 >
```
Spot light colors array

### var spotLightDirections
```cj
public var spotLightDirections: Array < Float32 >
```
Spot light directions array

### var spotLightParams
```cj
public var spotLightParams: Array < Float32 >
```
Spot light params array

### var spotLightPositions
```cj
public var spotLightPositions: Array < Float32 >
```
Spot light positions array

