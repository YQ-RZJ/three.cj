LuaBinder.registerFunction(vm, "cj_add") { args ->
let a = args[0].numberValue()
let b = args[1].numberValue()
[LuaValue.of(a + b)]
}
vm.doString("result = cj_add(2, 3)")   // Lua 侧直接调用仓颉函数