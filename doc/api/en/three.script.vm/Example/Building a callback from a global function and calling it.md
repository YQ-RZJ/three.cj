let cb = LuaCallback.fromValue(vm, vm.getGlobal("onUpdate")).getOrThrow()
let r = cb.call([LuaValue.of(1.0), LuaValue.of(2.0)])
cb.release(vm)