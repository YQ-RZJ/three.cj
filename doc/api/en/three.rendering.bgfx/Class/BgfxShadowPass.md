# Class
## class BgfxShadowPass
```cj
public class BgfxShadowPass
```
Shadow depth pre-pass

### func \_allocShadowViewId\(Int64\)
```cj
public func _allocShadowViewId(count!: Int64 = 1): UInt16
```
Allocate view ID segment for a new shadow light

Parameter: 

|Name|Type|Describe|
|---|---|---|
|count|Int64|Number of view IDs this light occupies (2D shadow=1, cube shadow=6)|

Return: 

- Starting view ID

### func \_collectShadowCasters\(Object3D,ArrayList<RenderObject>\)
```cj
public func _collectShadowCasters(obj: Object3D, renderObjects: ArrayList < RenderObject >): Unit
```
Recursively collect all castShadow Mesh geometry in the scene as shadow casters

Parameter: 

|Name|Type|Describe|
|---|---|---|
|obj|Object3D|Scene objectrenderObjects Render object list|
|renderObjects|ArrayList<RenderObject>||

### func \_destroySlot\(ShadowSlot\)
```cj
public func _destroySlot(slot: ShadowSlot): Unit
```
Destroy all GPU resources held by a ShadowSlot (framebuffer + texture + cube face framebuffers + VSM chain)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|ShadowSlot|Shadow slot|

### func beginFrame\(\)
```cj
public func beginFrame(): Unit
```
Clear current frame shadow slots at frame start (persistent resources _shadowResources are not cleared, reused across frames)

### func bindShadowUniforms\(\)
```cj
public func bindShadowUniforms(): Unit
```
Bind shadow uniforms to main pass draw (called in _drawRenderObject)

### func dispose\(\)
```cj
public func dispose(): Unit
```
Destroy all persistent shadow resources (_shadowResources), called by BgfxBackend.dispose

### func init\(\)
```cj
public init()
```


### func init\(BgfxBackend\)
```cj
public init(backend!: BgfxBackend)
```
Constructor with host reference

Parameter: 

|Name|Type|Describe|
|---|---|---|
|backend|BgfxBackend|Host BgfxBackend instance|

### func renderPointShadowMap\(PointLight,Scene\)
```cj
public func renderPointShadowMap(light: PointLight, scene: Scene): Unit
```
Render point light shadow map (pre-pass)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|PointLight|Point light (with shadow.camera PerspectiveCamera fov=90 + shadow.mapSize)scene Scene (collects caster geometry)|
|scene|Scene||

### func renderShadowMap\(DirectionalLight,Scene\)
```cj
public func renderShadowMap(light: DirectionalLight, scene: Scene): Unit
```
Render directional light shadow map (pre-pass)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|DirectionalLight|Directional light (with shadow.camera orthographic camera + shadow.mapSize)scene Scene (collects caster geometry)|
|scene|Scene||

### func renderSpotShadowMap\(SpotLight,Scene\)
```cj
public func renderSpotShadowMap(light: SpotLight, scene: Scene): Unit
```
Render spot light shadow map (pre-pass)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|SpotLight|Spot light (with shadow.camera perspective camera + shadow.mapSize)scene Scene (collects caster geometry)|
|scene|Scene||

### let SHADOW\_VIEW\_ID\_BASE
```cj
public static let SHADOW_VIEW_ID_BASE: UInt16 = 64u16
```
Shadow depth pre-pass view ID segment convention: main render view 0, shadow views start from 64

