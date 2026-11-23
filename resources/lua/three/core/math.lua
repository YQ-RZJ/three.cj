-- three/core/math.lua —— three.core.math 绑定模块
--
-- 返回 three.core.math 全局命名空间。需引擎侧先安装 math 绑定：
--     LuaBindingFactory.installPackage(vm, "three.core.math")
--
-- 用法：
--     local math = require "three.core.math"
--     local v = math.Vector3.new(1, 2, 3)
--     local m = math.Matrix4.new()
--     v:applyMatrix4(m)
--
-- 已绑定类（MathUtils / Box / Plane / Ray / Triangle / Frustum / 向量 / 矩阵 / 四元数 / 颜色等）：
--   Vector2 Vector3 Vector4 Vector3F Vector4F
--   Matrix2 Matrix3 Matrix4 Color Color4 Euler Quaternion Spherical Cylindrical
--   MathUtils Box2 Box3 Plane Ray Line3 Sphere Triangle Frustum SphericalHarmonics3
--   Interpolant ColorManagement ColorSpaceDefinition ColorSpaceWorkingConfig ColorSpaceOutputConfig
--   math.interpolants.LinearInterpolant / DiscreteInterpolant / CubicInterpolant /
--   QuaternionLinearInterpolant / BezierInterpolant

return require("three").core.math