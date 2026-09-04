# 类
## class BgfxRenderList
```cj
public class BgfxRenderList
```
渲染列表

### func \`init\`\(\)
```cj
public func `init`(): Unit
```
初始化渲染列表

### func finish\(\)
```cj
public func finish(): Unit
```
排序渲染列表

### func getOpaque\(\)
```cj
public func getOpaque(): ArrayList < RenderItem >
```
获取不透明对象列表

返回: 

- 不透明对象列表

### func getTransmissive\(\)
```cj
public func getTransmissive(): ArrayList < RenderItem >
```
获取半透明对象列表

返回: 

- 半透明对象列表

### func getTransparent\(\)
```cj
public func getTransparent(): ArrayList < RenderItem >
```
获取透明对象列表

返回: 

- 透明对象列表

### func init\(\)
```cj
public init()
```


### func push\(Int64,Int64,Int64,Int64,Int64,Int64,Float64,Int64\)
```cj
public func push(id: Int64, objectId: Int64, renderOrder: Int64, groupOrder: Int64, materialId: Int64, materialVariant: Int64, z: Float64, programId: Int64): Unit
```
添加渲染项

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64||
|objectId|Int64||
|renderOrder|Int64||
|groupOrder|Int64||
|materialId|Int64||
|materialVariant|Int64||
|z|Float64||
|programId|Int64||

