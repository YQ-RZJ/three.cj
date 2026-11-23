# Interface
## interface ISysEtyMapManager < S, E >
```cj
public interface ISysEtyMapManager < S, E >
```
System-entity mapping manager interface

### func addEntity\(E\)
```cj
func addEntity(ety: E): Unit
```
Add an entity to each system's record area

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ety|E|Entity|

### func addSystem\(S\)
```cj
func addSystem(sys: S): Unit
```
Add a system to the record area

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sys|S|System|

### func bind\(HashMap<Int64,S>,HashMap<Int64,E>\)
```cj
func bind(systems: HashMap < Int64, S >, entitys: HashMap < Int64, E >): Unit
```
Bind system table and entity table (shared references, established by SystemManager)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|systems|HashMap<Int64,S>|System hash mapentitys Entity hash map|
|entitys|HashMap<Int64,E>||

### func changeEntity\(Array<UInt8>,E\)
```cj
func changeEntity(oldMask: Array < UInt8 >, ety: E): Unit
```
Entity components changed, adjust entity's record area assignments

Parameter: 

|Name|Type|Describe|
|---|---|---|
|oldMask|Array<UInt8>|Old component maskety Entity|
|ety|E||

### func clear\(\)
```cj
func clear(): Unit
```
Clear all record areas

### func delEntity\(E\)
```cj
func delEntity(ety: E): Unit
```
Remove an entity from all system record areas

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ety|E|Entity|

### func delSystem\(S\)
```cj
func delSystem(sys: S): Unit
```
Remove a system from the record area

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sys|S|System|

### func getSystemEntitys\(S\)
```cj
func getSystemEntitys(sys: S):(Int64, Iterator < E >)
```
Get all entities in the system's record area

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sys|S||

Return: 

- (Total count, current round snapshot iterator)

