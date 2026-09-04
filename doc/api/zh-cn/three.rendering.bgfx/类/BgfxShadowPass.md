# 类
## class BgfxShadowPass
```cj
public class BgfxShadowPass
```
阴影深度预 pass

### func \_allocShadowViewId\(Int64\)
```cj
public func _allocShadowViewId(count!: Int64 = 1): UInt16
```
为新的阴影光源分配 view ID 段

参数: 

|名称|类型|描述|
|---|---|---|
|count|Int64|该光源占用的 view ID 数（2D 阴影=1，cube 阴影=6）|

返回: 

- 起始 view ID

### func \_collectShadowCasters\(Object3D,ArrayList<RenderObject>\)
```cj
public func _collectShadowCasters(obj: Object3D, renderObjects: ArrayList < RenderObject >): Unit
```
递归收集场景中所有 castShadow 的 Mesh 几何体作为阴影 caster

参数: 

|名称|类型|描述|
|---|---|---|
|obj|Object3D|场景对象renderObjects 渲染对象列表|
|renderObjects|ArrayList<RenderObject>||

### func \_destroySlot\(ShadowSlot\)
```cj
public func _destroySlot(slot: ShadowSlot): Unit
```
销毁一个 ShadowSlot 持有的所有 GPU 资源（framebuffer + 纹理 + cube face framebuffer + VSM 链）

参数: 

|名称|类型|描述|
|---|---|---|
|slot|ShadowSlot|阴影槽|

### func beginFrame\(\)
```cj
public func beginFrame(): Unit
```
每帧开始时清空当前帧阴影槽（持久资源 _shadowResources 不清，跨帧复用）

### func bindShadowUniforms\(\)
```cj
public func bindShadowUniforms(): Unit
```
绑定阴影 uniform 到主 pass draw（在 _drawRenderObject 中调用）

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁所有持久阴影资源（_shadowResources），供 BgfxBackend.dispose 调用

### func init\(\)
```cj
public init()
```


### func init\(BgfxBackend\)
```cj
public init(backend!: BgfxBackend)
```
带宿主引用的构造

参数: 

|名称|类型|描述|
|---|---|---|
|backend|BgfxBackend|宿主 BgfxBackend 实例|

### func renderPointShadowMap\(PointLight,Scene\)
```cj
public func renderPointShadowMap(light: PointLight, scene: Scene): Unit
```
渲染点光源阴影贴图（预 pass）

参数: 

|名称|类型|描述|
|---|---|---|
|light|PointLight|点光源（含 shadow.camera PerspectiveCamera fov=90 + shadow.mapSize）scene 场景（收集 caster 几何体）|
|scene|Scene||

### func renderShadowMap\(DirectionalLight,Scene\)
```cj
public func renderShadowMap(light: DirectionalLight, scene: Scene): Unit
```
渲染方向光阴影贴图（预 pass）

参数: 

|名称|类型|描述|
|---|---|---|
|light|DirectionalLight|方向光（含 shadow.camera 正交相机 + shadow.mapSize）scene 场景（收集 caster 几何体）|
|scene|Scene||

### func renderSpotShadowMap\(SpotLight,Scene\)
```cj
public func renderSpotShadowMap(light: SpotLight, scene: Scene): Unit
```
渲染聚光灯阴影贴图（预 pass）

参数: 

|名称|类型|描述|
|---|---|---|
|light|SpotLight|聚光灯（含 shadow.camera 透视相机 + shadow.mapSize）scene 场景（收集 caster 几何体）|
|scene|Scene||

### let SHADOW\_VIEW\_ID\_BASE
```cj
public static let SHADOW_VIEW_ID_BASE: UInt16 = 64u16
```
阴影深度预 pass 用的 view ID 段约定：主渲染 view 0，阴影 view 从 64 开始

