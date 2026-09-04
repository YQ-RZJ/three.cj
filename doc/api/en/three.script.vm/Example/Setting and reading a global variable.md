let v: LuaValue = LuaValue.Number(42.0)
vm.setGlobal("answer", v)
let back = vm.getGlobal("answer")   // LuaValue.Number(42.0)