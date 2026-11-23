# 类
## class EngineRenderTarget
```cj
public class EngineRenderTarget <: IReleasable
```
引擎渲染目标

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源（dispose 的别名，满足链式习惯）

### func init\(IRenderBackend,Int64,Int64,UInt32,UInt64,Bool\)
```cj
public init(backend: IRenderBackend, width: Int64, height: Int64, format!: UInt32, flags!: UInt64, depth!: Bool = true)
```
构造渲染目标并创建 GPU 资源

参数: 

|名称|类型|描述|
|---|---|---|
|backend|IRenderBackend||
|width|Int64||
|height|Int64||
|format|UInt32||
|flags|UInt64||
|depth|Bool||

### func release\(\)
```cj
public func release(): Bool
```
释放 GPU 资源（幂等）

### func resize\(Int64,Int64\)
```cj
public func resize(width: Int64, height: Int64): Unit
```
重建为指定尺寸（沿用构造时的格式/标志/深度配置）

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|新宽（物理像素）height 新高（物理像素）|
|height|Int64||

### prop height: Int64
```cj
public prop height: Int64
```
RT 高（物理像素）

### prop releasable: Bool
```cj
public prop releasable: Bool
```
GPU 资源是否有效

### prop width: Int64
```cj
public prop width: Int64
```
RT 宽（物理像素）

