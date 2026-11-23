-- three/core/event.lua —— three.core.event 绑定模块
--
-- 需引擎侧先安装 event 绑定：
--     LuaBindingFactory.installPackage(vm, "three.core.event")
--
-- 已绑定类：Event / EventDispatcher / ListenerHandle / EventManager /
-- EventRecord / EventFactory
--
-- 用法：
--     local event = require "three.core.event"
--     local ed = event.EventDispatcher.new()
--     ed:addEventListener("boom", function(e) print("boom!", e.type) end)
--     ed:dispatchEvent(event.Event.new("boom"))

return require("three").core.event