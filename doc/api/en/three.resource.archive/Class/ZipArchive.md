# Class
## class ZipArchive
```cj
public class ZipArchive
```
ZIP archive: parses the central directory and extracts entries on demand

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>loadFromBytes only parses the directory (cost proportional to the entry count,
no decompression); decompression and CRC32 verification happen per read()/extractAll().</p>

### func extractAll\(String,Bool\)
```cj
public func extractAll(dir: String, verify!: Bool = true): Bool
```
Extracts all entries to the target directory

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dir|String|Target directory|
|verify|Bool|Whether to verify each file entry's CRC32 (default true)|

Return: 

- true when all entries are processed successfully

### func find\(String\)
```cj
public func find(name: String): Option < ZipEntry >
```
Finds an entry by name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Entry path inside the archive|

Return: 

- Some(ZipEntry) when found, otherwise None

### func loadFromBytes\(Array<UInt8>\)
```cj
public static func loadFromBytes(bytes: Array < UInt8 >): Option < ZipArchive >
```
Parses a ZIP archive from bytes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bytes|Array<UInt8>|ZIP archive bytes|

Return: 

- Some(ZipArchive) on success; None (with an error log) when the structureis not a ZIP (EOCD not found / bad central directory signatures / entries out of range)

### func loadFromFile\(String\)
```cj
public static func loadFromFile(path: String): Option < ZipArchive >
```
Loads and parses a ZIP archive from a local file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|path|String|ZIP file path|

Return: 

- Some(ZipArchive) on success; None when the file is missing or not a ZIP

### func read\(String,Bool\)
```cj
public func read(name: String, verify!: Bool = true): Option < Array < UInt8 >>
```
Extracts a single entry (CRC32 verification by default)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Entry path|
|verify|Bool|Whether to verify the extracted data's CRC32 (default true)|

Return: 

- Some(extracted bytes) on success; None (with an error log) when the entryis missing/encrypted/uses an unsupported method/decompression fails/CRC mismatch

### prop entries: ArrayList < ZipEntry >
```cj
public prop entries: ArrayList < ZipEntry >
```
All entries in the archive (in archive order, read-only view)

### prop entryCount: Int64
```cj
public prop entryCount: Int64
```
Number of entries

