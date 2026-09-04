# 包 three.rendering.geometry 

## API列表

### 函数
|  名称   | 描述  |
|  ----  | ----  |
|[CatmullRom(Float64,Float64,Float64,Float64,Float64)](./函数.md#func-catmullromfloat64float64float64float64float64)||
|[CubicBezier(Float64,Float64,Float64,Float64,Float64)](./函数.md#func-cubicbezierfloat64float64float64float64float64)||
|[QuadraticBezier(Float64,Float64,Float64,Float64)](./函数.md#func-quadraticbezierfloat64float64float64float64)||
|[deviation(Array<Float64>,Array<Int64>,Int64,Array<UInt32>)](./函数.md#func-deviationarrayfloat64arrayint64int64arrayuint32)|返回三角剖分面积与多边形面积之间的百分比差异|
|[earcut(Array<Float64>,Array<Int64>,Int64)](./函数.md#func-earcutarrayfloat64arrayint64int64)|主入口：对多边形进行 earcut 三角剖分|
|[fromHalfFloat(UInt16)](./函数.md#func-fromhalffloatuint16)||
|[toHalfFloat(Float64)](./函数.md#func-tohalffloatfloat64)||

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[ArcCurve](./类/ArcCurve.md#class-arccurve)|弧曲线类，继承自 EllipseCurve|
|[BoxGeometry](./类/BoxGeometry.md#class-boxgeometry)|长方体几何体类|
|[BufferGeometryGroup](./类/BufferGeometryGroup.md#class-buffergeometrygroup)|绘制组结构，定义几何体的绘制分组|
|[BufferGeometry](./类/BufferGeometry.md#class-buffergeometry)|缓冲几何体类：描述几何体数据（顶点/法线/UV 等属性）|
|[CapsuleGeometry](./类/CapsuleGeometry.md#class-capsulegeometry)|胶囊体几何体类，由圆柱体中间段和两个半球帽组成|
|[CatmullRomCurve3](./类/CatmullRomCurve3.md#class-catmullromcurve3)|3D Catmull-Rom 样条曲线类|
|[CircleGeometry](./类/CircleGeometry.md#class-circlegeometry)|圆形几何体类|
|[ConeGeometry](./类/ConeGeometry.md#class-conegeometry)|圆锥体几何体类，是 CylinderGeometry 的特例（radiusTop = 0）|
|[CubicBezierCurve3](./类/CubicBezierCurve3.md#class-cubicbeziercurve3)|3D 三次贝塞尔曲线类|
|[CubicBezierCurve](./类/CubicBezierCurve.md#class-cubicbeziercurve)|2D 三次贝塞尔曲线类|
|[CurvePath](./类/CurvePath.md#class-curvepath)|曲线路径类，由多条曲线串联而成的复合路径|
|[Curve](./类/Curve.md#class-curve)|曲线抽象基类|
|[CylinderGeometry](./类/CylinderGeometry.md#class-cylindergeometry)|圆柱几何体类|
|[DataUtils](./类/DataUtils.md#class-datautils)|数据工具类，提供半精度浮点数转换的静态方法  此类是 toHalfFloat 和 fromHalfFloat 函数的面向对象封装， 与 Three.js 的 DataUtils 类接口保持一致。|
|[DodecahedronGeometry](./类/DodecahedronGeometry.md#class-dodecahedrongeometry)|十二面体几何体（多面体特例）|
|[Earcut](./类/Earcut.md#class-earcut)|Earcut 多边形三角剖分工具类  提供 earcut 算法的静态接口，将一个 2D 多边形（可能含孔洞） 剖分为若干三角形，返回三角形顶点索引数组。  注意：本文件同时包含底层算法实现（earcut/deviation）与 Earcut 封装类（Windows 文件系统大小写不敏感，Earcut.cj 与 earcut.cj 实为同一文件，故合并于此）。  参见：https://github.com/mapbox/earcut|
|[EdgesGeometry](./类/EdgesGeometry.md#class-edgesgeometry)|边线几何体类，从 BufferGeometry 中提取边线|
|[EllipseCurve](./类/EllipseCurve.md#class-ellipsecurve)|椭圆曲线类|
|[ExtrudeGeometry](./类/ExtrudeGeometry.md#class-extrudegeometry)|挤出几何体类：Shape 轮廓 + 深度挤出|
|[IcosahedronGeometry](./类/IcosahedronGeometry.md#class-icosahedrongeometry)|二十面体几何体（多面体特例）|
|[InstancedBufferGeometry](./类/InstancedBufferGeometry.md#class-instancedbuffergeometry)|实例化缓冲几何体类  实例化缓冲几何体是 {|
|[LatheGeometry](./类/LatheGeometry.md#class-lathegeometry)|车削几何体类|
|[LineCurve3](./类/LineCurve3.md#class-linecurve3)|3D 直线段曲线类|
|[LineCurve](./类/LineCurve.md#class-linecurve)|2D 直线段曲线类|
|[OctahedronGeometry](./类/OctahedronGeometry.md#class-octahedrongeometry)|八面体几何体（多面体特例）|
|[Path](./类/Path.md#class-path)|2D 路径类|
|[PlaneGeometry](./类/PlaneGeometry.md#class-planegeometry)|平面几何体类|
|[PolyhedronGeometry](./类/PolyhedronGeometry.md#class-polyhedrongeometry)|多面体几何体类，将顶点数组投影到球面并细分到指定细节级别|
|[QuadraticBezierCurve3](./类/QuadraticBezierCurve3.md#class-quadraticbeziercurve3)|3D 二次贝塞尔曲线类|
|[QuadraticBezierCurve](./类/QuadraticBezierCurve.md#class-quadraticbeziercurve)|2D 二次贝塞尔曲线类|
|[RingGeometry](./类/RingGeometry.md#class-ringgeometry)|环形几何体类|
|[ShapeGeometry](./类/ShapeGeometry.md#class-shapegeometry)|形状几何体类，从 Shape 三角化生成平面网格|
|[ShapePath](./类/ShapePath.md#class-shapepath)||
|[ShapeUtils](./类/ShapeUtils.md#class-shapeutils)|形状工具类，提供 2D 多边形的面积计算、绕向判断与三角剖分功能|
|[Shape](./类/Shape.md#class-shape)|形状类，定义带可选洞的 2D 形状平面|
|[SphereGeometry](./类/SphereGeometry.md#class-spheregeometry)|球体几何体类|
|[SplineCurve](./类/SplineCurve.md#class-splinecurve)|2D 样条曲线类|
|[TetrahedronGeometry](./类/TetrahedronGeometry.md#class-tetrahedrongeometry)|四面体几何体（多面体特例）|
|[TorusGeometry](./类/TorusGeometry.md#class-torusgeometry)|圆环几何体类|
|[TorusKnotGeometry](./类/TorusKnotGeometry.md#class-torusknotgeometry)|环面纽结几何体类|
|[TubeGeometry](./类/TubeGeometry.md#class-tubegeometry)|管道几何体类，沿 3D 曲线挤出管道|
|[WireframeGeometry](./类/WireframeGeometry.md#class-wireframegeometry)|线框几何体类，从 BufferGeometry 提取所有边线（去重）|

