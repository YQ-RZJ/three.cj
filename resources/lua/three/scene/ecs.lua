-- three/scene/ecs.lua —— three.scene.ecs 绑定模块 + Lua 侧 ECS 装饰器
--
-- 返回 three.scene.ecs 全局命名空间。需引擎侧先安装 ecs 绑定：
--     LuaBindingFactory.installPackage(vm, "three.scene.ecs")
--
-- 仓颉侧的 @Component / @Entity / @System 是编译期宏，无法进入 Lua。
-- 本模块在绑定的 ecs 命名空间上追加 `decorator`（以及小写别名），用 Lua 元表实现
-- 与宏等价的语义（类似 JS 装饰器）：
--
--   local ecs = require "three.scene.ecs"
--   local D = ecs.decorator
--
--   -- 组件：盖类级唯一 ID 印章（与仓颉组件共用 ComponentRegistry 的 ID 空间）
--   local PositionCpt = D.Component("Position", { x = 0.0, y = 0.0 })
--   local p = PositionCpt.new()
--
--   -- 实体：实例 ID + 组件表 + 掩码 + 生命周期钩子
--   local Player = D.Entity("Player")
--   local e = Player.new()
--   e:addComponent(PositionCpt.new())
--
--   -- 系统：登记所需组件，注入 collectCptMask / cptMask（支持父系统掩码叠加）
--   local MoveSystem = D.System("MoveSystem", { PositionCpt }, function(sys, list, dt)
--       for i = 1, #list do local e = list[i] ... end
--   end)
--
--   -- Lua 世界：实体/系统编排 + onUpdate 过滤派发
--   local world = D.world()
--   world:addSystem(MoveSystem.new())
--   world:addEntity(e)
--   world:onUpdate(1 / 60)
--
-- 与仓颉 ECS 的关系：绑定类 ecs.Component / Entity / System / World 仍可直接使用
-- （面向仓颉组件与原生管理器）；decorator 产出的是纯 Lua 对象，用于脚本侧快速扩展，
-- 两者通过 ComponentRegistry 共享组件 ID 空间。

local ecs = require("three").scene.ecs

local M = ecs.decorator or {}
ecs.decorator = M
ecs.component = M.Component
ecs.entity = M.Entity
ecs.system = M.System
ecs.world = M.world

-- ===========================================================================
-- 组件 ID 登记
-- ===========================================================================
local Registry = ecs.ComponentRegistry
local _localNextId = 1
local _localIds = {}

-- 为组件类申请全局唯一 ID：优先走引擎注册表（registerType），失败回退本地自增
local function registerComponentId(key)
    if Registry ~= nil and Registry.registerType ~= nil then
        local ok, id = pcall(Registry.registerType, key)
        if ok and type(id) == "number" then
            return id
        end
    end
    if _localIds[key] == nil then
        _localIds[key] = _localNextId
        _localNextId = _localNextId + 1
    end
    return _localIds[key]
end

-- 浅拷贝类表上的非函数字段到实例（作为默认值）
local function applyDefaults(obj, cls)
    for k, v in pairs(cls) do
        if type(v) ~= "function" and k ~= "__name" and k ~= "__cptId" then
            obj[k] = v
        end
    end
end

-- ===========================================================================
-- 掩码：稀疏 id 集合，提供与 BitArray 相近的 set/get/cover/clear
-- ===========================================================================
local MaskMT = {}
MaskMT.__index = MaskMT

function MaskMT:set(id, value)
    if value == false then
        self[id] = nil
    else
        self[id] = true
    end
end

function MaskMT:get(id)
    return self[id] == true
end

function MaskMT:clear()
    for k in pairs(self) do
        self[k] = nil
    end
end

-- 当前掩码是否覆盖 other（other 中置位的 id 本掩码也必须置位）
function MaskMT:cover(other)
    for id in pairs(other) do
        if self[id] ~= true then
            return false
        end
    end
    return true
end

function MaskMT:copy()
    local m = setmetatable({}, MaskMT)
    for id in pairs(self) do
        m[id] = true
    end
    return m
end

function M.Mask()
    return setmetatable({}, MaskMT)
end

-- ===========================================================================
-- 组件装饰器：@Component 等价
-- ===========================================================================
--- 定义 / 装饰一个 Lua 组件类。
-- @param nameOrClass 组件名（字符串）或已存在的类表
-- @param fields 可选，字段默认值表
-- @return 组件类表（提供 typeId() 静态访问与 new(...) 构造）
function M.Component(nameOrClass, fields)
    local cls
    local name
    if type(nameOrClass) == "string" then
        cls = {}
        name = nameOrClass
    elseif type(nameOrClass) == "table" then
        cls = nameOrClass
        name = cls.__name or "LuaComponent"
    else
        cls = {}
        name = "LuaComponent"
    end
    cls.__name = name
    if fields ~= nil then
        for k, v in pairs(fields) do
            if cls[k] == nil then
                cls[k] = v
            end
        end
    end
    local key = cls.__key or ("lua.component." .. name)
    local id = registerComponentId(key)
    cls.__cptId = id
    cls.isComponent = true

    -- 等价于宏注入的 public static func typeId()
    function cls.typeId()
        return id
    end

    -- 等价于宏注入的实例 cptId + 无参工厂（对象池语义的简化版）
    function cls.new(...)
        local obj = {}
        applyDefaults(obj, cls)
        obj.cptId = id
        obj.entity = nil
        obj.__class = cls
        setmetatable(obj, { __index = cls })
        if type(cls.init) == "function" then
            cls.init(obj, ...)
        end
        return obj
    end

    return cls
end

-- ===========================================================================
-- 实体装饰器：@Entity 等价
-- ===========================================================================
local _nextEntityId = 1

local function allocateEntityId()
    local id = _nextEntityId
    _nextEntityId = _nextEntityId + 1
    return id
end

--- 定义 / 装饰一个 Lua 实体类。
-- @param nameOrClass 实体名（字符串）或已存在的类表
-- @param fields 可选，字段默认值表
-- @return 实体类表（提供 new() / addComponent / getComponent / hasComponent /
--         removeComponentById / removeAllComponents / construct / restruct / destruct）
function M.Entity(nameOrClass, fields)
    local cls
    local name
    if type(nameOrClass) == "string" then
        cls = {}
        name = nameOrClass
    elseif type(nameOrClass) == "table" then
        cls = nameOrClass
        name = cls.__name or "LuaEntity"
    else
        cls = {}
        name = "LuaEntity"
    end
    cls.__name = name
    if fields ~= nil then
        for k, v in pairs(fields) do
            if cls[k] == nil then
                cls[k] = v
            end
        end
    end
    cls.isEntity = true

    function cls.new(...)
        local obj = {}
        applyDefaults(obj, cls)
        obj.etyId = allocateEntityId()
        obj.__components = {}
        obj.__cptMask = M.Mask()
        obj.__class = cls
        obj.__constructed = true
        setmetatable(obj, { __index = cls })
        if type(cls.init) == "function" then
            cls.init(obj, ...)
        end
        if type(cls.onConstruct) == "function" then
            cls.onConstruct(obj)
        end
        return obj
    end

    function cls.addComponent(self, c)
        if c == nil or c.cptId == nil then
            return false
        end
        if self.__components[c.cptId] ~= nil then
            return false
        end
        self.__components[c.cptId] = c
        self.__cptMask:set(c.cptId, true)
        c.entity = self
        if type(c.restruct) == "function" then
            c:restruct()
        end
        if self.__world ~= nil then
            self.__world:_touch(self)
        end
        return true
    end

    function cls.getComponent(self, cptId)
        return self.__components[cptId]
    end

    function cls.hasComponent(self, cptId)
        return self.__cptMask:get(cptId)
    end

    function cls.removeComponentById(self, cptId)
        local c = self.__components[cptId]
        if c == nil then
            return nil
        end
        self.__components[cptId] = nil
        self.__cptMask:set(cptId, false)
        c.entity = nil
        if type(c.destruct) == "function" then
            c:destruct()
        end
        if self.__world ~= nil then
            self.__world:_touch(self)
        end
        return c
    end

    function cls.removeAllComponents(self)
        for id, c in pairs(self.__components) do
            c.entity = nil
            if type(c.destruct) == "function" then
                c:destruct()
            end
        end
        self.__components = {}
        self.__cptMask:clear()
        if self.__world ~= nil then
            self.__world:_touch(self)
        end
    end

    function cls.componentCount(self)
        local n = 0
        for _ in pairs(self.__components) do
            n = n + 1
        end
        return n
    end

    function cls.cptMask(self)
        return self.__cptMask
    end

    function cls.construct(self)
        if not self.__constructed then
            self.__constructed = true
            if type(cls.onConstruct) == "function" then
                cls.onConstruct(self)
            end
        end
    end

    function cls.restruct(self)
        self.__constructed = true
        if type(cls.onConstruct) == "function" then
            cls.onConstruct(self)
        end
    end

    function cls.destruct(self)
        if self.__constructed then
            if type(cls.onDestruct) == "function" then
                cls.onDestruct(self)
            end
            self:removeAllComponents()
            self.__constructed = false
        end
    end

    return cls
end

-- ===========================================================================
-- 系统装饰器：@System[cpt...] 等价
-- ===========================================================================
local _nextSystemId = 1

--- 定义 / 装饰一个 Lua 系统类。
-- @param nameOrClass 系统名（字符串）或已存在的类表
-- @param cpts 所需组件类数组（可为 nil / 空表）
-- @param update 可选，onUpdate(self, entities, dt) 实现
-- @param parent 可选，父系统类表（其 collectCptMask 会先执行，等价 super 叠加）
-- @return 系统类表
function M.System(nameOrClass, cpts, update, parent)
    local cls
    local name
    if type(nameOrClass) == "string" then
        cls = {}
        name = nameOrClass
    elseif type(nameOrClass) == "table" then
        cls = nameOrClass
        name = cls.__name or "LuaSystem"
    else
        cls = {}
        name = "LuaSystem"
    end
    cls.__name = name
    cls.isSystem = true
    cls.__required = {}
    cls.__parentSystem = parent
    if cpts ~= nil then
        for i = 1, #cpts do
            local c = cpts[i]
            local id = c
            if type(c) == "table" and type(c.typeId) == "function" then
                id = c.typeId()
            end
            cls.__required[#cls.__required + 1] = id
        end
    end
    if type(update) == "function" then
        cls.onUpdate = update
    end
    if cls.isActive == nil then
        cls.isActive = true
    end

    function cls.new(...)
        local obj = {}
        applyDefaults(obj, cls)
        obj.sysId = _nextSystemId
        _nextSystemId = _nextSystemId + 1
        obj.isActive = true
        obj.__maskReady = false
        obj.__cptMask = M.Mask()
        obj.__class = cls
        setmetatable(obj, { __index = cls })
        if type(cls.init) == "function" then
            cls.init(obj, ...)
        end
        return obj
    end

    -- 等价于 @System 宏注入的 collectCptMask：先父系统叠加，再置位本类所需组件
    function cls.collectCptMask(self, mask)
        if cls.__parentSystem ~= nil and type(cls.__parentSystem.collectCptMask) == "function" then
            cls.__parentSystem.collectCptMask(self, mask)
        end
        for i = 1, #cls.__required do
            mask:set(cls.__required[i], true)
        end
    end

    -- 惰性收集（与仓颉 System.cptMask 语义一致）
    function cls.cptMask(self)
        if not self.__maskReady then
            self.__maskReady = true
            cls.collectCptMask(self, self.__cptMask)
        end
        return self.__cptMask
    end

    return cls
end

-- ===========================================================================
-- Lua 世界：实体 / 系统编排
-- ===========================================================================
local WorldMT = {}
WorldMT.__index = WorldMT

--- 创建一个 Lua 世界
-- @return world 对象（addEntity / delEntity / addSystem / delSystemById / onUpdate / clear）
function M.world()
    return setmetatable({
        __entities = {},
        __systems = {},
        __order = {},
        __dirty = false
    }, WorldMT)
end

function WorldMT:_touch(entity)
    self.__dirty = true
end

function WorldMT:addEntity(e)
    if e == nil or e.etyId == nil then
        return nil
    end
    e.__world = self
    self.__entities[e.etyId] = e
    self.__dirty = true
    return e.etyId
end

function WorldMT:getEntity(id)
    return self.__entities[id]
end

function WorldMT:delEntity(id)
    local e = self.__entities[id]
    if e ~= nil then
        if type(e.destruct) == "function" then
            e:destruct()
        end
        e.__world = nil
        self.__entities[id] = nil
        self.__dirty = true
    end
    return e
end

function WorldMT:entities()
    local out = {}
    for _, e in pairs(self.__entities) do
        out[#out + 1] = e
    end
    return out
end

function WorldMT:addSystem(sys)
    if sys == nil or sys.sysId == nil then
        return nil
    end
    self.__systems[sys.sysId] = sys
    self.__order[#self.__order + 1] = sys.sysId
    self.__dirty = true
    return sys.sysId
end

function WorldMT:delSystemById(id)
    local sys = self.__systems[id]
    if sys == nil then
        return nil
    end
    self.__systems[id] = nil
    local kept = {}
    for i = 1, #self.__order do
        if self.__order[i] ~= id then
            kept[#kept + 1] = self.__order[i]
        end
    end
    self.__order = kept
    self.__dirty = true
    return sys
end

-- 按 updateOrder 顺序派发：对每个激活系统，筛选掩码覆盖其需求的实体
function WorldMT:onUpdate(dt)
    for i = 1, #self.__order do
        local sys = self.__systems[self.__order[i]]
        if sys ~= nil and sys.isActive then
            local mask = sys:cptMask()
            local list = {}
            for _, e in pairs(self.__entities) do
                if mask:cover(e.__cptMask) then
                    list[#list + 1] = e
                end
            end
            if type(sys.onUpdate) == "function" then
                sys:onUpdate(list, dt)
            end
        end
    end
end

function WorldMT:clear()
    for _, e in pairs(self.__entities) do
        if type(e.destruct) == "function" then
            e:destruct()
        end
        e.__world = nil
    end
    self.__entities = {}
    self.__systems = {}
    self.__order = {}
    self.__dirty = false
end

return ecs
