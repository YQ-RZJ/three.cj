# Class
## class BgfxMaterials
```cj
public class BgfxMaterials
```
bgfx material management

### func disposeAll\(\)
```cj
public func disposeAll(): Unit
```
Disposes all material states

### func dispose\(Int64\)
```cj
public func dispose(materialId: Int64): Unit
```
Disposes material state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|materialId|Int64|Material ID|

### func getMaterialState\(Int64\)
```cj
public func getMaterialState(materialId: Int64): MaterialState
```
Gets or creates material state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|materialId|Int64|Material ID|

Return: 

- Material state

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|info|BgfxInfo||

### func markNeedsUpdate\(Int64\)
```cj
public func markNeedsUpdate(materialId: Int64): Unit
```
Marks material as needing update

Parameter: 

|Name|Type|Describe|
|---|---|---|
|materialId|Int64|Material ID|

### func markUpdated\(Int64\)
```cj
public func markUpdated(materialId: Int64): Unit
```
Marks material as updated

Parameter: 

|Name|Type|Describe|
|---|---|---|
|materialId|Int64|Material ID|

### func needsUpdate\(Int64\)
```cj
public func needsUpdate(materialId: Int64): Bool
```
Checks if material needs update

Parameter: 

|Name|Type|Describe|
|---|---|---|
|materialId|Int64|Material ID|

Return: 

- Whether update is needed

