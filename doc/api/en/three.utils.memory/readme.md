# Package three.utils.memory 

## API List

### Function
|  Name   | Describe  |
|  ----  | ----  |
|[intToCPointer(T)where T <: CType](./Function.md#func-inttocpointertwhere-t-ctype)|Converts an integer type into a pointer|
|[makeAutoFree(CPointer<T>)where T <: CType](./Function.md#func-makeautofreecpointertwhere-t-ctype)|Convenience factory for AutoFreePtr|
|[makeScopeGuard(()->Unit)](./Function.md#func-makescopeguard-unit)|Convenience factory for ScopeGuard|
|[makeShared(CPointer<T>)where T <: CType](./Function.md#func-makesharedcpointertwhere-t-ctype)|Convenience factory for SharedPtr (released via default LibC.free)|
|[makeShared(CPointer<T>,(CPointer<T>)->Unit)where T <: CType](./Function.md#func-makesharedcpointertcpointert-unitwhere-t-ctype)|Convenience factory for SharedPtr (with a custom deleter)|
|[makeUnique(CPointer<T>)where T <: CType](./Function.md#func-makeuniquecpointertwhere-t-ctype)|Convenience factory for UniquePtr (released via default LibC.free)|
|[makeUnique(CPointer<T>,(CPointer<T>)->Unit)where T <: CType](./Function.md#func-makeuniquecpointertcpointert-unitwhere-t-ctype)|Convenience factory for UniquePtr (with a custom deleter)|

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[AutoFreePtr<T> where T <: CType](./Class/AutoFreePtr.md#class-autofreeptr-t-where-t-ctype)|Auto-free pointer wrapper|
|[BgfxMemory](./Class/BgfxMemory.md#class-bgfxmemory)|Safe wrapper around bgfx Memory allocation|
|[PtrArray<T> where T <: CType](./Class/PtrArray.md#class-ptrarray-t-where-t-ctype)|Pointer-backed array|
|[ScopeGuard](./Class/ScopeGuard.md#class-scopeguard)|RAII scope guard|
|[SharedPtr<T> where T <: CType](./Class/SharedPtr.md#class-sharedptr-t-where-t-ctype)|Reference-counted shared smart pointer|
|[UniquePtr<T> where T <: CType](./Class/UniquePtr.md#class-uniqueptr-t-where-t-ctype)|Exclusive-ownership smart pointer|

### Type Alias
|  Name   | Describe  |
|  ----  | ----  |
|[VoidPtr](./Type%20Alias.md#type-voidptr)|void* pointer wrapper|

