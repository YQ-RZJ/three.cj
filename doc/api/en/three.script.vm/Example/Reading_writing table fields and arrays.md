vm.doString("player = {name='Alice', hp=100, x=1, y=2}")
let t = LuaTable.fromGlobal(vm, "player")
t.set("hp", LuaValue.of(Int64(90)))          // 写字段
let hp = t.get("hp").numberValue()           // 读字段
let x = t.getIndex(1).numberValue()          // 数组索引
let n = t.len()                              // 数组长度