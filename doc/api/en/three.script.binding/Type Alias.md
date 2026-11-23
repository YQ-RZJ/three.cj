# Type Alias
## type LuaCtorFn
```cj
public type LuaCtorFn =(Array < LuaValue >) -> Any
```
Constructor callback signature

## type LuaGetterFn
```cj
public type LuaGetterFn =(LuaObjectRef) -> LuaValue
```
Property getter callback signature

## type LuaMethodFn
```cj
public type LuaMethodFn =(LuaObjectRef, Array < LuaValue >) -> Array < LuaValue >
```
Instance method callback signature

## type LuaSetterFn
```cj
public type LuaSetterFn =(LuaObjectRef, LuaValue) -> Unit
```
Property setter callback signature

## type LuaStaticFn
```cj
public type LuaStaticFn =(Array < LuaValue >) -> Array < LuaValue >
```
Static method callback signature

