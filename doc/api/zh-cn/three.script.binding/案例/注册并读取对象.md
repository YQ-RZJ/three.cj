let id = LuaObjectRegistry.register(myObj, "three.Example")
let obj = LuaObjectRegistry.get(id)   // Option<Any>