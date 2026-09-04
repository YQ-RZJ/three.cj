# 类
## class Buffer
```cj
public open class Buffer <: Binding
```
GPU 缓冲区管理类

### func createIndexBuffer\(Array<UInt32>,Int64\)
```cj
public func createIndexBuffer(data: Array < UInt32 >, size: Int64): Int64
```
创建索引缓冲区

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt32>|索引数据数组size 数据大小|
|size|Int64||

返回: 

- 缓冲区句柄

### func createVertexBuffer\(Array<Float32>,Int64\)
```cj
public func createVertexBuffer(data: Array < Float32 >, size: Int64): Int64
```
创建顶点缓冲区

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<Float32>|顶点数据数组size 数据大小|
|size|Int64||

返回: 

- 缓冲区句柄

### func destroyBuffer\(Int64\)
```cj
public func destroyBuffer(handle: Int64): Unit
```
销毁缓冲区

参数: 

|名称|类型|描述|
|---|---|---|
|handle|Int64|缓冲区句柄|

### func init\(Backend\)
```cj
public init(backend: Backend)
```
构造缓冲区，关联到指定后端

参数: 

|名称|类型|描述|
|---|---|---|
|backend|Backend|渲染后端实例|

### func updateBuffer\(Int64,Array<Float32>\)
```cj
public func updateBuffer(handle: Int64, data: Array < Float32 >): Unit
```
更新缓冲区数据

参数: 

|名称|类型|描述|
|---|---|---|
|handle|Int64|缓冲区句柄data 更新数据|
|data|Array<Float32>||

### var backend
```cj
public var backend: Backend
```
后端引用

