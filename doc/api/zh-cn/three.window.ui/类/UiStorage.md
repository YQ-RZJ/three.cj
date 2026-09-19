# 类
## class UiStorage
```cj
public class UiStorage
```
ImGui 持久化 key-value 存储

### func buildSortByKey\(\)
```cj
public func buildSortByKey(): Unit
```
按 key 排序（优化查找性能）

### func clear\(\)
```cj
public func clear(): Unit
```
清空所有数据

### func getBoolRef\(UInt32,Bool\)
```cj
public func getBoolRef(key: UInt32, defaultVal!: Bool = false): PtrArray < Int32 >
```
获取布尔引用

参数: 

|名称|类型|描述|
|---|---|---|
|key|UInt32|数据键（ImGui 内部用 ID 哈希）|
|defaultVal|Bool|默认值，默认 false|

返回: 

- 指向存储位置的引用数组（修改引用值会自动持久化）

### func getBool\(UInt32,Bool\)
```cj
public func getBool(key: UInt32, defaultVal!: Bool = false): Bool
```
获取布尔值

参数: 

|名称|类型|描述|
|---|---|---|
|key|UInt32|数据键（ImGui 内部用 ID 哈希）|
|defaultVal|Bool|默认值，默认 false|

返回: 

- 存储值；不存在时返回默认值

### func getFloatRef\(UInt32,Float32\)
```cj
public func getFloatRef(key: UInt32, defaultVal!: Float32 = 0.0f32): PtrArray < Float32 >
```
获取浮点引用

参数: 

|名称|类型|描述|
|---|---|---|
|key|UInt32|数据键（ImGui 内部用 ID 哈希）|
|defaultVal|Float32|默认值，默认 0.0|

返回: 

- 指向存储位置的引用数组（修改引用值会自动持久化）

### func getFloat\(UInt32,Float32\)
```cj
public func getFloat(key: UInt32, defaultVal!: Float32 = 0.0f32): Float32
```
获取浮点值

参数: 

|名称|类型|描述|
|---|---|---|
|key|UInt32|数据键（ImGui 内部用 ID 哈希）|
|defaultVal|Float32|默认值，默认 0.0|

返回: 

- 存储值；不存在时返回默认值

### func getIntRef\(UInt32,Int32\)
```cj
public func getIntRef(key: UInt32, defaultVal!: Int32 = 0): PtrArray < Int32 >
```
获取整数引用（不存在则插入默认值）

参数: 

|名称|类型|描述|
|---|---|---|
|key|UInt32|数据键（ImGui 内部用 ID 哈希）|
|defaultVal|Int32|默认值，默认 0|

返回: 

- 指向存储位置的引用数组（修改引用值会自动持久化）

### func getInt\(UInt32,Int32\)
```cj
public func getInt(key: UInt32, defaultVal!: Int32 = 0): Int32
```
获取整数值

参数: 

|名称|类型|描述|
|---|---|---|
|key|UInt32|数据键（ImGui 内部用 ID 哈希）|
|defaultVal|Int32|默认值|

返回: 

- 存储值；不存在时返回默认值

### func getVoidPtr\(UInt32\)
```cj
public func getVoidPtr(key: UInt32): VoidPtr
```
获取 void* 值

参数: 

|名称|类型|描述|
|---|---|---|
|key|UInt32|数据键（ImGui 内部用 ID 哈希）|

返回: 

- 存储的 void* 指针；不存在时返回空指针

### func getWindowStorage\(\)
```cj
public static func getWindowStorage(): UiStorage
```
获取当前窗口的 ImGuiStorage

返回: 

- 当前窗口关联的存储对象

### func init\(VoidPtr\)
```cj
public init(storagePtr: VoidPtr)
```
以底层 ImGuiStorage 指针构造

参数: 

|名称|类型|描述|
|---|---|---|
|storagePtr|VoidPtr|底层 ImGuiStorage 指针封装|

### func setAllInt\(Int32\)
```cj
public func setAllInt(val: Int32): Unit
```
将所有整数值设为同一值

参数: 

|名称|类型|描述|
|---|---|---|
|val|Int32|要设置的值|

### func setBool\(UInt32,Bool\)
```cj
public func setBool(key: UInt32, val: Bool): Unit
```
设置布尔值

参数: 

|名称|类型|描述|
|---|---|---|
|key|UInt32|数据键（ImGui 内部用 ID 哈希）|
|val|Bool|要存储的布尔值|

### func setFloat\(UInt32,Float32\)
```cj
public func setFloat(key: UInt32, val: Float32): Unit
```
设置浮点值

参数: 

|名称|类型|描述|
|---|---|---|
|key|UInt32|数据键（ImGui 内部用 ID 哈希）|
|val|Float32|要存储的浮点值|

### func setInt\(UInt32,Int32\)
```cj
public func setInt(key: UInt32, val: Int32): Unit
```
设置整数值

参数: 

|名称|类型|描述|
|---|---|---|
|key|UInt32|数据键（ImGui 内部用 ID 哈希）|
|val|Int32|要存储的整数值|

### func setVoidPtr\(UInt32,VoidPtr\)
```cj
public func setVoidPtr(key: UInt32, val: VoidPtr): Unit
```
设置 void* 值

参数: 

|名称|类型|描述|
|---|---|---|
|key|UInt32|数据键（ImGui 内部用 ID 哈希）|
|val|VoidPtr|要存储的 void* 指针|

### func setWindowStorage\(UiStorage\)
```cj
public static func setWindowStorage(storage: UiStorage): Unit
```
设置当前窗口的 ImGuiStorage

参数: 

|名称|类型|描述|
|---|---|---|
|storage|UiStorage|要设置的存储对象|

