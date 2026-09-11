# 类
## class XRManager
```cj
public class XRManager <: EventDispatcher
```
XRManager — 管理 XR 会话、视图矩阵、控制器跟踪

### func endSession\(\)
```cj
public func endSession(): Unit
```
结束 XR 会话

### func getCamera\(\)
```cj
public func getCamera(): ArrayCamera
```
获取 XR 相机（左右眼组合）

返回: 

- 数组相机

### func getControllerGrip\(Int64\)
```cj
public func getControllerGrip(index: Int64): XRControllerSpace
```
获取指定索引控制器的握持空间

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|控制器索引|

返回: 

- 控制器空间

### func getController\(Int64\)
```cj
public func getController(index: Int64): XRControllerSpace
```
获取指定索引控制器的目标射线空间

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|控制器索引|

返回: 

- 控制器空间

### func getEnvironmentBlendMode\(\)
```cj
public func getEnvironmentBlendMode(): String
```
获取环境混合模式

返回: 

- 环境混合模式

### func getFoveation\(\)
```cj
public func getFoveation(): Float64
```
获取注视点渲染级别

返回: 

- 注视点级别

### func getHand\(Int64\)
```cj
public func getHand(index: Int64): XRControllerSpace
```
获取指定索引控制器的手部空间

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|控制器索引|

返回: 

- 控制器空间

### func getReferenceSpaceType\(\)
```cj
public func getReferenceSpaceType(): XRReferenceSpaceType
```
获取参考空间类型

返回: 

- 参考空间类型

### func init\(ThreeRenderer\)
```cj
public init(renderer: ThreeRenderer)
```
构造 XR 管理器

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|bgfx 渲染器实例|

### func isXRPresenting\(\)
```cj
public func isXRPresenting(): Bool
```
XR 是否正在呈现

返回: 

- 是否正在呈现

### func requestSession\(String\)
```cj
public func requestSession(mode: String): Unit
```
请求 XR 会话

参数: 

|名称|类型|描述|
|---|---|---|
|mode|String|会话模式（如 "immersive-vr"）|

### func setEnabled\(Bool\)
```cj
public func setEnabled(value: Bool): Unit
```
设置 XR 是否启用

参数: 

|名称|类型|描述|
|---|---|---|
|value|Bool|是否启用|

### func setFoveation\(Float64\)
```cj
public func setFoveation(value: Float64): Unit
```
设置注视点渲染级别

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float64|注视点级别|

### func setFramebufferScaleFactor\(Float64\)
```cj
public func setFramebufferScaleFactor(factor: Float64): Unit
```
设置帧缓冲缩放因子

参数: 

|名称|类型|描述|
|---|---|---|
|factor|Float64|缩放因子|

### func setReferenceSpaceType\(XRReferenceSpaceType\)
```cj
public func setReferenceSpaceType(`type`: XRReferenceSpaceType): Unit
```
设置参考空间类型

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|XRReferenceSpaceType|参考空间类型|

### func updateCamera\(PerspectiveCamera\)
```cj
public func updateCamera(camera: PerspectiveCamera): Unit
```
更新相机（左右眼投影矩阵与位姿）

参数: 

|名称|类型|描述|
|---|---|---|
|camera|PerspectiveCamera|主透视相机|

