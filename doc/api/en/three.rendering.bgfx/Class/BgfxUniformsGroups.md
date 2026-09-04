# Class
## class BgfxUniformsGroups
```cj
public class BgfxUniformsGroups
```
bgfx uniform group management

### func bind\(Int64,Int64\)
```cj
public func bind(groupId: Int64, programId: Int64): Unit
```
Bind uniform group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|groupId|Int64|Uniform group IDprogramId Shader program ID|
|programId|Int64||

### func disposeAll\(\)
```cj
public func disposeAll(): Unit
```
Dispose all uniform groups

### func dispose\(Int64\)
```cj
public func dispose(groupId: Int64): Unit
```
Dispose uniform group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|groupId|Int64|Uniform group ID|

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|info|BgfxInfo||

### func update\(Int64,Int64\)
```cj
public func update(groupId: Int64, programId: Int64): Unit
```
Update uniform group data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|groupId|Int64|Uniform group IDprogramId Shader program ID|
|programId|Int64||

