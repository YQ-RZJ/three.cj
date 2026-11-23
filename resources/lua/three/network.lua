-- three/network.lua —— three.network 绑定模块
--
-- 返回 three.network 全局命名空间。需引擎侧先安装 network 绑定：
--     LuaBindingFactory.installPackage(vm, "three.network")
--
-- 子模块（不创建新的状态，均指向同一全局表）：
--     require "three.network.protocol"   协议包编解码（PacketWriter / PacketReader）
--     require "three.network.http"       HTTP 请求 / 响应 / 客户端
--     require "three.network.socket"     TCP 客户端 / 服务端 / UDP
--     require "three.network.transport"  TCP 长连接 / 可靠 UDP
--     require "three.network.sync"       帧同步 / 快照缓冲

return require("three").network
