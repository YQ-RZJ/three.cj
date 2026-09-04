# Class
## class BgfxBindingStates
```cj
public class BgfxBindingStates
```
bgfx vertex binding states management

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose all binding states

### func init\(\)
```cj
public init()
```


### func releaseStatesOfGeometry\(Int64\)
```cj
public func releaseStatesOfGeometry(geometryId: Int64): Unit
```
Release binding states of a geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64|Geometry ID|

### func releaseStatesOfProgram\(Int64\)
```cj
public func releaseStatesOfProgram(programId: Int64): Unit
```
Release binding states of a program

Parameter: 

|Name|Type|Describe|
|---|---|---|
|programId|Int64|Program ID|

### func reset\(\)
```cj
public func reset(): Unit
```
Reset binding states

### func setup\(Int64,Int64,Int64,Bool\)
```cj
public func setup(geometryId: Int64, objectId: Int64, programId: Int64, wireframe: Bool): BindingState
```
Set up vertex binding

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64|Geometry IDobjectId Object IDprogramId Program IDwireframe Whether wireframe mode|
|objectId|Int64||
|programId|Int64||
|wireframe|Bool||

Return: 

- Binding state

