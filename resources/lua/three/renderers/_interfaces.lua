-- three/renderers/_interfaces.lua —— three.renderers._interfaces 绑定模块
--
-- 返回 three.renderers._interfaces 全局命名空间。需引擎侧先安装 interfaces 绑定：
--     LuaBindingFactory.installPackage(vm, "three.renderers._interfaces")
--
-- 已绑定接口实例：
--   IShaderProgram    —— compile([defines]) / resetHandles() / gfxProgramHandle（整数句柄）
--   IUniformRegistry  —— createUniform / setVec4 / setMat4 / setMat3 / setTexture /
--                        getHandle / release / releasable
--
-- 实例来源：ThreeRenderer.makeShaderProgram(...) / ThreeRenderer.makeUniformRegistry()、
-- Pass.passUniforms()。

return require("three").renderers._interfaces
