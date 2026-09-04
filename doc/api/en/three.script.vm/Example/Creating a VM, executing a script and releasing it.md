let vm = LuaVM()                       // 创建状态机 + 打开标准库
let r = vm.doString("return 1 + 2")    // 动态解析 + 执行，返回多值
vm.setGlobal("player", LuaValue.of("Alice"))
let fn = vm.loadString("function(a,b) return a*b end")  // 编译
vm.dispose()                           // 关闭状态机