# Class
## class BgfxClipping
```cj
public class BgfxClipping
```
bgfx clipping plane management

### func \`init\`\(ArrayList<Plane>,Bool\)
```cj
public func `init`(planes: ArrayList < Plane >, enableLocalClipping: Bool): Bool
```
Initializes clipping planes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|planes|ArrayList<Plane>|Global clipping plane arrayenableLocalClipping Whether to enable local clipping|
|enableLocalClipping|Bool||

Return: 

- Whether clipping is enabled

### func beginShadows\(\)
```cj
public func beginShadows(): Unit
```
Begins shadow rendering

### func endShadows\(\)
```cj
public func endShadows(): Unit
```
Ends shadow rendering

### func init\(\)
```cj
public init()
```


### func setGlobalState\(ArrayList<Plane>,Camera\)
```cj
public func setGlobalState(planes: ArrayList < Plane >, camera: Camera): Unit
```
Sets global clipping state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|planes|ArrayList<Plane>|Global clipping plane arraycamera Camera|
|camera|Camera||

### func setState\(Material,Camera,Bool\)
```cj
public func setState(material: Material, camera: Camera, useCache: Bool): Unit
```
Sets material clipping state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|material|Material|Materialcamera CamerauseCache Whether to use cache|
|camera|Camera||
|useCache|Bool||

### var numIntersection
```cj
public var numIntersection: Int64 = 0
```
Number of intersection clipping planes

### var numPlanes
```cj
public var numPlanes: Int64 = 0
```
Number of clipping planes

### let uniform
```cj
public let uniform: ClippingUniform
```
Clipping plane uniform

