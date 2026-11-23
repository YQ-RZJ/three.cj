-- three/scene.lua —— three.scene 绑定模块
--
-- 返回 three.scene 全局命名空间。需引擎侧先安装 scene 绑定：
--     LuaBindingFactory.installPackage(vm, "three.scene")
--
-- 子模块（不创建新的状态，均指向同一全局表）：
--     require "three.scene.ecs"         ECS 运行时 + Lua 装饰器（Component/Entity/System/world）
--     require "three.scene.objects"     Object3D / Layers / Raycaster
--     require "three.scene.entity"      Mesh / SkinnedMesh / Skeleton / Line / Points / Sprite / LOD …
--     require "three.scene.scenegraph"  Scene / Group / Fog / FogExp2 / ClippingGroup

local scene = require("three").scene
require("three.scene.ecs")
return scene
