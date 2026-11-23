-- three/renderers/textures.lua —— three.renderers.textures 绑定模块
--
-- 返回 three.renderers.textures 全局命名空间。需引擎侧先安装 textures 绑定：
--     LuaBindingFactory.installPackage(vm, "three.renderers.textures")
--
-- 已绑定类：
--   Texture / Source / DataTexture / Data3DTexture / DataArrayTexture
--   CompressedTexture / CompressedArrayTexture / CompressedCubeTexture
--   CubeTexture / CubeDepthTexture / DepthTexture / CanvasTexture / VideoTexture
--   VideoFrameTexture / FramebufferTexture / ExternalTexture
--   ImageUtils / TextureUtils / TypeByteLength / PMREMGenerator

return require("three").renderers.textures
