# Lua 团队协作标准手册（LuaJIT 版）

> 本手册面向基于 **LuaJIT** 进行业务开发或引擎封装的团队，规定统一的编码、模块、错误处理、资源管理、工具链与协作流程要求。
> 编写时参考了《Lua 团队开发规范》与《Lua 常用特性模拟指南》，并在其基础上补充了 LuaJIT 专属规范（FFI、JIT 编译行为、cdata 资源生命周期等）。

---

## 1. 适用范围

- 使用 LuaJIT 作为宿主脚本引擎的业务逻辑开发；
- 通过 FFI 封装 C/C++ 引擎接口（渲染、物理、音频、资源系统等）的绑定层开发；
- 游戏逻辑、工具脚本、嵌入脚本等所有 Lua/LuaJIT 代码。

规范目标是：代码可读、可维护、可协作、JIT 友好，并尽量通过工具自动执行。

---

## 2. 环境要求

| 项目 | 要求 |
|---|---|
| Lua 方言 | LuaJIT 2.1（语法基线为 Lua 5.1，附带部分 5.2 扩展） |
| 语法约束 | 只使用 Lua 5.1 兼容语法；禁止使用 5.2+/5.3+/5.4 专有特性（`goto`、整数除法 `//`、位运算符等） |
| FFI | 使用 LuaJIT 内置 `ffi` 库，禁止依赖外部 Lua C 扩展的 FFI 替代品 |
| 编辑器 | 推荐使用支持 lua-language-server 的编辑器 |
| 格式化 | StyLua（`dialect = "LuaJIT"`） |
| 静态检查 | Selene（`std = "luajit"`）或 luacheck（`std = "luajit"`） |
| 类型提示 | lua-language-server 注解（`---@class` / `---@param` / `---@return`） |
| 编码 | UTF-8（无 BOM） |
| 换行 | Unix LF |
| 缩进 | 4 空格 |

> **Lua 5.1 基线注意**：无 `goto`、无原生整数类型、位运算使用 `bit` 库、`#` 对含 `nil` 的数组段行为未定义、`unpack` 而非 `table.unpack`、`setfenv/getfenv` 可用但禁止滥用。

---

## 3. 文件与目录规范

### 3.1 文件命名

- 源文件统一使用 `.lua` 后缀；
- 文件名使用小写字母、数字和下划线（snake_case）；
- 不使用空格、中文、特殊符号；
- 模块文件名应体现用途。

```text
player_manager.lua
ui_button.lua
event_bus.lua
engine/renderer_ffi.lua
config.lua
```

### 3.2 目录结构

推荐按模块划分：

```text
src/
  core/          -- 基础设施：事件、日志、工具
  engine/        -- 引擎绑定层：FFI cdef、句柄包装
  game/          -- 业务逻辑
  ui/
  utils/
  config/
tests/
tools/
```

- `engine/` 层是**唯一**允许直接调用 `ffi.cdef` / 持有裸 cdata 指针的地方；
- `game/` 等业务层只能使用 `engine/` 导出的安全包装，不允许直接操作裸指针。

### 3.3 模块入口

模块文件应返回一个表：

```lua
local M = {}

function M.greet(name)
    return "Hello, " .. name
end

return M
```

不推荐直接修改全局表或隐式返回 `nil`。

---

## 4. 命名规范

### 4.1 基本命名

| 类型 | 命名方式 | 示例 |
|---|---|---|
| 文件名 | snake_case | `player_manager.lua` |
| 模块表 | PascalCase | `PlayerManager` |
| 普通函数 | camelCase | `getPlayer`, `updateScore` |
| 私有函数/字段 | 下划线前缀 | `_initPlayer`, `_cache` |
| 变量 | camelCase | `playerName` |
| 常量 | UPPER_SNAKE_CASE | `MAX_LEVEL` |
| 类/对象表 | PascalCase | `Animal`, `Button` |
| FFI struct/typedef | C 风格或 PascalCase，与 cdef 保持一致 | `Vec3`, `MeshHandle` |
| 布尔变量 | is/has/can 前缀 | `isVisible`, `canAttack` |

团队应在 camelCase 和 snake_case 中二选一（本手册推荐 camelCase），并在项目内保持一致。

### 4.2 模块命名

模块名应简短、可读、避免缩写歧义。

```lua
-- 推荐
local PlayerManager = require "game.player_manager"
local EventBus = require "core.event_bus"

-- 不推荐
local PM = require "game.pm"
local EB = require "core.eb"
```

---

## 5. 变量与作用域

### 5.1 默认使用 local

所有变量、函数、模块引用都应使用 `local`，除非确实需要全局访问。

```lua
local name = "LuaJIT"
local function add(a, b)
    return a + b
end
```

### 5.2 禁止全局变量

禁止随意写入全局变量。宿主注入的入口全局（如 `engine`、`jit`）除外，且必须在文档中说明来源和用途。

```lua
-- 不推荐
score = 100

-- 推荐
local score = 100
```

### 5.3 变量初始化

变量应在首次使用前初始化，避免后续出现 `nil` 访问。

```lua
local items = {}
local maxCount = 100
```

### 5.4 多返回值

多返回值应明确接收，避免忽略重要返回值。

```lua
local ok, err = pcall(function()
    error("fail")
end)

if not ok then
    print(err)
end
```

---

## 6. 函数规范

### 6.1 函数定义

优先使用局部函数：

```lua
local function calculateDamage(base, rate)
    return base * rate
end
```

模块方法使用表字段：

```lua
local M = {}

function M.calculateDamage(base, rate)
    return base * rate
end

return M
```

### 6.2 参数数量

普通函数参数不宜超过 5 个。超过时应使用表传参：

```lua
local function createPlayer(opts)
    local name = opts.name
    local level = opts.level or 1
    local hp = opts.hp or 100
end
```

### 6.3 函数长度

单个函数建议不超过 80 行。复杂逻辑应拆分为子函数。

### 6.4 返回值

- 函数应明确返回值含义；
- 失败情况优先返回 `nil, error`；
- 不要混用多种返回风格。

```lua
local function loadConfig(path)
    local ok, data = pcall(readFile, path)
    if not ok then
        return nil, "load config failed: " .. tostring(data)
    end
    return data
end
```

---

## 7. 表与数据结构

### 7.1 数组使用

Lua/LuaJIT 数组从 1 开始。遍历数组：

- **热路径（hot path）**优先使用数值 for 循环（对 JIT 最友好）；
- 一般场景可用 `ipairs`；
- `pairs` 遍历无序且在 JIT 中通常不可编译，禁止在热路径使用。

```lua
-- 热路径推荐
for i = 1, #list do
    local v = list[i]
    -- ...
end

-- 一般场景
for i, v in ipairs(list) do
    print(i, v)
end
```

### 7.2 字典使用

键值表使用 `pairs` 遍历，仅用于非热路径（初始化、配置处理、调试输出）。

```lua
for k, v in pairs(config) do
    print(k, v)
end
```

### 7.3 避免混用数组和字典

同一张表不要同时依赖整数索引和字符串键进行复杂操作，除非团队明确约定。

### 7.4 表拷贝

Lua 表是引用类型。需要副本时应显式拷贝：

```lua
local function shallowCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end
```

### 7.5 表构造

已知所有字段时优先使用一次性表构造器（避免多次 rehash）：

```lua
-- 推荐
local point = { x = 1, y = 2, z = 3 }

-- 不推荐（触发多次扩容）
local point = {}
point.x = 1
point.y = 2
point.z = 3
```

---

## 8. 类与对象

### 8.1 类实现方式

统一使用 `table + metatable + __index` 实现类：

```lua
local Animal = {}
Animal.__index = Animal

function Animal:new(name)
    local obj = setmetatable({}, self)
    obj.name = name
    return obj
end

function Animal:speak()
    print(self.name .. " makes a sound")
end
```

### 8.2 继承方式

子类通过设置 `__index` 指向父类实现继承：

```lua
local Dog = setmetatable({}, { __index = Animal })
Dog.__index = Dog

function Dog:new(name)
    local obj = Animal.new(self, name)
    return setmetatable(obj, Dog)
end

function Dog:speak()
    print(self.name .. " barks")
end
```

### 8.3 实例字段

实例字段应在构造函数中初始化，不应随意在外部新增：

```lua
local dog = Dog:new("Buddy")
dog.age = 3  -- 不推荐，除非有明确约定
```

### 8.4 私有字段约定

Lua 没有真正私有字段。团队约定使用 `_` 前缀表示内部字段：

```lua
obj._internalCache = {}
```

如需更强封装，可使用闭包（见第 9.5 节）。

### 8.5 多态与接口

- 多态依赖鸭子类型：统一方法名即可互换调用；
- 接口通过运行时检查模拟：

```lua
local function checkDrawable(obj)
    if type(obj.draw) ~= "function" then
        error("Object must implement draw()")
    end
end
```

### 8.6 性能提示

metatable 查找有开销。每帧调用多次的热路径（如实体更新），可在方法外缓存函数引用或直接使用普通函数 + 显式参数，避免深链 `__index` 查找。

---

## 9. 模块规范

### 9.1 模块结构

```lua
local M = {}

local function helper()
end

function M.doSomething()
    helper()
end

return M
```

### 9.2 依赖引入

所有依赖都应使用 `local` 引入，且只允许出现在文件顶部：

```lua
local EventBus = require "core.event_bus"
local Config = require "config.game_config"
```

### 9.3 禁止循环依赖

模块之间不应形成循环 `require`。若出现循环依赖，应通过事件总线、回调或中间层解耦。

### 9.4 模块职责

一个模块只负责一个明确职责。例如：

- `PlayerManager` 管理玩家数据；
- `EventBus` 管理事件；
- `ResourceManager` 管理资源加载与释放。

### 9.5 闭包封装

需要隐藏内部状态时，用闭包暴露固定方法：

```lua
local function newAccount(initial)
    local balance = initial or 0

    return {
        deposit = function(amount) balance = balance + amount end,
        withdraw = function(amount)
            if amount > balance then
                error("Insufficient balance")
            end
            balance = balance - amount
        end,
        getBalance = function() return balance end
    }
end
```

注意：闭包对象创建成本高于 metatable 方案，**禁止在每帧循环中批量创建**，适合低频对象（对话框、一次性任务）。

### 9.6 单例模式

```lua
local GameManager = {}
local instance = nil

function GameManager.getInstance()
    if not instance then
        instance = { score = 0, level = 1 }
    end
    return instance
end

return GameManager
```

### 9.7 枚举与常量

用只读表 + `__newindex` 保护模拟：

```lua
local Season = {
    SPRING = 1,
    SUMMER = 2,
    AUTUMN = 3,
    WINTER = 4
}

setmetatable(Season, {
    __newindex = function()
        error("Cannot modify enum Season")
    end
})
```

注意：此方式只能防止顶层字段被修改，不能防止深层修改。与 FFI 交互时，枚举应与 C 侧 cdef 中的常量数值保持一致，并注明来源。

---

## 10. LuaJIT FFI 规范

FFI 是 LuaJIT 引擎封装的核心能力，也是最容易引入崩溃和内存错误的区域，必须严格约束。

### 10.1 分层原则

- `ffi.cdef` 声明、`ffi.load` 加载**只允许**出现在 `src/engine/` 层；
- 每个原生库对应一个绑定模块（如 `engine/renderer_ffi.lua`），对外只导出安全的 Lua 接口；
- 业务层持有的是包装对象（table 或轻量 userdata 风格包装），不是裸 cdata 指针。

### 10.2 cdata 与 GC

- cdata 不受 Lua GC 值语义管理，**由 C 侧分配的内存/资源必须显式释放**；
- 使用 `ffi.gc` 为句柄类 cdata 注册终化函数，作为兜底而非主要释放手段：

```lua
local handle = ffi.gc(lib.createTexture(path), lib.destroyTexture)
```

- 主要释放手段仍是显式 `release()`（见第 13 章），`ffi.gc` 仅防泄漏；
- 禁止把 C 指针长期存入 Lua 表后忘记持有 cdata 本体（指针悬空）。

### 10.3 类型与转换

- 所有跨边界数值明确类型：C 侧 `int32_t/float/double`，Lua 侧 `number`，必要时用 `ffi.cast` 或 `tonumber` 显式转换；
- 字符串传递：Lua string → `const char*` 可直接传；从 C 返回 `char*` 时必须指定长度或确认 NUL 结尾，并用 `ffi.string` 立即复制成 Lua string；
- 禁止把 Lua string 的指针（`ffi.cast("const char*", str)` 后长期保存）缓存起来——Lua string 可能被 GC；
- bool 传递使用 `true/false`（ffi 自动转换），不要手写 `1/0` 传给 `bool` 参数。

### 10.4 禁止项

- 禁止在业务层直接 `ffi.cast`、指针算术、`ffi.copy`；
- 禁止缓存指向 C 侧临时缓冲区的指针跨帧使用；
- 禁止在 cdef 中声明与实际 ABI 不一致的签名（错误签名 = 未定义行为 = 随机崩溃）；
- 禁止从多个线程并发调用未标明线程安全的原生接口，除非引擎明确支持。

---

## 11. 错误处理

### 11.1 使用 pcall / xpcall

可能失败的操作应使用 `pcall` 或 `xpcall`：

```lua
local ok, result = pcall(loadData, path)

if not ok then
    logError("load failed: " .. tostring(result))
end
```

带堆栈的错误处理：

```lua
local ok, err = xpcall(criticalInit, debug.traceback)
if not ok then
    logError(err)
end
```

### 11.2 错误信息

错误信息应包含上下文（模块、函数、参数值），便于定位问题：

```lua
error("PlayerManager:addItem: item is nil")
```

### 11.3 禁止静默吞错

```lua
-- 不推荐
pcall(someFunction)

-- 推荐
local ok, err = pcall(someFunction)
if not ok then
    logError(err)
end
```

### 11.4 FFI 错误

- `ffi.cdef` 声明的 C 函数抛出的 `ffi.error` 应被捕获并转换为带上下文的 Lua 错误；
- 引擎层返回的错误码必须检查，禁止忽略返回值直接使用句柄。

---

## 12. 日志规范

日志应区分等级：`DEBUG` / `INFO` / `WARN` / `ERROR` / `FATAL`。

```lua
logInfo("Player %s entered scene %s", playerName, sceneName)
logError("Failed to load config: %s", path)
```

- 禁止在生产环境输出大量调试日志；
- 日志内容不应包含敏感信息；
- 热路径中的日志调用应可通过编译期或运行期开关整体关闭（空函数调用也会被 JIT 消除，但格式化参数不会）。

---

## 13. 资源管理

Lua 有 GC 但**没有确定性析构**；FFI 资源更完全不受 GC 管理。因此资源释放依赖统一约定。

### 13.1 release 约定

需要手动释放的资源必须提供幂等的 `release` 方法：

```lua
function obj:release()
    if self._released then
        return
    end
    self._released = true
    -- 释放底层资源 / 调用 C 侧 destroy
end
```

### 13.2 生命周期管理

- 复杂项目应统一由 `ResourceManager` 管理资源创建、引用计数、释放顺序，避免依赖 GC 及时回收；
- FFI 句柄配对规则：`create/destroy`、`load/unload`、`lock/unlock` 必须成对出现在同一模块，并在包装层保证调用配对；
- Lua 侧大表、事件监听、定时器、协程不再使用时应置 `nil` 或显式清理，帮助 GC 回收。

### 13.3 Safe 包装

可使用通用安全包装防止 use-after-release：

```lua
local function Safe(obj)
    return {
        _obj = obj,
        get = function(self)
            if self._obj == nil then
                error("Object already released")
            end
            return self._obj
        end,
        release = function(self)
            if self._obj and self._obj.release then
                self._obj:release()
            end
            self._obj = nil
        end
    }
end
```

适用于文件句柄、网络连接、纹理、音频等资源。仅用于边界处，热路径不要层层包裹。

---

## 14. 协程规范

- 协程用于状态机、任务调度、异步流程模拟，是**协作式并发，不是多线程**，不能利用多核；
- 每帧驱动的主循环中，协程 `resume` 次数应可控，禁止无界让出循环；
- 协程内进行的 FFI 调用不得阻塞主循环超过一帧预算；
- 协程对象使用完毕应置 `nil`。

```lua
local co = coroutine.create(function()
    print("start")
    coroutine.yield()
    print("resume")
end)

coroutine.resume(co)   -- start
coroutine.resume(co)   -- resume
```

---

## 15. 性能规范（JIT 友好编码）

LuaJIT 通过 trace compiler 优化热路径。编码时遵守以下规则，避免 trace 中止：

1. **热路径避免 NYI 操作**：`pairs`、`string.format`（部分场景）、`select('#')` 滥用、`pcall` 内的复杂循环等可能不可编译。热点函数应以数值 for 循环、局部变量、简单算术为主。对可疑热点用 `jit.debug` / `-jdump` 验证，而不是猜测；
2. **局部化一切**：循环内使用的全局函数、模块字段先赋给 local（global 访问在 trace 中开销高）；
3. **循环内不创建闭包、表、协程**；复用缓冲表或上提分配；
4. **字符串拼接**多次时用表收集 + `table.concat`，禁止循环内 `..` 大量拼接；
5. **保持类型稳定**：同一变量/字段不要在 number 与 table 之间变来变去（类型变更会中止 trace）；
6. **避免在热路径修改 metatable 或依赖 `__newindex`**；
7. `bit` 库做位运算，不模拟算术位操作；
8. 大表不再使用时置 `nil`，配合 `collectgarbage("step")` 平滑 GC 峰值（仅限确有卡顿证据时）。

---

## 16. 注释规范

### 16.1 模块注释

每个模块头部应说明用途：

```lua
-- 玩家管理器
-- 负责玩家创建、属性更新和事件通知
```

### 16.2 函数注释

公开函数应说明参数、返回值和副作用。使用 lua-language-server 注解：

```lua
---@param playerId number
---@param amount number
---@return boolean
---@return string?
function PlayerManager:addItem(playerId, amount)
```

### 16.3 FFI 注释

`engine/` 层的每个 cdef 导出函数应注明：所属原生库、线程安全约束、资源所有权（调用方释放还是库释放）。

### 16.4 避免无意义注释

```lua
-- 不推荐
local a = 10 -- 赋值10

-- 推荐
local maxRetryCount = 10
```

---

## 17. 格式化规范

项目统一使用 **StyLua** 格式化，`.stylua.toml`：

```toml
column_width = 100
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 4
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
```

提交代码前执行：

```bash
stylua src/
```

不建议手动争论空格、换行、引号等格式问题，全部交给工具处理。

---

## 18. 静态检查规范

使用 **Selene**（推荐）或 luacheck，标准库设置为 LuaJIT：

```toml
# selene.toml
std = "luajit"

[lints]
global_usage = "deny"
undefined_variable = "deny"
unused_variable = "warn"
empty_if = "warn"
```

CI 或本地提交前应通过静态检查：

```bash
selene src/
```

若项目使用宿主引擎（LÖVE、Defold、自研引擎绑定等），应配置对应标准库定义，避免误报。

---

## 19. 类型提示规范

Lua 没有原生类型系统，使用 lua-language-server 注解：

```lua
---@class Player
---@field name string
---@field level number
---@field hp number

---@param player Player
---@return number
local function getLevel(player)
    return player.level
end
```

- 类型提示不要求覆盖所有代码，但**公共 API、engine/ 绑定层、跨模块接口必须补充**；
- FFI 包装对象的 `---@class` 应标注其包装的 C 类型，如 `---@class TextureHandle @wraps Texture*`。

---

## 20. 测试规范

### 20.1 测试文件命名

测试文件统一放在 `tests/` 目录：

```text
tests/test_player_manager.lua
tests/test_event_bus.lua
tests/test_renderer_ffi.lua
```

### 20.2 测试覆盖范围

以下代码必须有测试：

- 核心算法与数据转换；
- 配置解析；
- 资源管理（含 FFI 资源的释放配对）；
- 事件系统；
- 网络协议处理；
- `engine/` 绑定层的参数转换与错误码处理。

### 20.3 测试原则

- 测试应可重复执行；
- 不应依赖外部不可控状态；
- 失败信息应能定位到具体用例；
- FFI 相关测试必须同时验证正常路径与释放路径（重复 release 不崩溃）。

---

## 21. 代码审查规范

审查时重点关注：

- 是否符合命名和模块规范；
- 是否引入不必要的全局变量；
- 是否有未处理的错误；
- 是否有资源泄漏风险（尤其是 FFI 句柄的释放配对）；
- 热路径是否存在 NYI 操作、循环内分配、深 metatable 查找；
- 是否缺少必要注释；
- 是否有测试覆盖。

格式问题交给 StyLua 和 Selene，审查不纠缠格式。

---

## 22. 禁止项

- 禁止随意使用全局变量；
- 禁止修改 Lua/LuaJIT 内置库（包括给 string/table 添加方法）；
- 禁止使用超出 Lua 5.1 基线的语法（goto、`//`、`~=` 之外的位运算符等）；
- 禁止在业务层直接使用 `ffi.cdef` / `ffi.cast` / 裸指针；
- 禁止缓存指向 Lua string 或 C 临时缓冲区的裸指针跨帧使用；
- 禁止在模块顶层执行耗时操作；
- 禁止在循环中频繁创建闭包；
- 禁止吞掉错误而不记录日志；
- 禁止提交未格式化或静态检查未通过的代码；
- 禁止使用含义不明的缩写。

---

## 23. 推荐项

- 使用 `local` 声明所有变量；
- 使用 `require` 管理模块；
- 使用 `pcall` 处理可能失败的操作；
- 使用统一事件总线解耦模块；
- 使用 `release()` 约定 + `ffi.gc` 兜底管理资源；
- 使用 lua-language-server 注解做类型提示；
- 使用 StyLua 统一格式、Selene/luacheck 静态检查；
- 热路径以数值 for 循环和局部变量为主，并定期用 JIT 工具验证编译情况；
- 为公共 API 编写注释和测试。

---

