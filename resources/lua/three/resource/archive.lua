-- three/resource/archive.lua —— three.resource.archive 绑定模块
--
-- 返回 three.resource.archive 全局命名空间。需引擎侧先安装 archive 绑定：
--     LuaBindingFactory.installPackage(vm, "three.resource.archive")
--
-- 用法：
--     local A = require "three.resource.archive"
--     local zip = A.ZipArchive.loadFromFile("assets.zip")
--     if zip then
--         local bytes = zip:read("data/level.json")
--         zip:extractAll("out/")
--     end
--
-- 已绑定类：
--   ZipEntry    条目元信息（name / isDirectory / compressedSize / uncompressedSize /
--               crc32 / method / flags）
--   ZipArchive  ZIP 包（entries / entryCount / loadFromBytes / loadFromFile / find /
--               read / extractAll）

return require("three").resource.archive
