# Class
## class PostProcessing
```cj
public class PostProcessing
```
Post-processing renderer

### func init\(\)
```cj
public init()
```
Constructs a default post-processing renderer (disabled)

### func render\(Scene,Camera\)
```cj
public func render(scene: Scene, camera: Camera): Unit
```
Executes post-processing rendering

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene|Scenecamera Camera|
|camera|Camera||

### var enabled
```cj
public var enabled: Bool
```
Whether post-processing is enabled

