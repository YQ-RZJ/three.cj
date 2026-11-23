-- three.lua —— 引擎 Lua 绑定总入口
--
-- 在仓颉侧调用 LuaBindingFactory.installAll(vm)（或 install/installPackage 按需安装）之后，
-- 引擎绑定的类表会出现在 Lua 全局命名空间 three.* 下（如 three.core.math.Vector3）。
-- 本模块通过惰性代理返回该全局 three 表，避免与"安装时机"耦合：
--
--     local three = require "three"
--     local v = three.core.math.Vector3.new(1, 2, 3)
--     v:set(4, 5, 6):normalize()
--
-- 子模块（不创建新的状态，均指向同一全局表）：
--     require "three.core.math"
--     require "three.core.dsa"
--     require "three.core.event"
--     require "three.core.dispatch"
--     require "three.core.thread"
--     require "three.core.time"
--     require "three.core.system"
--     require "three.animation.blend"
--     require "three.animation.tracks"
--     require "three.animation.clip"
--     require "three.animation.offline"
--     require "three.animation.skeletal"
--     require "three.audio.device"
--     require "three.audio.listener"
--     require "three.audio.mixer"
--     require "three.audio.source"
--     require "three.audio.capture"
--     require "three.network.protocol"
--     require "three.network.http"
--     require "three.network.socket"
--     require "three.network.transport"
--     require "three.network.sync"
--     require "three.physics.interfaces"
--     require "three.physics.world"
--     require "three.physics.body"
--     require "three.physics.constraint"
--     require "three.physics.character"
--     require "three.physics.heightfield"
--     require "three.physics.softbody"
--     require "three.physics.vehicle"
--     require "three.physics.ragdoll"
--     require "three.physics.debug"
--     require "three.physics.binding"
--     require "three.physics.backend"
--     require "three.profiler"
--     require "three.resource.cache"
--     require "three.resource.archive"
--     require "three.resource.serializer"
--     require "three.resource.pipeline"
--     require "three.resource.loader"
--     require "three.renderers.buffer"
--     require "three.renderers.textures"
--     require "three.renderers.geometry"
--     require "three.renderers.materials"
--     require "three.renderers.cameras"
--     require "three.renderers.lights"
--     require "three.renderers.rendertarget"
--     require "three.renderers.helpers"
--     require "three.renderers.postprocessing"
--     require "three.utils.safe"
--     require "three.utils.pool"
--     require "three.utils.log"
--     require "three.utils.encode"
--     require "three.utils.constants"
--     require "three.utils.memory"
--     require "three.utils.allocator"

local proxy = {}

setmetatable(proxy, {
    __index = function(_, k)
        local t = _G.three
        if t == nil then
            return nil
        end
        return t[k]
    end,
    __newindex = function(_, k, v)
        local t = _G.three
        if t == nil then
            error("three: engine global namespace 'three' not installed (call LuaBindingFactory first)")
        end
        t[k] = v
    end
})

return proxy