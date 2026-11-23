let vb = LuaClassBinder.defineClass(vm, "three.core.math.Vector3")
vb.constructor { args -> Vector3(args[0].numberValue(), args[1].numberValue(), args[2].numberValue()) }
vb.method("set") { (ref, args) ->
let v = ref.as<Vector3>()
v.set(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
[LuaValue.Object(ref.id)]     // 链式返回自身
}
vb.property("x", ...)
vb.install(vm)