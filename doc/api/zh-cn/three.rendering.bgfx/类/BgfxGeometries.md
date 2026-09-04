# 类
## class BgfxGeometries
```cj
public class BgfxGeometries
```
bgfx 几何体管理

### func disposeAll\(\)
```cj
public func disposeAll(): Unit
```
释放所有几何体

### func dispose\(Int64,Option<Int64>,ArrayList<Int64>\)
```cj
public func dispose(geometryId: Int64, indexAttributeId: Option < Int64 >, attributeIds: ArrayList < Int64 >): Unit
```
释放几何体资源

参数: 

|名称|类型|描述|
|---|---|---|
|geometryId|Int64|几何体 IDindexAttributeId 索引属性 IDattributeIds 顶点属性 ID 列表|
|indexAttributeId|Option<Int64>||
|attributeIds|ArrayList<Int64>||

### func getIndexBuffer\(Int64\)
```cj
public func getIndexBuffer(attributeId: Int64): Option < IndexBufferInfo >
```
获取索引缓冲信息

参数: 

|名称|类型|描述|
|---|---|---|
|attributeId|Int64|属性 ID|

返回: 

- 索引缓冲信息（含 IndexBufferHandle）

### func getLayoutHandle\(Int64\)
```cj
public func getLayoutHandle(attributeId: Int64): Option < VertexLayoutHandle >
```
获取顶点布局句柄

参数: 

|名称|类型|描述|
|---|---|---|
|attributeId|Int64|属性 ID|

返回: 

- 顶点布局句柄

### func getVertexBuffer\(Int64\)
```cj
public func getVertexBuffer(attributeId: Int64): Option < VertexBufferInfo >
```
获取顶点缓冲信息

参数: 

|名称|类型|描述|
|---|---|---|
|attributeId|Int64|属性 ID|

返回: 

- 顶点缓冲信息（含 VertexBufferHandle）

### func getWireframeAttribute\(Int64\)
```cj
public func getWireframeAttribute(geometryId: Int64): Option < Int64 >
```
获取线框属性

参数: 

|名称|类型|描述|
|---|---|---|
|geometryId|Int64|几何体 ID|

返回: 

- 线框属性 ID

### func get\(Int64\)
```cj
public func get(geometryId: Int64): Bool
```
获取或注册几何体

参数: 

|名称|类型|描述|
|---|---|---|
|geometryId|Int64|几何体 ID|

返回: 

- 是否为新注册的几何体

### func init\(BgfxAttributes,BgfxInfo,BgfxBindingStates\)
```cj
public init(attributes!: BgfxAttributes, info!: BgfxInfo, bindingStates!: BgfxBindingStates)
```


参数: 

|名称|类型|描述|
|---|---|---|
|attributes|BgfxAttributes||
|info|BgfxInfo||
|bindingStates|BgfxBindingStates||

### func updateWireframeAttribute\(Int64,Int64\)
```cj
public func updateWireframeAttribute(geometryId: Int64, wireframeAttrId: Int64): Unit
```
更新线框属性

参数: 

|名称|类型|描述|
|---|---|---|
|geometryId|Int64|几何体 IDwireframeAttrId 线框属性 ID|
|wireframeAttrId|Int64||

### func update\(Int64\)
```cj
public func update(geometryId: Int64): Unit
```
更新几何体的所有属性缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|geometryId|Int64|几何体 ID|

