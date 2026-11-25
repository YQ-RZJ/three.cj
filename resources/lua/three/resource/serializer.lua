-- three/resource/serializer.lua —— three.resource.serializer 绑定模块 + Lua 侧 JSON 注解能力
--
-- 返回 three.resource.serializer 全局命名空间。需引擎侧先安装 serializer 绑定：
--     LuaBindingFactory.installPackage(vm, "three.resource.serializer")
--
-- 编解码实现：本模块不再手写 JSON 语法，而是复用引擎的 cjfast_json（three.resource.serializer
-- 重导出）——由绑定 three.resource.serializer.JsonUtil 提供：
--     JsonUtil.parse(text, nullValue)         JSON 文本 → Lua 值（对象/数组 → 表，null → 哨兵）
--     JsonUtil.isValid(text)                  文本是否可解析
--     JsonUtil.stringify(value, opts)         Lua 值 → JSON 文本
-- 本模块只保留「注解与适配器（Adapter）」这一层：字段元数据、类型校验、继承、多态分派。
--
-- 仓颉侧的 @JsonAdapter / @JsonName / @JsonIgnore / @JsonIgnoreNull / @JsonCustom 是编译期宏，
-- 无法进入 Lua。本模块在绑定的 serializer 命名空间上追加一套等价的 Lua 实现（参考 scene/ecs.lua
-- 的装饰器方案）：
--
--   local S = require "three.resource.serializer"
--   local J = S.decorator
--
--   -- JSON 编解码（通用，无需注解）
--   local text = S.encode({ id = 1, tags = { "a", "b" } }, { pretty = true })
--   local value = S.decode(text)
--
--   -- 带注解的类（等价 @JsonAdapter）
--   local Vec = J.Adapter("Vec", {
--       { name = "x", type = "number", default = 0.0 },
--       { name = "y", type = "number", default = 0.0 },
--   })
--   local v = Vec.new(1, 2)
--   v:toJson()                 -- {"x":1,"y":2}
--   Vec.fromJson('{"x":3,"y":4}')
--
--   -- 字段注解（等价 @JsonName / @JsonIgnore / @JsonIgnoreNull / @JsonCustom）
--   local Player = J.Adapter("Player", {
--       { name = "id",   type = "number" },
--       { name = "nick", jsonName = "nickname" },          -- @JsonName
--       { name = "cache", ignore = true },                  -- @JsonIgnore
--       { name = "tag",  ignoreNull = true },               -- @JsonIgnoreNull
--       { name = "meta", custom = "metaJson" },             -- @JsonCustom
--       { name = "_secret", type = "string" },              -- ignorePrivate 时跳过
--   }, { ignorePrivate = true, metaJson = {                 -- 自定义字段读写器
--       get = function(obj) return { level = 3 } end,
--       set = function(obj, value) obj.metaLevel = value and value.level or 0 end,
--   }})
--
--   -- 继承（等价 @JsonAdapter(withSuperClass = true)）
--   local Boss = J.Adapter("Boss", { { name = "hp", type = "number" } },
--       { withSuperClass = Player })
--
--   -- 多态（等价 @JsonAdapter(polymorphic = true) + 注册表）
--   local Shape = J.Adapter("Shape", { { name = "area", type = "number" } },
--       { polymorphic = true })
--   J.register(Shape)
--   -- toJson 会写入 "kind":"Shape"；fromJson 按 kind 分派到注册类
--
-- 语义对应关系：
--   @JsonAdapter(attr)        -> J.Adapter(nameOrClass, fields, opts)
--   @JsonAdapter(withSuperClass) -> opts.withSuperClass = 父类
--   @JsonAdapter(ignorePrivate)  -> opts.ignorePrivate = true（默认私有前缀 "_"）
--   @JsonAdapter(polymorphic)    -> opts.polymorphic = true + J.register(cls)
--   @JsonAdapter(genericType)    -> Lua 无泛型，忽略（字段按动态类型处理）
--   @JsonName("n")            -> 字段 jsonName = "n" 或 J.JsonName("n")
--   @JsonIgnore               -> 字段 ignore = true 或 J.JsonIgnore()
--   @JsonIgnoreNull           -> 字段 ignoreNull = true 或 J.JsonIgnoreNull()
--   @JsonCustom["f"]          -> 字段 custom = 属性名；opts[属性名] = { get=, set= }
--   嵌套对象                   -> 字段 cls = 子类（fromJson 自动构造）
--   Option<T> / None          -> nil 或 S.null（JSON null）
--
-- 字段描述（全部可选，除 name）：
--   name       string   字段名
--   type       string   "number" / "integer" / "string" / "boolean" / "any"（默认 any）
--   jsonName   string   JSON 键名
--   ignore     boolean  序列化与反序列化都跳过
--   ignoreNull boolean  值为 nil / S.null 时不写出
--   custom     string   自定义读写器属性名（对应 opts[属性名] = { get=, set= }）
--   cls        table    嵌套 Adapter 类
--   arrayOf    table    数组元素 Adapter 类（值为数组时逐项构造）
--   default    any      构造默认值（缺省 nil）
--   meta       table    J.JsonName() 等注解标记（与上面的键等价）
--
-- encode 选项（与 JsonUtil.stringify 一致）：
--   pretty      boolean|number  美化输出（true = 2 空格；数字 = 缩进空格数）
--   indent      string          自定义缩进串（优先于 pretty）
--   sortKeys    boolean         对象键按字典序输出
--   ignoreNull  boolean         值为 nil / S.null 的字段不写出（数组内保留 null）
--   maxDepth    number          最大嵌套深度（缺省 256）
--
-- 注意：字节 / 字符串类编解码请复用引擎已绑定的 three.utils.encode（UUID / Base64 / Hex /
-- UrlEncode / Hash / MD5 / SHA / GroupVarint），典型用法是在 @JsonCustom 读写器中组合，例如：
--     local E = require "three.utils.encode"
--     local Blob = J.Adapter("Blob", { { name = "data", custom = "dataB64" } }, {
--         dataB64 = {
--             get = function(o) return E.Base64.encode(o.raw) end,
--             set = function(o, v) o.raw = E.Base64.decode(v) end,
--         },
--     })

local serializer = require("three").resource.serializer

-- 引擎 JSON 桥接（three.resource.serializer.JsonUtil，由 prebind 安装）
local JsonUtil = serializer.JsonUtil
if JsonUtil == nil then
    error("three.resource.serializer 需要引擎侧安装 JsonUtil 绑定（LuaBindingFactory）", 2)
end

-- 最大嵌套深度（与引擎桥接缺省值一致）
local MAX_DEPTH = 256

-- ===========================================================================
-- JSON null 哨兵与数组标记
-- ===========================================================================
--- JSON null 哨兵（Lua 的 nil 无法存入表，故用唯一表表示显式 null）
local NULL = setmetatable({}, {
    __tostring = function() return "null" end,
    __eq = function(a, b) return a == b end,
})

--- 强制按 JSON 数组编码的标记（空表默认编码为 {}；__jsonArray 供引擎桥接识别）
local ARRAY_MT = { __jsonArray = true }

-- ===========================================================================
-- 注解标记（与仓颉宏同名，返回字段元数据片段）
-- ===========================================================================
local J = {}

--- @JsonName 等价：指定 JSON 键名
-- @param name JSON 键名
-- @return 元数据表
function J.JsonName(name)
    if type(name) ~= "string" or name == "" then
        error("JsonName expects a non-empty string", 2)
    end
    return { jsonName = name }
end

--- @JsonIgnore 等价：跳过该字段
-- @return 元数据表
function J.JsonIgnore()
    return { ignore = true }
end

--- @JsonIgnoreNull 等价：值为 null 时不写出
-- @return 元数据表
function J.JsonIgnoreNull()
    return { ignoreNull = true }
end

--- @JsonCustom 等价：指定目标字段的自定义读写器属性名
-- @param fieldName 目标字段名
-- @return 元数据表
function J.JsonCustom(fieldName)
    if type(fieldName) ~= "string" or fieldName == "" then
        error("JsonCustom expects a non-empty target field name", 2)
    end
    return { custom = fieldName }
end

-- ===========================================================================
-- Adapter：类定义 / 继承 / 注册表
-- ===========================================================================
J.registry = {}

--- 规范化字段描述（合并 meta 注解标记）
local function normalizeField(desc, index)
    if type(desc) ~= "table" then
        error(string.format("field #%d must be a table", index), 3)
    end
    local field = {}
    local meta = desc.meta
    if type(meta) == "table" then
        for k, v in pairs(meta) do field[k] = v end
    end
    for _, key in ipairs({ "name", "type", "jsonName", "ignore", "ignoreNull",
                           "custom", "cls", "arrayOf", "default" }) do
        if desc[key] ~= nil then field[key] = desc[key] end
    end
    if type(field.name) ~= "string" or field.name == "" then
        error(string.format("field #%d requires a non-empty 'name'", index), 3)
    end
    field.ignore = field.ignore == true
    field.ignoreNull = field.ignoreNull == true
    return field
end

--- 递归收集字段（父类在前，本类在后）并按 ignorePrivate 过滤私有字段
local function collectFields(cls, ignorePrivate)
    local out = {}
    local base = cls.__baseClass
    if base ~= nil then
        local parentFields = collectFields(base, ignorePrivate)
        for i = 1, #parentFields do out[#out + 1] = parentFields[i] end
    end
    for i = 1, #cls.__ownFields do
        local field = cls.__ownFields[i]
        local isPrivate = ignorePrivate and string.sub(field.name, 1, #cls.__privatePrefix) == cls.__privatePrefix
        if not isPrivate then
            out[#out + 1] = field
        end
    end
    return out
end

--- 收集自定义读写器（父类 → 本类，子类覆盖父类）
local function collectCustoms(cls)
    local out = {}
    local base = cls.__baseClass
    if base ~= nil then
        local parentCustoms = collectCustoms(base)
        for k, v in pairs(parentCustoms) do out[k] = v end
    end
    for k, v in pairs(cls.__ownCustoms) do out[k] = v end
    return out
end

--- 类链上是否启用多态（本类或任一父类 polymorphic = true）
local function isPolymorphic(cls)
    local c = cls
    while c ~= nil do
        if c.__polymorphic then return true end
        c = c.__baseClass
    end
    return false
end

--- 取字段的 JSON 键名
local function fieldKey(field)
    return field.jsonName or field.name
end

--- 按字段类型校验 / 转换反序列化值
local function coerceValue(field, raw, cls)
    if raw == NULL then return nil end
    if raw == nil then return nil end
    if field.cls ~= nil then
        if type(raw) ~= "table" then
            error(string.format("%s.%s expects an object", cls.__kind, field.name), 0)
        end
        return field.cls.fromTable(raw)
    end
    if field.arrayOf ~= nil then
        if type(raw) ~= "table" then
            error(string.format("%s.%s expects an array", cls.__kind, field.name), 0)
        end
        local out = {}
        for i = 1, #raw do
            local item = raw[i]
            if item == NULL then
                out[i] = NULL
            elseif item ~= nil then
                out[i] = field.arrayOf.fromTable(item)
            end
        end
        return out
    end
    local t = field.type
    if t == "number" or t == "integer" then
        if type(raw) ~= "number" then
            error(string.format("%s.%s expects a number", cls.__kind, field.name), 0)
        end
        return raw
    elseif t == "string" then
        if type(raw) ~= "string" then
            error(string.format("%s.%s expects a string", cls.__kind, field.name), 0)
        end
        return raw
    elseif t == "boolean" then
        if type(raw) ~= "boolean" then
            error(string.format("%s.%s expects a boolean", cls.__kind, field.name), 0)
        end
        return raw
    end
    return raw
end

--- 从普通表填充实例（含父类字段）
local function fillFromTable(cls, obj, source)
    local fields = cls.__allFields
    for i = 1, #fields do
        local field = fields[i]
        if not field.ignore then
            local key = fieldKey(field)
            local raw = source[key]
            if field.custom ~= nil then
                local writer = cls.__customs[field.custom]
                if writer ~= nil and type(writer.set) == "function" and raw ~= nil then
                    if raw == NULL then
                        writer.set(obj, nil)
                    else
                        writer.set(obj, raw)
                    end
                end
            elseif raw ~= nil then
                obj[field.name] = coerceValue(field, raw, cls)
            end
        end
    end
    return obj
end

--- 实例转普通表（含父类字段、注解语义；供编码前的 plainify 使用）
local function toPlainTable(cls, obj)
    local out = {}
    if isPolymorphic(cls) then
        out.kind = cls.__kind
    end
    local fields = cls.__allFields
    for i = 1, #fields do
        local field = fields[i]
        if not field.ignore then
            local key = fieldKey(field)
            if field.custom ~= nil then
                local reader = cls.__customs[field.custom]
                if reader ~= nil and type(reader.get) == "function" then
                    local value = reader.get(obj)
                    if not (field.ignoreNull and (value == nil or value == NULL)) then
                        out[key] = value
                    end
                end
            else
                local value = obj[field.name]
                if not (field.ignoreNull and (value == nil or value == NULL)) then
                    out[key] = value
                end
            end
        end
    end
    return out
end

--- 定义 / 装修一个带 JSON 注解的类（等价 @JsonAdapter）
-- @param nameOrClass 类名（字符串）或已存在的类表
-- @param fields 字段描述数组
-- @param opts 可选配置：name / kind / withSuperClass / polymorphic / ignorePrivate /
--             privatePrefix / init / 以及自定义读写器（custom 指向的 { get=, set= }）
-- @return 类表（new / fromJson / fromTable / getKind 与实例方法 toJson / toTable）
function J.Adapter(nameOrClass, fields, opts)
    local cls
    local kind
    if type(nameOrClass) == "string" then
        cls = {}
        kind = nameOrClass
    elseif type(nameOrClass) == "table" then
        cls = nameOrClass
        kind = cls.__kind or cls.__name or "LuaAdapter"
    else
        cls = {}
        kind = "LuaAdapter"
    end
    opts = opts or {}
    kind = opts.kind or opts.name or kind

    cls.__kind = kind
    cls.__name = kind
    cls.__adapter = true
    cls.__polymorphic = opts.polymorphic == true
    cls.__privatePrefix = opts.privatePrefix or "_"
    cls.__baseClass = opts.withSuperClass
    cls.__ownFields = {}
    cls.__ownCustoms = {}

    if type(fields) ~= "table" then
        error("Adapter expects a field array", 2)
    end
    for i = 1, #fields do
        cls.__ownFields[#cls.__ownFields + 1] = normalizeField(fields[i], i)
    end
    -- 自定义读写器：opts 中除保留键外，值为 { get=, set= } 的表即读写器
    local reserved = {
        name = true, kind = true, withSuperClass = true, polymorphic = true,
        ignorePrivate = true, privatePrefix = true, init = true, fields = true,
    }
    for k, v in pairs(opts) do
        if not reserved[k] and type(v) == "table" then
            cls.__ownCustoms[k] = v
        elseif k == "init" then
            cls.init = v
        end
    end
    cls.__allFields = collectFields(cls, opts.ignorePrivate == true)
    cls.__customs = collectCustoms(cls)

    --- 静态：取类名（多态 kind）
    function cls.getKind()
        return cls.__kind
    end

    --- 静态：从 JSON 文本或表构造实例（多态类按 kind 分派）
    -- @param source JSON 字符串或普通表
    -- @return 实例
    function cls.fromJson(source)
        local data
        if type(source) == "string" then
            data = serializer.decode(source)
        elseif type(source) == "table" then
            data = source
        else
            error("fromJson expects a JSON string or table", 2)
        end
        return cls.fromTable(data)
    end

    --- 静态：从普通表构造实例（多态类按 kind 分派）
    -- @param data 普通表
    -- @return 实例
    function cls.fromTable(data)
        if type(data) ~= "table" then
            error("fromTable expects a table", 2)
        end
        if isPolymorphic(cls) and data.kind ~= nil and data.kind ~= cls.__kind then
            local target = J.registry[data.kind]
            if target == nil then
                error("unregistered polymorphic kind '" .. tostring(data.kind) .. "'", 2)
            end
            return target.fromTable(data)
        end
        local obj = cls.new()
        return fillFromTable(cls, obj, data)
    end

    --- 构造实例（应用字段默认值，再调用 opts.init）
    function cls.new(...)
        local obj = {}
        for i = 1, #cls.__allFields do
            local field = cls.__allFields[i]
            if field.default ~= nil then
                obj[field.name] = field.default
            end
        end
        setmetatable(obj, { __index = cls, __adapterClass = cls })
        if type(cls.init) == "function" then
            cls.init(obj, ...)
        end
        return obj
    end

    --- 实例：转 JSON 字符串
    function cls.toJson(self, encodeOpts)
        return serializer.encode(self, encodeOpts)
    end

    --- 实例：转普通表
    function cls.toTable(self)
        return toPlainTable(cls, self)
    end

    --- 实例：从 JSON 文本或表填充自身
    function cls.fromJsonInto(self, source)
        local data
        if type(source) == "string" then
            data = serializer.decode(source)
        elseif type(source) == "table" then
            data = source
        else
            error("fromJson expects a JSON string or table", 2)
        end
        fillFromTable(cls, self, data)
        return self
    end

    -- 多态继承链上的类自动登记（等价于宏展开时注册到 JsonPolymorphicRegistry）
    if isPolymorphic(cls) then
        J.registry[kind] = cls
    end
    return cls
end

--- 登记多态类（可重复调用，后注册覆盖同名）
-- @param cls Adapter 类
-- @return 类名
function J.register(cls)
    if type(cls) ~= "table" or cls.__kind == nil then
        error("register expects an Adapter class", 2)
    end
    J.registry[cls.__kind] = cls
    return cls.__kind
end

--- 判断值是否为 Adapter 实例
-- @param value 任意值
-- @return boolean
function J.isAdapter(value)
    local mt = getmetatable(value)
    return mt ~= nil and mt.__adapterClass ~= nil
end

--- 取 Adapter 实例的类名
-- @param value Adapter 实例
-- @return 类名或 nil
function J.kindOf(value)
    local mt = getmetatable(value)
    if mt == nil or mt.__adapterClass == nil then return nil end
    return mt.__adapterClass.__kind
end

-- ===========================================================================
-- 编码前处理：Adapter 实例 → 普通表（引擎桥接只接受纯数据表）
-- ===========================================================================
--- 递归把 Adapter 实例转成普通表，并保留 null 哨兵与数组标记
-- @param v 任意 Lua 值
-- @param depth 当前嵌套深度
-- @return 可交给 JsonUtil.stringify 的纯数据值
local function plainify(v, depth)
    if v == nil or v == NULL then return v end
    if type(v) ~= "table" then return v end
    depth = depth + 1
    if depth > MAX_DEPTH then
        error("json encode depth exceeded (cycle?)", 0)
    end
    local mt = getmetatable(v)
    if mt ~= nil and mt.__adapterClass ~= nil then
        local fields = toPlainTable(mt.__adapterClass, v)
        local out = {}
        for k, val in pairs(fields) do out[k] = plainify(val, depth) end
        return out
    end
    local out = {}
    for k, val in pairs(v) do out[k] = plainify(val, depth) end
    if mt == ARRAY_MT then setmetatable(out, ARRAY_MT) end
    return out
end

-- ===========================================================================
-- 编解码：委托引擎 cjfast_json（JsonUtil 绑定）
-- ===========================================================================
--- 解码 JSON 字符串为 Lua 值（对象 → table，数组 → 数组，null → S.null）
-- @param text JSON 文本
-- @return Lua 值
function serializer.decode(text)
    if type(text) ~= "string" then
        error("decode expects a string", 2)
    end
    return JsonUtil.parse(text, NULL)
end

--- 校验字符串是否为合法 JSON
-- @param text JSON 文本
-- @return boolean
function serializer.isValid(text)
    if type(text) ~= "string" then return false end
    return JsonUtil.isValid(text)
end

--- 编码 Lua 值为 JSON 字符串
-- @param value Lua 值（table / number / string / boolean / S.null / Adapter 实例）
-- @param opts 可选：{ pretty = true|缩进空格数, indent = "  ", sortKeys = bool,
--              ignoreNull = bool, maxDepth = number }
-- @return JSON 字符串
function serializer.encode(value, opts)
    local o = {}
    if opts ~= nil then
        for k, v in pairs(opts) do o[k] = v end
    end
    o.nullValue = NULL
    if o.maxDepth == nil then o.maxDepth = MAX_DEPTH end
    return JsonUtil.stringify(plainify(value, 0), o)
end

-- ===========================================================================
-- 挂到命名空间（保持向后兼容：命名空间表原样返回）
-- ===========================================================================
serializer.decorator = J
serializer.null = NULL
serializer.JsonName = J.JsonName
serializer.JsonIgnore = J.JsonIgnore
serializer.JsonIgnoreNull = J.JsonIgnoreNull
serializer.JsonCustom = J.JsonCustom
serializer.Adapter = J.Adapter
serializer.adapter = J.Adapter
serializer.register = J.register
serializer.registry = J.registry
serializer.isAdapter = J.isAdapter
serializer.kindOf = J.kindOf

--- 强制按数组编码（空表默认编码为对象）
-- @param t 数组
-- @return 带数组标记的表
function serializer.array(t)
    t = t or {}
    return setmetatable(t, ARRAY_MT)
end

return serializer
