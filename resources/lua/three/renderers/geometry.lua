-- three/renderers/geometry.lua —— three.renderers.geometry 绑定模块
--
-- 返回 three.renderers.geometry 全局命名空间。需引擎侧先安装 geometry 绑定：
--     LuaBindingFactory.installPackage(vm, "three.renderers.geometry")
--
-- 已绑定类：
--   BufferGeometry / BufferGeometryGroup / InstancedBufferGeometry
--   Curve / CurvePath / Path / Shape / ShapePath / ShapeUtils / DataUtils / Earcut
--   EllipseCurve / ArcCurve / LineCurve / LineCurve3 / CatmullRomCurve3
--   CubicBezierCurve / CubicBezierCurve3 / QuadraticBezierCurve / QuadraticBezierCurve3 / SplineCurve
--   BoxGeometry / CapsuleGeometry / CircleGeometry / ConeGeometry / CylinderGeometry
--   DodecahedronGeometry / EdgesGeometry / ExtrudeGeometry / IcosahedronGeometry / LatheGeometry
--   OctahedronGeometry / PlaneGeometry / PolyhedronGeometry / RingGeometry / ShapeGeometry
--   SphereGeometry / TetrahedronGeometry / TorusGeometry / TorusKnotGeometry / TubeGeometry
--   WireframeGeometry

return require("three").renderers.geometry
