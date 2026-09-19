# 包 three.utils.memory 

## API列表

### 函数
|  名称   | 描述  |
|  ----  | ----  |
|[intToCPointer(T)where T <: CType](./函数.md#func-inttocpointertwhere-t-ctype)|将整数类型转换为指针|
|[makeAutoFree(CPointer<T>)where T <: CType](./函数.md#func-makeautofreecpointertwhere-t-ctype)|创建 AutoFreePtr 的便捷函数|
|[makeScopeGuard(()->Unit)](./函数.md#func-makescopeguard-unit)|创建 ScopeGuard 的便捷函数|
|[makeShared(CPointer<T>)where T <: CType](./函数.md#func-makesharedcpointertwhere-t-ctype)|创建 SharedPtr 的便捷函数（使用默认 LibC.free 释放）|
|[makeShared(CPointer<T>,(CPointer<T>)->Unit)where T <: CType](./函数.md#func-makesharedcpointertcpointert-unitwhere-t-ctype)|创建 SharedPtr 的便捷函数（使用自定义释放函数）|
|[makeUnique(CPointer<T>)where T <: CType](./函数.md#func-makeuniquecpointertwhere-t-ctype)|创建 UniquePtr 的便捷函数（使用默认 LibC.free 释放）|
|[makeUnique(CPointer<T>,(CPointer<T>)->Unit)where T <: CType](./函数.md#func-makeuniquecpointertcpointert-unitwhere-t-ctype)|创建 UniquePtr 的便捷函数（使用自定义释放函数）|

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[AutoFreePtr<T> where T <: CType](./类/AutoFreePtr.md#class-autofreeptr-t-where-t-ctype)|自动释放指针包装|
|[BgfxMemory](./类/BgfxMemory.md#class-bgfxmemory)|安全包装 bgfx Memory 分配|
|[PtrArray<T> where T <: CType](./类/PtrArray.md#class-ptrarray-t-where-t-ctype)|指针底层数组|
|[ScopeGuard](./类/ScopeGuard.md#class-scopeguard)|RAII 作用域守卫|
|[SharedPtr<T> where T <: CType](./类/SharedPtr.md#class-sharedptr-t-where-t-ctype)|引用计数共享智能指针|
|[UniquePtr<T> where T <: CType](./类/UniquePtr.md#class-uniqueptr-t-where-t-ctype)|独占所有权智能指针|

### 类型别名
|  名称   | 描述  |
|  ----  | ----  |
|[VoidPtr](./类型别名.md#type-voidptr)|void* 指针包装|

