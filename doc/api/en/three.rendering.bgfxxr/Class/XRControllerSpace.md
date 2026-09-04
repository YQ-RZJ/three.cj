# Class
## class XRControllerSpace
```cj
public class XRControllerSpace
```
XR controller space

### func dispatchEvent\(HashMap<String,Any>\)
```cj
public func dispatchEvent(event: HashMap < String, Any >): Unit
```
Dispatch event to this space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|event|HashMap<String,Any>|Event data|

### func init\(\)
```cj
public init()
```


### var angularVelocityX
```cj
public var angularVelocityX: Float64 = 0.0
```
Angular velocity (referring to Three.js targetRay/grip angularVelocity)

### var angularVelocityY
```cj
public var angularVelocityY: Float64 = 0.0
```
Angular velocity Y component

### var angularVelocityZ
```cj
public var angularVelocityZ: Float64 = 0.0
```
Angular velocity Z component

### var eventsEnabled
```cj
public var eventsEnabled: Bool = true
```
Whether events are enabled (referring to Three.js grip.eventsEnabled)

### var hasAngularVelocity
```cj
public var hasAngularVelocity: Bool = false
```
Whether has angular velocity

### var hasInputSource
```cj
public var hasInputSource: Bool = false
```
Whether has input source

### var hasLinearVelocity
```cj
public var hasLinearVelocity: Bool = false
```


### var inputState
```cj
public var inputState: HashMap < String, Any >
```
Input state (referring to Three.js hand.inputState)

### var joints
```cj
public var joints: HashMap < String, XRControllerSpace >
```
Hand joint mapping (referring to Three.js hand.joints)

### var linearVelocityX
```cj
public var linearVelocityX: Float64 = 0.0
```
Linear velocity (referring to Three.js targetRay/grip linearVelocity)

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
Position X

### var positionY
```cj
public var positionY: Float64 = 0.0
```
Position Y

### var positionZ
```cj
public var positionZ: Float64 = 0.0
```
Position Z

### var quaternionW
```cj
public var quaternionW: Float64 = 1.0
```
Rotation quaternion W

### var quaternionX
```cj
public var quaternionX: Float64 = 0.0
```
Rotation quaternion X

### var quaternionY
```cj
public var quaternionY: Float64 = 0.0
```
Rotation quaternion Y

### var quaternionZ
```cj
public var quaternionZ: Float64 = 0.0
```
Rotation quaternion Z

### var spaceType
```cj
public var spaceType: String = ""
```
Space type

### var visible
```cj
public var visible: Bool = false
```
Whether visible

