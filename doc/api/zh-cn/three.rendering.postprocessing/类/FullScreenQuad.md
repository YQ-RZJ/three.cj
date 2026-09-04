# 类
## class FullScreenQuad
```cj
public class FullScreenQuad
```
全屏四边形共享资源

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放全屏四边形占用的 GPU 资源

### func ensureResources\(BgfxRenderer\)
```cj
public func ensureResources(renderer: BgfxRenderer): Unit
```
确保全屏四边形缓存资源已创建（懒创建）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器（bgfx 资源创建经其高阶 API 序列化到渲染线程）|

### func init\(\)
```cj
public init()
```


### func setRenderer\(BgfxRenderer\)
```cj
public func setRenderer(renderer: BgfxRenderer): Unit
```
注入渲染器

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|

### func submitWithState\(UInt16,ProgramHandle,UInt64\)
```cj
public func submitWithState(viewId: UInt16, prog: ProgramHandle, state: UInt64): Unit
```
提交全屏四边形，使用自定义 render state（如加性混合）

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view id|
|prog|ProgramHandle|已编译的 program handle|
|state|UInt64|完整 render state（bgfx_set_state_cj 第 1 参）|

### func submit\(UInt16,ProgramHandle\)
```cj
public func submit(viewId: UInt16, prog: ProgramHandle): Unit
```
提交全屏四边形（用缓存的 VB/IB/layout）

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view id|
|prog|ProgramHandle|已编译的 program handle|

