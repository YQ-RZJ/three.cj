# 类
## class BgfxAttributes
```cj
public class BgfxAttributes
```
bgfx 顶点属性缓冲管理

### func createVertexLayout\(Array<BgfxAttributeDesc>\)
```cj
public func createVertexLayout(attributes: Array < BgfxAttributeDesc >): VertexLayoutHandle
```
创建顶点布局并登记内存指针

参数: 

|名称|类型|描述|
|---|---|---|
|attributes|Array<BgfxAttributeDesc>|属性描述列表（BgfxAttributeDesc）|

返回: 

- 顶点布局句柄（无效则 idx=0xFFFF）

### func destroyVertexLayout\(VertexLayoutHandle\)
```cj
public func destroyVertexLayout(layout: VertexLayoutHandle): Unit
```
销毁顶点布局并释放登记的内存指针

参数: 

|名称|类型|描述|
|---|---|---|
|layout|VertexLayoutHandle|待销毁的顶点布局句柄|

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放所有缓冲

### func getIndexBuffer\(Int64\)
```cj
public func getIndexBuffer(attributeId: Int64): Option < IndexBufferInfo >
```
获取索引缓冲信息

参数: 

|名称|类型|描述|
|---|---|---|
|attributeId|Int64|属性对象 ID|

返回: 

- 索引缓冲信息，未找到返回 None

### func getVertexBuffer\(Int64\)
```cj
public func getVertexBuffer(attributeId: Int64): Option < VertexBufferInfo >
```
获取顶点缓冲信息

参数: 

|名称|类型|描述|
|---|---|---|
|attributeId|Int64|属性对象 ID|

返回: 

- 顶点缓冲信息，未找到返回 None

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


参数: 

|名称|类型|描述|
|---|---|---|
|info|BgfxInfo||

### func removeIndexBuffer\(Int64\)
```cj
public func removeIndexBuffer(attributeId: Int64): Unit
```
移除索引缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|attributeId|Int64|属性对象 ID|

### func removeVertexBuffer\(Int64\)
```cj
public func removeVertexBuffer(attributeId: Int64): Unit
```
移除顶点缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|attributeId|Int64|属性对象 ID|

### func updateIndexBuffer\(Int64,BgfxMemory,Int64,Int64,Int64\)
```cj
public func updateIndexBuffer(attributeId: Int64, mem: BgfxMemory, size: Int64, bytesPerElement: Int64, version: Int64): Unit
```
更新或创建索引缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|attributeId|Int64|属性对象 IDmem 索引数据内存size 数据大小（字节）bytesPerElement 每元素字节数version 版本号|
|mem|BgfxMemory||
|size|Int64||
|bytesPerElement|Int64||
|version|Int64||

### func updateVertexBuffer\(Int64,BgfxMemory,VertexLayoutHandle,Int64,Int64,Int64,Bool\)
```cj
public func updateVertexBuffer(attributeId: Int64, mem: BgfxMemory, layout: VertexLayoutHandle, size: Int64, bytesPerElement: Int64, version: Int64, dynamic: Bool): Unit
```
更新或创建顶点缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|attributeId|Int64|属性对象 IDmem 顶点数据内存（BgfxMemory，内部取指针）layout 顶点布局句柄（经 createVertexLayout 创建，内部查表取指针）size 数据大小（字节）bytesPerElement 每元素字节数version 版本号dynamic 是否动态缓冲|
|mem|BgfxMemory||
|layout|VertexLayoutHandle||
|size|Int64||
|bytesPerElement|Int64||
|version|Int64||
|dynamic|Bool||

