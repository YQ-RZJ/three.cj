# 包 three.core.interfaces 

## API列表

### 接口
|  名称   | 描述  |
|  ----  | ----  |
|[AttributeReader](./接口/AttributeReader.md#interface-attributereader)|顶点属性只读访问接口（getX/getY/getZ/getW + count）|
|[IArrayCameraSource](./接口/IArrayCameraSource.md#interface-iarraycamerasource)|数组相机只读接口：提供子相机投影/视图逆矩阵数据|
|[IBackground](./接口/IBackground.md#interface-ibackground)|场景背景标记接口：Scene.background 的元素类型|
|[IBox3Expandable](./接口/IBox3Expandable.md#interface-ibox3expandable)|包围盒展开只读接口：供 Box3.setFromObject / expandByObject 遍历使用|
|[ICircularQueue<T>](./接口/ICircularQueue.md#interface-icircularqueue-t-)|循环队列接口|
|[IFrustumCullable](./接口/IFrustumCullable.md#interface-ifrustumcullable)|视锥体裁剪只读接口：提供对象的世界空间包围球|
|[ILoadResult](./接口/ILoadResult.md#interface-iloadresult)|加载结果标记接口：Loader.load 的 onLoad 回调参数类型|
|[IMaterial](./接口/IMaterial.md#interface-imaterial)|材质标记接口：Object3D.customDepthMaterial/customDistanceMaterial 的元素类型|
|[IPropertyBindingRoot](./接口/IPropertyBindingRoot.md#interface-ipropertybindingroot)|属性绑定根节点接口：PropertyBinding 的 rootNode/node/targetObject 类型|
|[IQueue<T>](./接口/IQueue.md#interface-iqueue-t-)|队列接口|
|[ISysEtyMapManager < S, E >](./接口/ISysEtyMapManager.md#interface-isysetymapmanager-s-e-)|系统-实体映射管理接口|

