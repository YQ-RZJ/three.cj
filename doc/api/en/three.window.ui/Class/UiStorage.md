# Class
## class UiStorage
```cj
public class UiStorage
```
ImGui persistent key-value storage

### func buildSortByKey\(\)
```cj
public func buildSortByKey(): Unit
```
Sorts by key (optimizes lookup performance)

### func clear\(\)
```cj
public func clear(): Unit
```
Clears all data

### func getBoolRef\(UInt32,Bool\)
```cj
public func getBoolRef(key: UInt32, defaultVal!: Bool = false): CPointer < Int32 >
```
Gets a boolean reference

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|UInt32||
|defaultVal|Bool||

### func getBool\(UInt32,Bool\)
```cj
public func getBool(key: UInt32, defaultVal!: Bool = false): Bool
```
Gets a boolean value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|UInt32||
|defaultVal|Bool||

### func getFloatRef\(UInt32,Float32\)
```cj
public func getFloatRef(key: UInt32, defaultVal!: Float32 = 0.0f32): CPointer < Float32 >
```
Gets a float reference

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|UInt32||
|defaultVal|Float32||

### func getFloat\(UInt32,Float32\)
```cj
public func getFloat(key: UInt32, defaultVal!: Float32 = 0.0f32): Float32
```
Gets a float value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|UInt32||
|defaultVal|Float32||

### func getIntRef\(UInt32,Int32\)
```cj
public func getIntRef(key: UInt32, defaultVal!: Int32 = 0): CPointer < Int32 >
```
Gets an integer reference (inserts default if not found)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|UInt32||
|defaultVal|Int32||

### func getInt\(UInt32,Int32\)
```cj
public func getInt(key: UInt32, defaultVal!: Int32 = 0): Int32
```
Gets an integer value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|UInt32|Data key (ImGui uses ID hash internally)|
|defaultVal|Int32|Default value|

Return: 

- Stored value; returns default if not found

### func getVoidPtr\(UInt32\)
```cj
public func getVoidPtr(key: UInt32): CPointer < Unit >
```
Gets a void* value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|UInt32||

### func getWindowStorage\(\)
```cj
public static func getWindowStorage(): UiStorage
```
Gets the current window's ImGuiStorage

### func init\(CPointer<Unit>\)
```cj
public init(storagePtr: CPointer < Unit >)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|storagePtr|CPointer<Unit>||

### func setAllInt\(Int32\)
```cj
public func setAllInt(val: Int32): Unit
```
Sets all integer values to the same value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|val|Int32||

### func setBool\(UInt32,Bool\)
```cj
public func setBool(key: UInt32, val: Bool): Unit
```
Sets a boolean value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|UInt32||
|val|Bool||

### func setFloat\(UInt32,Float32\)
```cj
public func setFloat(key: UInt32, val: Float32): Unit
```
Sets a float value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|UInt32||
|val|Float32||

### func setInt\(UInt32,Int32\)
```cj
public func setInt(key: UInt32, val: Int32): Unit
```
Sets an integer value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|UInt32||
|val|Int32||

### func setVoidPtr\(UInt32,CPointer<Unit>\)
```cj
public func setVoidPtr(key: UInt32, val: CPointer < Unit >): Unit
```
Sets a void* value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|UInt32||
|val|CPointer<Unit>||

### func setWindowStorage\(UiStorage\)
```cj
public static func setWindowStorage(storage: UiStorage): Unit
```
Sets the current window's ImGuiStorage

Parameter: 

|Name|Type|Describe|
|---|---|---|
|storage|UiStorage||

