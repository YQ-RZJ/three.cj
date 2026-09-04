# 类
## class BgfxBufferRenderer
```cj
public class BgfxBufferRenderer
```
bgfx 非索引缓冲绘制器

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
实例化非索引绘制

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|ViewId|视图 IDprogram 着色器程序句柄start 起始顶点索引count 绘制顶点数primcount 实例数depth 深度值|
|program|ProgramHandle||
|start|Int64||
|count|Int64||
|primcount|Int64||
|depth|UInt32||

### func renderMultiDraw\(ViewId,ProgramHandle,Array<Int64>,Array<Int64>,Int64,UInt32\)
```cj
public func renderMultiDraw(viewId: ViewId, program: ProgramHandle, starts: Array < Int64 >, counts: Array < Int64 >, drawCount: Int64, depth: UInt32): Unit
```
多次绘制（间接绘制）

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|ViewId|视图 IDprogram 着色器程序句柄starts 起始索引数组counts 顶点计数数组drawCount 绘制调用数depth 深度值|
|program|ProgramHandle||
|starts|Array<Int64>||
|counts|Array<Int64>||
|drawCount|Int64||
|depth|UInt32||

### func render\(ViewId,ProgramHandle,Int64,Int64,UInt32\)
```cj
public func render(viewId: ViewId, program: ProgramHandle, start: Int64, count: Int64, depth: UInt32): Unit
```
非索引绘制

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|ViewId|视图 IDprogram 着色器程序句柄start 起始顶点索引count 绘制顶点数depth 深度值|
|program|ProgramHandle||
|start|Int64||
|count|Int64||
|depth|UInt32||

### func setMode\(UInt64\)
```cj
public func setMode(value: UInt64): Unit
```
设置绘制模式

参数: 

|名称|类型|描述|
|---|---|---|
|value|UInt64|绘制模式值|

