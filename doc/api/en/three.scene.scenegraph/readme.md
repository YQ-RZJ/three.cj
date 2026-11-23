# Package three.scene.scenegraph 

## API List

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[ClippingGroup](./Class/ClippingGroup.md#class-clippinggroup)|Clipping group, managing a set of sub-objects for frustum clipping|
|[FogExp2](./Class/FogExp2.md#class-fogexp2)|Exponential fog class, exponentially increasing opacity with distance|
|[Fog](./Class/Fog.md#class-fog)|Linear fog class, linearly increasing opacity with distance|
|[Group](./Class/Group.md#class-group)|Group, a transform-less container scene object|
|[Scene](./Class/Scene.md#class-scene)|Scene, the root node of the scene graph|

### Interface
|  Name   | Describe  |
|  ----  | ----  |
|[IBackground](./Interface/IBackground.md#interface-ibackground)|Scene background marker interface: element type of Scene.background|
|[IGroup](./Interface/IGroup.md#interface-igroup)|Render group marker interface: group parameter type for Material.onBeforeRender callback|
|[IScene](./Interface/IScene.md#interface-iscene)|Scene marker interface: scene parameter type for CubeCamera.update / PMREMGenerator.fromScene|

