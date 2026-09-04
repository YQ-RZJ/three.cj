# Package three.rendering.geometry 

## API List

### Function
|  Name   | Describe  |
|  ----  | ----  |
|[CatmullRom(Float64,Float64,Float64,Float64,Float64)](./Function.md#func-catmullromfloat64float64float64float64float64)||
|[CubicBezier(Float64,Float64,Float64,Float64,Float64)](./Function.md#func-cubicbezierfloat64float64float64float64float64)||
|[QuadraticBezier(Float64,Float64,Float64,Float64)](./Function.md#func-quadraticbezierfloat64float64float64float64)||
|[deviation(Array<Float64>,Array<Int64>,Int64,Array<UInt32>)](./Function.md#func-deviationarrayfloat64arrayint64int64arrayuint32)|返回三角剖分面积与多边形面积之间的百分比差异|
|[earcut(Array<Float64>,Array<Int64>,Int64)](./Function.md#func-earcutarrayfloat64arrayint64int64)|主入口：对多边形进行 earcut 三角剖分|
|[fromHalfFloat(UInt16)](./Function.md#func-fromhalffloatuint16)||
|[toHalfFloat(Float64)](./Function.md#func-tohalffloatfloat64)||

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[ArcCurve](./Class/ArcCurve.md#class-arccurve)|Arc curve class, extending EllipseCurve|
|[BoxGeometry](./Class/BoxGeometry.md#class-boxgeometry)|Box geometry class|
|[BufferGeometryGroup](./Class/BufferGeometryGroup.md#class-buffergeometrygroup)|Draw group structure, defining geometry draw groups|
|[BufferGeometry](./Class/BufferGeometry.md#class-buffergeometry)|Buffer geometry class: describes geometry data (vertex/normal/UV attributes)|
|[CapsuleGeometry](./Class/CapsuleGeometry.md#class-capsulegeometry)|Capsule geometry class, composed of a cylindrical middle section and two hemispherical caps|
|[CatmullRomCurve3](./Class/CatmullRomCurve3.md#class-catmullromcurve3)|3D Catmull-Rom spline curve class|
|[CircleGeometry](./Class/CircleGeometry.md#class-circlegeometry)|Circle geometry class|
|[ConeGeometry](./Class/ConeGeometry.md#class-conegeometry)|Cone geometry class, a special case of CylinderGeometry (radiusTop = 0)|
|[CubicBezierCurve3](./Class/CubicBezierCurve3.md#class-cubicbeziercurve3)|3D cubic Bezier curve class|
|[CubicBezierCurve](./Class/CubicBezierCurve.md#class-cubicbeziercurve)|2D cubic Bezier curve class|
|[CurvePath](./Class/CurvePath.md#class-curvepath)|Curve path class, a composite path of multiple curves connected in sequence|
|[Curve](./Class/Curve.md#class-curve)|Abstract base class for curves|
|[CylinderGeometry](./Class/CylinderGeometry.md#class-cylindergeometry)|Cylinder geometry class|
|[DataUtils](./Class/DataUtils.md#class-datautils)|数据工具类，提供半精度浮点数转换的静态方法  此类是 toHalfFloat 和 fromHalfFloat 函数的面向对象封装， 与 Three.js 的 DataUtils 类接口保持一致。|
|[DodecahedronGeometry](./Class/DodecahedronGeometry.md#class-dodecahedrongeometry)|Dodecahedron geometry (polyhedron special case)|
|[Earcut](./Class/Earcut.md#class-earcut)|Earcut 多边形三角剖分工具类  提供 earcut 算法的静态接口，将一个 2D 多边形（可能含孔洞） 剖分为若干三角形，返回三角形顶点索引数组。  注意：本文件同时包含底层算法实现（earcut/deviation）与 Earcut 封装类（Windows 文件系统大小写不敏感，Earcut.cj 与 earcut.cj 实为同一文件，故合并于此）。  参见：https://github.com/mapbox/earcut|
|[EdgesGeometry](./Class/EdgesGeometry.md#class-edgesgeometry)|Edges geometry class, extracts edges from BufferGeometry|
|[EllipseCurve](./Class/EllipseCurve.md#class-ellipsecurve)|Ellipse curve class|
|[ExtrudeGeometry](./Class/ExtrudeGeometry.md#class-extrudegeometry)|Extrude geometry class: Shape contour + depth extrusion|
|[IcosahedronGeometry](./Class/IcosahedronGeometry.md#class-icosahedrongeometry)|Icosahedron geometry (polyhedron special case)|
|[InstancedBufferGeometry](./Class/InstancedBufferGeometry.md#class-instancedbuffergeometry)|实例化缓冲几何体类  实例化缓冲几何体是 {|
|[LatheGeometry](./Class/LatheGeometry.md#class-lathegeometry)|Lathe geometry class|
|[LineCurve3](./Class/LineCurve3.md#class-linecurve3)|3D line curve class|
|[LineCurve](./Class/LineCurve.md#class-linecurve)|2D line curve class|
|[OctahedronGeometry](./Class/OctahedronGeometry.md#class-octahedrongeometry)|Octahedron geometry (polyhedron special case)|
|[Path](./Class/Path.md#class-path)|2D path class|
|[PlaneGeometry](./Class/PlaneGeometry.md#class-planegeometry)|Plane geometry class|
|[PolyhedronGeometry](./Class/PolyhedronGeometry.md#class-polyhedrongeometry)|Polyhedron geometry class, projecting vertex arrays onto a sphere and subdividing to specified detail level|
|[QuadraticBezierCurve3](./Class/QuadraticBezierCurve3.md#class-quadraticbeziercurve3)|3D quadratic Bezier curve class|
|[QuadraticBezierCurve](./Class/QuadraticBezierCurve.md#class-quadraticbeziercurve)|2D quadratic Bezier curve class|
|[RingGeometry](./Class/RingGeometry.md#class-ringgeometry)|Ring geometry class|
|[ShapeGeometry](./Class/ShapeGeometry.md#class-shapegeometry)|Shape geometry class, generating a plane mesh from a Shape via triangulation|
|[ShapePath](./Class/ShapePath.md#class-shapepath)||
|[ShapeUtils](./Class/ShapeUtils.md#class-shapeutils)|Shape utility class, provides 2D polygon area calculation, winding direction and triangulation|
|[Shape](./Class/Shape.md#class-shape)|Shape class, defining a 2D shape plane with optional holes|
|[SphereGeometry](./Class/SphereGeometry.md#class-spheregeometry)|Sphere geometry class|
|[SplineCurve](./Class/SplineCurve.md#class-splinecurve)|2D spline curve class|
|[TetrahedronGeometry](./Class/TetrahedronGeometry.md#class-tetrahedrongeometry)|Tetrahedron geometry (polyhedron special case)|
|[TorusGeometry](./Class/TorusGeometry.md#class-torusgeometry)|Torus geometry class|
|[TorusKnotGeometry](./Class/TorusKnotGeometry.md#class-torusknotgeometry)|Torus knot geometry class|
|[TubeGeometry](./Class/TubeGeometry.md#class-tubegeometry)|Tube geometry class, extruding a tube along a 3D curve|
|[WireframeGeometry](./Class/WireframeGeometry.md#class-wireframegeometry)|Wireframe geometry class, extracting all unique edges from BufferGeometry|

