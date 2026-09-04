let f = vm.loadString("function(a, b) return a + b, a * b end")
let r = f.call([LuaValue.of(3.0), LuaValue.of(4.0)])
r[0].numberValue() == 7.0   // a+b
r[1].numberValue() == 12.0  // a*b