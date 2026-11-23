-- three/window.lua —— three.window 绑定模块 + 声明式窗口门面
--
-- 返回 three.window 全局命名空间。需引擎侧先安装 window 绑定：
--     LuaBindingFactory.installPackage(vm, "three.window")
--
-- 子模块（不创建新的状态，均指向同一全局表）：
--     require "three.window.ui"     ImGui 控件 / 布局 / 样式 / 字体 / 绘制列表 + 声明式辅助函数
--
-- 声明式窗口用法（等价 Cangjie 的 Window{} 尾随闭包）：
--
--   local W = require "three.window"
--   local ui = require "three.window.ui"
--   local win = W.window("Demo", 1280, 720, function(w)
--       w:ui(function()
--           ui.window("Panel", function()
--               ui.text("Hello")
--               if ui.button("OK") then print("clicked") end
--           end)
--       end)
--   end)
--   win:run()   -- 阻塞主线程；回调用窗口泵线程执行（见绑定注释的线程约定）
--
-- 说明：Cangjie 侧的 Window 构造要求 build 闭包，绑定层以空实现创建；
-- 本模块的 W.window 在 new 之后调用 body，语义等价，且能拿到规范化后的 Lua 对象。

local window = require("three").window

require("three.window.ui")

--- 创建声明式窗口并在 new 之后执行声明函数（等价 Cangjie 的 build 闭包）
-- @param title string 窗口标题
-- @param width number 逻辑宽度
-- @param height number 逻辑高度
-- @param body function? 声明函数，入参为窗口对象
-- @param config table? WindowConfig 对象
-- @return Window 窗口对象
function window.window(title, width, height, body, config)
    local win = window.Window.new(title, width, height, config)
    if body ~= nil then
        body(win)
    end
    return win
end

return window
