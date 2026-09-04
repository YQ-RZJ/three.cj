# 类
## class BgfxIndexedBufferRenderer
```cj
public class BgfxIndexedBufferRenderer
```
bgfx 索引缓冲绘制器

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


参数: 

|名称|类型|描述|
|---|---|---|
|info|BgfxInfo||

### func renderInstances\(ViewId,ProgramHandle,Int64,Int64,Int64,UInt32\)
```cj
public func renderInstances(viewId: ViewId, program: ProgramHandle, start: Int64, count: Int64, primcount: Int64, depth: UInt32): Unit
```
实例化索引绘制

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|ViewId|视图 IDprogram 着色器程序句柄start 起始索引count 索引数量primcount 实例数量depth 深度值|
|program|ProgramHandle||
|start|Int64||
|count|Int64||
|primcount|Int64||
|depth|UInt32||

### func renderMultiDraw\(ViewId,ProgramHandle,Array<Int64>,Array<Int64>,Int64,UInt32\)
```cj
public func renderMultiDraw(viewId: ViewId, program: ProgramHandle, starts: Array < Int64 >, counts: Array < Int64 >, drawCount: Int64, depth: UInt32): Unit
```
多次索引绘制

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|ViewId|视图 IDprogram 着色器程序句柄starts 起始索引数组counts 索引数量数组drawCount 绘制次数depth 深度值|
|program|ProgramHandle||
|starts|Array<Int64>||
|counts|Array<Int64>||
|drawCount|Int64||
|depth|UInt32||

### func render\(ViewId,ProgramHandle,Int64,Int64,UInt32\)
```cj
public func render(viewId: ViewId, program: ProgramHandle, start: Int64, count: Int64, depth: UInt32): Unit
```
索引绘制
对照 WebGLIndexedBufferRenderer.render()

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|ViewId||
|program|ProgramHandle||
|start|Int64||
|count|Int64||
|depth|UInt32||

### func setIndex\(UInt32,Int64\)
```cj
public func setIndex(indexType: UInt32, bytesPerElement: Int64): Unit
```
设置索引类型

参数: 

|名称|类型|描述|
|---|---|---|
|indexType|UInt32|索引类型（0 = UInt16, 1 = UInt32）bytesPerElement 每个索引的字节数|
|bytesPerElement|Int64||

### func setMode\(UInt64\)
```cj
public func setMode(value: UInt64): Unit
```
设置绘制模式

参数: 

|名称|类型|描述|
|---|---|---|
|value|UInt64|绘制模式值|

