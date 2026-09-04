# Class
## class TouchProvider
```cj
public class TouchProvider <: InputProvider
```
Touch input provider

### func endFrame\(\)
```cj
public override func endFrame(): Unit
```
Resets edge states at frame end

### func getTouchByID\(Int64\)
```cj
public func getTouchByID(fingerID: Int64): Option < TouchPoint >
```
Gets the touch point with the specified finger ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fingerID|Int64|Finger instance ID|

Return: 

- The touch point data, or None if not found

### func getTouchCount\(\)
```cj
public func getTouchCount(): Int64
```
Gets the number of active touch points

Return: 

- The number of touch points

### func getTouch\(Int64\)
```cj
public func getTouch(index: Int64): Option < TouchPoint >
```
Gets the touch point at the specified index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Touch point index (0-based)|

Return: 

- The touch point data, or None if index is out of bounds

### func getTouchesBegan\(\)
```cj
public func getTouchesBegan(): ArrayList < TouchPoint >
```
Gets the list of touch points added this frame

Return: 

- The list of added touch points

### func getTouchesEnded\(\)
```cj
public func getTouchesEnded(): ArrayList < Int64 >
```
Gets the list of finger IDs removed this frame

Return: 

- The list of removed finger IDs

### func init\(\)
```cj
public init()
```
Constructs a touch provider

### func onEvent\(DispatchEvent\)
```cj
public override func onEvent(evt: DispatchEvent): Unit
```
Handles touch events

Parameter: 

|Name|Type|Describe|
|---|---|---|
|evt|DispatchEvent|The dispatch event|

