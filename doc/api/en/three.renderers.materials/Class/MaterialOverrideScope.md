# Class
## class MaterialOverrideScope
```cj
public class MaterialOverrideScope
```
Per-mesh material override stack (callback injection style)

### func init\(\)
```cj
public init()
```
Construct a new material override scope

### func pushOverride\(IMesh,\(\)\->IMaterial,\(IMaterial\)\->Unit\)
```cj
public func pushOverride(mesh: IMesh, getter:() -> IMaterial, setter:(IMaterial) -> Unit): Unit
```
Push a material override, backup current material and record setter callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mesh|IMesh|Object handle whose material is being replacedgetter Callback to get the current materialsetter Callback to restore the material|
|getter|()->IMaterial||
|setter|(IMaterial)->Unit||

### func restoreAll\(\)
```cj
public func restoreAll(): Unit
```
Restore all pushed material overrides (in reverse push order), and clear stack frames after restore

