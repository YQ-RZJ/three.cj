# 类
## class AssetBundle
```cj
public class AssetBundle
```
资源包（只读档案）

### func contains\(String\)
```cj
public func contains(name: String): Bool
```
是否包含指定资源

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|资源名|

返回: 

- 包含返回 true

### func getNames\(\)
```cj
public func getNames(): ArrayList < String >
```
遍历全部资源名

返回: 

- 资源名列表（顺序为打包顺序）

### func get\(String\)
```cj
public func get(name: String): Option < BundleEntry >
```
获取指定资源的索引信息

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|资源名|

返回: 

- 条目信息，不存在时返回 None

### func loadFromBytes\(Array<UInt8>,Bool\)
```cj
public static func loadFromBytes(bytes: Array < UInt8 >, verify!: Bool = true): Option < AssetBundle >
```
从字节构建资源包并做完整性校验

参数: 

|名称|类型|描述|
|---|---|---|
|bytes|Array<UInt8>|档案字节verify 是否校验各条目 CRC32（默认 true）|
|verify|Bool||

返回: 

- 解析成功返回 Some(AssetBundle)；魔数/版本不合法或 CRC 校验失败返回 None

### func loadFromFile\(String,Bool\)
```cj
public static func loadFromFile(path: String, verify!: Bool = true): Option < AssetBundle >
```
从本地文件加载资源包

参数: 

|名称|类型|描述|
|---|---|---|
|path|String|档案文件路径verify 是否校验各条目 CRC32（默认 true）|
|verify|Bool||

返回: 

- 成功返回 Some(AssetBundle)；文件不存在/格式错误返回 None

### func read\(String\)
```cj
public func read(name: String): Option < Array < UInt8 >>
```
读取指定资源的字节内容（返回切片副本）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|资源名|

返回: 

- 资源字节；资源不存在时返回 None

### prop entryCount: Int64
```cj
public prop entryCount: Int64
```
条目数量

### let MAGIC
```cj
public static let MAGIC: Array < UInt8 >=[0x43u8, 0x4Au8, 0x41u8, 0x42u8]
```
档案魔数（"CJAB"）

### const VERSION
```cj
public static const VERSION: UInt32 = 1u32
```
当前档案格式版本

