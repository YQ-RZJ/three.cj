# 包 three.core.math 

## API列表

### 函数
|  名称   | 描述  |
|  ----  | ----  |
|[arrayMax(Array<Float64>)](./函数.md#func-arraymaxarrayfloat64)|查找数组最大值，空数组返回 -Float64.Infinity|
|[arrayMin(Array<Float64>)](./函数.md#func-arrayminarrayfloat64)|查找数组最小值，空数组返回 Float64.Infinity|
|[arrayNeedsUint32(Array<Int64>)](./函数.md#func-arrayneedsuint32arrayint64)|检查数组是否包含 >= 65535 的值（需要 Uint32 表示）|
|[isTypedArray(Any)](./函数.md#func-istypedarrayany)|判断对象是否为 TypedArray（仓颉中检查是否为 Array 类型）|
|[toNormalizedProjectionMatrix(Matrix4)](./函数.md#func-tonormalizedprojectionmatrixmatrix4)|将投影矩阵从 NDC 范围 [-1, 1] 转换为 [0, 1]|
|[toReversedProjectionMatrix(Matrix4)](./函数.md#func-toreversedprojectionmatrixmatrix4)|反转投影矩阵的深度范围|

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[Box2](./类/Box2.md#class-box2)|2D 轴对齐包围盒类，用最小点和最大点表示|
|[Box3](./类/Box3.md#class-box3)|3D 轴对齐包围盒类，用最小点和最大点表示|
|[ColorManagement](./类/ColorManagement.md#class-colormanagement)|颜色空间管理类，提供颜色空间之间的转换功能|
|[ColorSpaceDefinition](./类/ColorSpaceDefinition.md#class-colorspacedefinition)|颜色空间定义，包含原色坐标、白点、传输函数、变换矩阵等信息|
|[ColorSpaceOutputConfig](./类/ColorSpaceOutputConfig.md#class-colorspaceoutputconfig)|输出颜色空间配置|
|[ColorSpaceWorkingConfig](./类/ColorSpaceWorkingConfig.md#class-colorspaceworkingconfig)|工作颜色空间配置|
|[Color](./类/Color.md#class-color)|颜色类，使用 RGB 分量表示，范围 [0, 1]|
|[Cylindrical](./类/Cylindrical.md#class-cylindrical)|圆柱坐标类，用于表示三维空间中的点|
|[Euler](./类/Euler.md#class-euler)|欧拉角类，用三个角度 (x, y, z) 和旋转顺序 (order) 描述旋转|
|[FrustumArray](./类/FrustumArray.md#class-frustumarray)|视锥体数组类，用于多层渲染的视锥体裁剪|
|[Frustum](./类/Frustum.md#class-frustum)|视锥体类，由6个平面定义|
|[HSL](./类/HSL.md#class-hsl)|HSL 颜色值容器，用于 getHSL 方法的 target 参数|
|[Interpolant](./类/Interpolant.md#class-interpolant)|插值器基类，提供区间查找和插值模板方法|
|[Line3](./类/Line3.md#class-line3)|三维线段类，由起点和终点定义|
|[MathUtils](./类/MathUtils.md#class-mathutils)|数学工具类，提供常用的数学函数集合|
|[Matrix2](./类/Matrix2.md#class-matrix2)|2x2 矩阵类，列主序存储|
|[Matrix3](./类/Matrix3.md#class-matrix3)|3x3 矩阵类，列主序存储|
|[Matrix4F](./类/Matrix4F.md#class-matrix4f)|Float32 4x4 矩阵类（列主序存储）|
|[Matrix4](./类/Matrix4.md#class-matrix4)|4x4 矩阵类，列主序存储（elements 数组）|
|[Plane](./类/Plane.md#class-plane)|平面类，使用单位法向量和常数表示|
|[QuaternionF](./类/QuaternionF.md#class-quaternionf)|Float32 四元数类，用于表示三维旋转|
|[Quaternion](./类/Quaternion.md#class-quaternion)|四元数类，用于表示三维旋转|
|[Ray](./类/Ray.md#class-ray)|射线类，由起点和方向向量定义|
|[ReversedDepthFuncs](./类/ReversedDepthFuncs.md#class-reverseddepthfuncs)|反转深度函数映射表|
|[Sphere](./类/Sphere.md#class-sphere)|球体类，用中心点和半径表示|
|[SphericalHarmonics3](./类/SphericalHarmonics3.md#class-sphericalharmonics3)|球面调和系数类，包含 9 个三阶系数向量|
|[Spherical](./类/Spherical.md#class-spherical)|球坐标类，用于表示三维空间中的点|
|[Triangle](./类/Triangle.md#class-triangle)|三角形类，由三个顶点定义|
|[Vector2](./类/Vector2.md#class-vector2)|2D 向量类，表示有序对 (x, y)|
|[Vector3F](./类/Vector3F.md#class-vector3f)|Float32 3D 向量类|
|[Vector3](./类/Vector3.md#class-vector3)|3D 向量类，表示有序三元组 (x, y, z)|
|[Vector4F](./类/Vector4F.md#class-vector4f)|Float32 4D 向量类|
|[Vector4](./类/Vector4.md#class-vector4)|4D 向量类，表示有序四元组 (x, y, z, w)|

### 枚举
|  名称   | 描述  |
|  ----  | ----  |
|[EulerOrder](./枚举/EulerOrder.md#enum-eulerorder)|欧拉角旋转顺序枚举|

### 变量与常量
|  名称   | 描述  |
|  ----  | ----  |
|[DEG2RAD](./变量与常量.md#let-deg2rad)|度转弧度常量|
|[LN2](./变量与常量.md#const-ln2)|2的自然对数常量|
|[PI](./变量与常量.md#const-pi)|圆周率常量|
|[RAD2DEG](./变量与常量.md#let-rad2deg)|弧度转度常量|

