# Package three.core.math 

## API List

### Function
|  Name   | Describe  |
|  ----  | ----  |
|[arrayMax(Array<Float64>)](./Function.md#func-arraymaxarrayfloat64)|Find the maximum value in an array, returns -Float64.Infinity for empty arrays|
|[arrayMin(Array<Float64>)](./Function.md#func-arrayminarrayfloat64)|Find the minimum value in an array, returns Float64.Infinity for empty arrays|
|[arrayNeedsUint32(Array<Int64>)](./Function.md#func-arrayneedsuint32arrayint64)|Check if array contains values >= 65535 (requires Uint32 representation)|
|[isTypedArray(Any)](./Function.md#func-istypedarrayany)|Check if an object is a TypedArray (in Cangjie, checks if it is an Array type)|
|[toNormalizedProjectionMatrix(Matrix4)](./Function.md#func-tonormalizedprojectionmatrixmatrix4)|Convert projection matrix from NDC range [-1, 1] to [0, 1]|
|[toReversedProjectionMatrix(Matrix4)](./Function.md#func-toreversedprojectionmatrixmatrix4)|Reverse the depth range of the projection matrix|

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[Box2](./Class/Box2.md#class-box2)|2D axis-aligned bounding box class, defined by min and max points|
|[Box3](./Class/Box3.md#class-box3)|3D axis-aligned bounding box class, defined by min and max points|
|[ColorManagement](./Class/ColorManagement.md#class-colormanagement)|Color space management class, providing color space conversion functionality|
|[ColorSpaceDefinition](./Class/ColorSpaceDefinition.md#class-colorspacedefinition)|Color space definition, containing primary coordinates, white point, transfer function, transformation matrix, etc.|
|[ColorSpaceOutputConfig](./Class/ColorSpaceOutputConfig.md#class-colorspaceoutputconfig)|Output color space configuration|
|[ColorSpaceWorkingConfig](./Class/ColorSpaceWorkingConfig.md#class-colorspaceworkingconfig)|Working color space configuration|
|[Color](./Class/Color.md#class-color)|Color class, represented by RGB components, range [0, 1]|
|[Cylindrical](./Class/Cylindrical.md#class-cylindrical)|Cylindrical coordinates class for representing points in 3D space|
|[Euler](./Class/Euler.md#class-euler)|Euler angles class, describing rotation using three angles (x, y, z) and rotation order|
|[FrustumArray](./Class/FrustumArray.md#class-frustumarray)|Frustum array class for multi-layer rendering frustum culling|
|[Frustum](./Class/Frustum.md#class-frustum)|Frustum class, defined by 6 planes|
|[HSL](./Class/HSL.md#class-hsl)|HSL color value container, used as target parameter for getHSL method|
|[Interpolant](./Class/Interpolant.md#class-interpolant)|Interpolant base class, providing interval search and interpolation template methods|
|[Line3](./Class/Line3.md#class-line3)|3D line segment class, defined by start and end points|
|[MathUtils](./Class/MathUtils.md#class-mathutils)|Math utility class providing a collection of commonly used math functions|
|[Matrix2](./Class/Matrix2.md#class-matrix2)|2x2 matrix class, stored in column-major order|
|[Matrix3](./Class/Matrix3.md#class-matrix3)|3x3 matrix class, stored in column-major order|
|[Matrix4F](./Class/Matrix4F.md#class-matrix4f)|Float32 4x4 matrix class (column-major storage)|
|[Matrix4](./Class/Matrix4.md#class-matrix4)|4x4 matrix class, column-major storage (elements array)|
|[Plane](./Class/Plane.md#class-plane)|Plane class, represented by unit normal and constant|
|[QuaternionF](./Class/QuaternionF.md#class-quaternionf)|Float32 quaternion class for representing 3D rotations|
|[Quaternion](./Class/Quaternion.md#class-quaternion)|Quaternion class for representing 3D rotations|
|[Ray](./Class/Ray.md#class-ray)|Ray class, defined by origin and direction vector|
|[ReversedDepthFuncs](./Class/ReversedDepthFuncs.md#class-reverseddepthfuncs)|Reversed depth function mapping table|
|[Sphere](./Class/Sphere.md#class-sphere)|Sphere class, represented by center and radius|
|[SphericalHarmonics3](./Class/SphericalHarmonics3.md#class-sphericalharmonics3)|Spherical harmonics coefficient class, containing 9 third-order coefficient vectors|
|[Spherical](./Class/Spherical.md#class-spherical)|Spherical coordinates class for representing points in 3D space|
|[Triangle](./Class/Triangle.md#class-triangle)|Triangle class, defined by three vertices|
|[Vector2](./Class/Vector2.md#class-vector2)|2D vector class, represents an ordered pair (x, y)|
|[Vector3F](./Class/Vector3F.md#class-vector3f)|Float32 3D vector class|
|[Vector3](./Class/Vector3.md#class-vector3)|3D vector class, represents an ordered triple (x, y, z)|
|[Vector4F](./Class/Vector4F.md#class-vector4f)|Float32 4D vector class|
|[Vector4](./Class/Vector4.md#class-vector4)|4D vector class, represents an ordered quadruple (x, y, z, w)|

### Enum
|  Name   | Describe  |
|  ----  | ----  |
|[EulerOrder](./Enum/EulerOrder.md#enum-eulerorder)|Euler angle rotation order enum|

### Variables & constants
|  Name   | Describe  |
|  ----  | ----  |
|[DEG2RAD](./Variables%20&%20constants.md#let-deg2rad)|Degrees to radians constant|
|[LN2](./Variables%20&%20constants.md#const-ln2)|Natural logarithm of 2 constant|
|[PI](./Variables%20&%20constants.md#const-pi)|Pi constant|
|[RAD2DEG](./Variables%20&%20constants.md#let-rad2deg)|Radians to degrees constant|

