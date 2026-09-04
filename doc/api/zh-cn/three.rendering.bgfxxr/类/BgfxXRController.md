# 类
## class BgfxXRController
```cj
public class BgfxXRController
```
XR 控制器

### func connect\(Any\)
```cj
public func connect(inputSource: Any): Unit
```
连接控制器

参数: 

|名称|类型|描述|
|---|---|---|
|inputSource|Any|输入源|

### func disconnect\(Any\)
```cj
public func disconnect(inputSource: Any): Unit
```
断开连接

参数: 

|名称|类型|描述|
|---|---|---|
|inputSource|Any|输入源|

### func dispatchEvent\(HashMap<String,Any>\)
```cj
public func dispatchEvent(event: HashMap < String, Any >): Unit
```
分发事件

参数: 

|名称|类型|描述|
|---|---|---|
|event|HashMap<String,Any>|事件数据|

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放资源

### func getGripSpace\(\)
```cj
public func getGripSpace(): XRControllerSpace
```
获取握持空间

返回: 

- 握持空间

### func getHandSpace\(\)
```cj
public func getHandSpace(): XRControllerSpace
```
获取手部空间

返回: 

- 手部空间

### func getInputSource\(\)
```cj
public func getInputSource(): Option < Any >
```
获取输入源

返回: 

- 输入源

### func getTargetRaySpace\(\)
```cj
public func getTargetRaySpace(): XRControllerSpace
```
获取目标射线空间

返回: 

- 目标射线空间

### func init\(\)
```cj
public init()
```


### func setInputSource\(Any\)
```cj
public func setInputSource(inputSource: Any): Unit
```
设置输入源

参数: 

|名称|类型|描述|
|---|---|---|
|inputSource|Any|输入源|

### func update\(Any,Any,Any\)
```cj
public func update(inputSource: Any, frame: Any, referenceSpace: Any): Unit
```
更新控制器状态

参数: 

|名称|类型|描述|
|---|---|---|
|inputSource|Any|输入源frame XR 帧referenceSpace 参考空间|
|frame|Any||
|referenceSpace|Any||

