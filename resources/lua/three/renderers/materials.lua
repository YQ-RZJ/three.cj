-- three/renderers/materials.lua —— three.renderers.materials 绑定模块
--
-- 返回 three.renderers.materials 全局命名空间。需引擎侧先安装 materials 绑定：
--     LuaBindingFactory.installPackage(vm, "three.renderers.materials")
--
-- 已绑定类：
--   Material / MeshBasicMaterial / MeshStandardMaterial / MeshPhysicalMaterial
--   MeshPhongMaterial / MeshLambertMaterial / MeshToonMaterial / MeshNormalMaterial
--   MeshMatcapMaterial / MeshDepthMaterial / MeshDistanceMaterial
--   SpriteMaterial / ShadowMaterial / PointsMaterial / LineBasicMaterial / LineDashedMaterial
--   ReflectorMaterial / ShaderMaterial / RawShaderMaterial
--   ShadowProjMaterial / ShadowFrustumMaterial / ShadowBlitMaterial
--   PcfVizMaterial / LightDirMaterial / DepthVizMaterial / MaterialOverrideScope

return require("three").renderers.materials
