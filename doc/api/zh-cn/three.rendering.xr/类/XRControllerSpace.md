# 类
## class XRControllerSpace
```cj
public class XRControllerSpace
```
XR 控制器空间

### func dispatchEvent\(HashMap<String,Any>\)
```cj
public func dispatchEvent(event: HashMap < String, Any >): Unit
```
分发事件到该空间

参数: 

|名称|类型|描述|
|---|---|---|
|event|HashMap<String,Any>|事件数据|

### func init\(\)
```cj
public init()
```


### var angularVelocityX
```cj
public var angularVelocityX: Float64 = 0.0
```
角速度（参照 Three.js targetRay/grip 的 angularVelocity）

### var angularVelocityY
```cj
public var angularVelocityY: Float64 = 0.0
```
角速度 Y 分量

### var angularVelocityZ
```cj
public var angularVelocityZ: Float64 = 0.0
```
角速度 Z 分量

### var eventsEnabled
```cj
public var eventsEnabled: Bool = true
```
事件是否启用（参照 Three.js grip.eventsEnabled）

### var hasAngularVelocity
```cj
public var hasAngularVelocity: Bool = false
```
是否有角速度

### var hasInputSource
```cj
public var hasInputSource: Bool = false
```
是否有输入源

### var hasLinearVelocity
```cj
public var hasLinearVelocity: Bool = false
```


### var inputState
```cj
public var inputState: HashMap < String, Any >
```
输入状态（参照 Three.js hand.inputState）

### var joints
```cj
public var joints: HashMap < String, XRControllerSpace >
```
手部关节映射（参照 Three.js hand.joints）

### var linearVelocityX
```cj
public var linearVelocityX: Float64 = 0.0
```
线速度（参照 Three.js targetRay/grip 的 linearVelocity）

### var linearVelocityY
```cj
public var linearVelocityY: Float64 = 0.0
```


### var linearVelocityZ
```cj
public var linearVelocityZ: Float64 = 0.0
```


### var positionX
```cj
public var positionX: Float64 = 0.0
```
位置 X

### var positionY
```cj
public var positionY: Float64 = 0.0
```
位置 Y

### var positionZ
```cj
public var positionZ: Float64 = 0.0
```
位置 Z

### var quaternionW
```cj
public var quaternionW: Float64 = 1.0
```
旋转四元数 W

### var quaternionX
```cj
public var quaternionX: Float64 = 0.0
```
旋转四元数 X

### var quaternionY
```cj
public var quaternionY: Float64 = 0.0
```
旋转四元数 Y

### var quaternionZ
```cj
public var quaternionZ: Float64 = 0.0
```
旋转四元数 Z

### var spaceType
```cj
public var spaceType: String = ""
```
空间类型

### var visible
```cj
public var visible: Bool = false
```
是否可见

