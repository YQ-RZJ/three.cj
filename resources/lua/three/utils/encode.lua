-- three/utils/encode.lua —— three.utils.encode 绑定模块
--
-- 返回 three.utils.encode 全局命名空间。需引擎侧先安装 encode 绑定：
--     LuaBindingFactory.installPackage(vm, "three.utils.encode")
--
-- 用法：
--     local encode = require "three.utils.encode"
--     local id = encode.UUID.uuid()
--
-- 已绑定类：
--   UUID   纯静态 uuid()（RFC 4122 v4 随机 UUID 字符串）

return require("three").utils.encode
