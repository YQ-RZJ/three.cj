# Class
## class BgfxXRController
```cj
public class BgfxXRController
```
XR controller

### func connect\(Any\)
```cj
public func connect(inputSource: Any): Unit
```
Connect controller

Parameter: 

|Name|Type|Describe|
|---|---|---|
|inputSource|Any|Input source|

### func disconnect\(Any\)
```cj
public func disconnect(inputSource: Any): Unit
```
Disconnect controller

Parameter: 

|Name|Type|Describe|
|---|---|---|
|inputSource|Any|Input source|

### func dispatchEvent\(HashMap<String,Any>\)
```cj
public func dispatchEvent(event: HashMap < String, Any >): Unit
```
Dispatch event

Parameter: 

|Name|Type|Describe|
|---|---|---|
|event|HashMap<String,Any>|Event data|

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose resources

### func getGripSpace\(\)
```cj
public func getGripSpace(): XRControllerSpace
```
Get grip space

Return: 

- Grip space

### func getHandSpace\(\)
```cj
public func getHandSpace(): XRControllerSpace
```
Get hand space

Return: 

- Hand space

### func getInputSource\(\)
```cj
public func getInputSource(): Option < Any >
```
Get input source

Return: 

- Input source

### func getTargetRaySpace\(\)
```cj
public func getTargetRaySpace(): XRControllerSpace
```
Get target ray space

Return: 

- Target ray space

### func init\(\)
```cj
public init()
```


### func setInputSource\(Any\)
```cj
public func setInputSource(inputSource: Any): Unit
```
Set input source

Parameter: 

|Name|Type|Describe|
|---|---|---|
|inputSource|Any|Input source|

### func update\(Any,Any,Any\)
```cj
public func update(inputSource: Any, frame: Any, referenceSpace: Any): Unit
```
Update controller state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|inputSource|Any|Input sourceframe XR framereferenceSpace Reference space|
|frame|Any||
|referenceSpace|Any||

