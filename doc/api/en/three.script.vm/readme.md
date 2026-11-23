# Package three.script.vm 

## API List

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[LuaCallback](./Class/LuaCallback.md#class-luacallback)|Lua function callback|
|[LuaDeferredCallbackQueue](./Class/LuaDeferredCallbackQueue.md#class-luadeferredcallbackqueue)|Cross-thread Lua callback queue|
|[LuaDeferredTaskQueue](./Class/LuaDeferredTaskQueue.md#class-luadeferredtaskqueue)|Cross-thread deferred task queue|
|[LuaFunction](./Class/LuaFunction.md#class-luafunction)|Lua function reference|
|[LuaTable](./Class/LuaTable.md#class-luatable)|Lua table reference|
|[LuaVM](./Class/LuaVM.md#class-luavm)|Lua scripting virtual machine|

### Struct
|  Name   | Describe  |
|  ----  | ----  |
|[LuaValue](./Struct/LuaValue.md#struct-luavalue)|Lua value type|

### Enum
|  Name   | Describe  |
|  ----  | ----  |
|[LuaVariant](./Enum/LuaVariant.md#enum-luavariant)|Internal variant of LuaValue (package-visible; do not depend on it directly)|

### Exception
|  Name   | Describe  |
|  ----  | ----  |
|[LuaReentryLimitError](./Exception/LuaReentryLimitError.md#class-luareentrylimiterror)|Lua callback reentry-limit exception|
|[LuaError](./Exception/LuaError.md#class-luaerror)|Lua script execution exception|


## Example

- [Building a callback from a global function and calling it](./Example/Building%20a%20callback%20from%20a%20global%20function%20and%20calling%20it.md)
- [Compiling and calling an addition function](./Example/Compiling%20and%20calling%20an%20addition%20function.md)
- [Reading/writing table fields and arrays](./Example/Reading_writing%20table%20fields%20and%20arrays.md)
- [Creating a VM, executing a script and releasing it](./Example/Creating%20a%20VM,%20executing%20a%20script%20and%20releasing%20it.md)
