# Class
## class LuaHotReload
```cj
public class LuaHotReload
```
Lua script hot reloader

### func init\(LuaVM,String\)
```cj
public init(vm: LuaVM, path: String)
```
Constructs a hot reloader

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machine (where the script runs)path The Lua script file path (relative to the current working directory)|
|path|String||

### func load\(\)
```cj
public func load(): Bool
```
Loads and executes the script file for the first time

Return: 

- Whether the load succeeded

### func poll\(\)
```cj
public func poll(): Bool
```
Polls for file changes and reloads automatically when changed

Return: 

- true = a change was detected and the script was reloaded; false = no change or load failure

### func reload\(\)
```cj
public func reload(): Bool
```
Reloads immediately (regardless of whether the file changed)

Return: 

- Whether the reload succeeded

### func setAfterReload\(\(\)\->Unit\)
```cj
public func setAfterReload(cb:() -> Unit): Unit
```
Registers a callback invoked after reload (e.g. refreshing scene state)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cb|()->Unit|The callback executed after reload|

### func setBeforeReload\(\(\)\->Unit\)
```cj
public func setBeforeReload(cb:() -> Unit): Unit
```
Registers a callback invoked before reload (e.g. saving scene state)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cb|()->Unit|The callback executed before reload|

### prop exists: Bool
```cj
public prop exists: Bool
```
Whether the script file currently exists

### prop lastReloadOk: Bool
```cj
public prop lastReloadOk: Bool
```
Whether the last reload succeeded

### prop loaded: Bool
```cj
public prop loaded: Bool
```
Whether the script has been loaded successfully

### prop path: String
```cj
public prop path: String
```
The script path

