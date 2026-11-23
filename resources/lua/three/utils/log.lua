-- three/utils/log.lua —— three.utils.log 绑定模块
--
-- 返回 three.utils.log 全局命名空间。需引擎侧先安装 log 绑定：
--     LuaBindingFactory.installPackage(vm, "three.utils.log")
--
-- 用法：
--     local log = require "three.utils.log"
--     log.Logger.setLevel(log.LogLevel.Warn())
--     log.Logger.warn({"something happened"})
--
-- 已绑定类：
--   Logger     纯静态分级日志（setLevel / getLevel / trace / debug / info / warn / error / warnOnce；
--              日志内容为字符串数组）
--   LogLevel   日志等级枚举（Trace / Debug / Info / Warn / Error / Off，均以整数值返回）

return require("three").utils.log
