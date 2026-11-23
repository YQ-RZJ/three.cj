# Package three.script.binding 

## API List

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[LuaBinder](./Class/LuaBinder.md#class-luabinder)|Cangjie-Lua binder (a collection of static methods)|
|[LuaClassBinder](./Class/LuaClassBinder.md#class-luaclassbinder)|Cangjie class → Lua type binding engine|
|[LuaObjectRef](./Class/LuaObjectRef.md#class-luaobjectref)|Engine object reference (self in method/property callbacks)|
|[LuaObjectRegistry](./Class/LuaObjectRegistry.md#class-luaobjectregistry)|Engine object registry (a collection of static methods)|

### Type Alias
|  Name   | Describe  |
|  ----  | ----  |
|[LuaCtorFn](./Type%20Alias.md#type-luactorfn)|Constructor callback signature|
|[LuaGetterFn](./Type%20Alias.md#type-luagetterfn)|Property getter callback signature|
|[LuaMethodFn](./Type%20Alias.md#type-luamethodfn)|Instance method callback signature|
|[LuaSetterFn](./Type%20Alias.md#type-luasetterfn)|Property setter callback signature|
|[LuaStaticFn](./Type%20Alias.md#type-luastaticfn)|Static method callback signature|


## Example

- [Registering a Cangjie function and calling it from Lua](./Example/Registering%20a%20Cangjie%20function%20and%20calling%20it%20from%20Lua.md)
- [Binding core operations of Vector3](./Example/Binding%20core%20operations%20of%20Vector3.md)
- [Registering and reading an object](./Example/Registering%20and%20reading%20an%20object.md)
