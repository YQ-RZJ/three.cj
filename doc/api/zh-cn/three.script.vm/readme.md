# 包 three.script.vm 

## API列表

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[LuaCallback](./类/LuaCallback.md#class-luacallback)|Lua 函数回调|
|[LuaDeferredCallbackQueue](./类/LuaDeferredCallbackQueue.md#class-luadeferredcallbackqueue)|跨线程 Lua 回调队列|
|[LuaDeferredTaskQueue](./类/LuaDeferredTaskQueue.md#class-luadeferredtaskqueue)|跨线程延迟任务队列|
|[LuaFunction](./类/LuaFunction.md#class-luafunction)|Lua 函数引用|
|[LuaTable](./类/LuaTable.md#class-luatable)|Lua 表引用|
|[LuaVM](./类/LuaVM.md#class-luavm)|Lua 脚本虚拟机|

### 结构体
|  名称   | 描述  |
|  ----  | ----  |
|[LuaValue](./结构体/LuaValue.md#struct-luavalue)|Lua 值类型|

### 枚举
|  名称   | 描述  |
|  ----  | ----  |
|[LuaVariant](./枚举/LuaVariant.md#enum-luavariant)|LuaValue 内部变体（包内可见，外部勿直接依赖）|

### 异常
|  名称   | 描述  |
|  ----  | ----  |
|[LuaError](./异常/LuaError.md#class-luaerror)|Lua 脚本执行异常|
|[LuaReentryLimitError](./异常/LuaReentryLimitError.md#class-luareentrylimiterror)|Lua 回调重入深度超限异常|


## 案例

- [从全局函数构造回调并调用](./案例/从全局函数构造回调并调用.md)
- [编译并调用一个加法函数](./案例/编译并调用一个加法函数.md)
- [读写表字段与数组](./案例/读写表字段与数组.md)
- [创建虚拟机、执行脚本并释放](./案例/创建虚拟机、执行脚本并释放.md)
