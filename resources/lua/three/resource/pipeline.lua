-- three/resource/pipeline.lua —— three.resource.pipeline 绑定模块
--
-- 返回 three.resource.pipeline 全局命名空间。需引擎侧先安装 pipeline 绑定：
--     LuaBindingFactory.installPackage(vm, "three.resource.pipeline")
--
-- 用法：
--     local P = require "three.resource.pipeline"
--     local mgr = P.AssetManager.new()
--     mgr:registerLoader("json", loader)
--     local asset = mgr:load("config.json")
--
-- 已绑定类：
--   BundleEntry        bundle 条目（值对象）
--   AssetBundle        资源包（加载 / 查找 / 读取 / 释放）
--   AssetBundleBuilder 资源包构建器
--   AssetCache         资源缓存（IReleasable）
--   AssetManager       资源管理器（加载器注册 / 异步加载 / 引用计数）

return require("three").resource.pipeline
