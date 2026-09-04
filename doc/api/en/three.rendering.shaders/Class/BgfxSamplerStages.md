# Class
## class BgfxSamplerStages
```cj
public class BgfxSamplerStages
```
Global sampler stage allocator

### func applyPlaceholders\(String\)
```cj
public static func applyPlaceholders(source: String): String
```
Replace __STAGE_XXX__ placeholders in shader source with actual stage numbers (fixed segment only)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|String|Shader source code|

Return: 

- Shader source code after replacement

### func dynamicShadowEnd\(Int64,Int64,Int64\)
```cj
public static func dynamicShadowEnd(numDir: Int64, numSpot: Int64, numPoint: Int64): UInt8
```
Compute the end stage of the dynamic shadow segment (fixed segment base, exclusive)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|numDir|Int64|Actual directional light shadow countnumSpot Actual spot light shadow countnumPoint Actual point light shadow count|
|numSpot|Int64||
|numPoint|Int64||

Return: 

- Dynamic segment end stage (= numDir + numSpot + numPoint)

### func getPlaceholderReplacements\(\)
```cj
public static func getPlaceholderReplacements(): Array <(String, String) >
```
Shader chunk placeholder to actual stage replacement mapping (fixed segment only)

### func init\(\)
```cj
public init()
```


### func validate\(Int64,Int64,Int64\)
```cj
public static func validate(numDir!: Int64 = 0, numSpot!: Int64 = 0, numPoint!: Int64 = 0): Bool
```
Validate stage allocation has no conflicts (for debugging, can be called once at startup)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|numDir|Int64|Directional light shadow count (default 0)numSpot Spot light shadow count (default 0)numPoint Point light shadow count (default 0)|
|numSpot|Int64||
|numPoint|Int64||

Return: 

- Whether allocation has no conflicts

### let MAX\_DIR\_SHADOW
```cj
public static let MAX_DIR_SHADOW: Int64 = 4
```
Maximum directional shadow map array size

### let MAX\_POINT\_SHADOW
```cj
public static let MAX_POINT_SHADOW: Int64 = 2
```
Maximum point shadow map array size

### let MAX\_SPOT\_SHADOW
```cj
public static let MAX_SPOT_SHADOW: Int64 = 2
```
Maximum spot shadow map array size

### let STAGE\_AO\_MAP
```cj
public static let STAGE_AO_MAP: UInt8 = 12u8
```
aoMap texture stage

### let STAGE\_DFGLUT
```cj
public static let STAGE_DFGLUT: UInt8 = 15u8
```
DFG LUT texture stage (SAMPLER2D)

### let STAGE\_EMISSIVE\_MAP
```cj
public static let STAGE_EMISSIVE_MAP: UInt8 = 13u8
```
emissiveMap texture stage

### let STAGE\_ENV\_MAP
```cj
public static let STAGE_ENV_MAP: UInt8 = 14u8
```
Environment map stage (u_envMap, SAMPLERCUBE)

### let STAGE\_FIXED\_BASE
```cj
public static let STAGE_FIXED_BASE: UInt8 = 8u8
```
Fixed segment base stage number; dynamic shadow segment occupies 0..7

### let STAGE\_MAP
```cj
public static let STAGE_MAP: UInt8 = 8u8
```
map texture stage (MeshStandard.map / MeshBasic.map)

### let STAGE\_METALNESS\_MAP
```cj
public static let STAGE_METALNESS_MAP: UInt8 = 10u8
```
metalnessMap texture stage

### let STAGE\_NORMAL\_MAP
```cj
public static let STAGE_NORMAL_MAP: UInt8 = 11u8
```
normalMap texture stage

### let STAGE\_ROUGHNESS\_MAP
```cj
public static let STAGE_ROUGHNESS_MAP: UInt8 = 9u8
```
roughnessMap texture stage

### let STAGE\_SHADOW\_BLIT
```cj
public static let STAGE_SHADOW_BLIT: UInt8 = 0u8
```
Shadow blit sampler stage (dedicated for shadow blit view)

