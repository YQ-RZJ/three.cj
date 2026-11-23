-- three/utils/constants.lua —— three.utils.constants 绑定模块
--
-- 返回 three.utils.constants 全局命名空间。需引擎侧先安装 constants 绑定：
--     LuaBindingFactory.installPackage(vm, "three.utils.constants")
--
-- 用法：
--     local C = require "three.utils.constants"
--     local side = C.Constants.CullFaceBack()
--     local rev  = C.Constants.REVISION()
--
-- 已绑定类：
--   Constants   引擎常量表（226 个顶层常量，均以静态方法返回；
--               如 MOUSE_LEFT / CullFaceBack / InterpolateLinear /
--               NormalAnimationBlendMode / SRGBColorSpace / REVISION 等）

return require("three").utils.constants
