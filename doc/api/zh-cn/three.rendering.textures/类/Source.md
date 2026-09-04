# 类
## class Source
```cj
public open class Source <: ILoadResult
```
贴图数据源类

### func getSize\(\)
```cj
public func getSize():(Int64, Int64)
```
取贴图宽高

返回: 

- (width, height) 元组

### func init\(Array<UInt8>,Int64,Int64\)
```cj
public init(data!: Array < UInt8 >= Array < UInt8 >(), width!: Int64 = 0, height!: Int64 = 0)
```
构造一个新的贴图数据源

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|像素数组，默认空width 数据宽度（像素），默认 0height 数据高度（像素），默认 0|
|width|Int64||
|height|Int64||

### prop needsUpdate: Bool
```cj
public mut prop needsUpdate: Bool
```
渲染器内部增量更新标志，true 时下次 render 会重传 GPU 缓冲

### var dataReady
```cj
public var dataReady: Bool
```
数据准备就绪标志

### var data
```cj
public var data: Array < UInt8 >
```
像素数据数组（渲染器内部按 format/type 解释）

### var height
```cj
public var height: Int64
```
数据高度（像素）

### var kind
```cj
public var kind: String
```
类型标签

### var version
```cj
public var version: Int64
```
渲染器内部版本号，每次 needsUpdate=true 时 render 后递增

### var width
```cj
public var width: Int64
```
数据宽度（像素）

