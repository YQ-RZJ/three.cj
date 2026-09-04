# Variables & constants
## let BASIC\_SHADOW\_MAP
```cj
public let BASIC_SHADOW_MAP: Int64 = 0
```
Shadow map implementation type (SmImpl)

## let CSM\_CASCADE\_COUNT
```cj
public let CSM_CASCADE_COUNT: Int64 = 4
```
CSM cascade count constant

## let DEPTH\_IMPL\_INVZ
```cj
public let DEPTH_IMPL_INVZ: Int64 = 0
```
Depth calculation method (DepthImpl)

## let DEPTH\_IMPL\_LINEAR
```cj
public let DEPTH_IMPL_LINEAR: Int64 = 1
```
Linear depth (light space distance)

## let ESM\_SHADOW\_MAP
```cj
public let ESM_SHADOW_MAP: Int64 = 5
```
ESM shadow map (16-shadowmaps exclusive)

## let PACK\_DEPTH\_RGBA
```cj
public let PACK_DEPTH_RGBA: Int64 = 0
```
Depth packing method (PackDepth)

## let PACK\_DEPTH\_VSM
```cj
public let PACK_DEPTH_VSM: Int64 = 1
```
VSM depth packing (depth + depth² → 2× half float)

## let PCF\_SHADOW\_MAP
```cj
public let PCF_SHADOW_MAP: Int64 = 1
```
PCF shadow map

## let PCF\_SOFT\_SHADOW\_MAP
```cj
public let PCF_SOFT_SHADOW_MAP: Int64 = 2
```
PCF soft shadow map (deprecated, falls back to PCF)

## let PCSS\_SHADOW\_MAP
```cj
public let PCSS_SHADOW_MAP: Int64 = 4
```
PCSS shadow map (16-shadowmaps exclusive)

## let SM\_TYPE\_CASCADE
```cj
public let SM_TYPE_CASCADE: Int64 = 2
```
CSM cascade (4-level atlas, directional light far scenes)

## let SM\_TYPE\_OMNI
```cj
public let SM_TYPE_OMNI: Int64 = 1
```
Cube map distribution (point light) or tetrahedron 4 faces

## let SM\_TYPE\_SINGLE
```cj
public let SM_TYPE_SINGLE: Int64 = 0
```
Shadow map distribution type (SmType)

## let VSM\_SHADOW\_MAP
```cj
public let VSM_SHADOW_MAP: Int64 = 3
```
VSM shadow map

