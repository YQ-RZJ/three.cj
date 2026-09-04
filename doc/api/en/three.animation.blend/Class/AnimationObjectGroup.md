# Class
## class AnimationObjectGroup
```cj
public class AnimationObjectGroup
```
Animation object group that lets a set of objects share the same animation

### func add\(Array<Object3D>\)
```cj
public func add(objects: Array < Object3D >): Unit
```
Adds any number of objects to this animation group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|objects|Array<Object3D>|The 3D objects to add|

### func init\(Array<Object3D>\)
```cj
public init(objects!: Array < Object3D >= Array < Object3D >())
```
Constructs a new animation object group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|objects|Array<Object3D>|The initial array of Object3D objects in the group, defaults to empty|

### func remove\(Array<Object3D>\)
```cj
public func remove(objects: Array < Object3D >): Unit
```
Removes any number of objects from this animation group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|objects|Array<Object3D>|The 3D objects to remove|

### func uncache\(Array<Object3D>\)
```cj
public func uncache(objects: Array < Object3D >): Unit
```
Releases all memory resources of the given 3D objects

Parameter: 

|Name|Type|Describe|
|---|---|---|
|objects|Array<Object3D>|The 3D objects to uncache|

### var stats
```cj
public var stats: HashMap < String, Any >
```
Statistics

### var uuid
```cj
public var uuid: String
```
Unique identifier of the group

