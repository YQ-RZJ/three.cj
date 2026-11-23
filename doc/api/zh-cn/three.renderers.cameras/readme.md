# 包 three.renderers.cameras 

## API列表

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[ArrayCamera](./类/ArrayCamera.md#class-arraycamera)|数组相机，管理一组 PerspectiveCamera 子相机|
|[CameraView](./类/CameraView.md#class-cameraview)|相机多视口裁剪配置|
|[Camera](./类/Camera.md#class-camera)|相机抽象基类，所有具体相机类型继承本类|
|[CubeCamera](./类/CubeCamera.md#class-cubecamera)|立方体相机|
|[OrthographicCamera](./类/OrthographicCamera.md#class-orthographiccamera)|正交投影相机|
|[PerspectiveCamera](./类/PerspectiveCamera.md#class-perspectivecamera)|透视投影相机|
|[StereoCamera](./类/StereoCamera.md#class-stereocamera)|立体相机|

### 接口
|  名称   | 描述  |
|  ----  | ----  |
|[IArrayCameraSource](./接口/IArrayCameraSource.md#interface-iarraycamerasource)|数组相机只读接口：提供子相机投影/视图逆矩阵数据|
|[ICamera](./接口/ICamera.md#interface-icamera)|相机抽象接口：IRenderer.render 的 camera 参数类型|

