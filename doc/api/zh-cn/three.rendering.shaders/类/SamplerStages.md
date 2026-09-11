# 类
## class SamplerStages
```cj
public class SamplerStages
```
全局 sampler stage 分配器

### func applyPlaceholders\(String\)
```cj
public static func applyPlaceholders(source: String): String
```
把着色器源码中的 __STAGE_XXX__ 占位符替换为实际 stage 数字（仅固定段）

参数: 

|名称|类型|描述|
|---|---|---|
|source|String|着色器源码|

返回: 

- 替换后的着色器源码

### func dynamicShadowEnd\(Int64,Int64,Int64\)
```cj
public static func dynamicShadowEnd(numDir: Int64, numSpot: Int64, numPoint: Int64): UInt8
```
计算动态 shadow 段的终止 stage（固定段起点，exclusive）

参数: 

|名称|类型|描述|
|---|---|---|
|numDir|Int64|实际方向光阴影数numSpot 实际聚光灯阴影数numPoint 实际点光源阴影数|
|numSpot|Int64||
|numPoint|Int64||

返回: 

- 动态段终止 stage（= numDir + numSpot + numPoint）

### func getPlaceholderReplacements\(\)
```cj
public static func getPlaceholderReplacements(): Array <(String, String) >
```
着色器 chunk 占位符 → 实际 stage 的替换映射（仅固定段）

### func init\(\)
```cj
public init()
```


### func validate\(Int64,Int64,Int64\)
```cj
public static func validate(numDir!: Int64 = 0, numSpot!: Int64 = 0, numPoint!: Int64 = 0): Bool
```
校验 stage 分配无冲突（调试用，可在启动时调一次）

参数: 

|名称|类型|描述|
|---|---|---|
|numDir|Int64|方向光阴影数（默认 0）numSpot 聚光灯阴影数（默认 0）numPoint 点光源阴影数（默认 0）|
|numSpot|Int64||
|numPoint|Int64||

返回: 

- 分配是否无冲突

### let MAX\_DIR\_SHADOW
```cj
public static let MAX_DIR_SHADOW: Int64 = 4
```
directionalShadowMap 数组上限

### let MAX\_POINT\_SHADOW
```cj
public static let MAX_POINT_SHADOW: Int64 = 2
```
pointShadowMap 数组上限

### let MAX\_SPOT\_SHADOW
```cj
public static let MAX_SPOT_SHADOW: Int64 = 2
```
spotShadowMap 数组上限

### let STAGE\_AO\_MAP
```cj
public static let STAGE_AO_MAP: UInt8 = 12u8
```
aoMap 纹理 stage

### let STAGE\_DFGLUT
```cj
public static let STAGE_DFGLUT: UInt8 = 15u8
```
DFG LUT 纹理 stage（SAMPLER2D）

### let STAGE\_EMISSIVE\_MAP
```cj
public static let STAGE_EMISSIVE_MAP: UInt8 = 13u8
```
emissiveMap 纹理 stage

### let STAGE\_ENV\_MAP
```cj
public static let STAGE_ENV_MAP: UInt8 = 14u8
```
环境贴图 stage（u_envMap, SAMPLERCUBE）

### let STAGE\_FIXED\_BASE
```cj
public static let STAGE_FIXED_BASE: UInt8 = 8u8
```
固定段起始 stage 编号，动态 shadow 段最大占用 0..7

### let STAGE\_MAP
```cj
public static let STAGE_MAP: UInt8 = 8u8
```
map 纹理 stage（MeshStandard.map / MeshBasic.map）

### let STAGE\_METALNESS\_MAP
```cj
public static let STAGE_METALNESS_MAP: UInt8 = 10u8
```
metalnessMap 纹理 stage

### let STAGE\_NORMAL\_MAP
```cj
public static let STAGE_NORMAL_MAP: UInt8 = 11u8
```
normalMap 纹理 stage

### let STAGE\_ROUGHNESS\_MAP
```cj
public static let STAGE_ROUGHNESS_MAP: UInt8 = 9u8
```
roughnessMap 纹理 stage

### let STAGE\_SHADOW\_BLIT
```cj
public static let STAGE_SHADOW_BLIT: UInt8 = 0u8
```
shadow blit sampler stage（shadow blit view 专用）

