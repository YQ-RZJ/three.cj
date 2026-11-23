# 包 three.scene.scenegraph 

## API列表

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[ClippingGroup](./类/ClippingGroup.md#class-clippinggroup)|裁剪组，管理一组用于视锥体裁剪的子对象|
|[FogExp2](./类/FogExp2.md#class-fogexp2)|指数雾类，随距离指数增长不透明度|
|[Fog](./类/Fog.md#class-fog)|线性雾类，随距离线性增加不透明度|
|[Group](./类/Group.md#class-group)|组，无变换的容器型场景对象|
|[Scene](./类/Scene.md#class-scene)|场景，场景图根节点|

### 接口
|  名称   | 描述  |
|  ----  | ----  |
|[IBackground](./接口/IBackground.md#interface-ibackground)|场景背景标记接口：Scene.background 的元素类型|
|[IGroup](./接口/IGroup.md#interface-igroup)|渲染组标记接口：Material.onBeforeRender 回调的 group 参数类型|
|[IScene](./接口/IScene.md#interface-iscene)|场景标记接口：CubeCamera.update / PMREMGenerator.fromScene 的 scene 参数类型|

