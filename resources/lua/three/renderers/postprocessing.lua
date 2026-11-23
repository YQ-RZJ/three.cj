-- three/renderers/postprocessing.lua —— three.renderers.postprocessing 绑定模块
--
-- 返回 three.renderers.postprocessing 全局命名空间。需引擎侧先安装 postprocessing 绑定：
--     LuaBindingFactory.installPackage(vm, "three.renderers.postprocessing")
--
-- 已绑定类：
--   Pass / EffectComposer / FullScreenQuad / RenderPass / ShaderPass / MaskPass / ClearMaskPass
--   ClearPass / TexturePass / CubeTexturePass / SavePass / AfterimagePass / BloomPass
--   BokehPass / DotScreenPass / FilmPass / FXAAPass / GlitchPass / GTAOPass / HalftonePass
--   LUTPass / OutlinePass / OutputPass / RenderPixelatedPass / RenderTransitionPass
--   SAOPass / SMAAPass / SSAARenderPass / SSAOPass / SSRPass / TAARenderPass
--   UnrealBloomPass / VolumeCloudPass / PostProcessingShaders
--
-- 注意：EffectComposer.render / addPass / setSize 会投递到渲染线程，须在引擎完成
-- 渲染后端初始化后调用；构造与属性读写可随时使用。

return require("three").renderers.postprocessing
