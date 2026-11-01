# Class
## class AssetBundle
```cj
public class AssetBundle
```
Read-only resource bundle

### func contains\(String\)
```cj
public func contains(name: String): Bool
```
Whether the bundle contains the named entry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Entry name|

Return: 

- True when contained

### func getNames\(\)
```cj
public func getNames(): ArrayList < String >
```
Iterates all entry names

Return: 

- Entry name list (in packing order)

### func get\(String\)
```cj
public func get(name: String): Option < BundleEntry >
```
Gets the index info of the named entry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Entry name|

Return: 

- Entry info, or None when absent

### func loadFromBytes\(Array<UInt8>,Bool\)
```cj
public static func loadFromBytes(bytes: Array < UInt8 >, verify!: Bool = true): Option < AssetBundle >
```
Builds a bundle from bytes with integrity verification

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bytes|Array<UInt8>|Archive bytesverify Whether to verify per-entry CRC32 (default true)|
|verify|Bool||

Return: 

- Some(AssetBundle) on success; None on bad magic/version or CRC mismatch

### func loadFromFile\(String,Bool\)
```cj
public static func loadFromFile(path: String, verify!: Bool = true): Option < AssetBundle >
```
Loads a bundle from a local file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|path|String|Archive file pathverify Whether to verify per-entry CRC32 (default true)|
|verify|Bool||

Return: 

- Some(AssetBundle) on success; None when the file is missing or malformed

### func read\(String\)
```cj
public func read(name: String): Option < Array < UInt8 >>
```
Reads the named entry bytes (returns a slice copy)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Entry name|

Return: 

- Entry bytes, or None when absent

### prop entryCount: Int64
```cj
public prop entryCount: Int64
```
Entry count

### let MAGIC
```cj
public static let MAGIC: Array < UInt8 >=[0x43u8, 0x4Au8, 0x41u8, 0x42u8]
```
Archive magic ("CJAB")

### const VERSION
```cj
public static const VERSION: UInt32 = 1u32
```
Current archive format version

