# Lua Team Collaboration Standard Handbook (LuaJIT Edition)

> This handbook targets teams doing business development or engine wrapping on top of **LuaJIT**. It defines unified requirements for coding style, modules, error handling, resource management, toolchain, and collaboration workflow.
> It is based on the *Lua Team Development Standard* and the *Lua Feature Emulation Guide*, extended with LuaJIT-specific rules (FFI, JIT compilation behavior, cdata resource lifecycle, etc.).

---

## 1. Scope

- Business logic development using LuaJIT as the host scripting engine;
- Binding-layer development that wraps C/C++ engine interfaces (rendering, physics, audio, resource systems) via FFI;
- All Lua/LuaJIT code, including game logic, tool scripts, and embedded scripts.

Goals: readable, maintainable, collaborative, JIT-friendly code — enforced by tooling wherever possible.

---

## 2. Environment Requirements

| Item | Requirement |
|---|---|
| Lua dialect | LuaJIT 2.1 (syntax baseline: Lua 5.1 plus a few 5.2 extensions) |
| Syntax constraints | Lua 5.1-compatible syntax only; no 5.2+/5.3+/5.4-only features (`goto`, integer division `//`, bitwise operators, etc.) |
| FFI | LuaJIT's built-in `ffi` library; no external FFI substitutes |
| Editor | Editors with lua-language-server support recommended |
| Formatting | StyLua (`dialect = "LuaJIT"`) |
| Static analysis | Selene (`std = "luajit"`) or luacheck (`std = "luajit"`) |
| Type hints | lua-language-server annotations (`---@class` / `---@param` / `---@return`) |
| Encoding | UTF-8 (no BOM) |
| Line endings | Unix LF |
| Indentation | 4 spaces |

> **Lua 5.1 baseline notes**: no `goto`, no native integer type, bitwise ops via the `bit` library, `#` on arrays with `nil` holes is undefined, use `unpack` (not `table.unpack`), `setfenv/getfenv` exist but must not be abused.

---

## 3. Files and Directories

### 3.1 File Naming

- Source files use the `.lua` suffix;
- File names use lowercase letters, digits, and underscores (snake_case);
- No spaces, non-ASCII characters, or special symbols;
- Module file names should reflect their purpose.

```text
player_manager.lua
ui_button.lua
event_bus.lua
engine/renderer_ffi.lua
config.lua
```

### 3.2 Directory Structure

Organize by module:

```text
src/
  core/          -- Infrastructure: events, logging, utilities
  engine/        -- Engine binding layer: FFI cdefs, handle wrappers
  game/          -- Business logic
  ui/
  utils/
  config/
tests/
tools/
```

- The `engine/` layer is the **only** place allowed to call `ffi.cdef` directly or hold raw cdata pointers;
- Business layers (`game/`, etc.) may only use the safe wrappers exported by `engine/` — no raw pointer access.

### 3.3 Module Entry

A module file must return a table:

```lua
local M = {}

function M.greet(name)
    return "Hello, " .. name
end

return M
```

Do not modify the global table or implicitly return `nil`.

---

## 4. Naming Conventions

### 4.1 Basic Naming

| Kind | Convention | Example |
|---|---|---|
| File name | snake_case | `player_manager.lua` |
| Module table | PascalCase | `PlayerManager` |
| Function | camelCase | `getPlayer`, `updateScore` |
| Private function/field | underscore prefix | `_initPlayer`, `_cache` |
| Variable | camelCase | `playerName` |
| Constant | UPPER_SNAKE_CASE | `MAX_LEVEL` |
| Class/object table | PascalCase | `Animal`, `Button` |
| FFI struct/typedef | C style or PascalCase, consistent with the cdef | `Vec3`, `MeshHandle` |
| Boolean variable | is/has/can prefix | `isVisible`, `canAttack` |

Pick one of camelCase or snake_case for variables (this handbook recommends camelCase) and stay consistent within the project.

### 4.2 Module Naming

Module names should be short, readable, and free of ambiguous abbreviations.

```lua
-- Recommended
local PlayerManager = require "game.player_manager"
local EventBus = require "core.event_bus"

-- Not recommended
local PM = require "game.pm"
local EB = require "core.eb"
```

---

## 5. Variables and Scope

### 5.1 Always Use local

All variables, functions, and module references must be `local`, unless global access is genuinely required.

```lua
local name = "LuaJIT"
local function add(a, b)
    return a + b
end
```

### 5.2 No Global Variables

Do not write globals arbitrarily. Host-injected entry globals (e.g. `engine`, `jit`) are the exception and must be documented.

```lua
-- Not recommended
score = 100

-- Recommended
local score = 100
```

### 5.3 Initialization

Initialize variables before first use to avoid later `nil` accesses:

```lua
local items = {}
local maxCount = 100
```

### 5.4 Multiple Return Values

Receive multiple return values explicitly; do not silently drop important ones:

```lua
local ok, err = pcall(function()
    error("fail")
end)

if not ok then
    print(err)
end
```

---

## 6. Functions

### 6.1 Definition

Prefer local functions:

```lua
local function calculateDamage(base, rate)
    return base * rate
end
```

Module methods use table fields:

```lua
local M = {}

function M.calculateDamage(base, rate)
    return base * rate
end

return M
```

### 6.2 Parameter Count

No more than 5 parameters for ordinary functions. Beyond that, pass a table:

```lua
local function createPlayer(opts)
    local name = opts.name
    local level = opts.level or 1
    local hp = opts.hp or 100
end
```

### 6.3 Function Length

Keep functions under 80 lines. Split complex logic into sub-functions.

### 6.4 Return Values

- Make the meaning of return values explicit;
- On failure, prefer returning `nil, error`;
- Do not mix return styles.

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

## 7. Tables and Data Structures

### 7.1 Arrays

Lua/LuaJIT arrays start at 1. For iteration:

- **Hot paths**: prefer numeric `for` loops (most JIT-friendly);
- General cases may use `ipairs`;
- `pairs` is unordered and generally not JIT-compiled — never use it in hot paths.

```lua
-- Recommended in hot paths
for i = 1, #list do
    local v = list[i]
    -- ...
end

-- General cases
for i, v in ipairs(list) do
    print(i, v)
end
```

### 7.2 Dictionaries

Iterate key-value tables with `pairs`, only in non-hot paths (initialization, config processing, debug output):

```lua
for k, v in pairs(config) do
    print(k, v)
end
```

### 7.3 Do Not Mix Arrays and Dictionaries

Do not use integer indexes and string keys on the same table for complex operations, unless the team has an explicit convention.

### 7.4 Table Copy

Tables are reference types. Copy explicitly when a duplicate is needed:

```lua
local function shallowCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end
```

### 7.5 Table Construction

When all fields are known, prefer a single table constructor (avoids repeated rehashing):

```lua
-- Recommended
local point = { x = 1, y = 2, z = 3 }

-- Not recommended (multiple resizes)
local point = {}
point.x = 1
point.y = 2
point.z = 3
```

---

## 8. Classes and Objects

### 8.1 Class Implementation

Use `table + metatable + __index` uniformly:

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

### 8.2 Inheritance

Subclasses inherit by pointing `__index` at the parent class:

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

### 8.3 Instance Fields

Initialize instance fields in the constructor; do not add them arbitrarily from outside:

```lua
local dog = Dog:new("Buddy")
dog.age = 3  -- Not recommended, unless explicitly agreed
```

### 8.4 Private Field Convention

Lua has no true private fields. Use a `_` prefix for internal fields:

```lua
obj._internalCache = {}
```

For stronger encapsulation, use closures (see section 9.5).

### 8.5 Polymorphism and Interfaces

- Polymorphism relies on duck typing: objects with the same method names are interchangeable;
- Interfaces are emulated via runtime checks:

```lua
local function checkDrawable(obj)
    if type(obj.draw) ~= "function" then
        error("Object must implement draw()")
    end
end
```

### 8.6 Performance Note

Metatable lookups have overhead. For per-frame hot paths (e.g. entity updates), cache method references outside the loop or use plain functions with explicit arguments instead of deep `__index` chains.

---

## 9. Modules

### 9.1 Module Structure

```lua
local M = {}

local function helper()
end

function M.doSomething()
    helper()
end

return M
```

### 9.2 Dependencies

All dependencies must be `local` requires at the top of the file:

```lua
local EventBus = require "core.event_bus"
local Config = require "config.game_config"
```

### 9.3 No Circular Dependencies

Modules must not form circular `require` chains. Decouple via an event bus, callbacks, or an intermediate layer.

### 9.4 Single Responsibility

One module, one clear responsibility. For example:

- `PlayerManager` manages player data;
- `EventBus` manages events;
- `ResourceManager` manages resource loading and release.

### 9.5 Closure Encapsulation

To hide internal state, expose fixed methods via closures:

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

Note: closure objects cost more to create than metatable-based ones. **Never create them in bulk inside per-frame loops**; they suit low-frequency objects (dialogs, one-shot tasks).

### 9.6 Singleton

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

### 9.7 Enums and Constants

Emulate with read-only tables protected by `__newindex`:

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

Note: this only protects top-level fields, not nested ones. When interoperating with FFI, enum values must match the constants in the C-side cdef, with provenance noted.

---

## 10. LuaJIT FFI Rules

FFI is the core of LuaJIT engine wrapping and the easiest place to introduce crashes and memory errors. It must be strictly constrained.

### 10.1 Layering

- `ffi.cdef` declarations and `ffi.load` calls are allowed **only** in `src/engine/`;
- Each native library gets one binding module (e.g. `engine/renderer_ffi.lua`) that exports only safe Lua interfaces;
- Business layers hold wrapper objects (tables or lightweight userdata-style wrappers), never raw cdata pointers.

### 10.2 cdata and GC

- cdata is not managed by the Lua GC in terms of value semantics; **memory/resources allocated on the C side must be released explicitly**;
- Use `ffi.gc` to attach a finalizer to handle-like cdata as a safety net, not the primary release mechanism:

```lua
local handle = ffi.gc(lib.createTexture(path), lib.destroyTexture)
```

- The primary release mechanism remains an explicit `release()` (see chapter 13); `ffi.gc` only guards against leaks;
- Never store a raw C pointer in a Lua table long-term while dropping the cdata that owns it (dangling pointer).

### 10.3 Types and Conversions

- Be explicit about numeric types across the boundary: `int32_t/float/double` on the C side, `number` on the Lua side, with explicit `ffi.cast` or `tonumber` where needed;
- Strings: a Lua string can be passed directly as `const char*`; when C returns `char*`, the length must be known or the buffer NUL-terminated, and it must be copied immediately with `ffi.string` into a Lua string;
- Never cache pointers into Lua strings (`ffi.cast("const char*", str)` held long-term) — the Lua string may be collected;
- Pass booleans as `true/false` (FFI converts automatically); do not hand-write `1/0` for `bool` parameters.

### 10.4 Prohibitions

- No `ffi.cast`, pointer arithmetic, or `ffi.copy` in business layers;
- No caching pointers into C-side temporary buffers for use across frames;
- No cdef signatures that disagree with the actual ABI (a wrong signature is undefined behavior = random crashes);
- No concurrent calls to native interfaces that are not documented thread-safe, unless the engine explicitly supports it.

---

## 11. Error Handling

### 11.1 pcall / xpcall

Wrap fallible operations in `pcall` or `xpcall`:

```lua
local ok, result = pcall(loadData, path)

if not ok then
    logError("load failed: " .. tostring(result))
end
```

With stack traces:

```lua
local ok, err = xpcall(criticalInit, debug.traceback)
if not ok then
    logError(err)
end
```

### 11.2 Error Messages

Error messages must include context (module, function, argument values) for troubleshooting:

```lua
error("PlayerManager:addItem: item is nil")
```

### 11.3 No Silent Error Swallowing

```lua
-- Not recommended
pcall(someFunction)

-- Recommended
local ok, err = pcall(someFunction)
if not ok then
    logError(err)
end
```

### 11.4 FFI Errors

- Catch `ffi.error` raised by cdef-declared C functions and re-raise as contextualized Lua errors;
- Engine-side error codes must be checked; never use returned handles without validating them.

---

## 12. Logging

Log levels: `DEBUG` / `INFO` / `WARN` / `ERROR` / `FATAL`.

```lua
logInfo("Player %s entered scene %s", playerName, sceneName)
logError("Failed to load config: %s", path)
```

- No bulk debug logging in production;
- No sensitive information in logs;
- Hot-path log calls should be globally disableable (an empty function call is eliminated by the JIT, but argument formatting is not).

---

## 13. Resource Management

Lua has GC but **no deterministic destruction**; FFI resources are entirely outside GC control. Resource release therefore relies on a uniform convention.

### 13.1 release Convention

Manually released resources must provide an idempotent `release` method:

```lua
function obj:release()
    if self._released then
        return
    end
    self._released = true
    -- Release the underlying resource / call the C-side destroy
end
```

### 13.2 Lifecycle Management

- Complex projects should manage creation, reference counting, and release order through a central `ResourceManager` instead of relying on timely GC;
- FFI pairing rule: `create/destroy`, `load/unload`, `lock/unlock` must appear as pairs within the same module, and the wrapper layer must guarantee the pairing;
- Large tables, event listeners, timers, and coroutines should be set to `nil` or explicitly cleaned up when no longer used, helping the GC reclaim them.

### 13.3 Safe Wrapper

A generic safe wrapper prevents use-after-release:

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

Suitable for file handles, network connections, textures, audio, etc. Use it at boundaries only — do not wrap layer upon layer in hot paths.

---

## 14. Coroutines

- Coroutines are for state machines, task scheduling, and async-flow emulation. They are **cooperative concurrency, not multithreading** — they cannot use multiple cores;
- In the per-frame main loop, keep `resume` counts bounded; no unbounded yield loops;
- FFI calls inside coroutines must not block the main loop beyond one frame's budget;
- Set coroutine objects to `nil` when finished.

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

## 15. Performance (JIT-Friendly Coding)

LuaJIT optimizes hot paths via its trace compiler. Follow these rules to avoid trace aborts:

1. **Avoid NYI operations in hot paths**: `pairs`, some `string.format` uses, `select('#')` abuse, and complex loops inside `pcall` may not compile. Hot functions should be dominated by numeric for loops, locals, and simple arithmetic. Verify suspicious hotspots with `jit.debug` / `-jdump` rather than guessing;
2. **Localize everything**: assign globals and module fields used inside loops to locals (global access is expensive in traces);
3. **No closures, tables, or coroutines created inside loops**; reuse buffers or hoist allocations;
4. **String building**: collect into a table and use `table.concat`; never build large strings with `..` inside loops;
5. **Keep types stable**: do not flip a variable/field between number and table (type changes abort traces);
6. **Avoid mutating metatables or relying on `__newindex` in hot paths**;
7. Use the `bit` library for bitwise operations, not arithmetic emulation;
8. Set large dead tables to `nil`, and smooth GC spikes with `collectgarbage("step")` (only with evidence of actual stutter).

---

## 16. Comments

### 16.1 Module Comments

Every module header states its purpose:

```lua
-- Player manager
-- Handles player creation, stat updates, and event notification
```

### 16.2 Function Comments

Public functions document parameters, return values, and side effects, using lua-language-server annotations:

```lua
---@param playerId number
---@param amount number
---@return boolean
---@return string?
function PlayerManager:addItem(playerId, amount)
```

### 16.3 FFI Comments

Every cdef-exported function in the `engine/` layer must document: the owning native library, thread-safety constraints, and resource ownership (released by caller or by the library).

### 16.4 No Meaningless Comments

```lua
-- Not recommended
local a = 10 -- assign 10

-- Recommended
local maxRetryCount = 10
```

---

## 17. Formatting

Format uniformly with **StyLua**, via `.stylua.toml`:

```toml
column_width = 100
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 4
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
```

Run before committing:

```bash
stylua src/
```

Do not argue about spaces, line breaks, or quotes by hand — leave it all to the tool.

---

## 18. Static Analysis

Use **Selene** (recommended) or luacheck with the LuaJIT standard library:

```toml
# selene.toml
std = "luajit"

[lints]
global_usage = "deny"
undefined_variable = "deny"
unused_variable = "warn"
empty_if = "warn"
```

Static analysis must pass in CI or before local commits:

```bash
selene src/
```

If the project runs under a host engine (LÖVE, Defold, custom engine bindings, etc.), configure the matching standard-library definitions to avoid false positives.

---

## 19. Type Hints

Lua has no native type system; use lua-language-server annotations:

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

- Coverage of every line is not required, but **public APIs, the engine/ binding layer, and cross-module interfaces must be annotated**;
- `---@class` declarations for FFI wrappers should note the wrapped C type, e.g. `---@class TextureHandle @wraps Texture*`.

---

## 20. Testing

### 20.1 Test File Naming

Test files live in `tests/`:

```text
tests/test_player_manager.lua
tests/test_event_bus.lua
tests/test_renderer_ffi.lua
```

### 20.2 Coverage Requirements

The following must have tests:

- Core algorithms and data transformations;
- Config parsing;
- Resource management (including FFI release pairing);
- The event system;
- Network protocol handling;
- Parameter conversion and error-code handling in the `engine/` binding layer.

### 20.3 Test Principles

- Tests must be repeatable;
- No dependence on uncontrolled external state;
- Failure messages must pinpoint the case;
- FFI tests must verify both the happy path and the release path (double release must not crash).

---

## 21. Code Review

Reviewers focus on:

- Compliance with naming and module conventions;
- Unnecessary global variables;
- Unhandled errors;
- Resource leak risks (especially FFI handle release pairing);
- NYI operations, in-loop allocations, or deep metatable lookups in hot paths;
- Missing comments;
- Test coverage.

Formatting issues belong to StyLua and Selene — do not nitpick them in review.

---

## 22. Prohibitions

- No arbitrary global variables;
- No modifying the Lua/LuaJIT built-in libraries (including adding methods to string/table);
- No syntax beyond the Lua 5.1 baseline (`goto`, `//`, bitwise operators, etc.);
- No `ffi.cdef` / `ffi.cast` / raw pointers in business layers;
- No caching raw pointers into Lua strings or C temporary buffers across frames;
- No expensive work at module top level;
- No frequent closure creation inside loops;
- No swallowing errors without logging;
- No committing unformatted code or code that fails static analysis;
- No meaningless abbreviations.

---

## 23. Recommendations

- Declare everything `local`;
- Manage modules with `require`;
- Handle fallible operations with `pcall`;
- Decouple modules through a unified event bus;
- Manage resources via the `release()` convention with `ffi.gc` as a safety net;
- Use lua-language-server annotations for type hints;
- Use StyLua for formatting and Selene/luacheck for static analysis;
- Favor numeric for loops and locals in hot paths, and periodically verify JIT compilation status;
- Write comments and tests for public APIs.
