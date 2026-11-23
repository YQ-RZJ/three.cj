# 类
## class ZipArchive
```cj
public class ZipArchive
```
ZIP 归档：解析中央目录并按条目解压

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>loadFromBytes 只解析目录（开销与条目数成正比，不做解压）；
解压与 CRC32 校验发生在每次 read()/extractAll()。</p>

### func extractAll\(String,Bool\)
```cj
public func extractAll(dir: String, verify!: Bool = true): Bool
```
将全部条目解压落盘到指定目录

参数: 

|名称|类型|描述|
|---|---|---|
|dir|String|目标目录|
|verify|Bool|是否校验每个文件条目的 CRC32（默认 true）|

返回: 

- 全部条目处理成功返回 true

### func find\(String\)
```cj
public func find(name: String): Option < ZipEntry >
```
按名查找条目

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|条目路径（ZIP 内部相对路径，'/' 分隔）|

返回: 

- 找到返回 Some(ZipEntry)，否则 None

### func loadFromBytes\(Array<UInt8>\)
```cj
public static func loadFromBytes(bytes: Array < UInt8 >): Option < ZipArchive >
```
从字节解析 ZIP 归档

参数: 

|名称|类型|描述|
|---|---|---|
|bytes|Array<UInt8>|ZIP 归档字节|

返回: 

- 解析成功返回 Some(ZipArchive)；非 ZIP 结构（找不到 EOCD /中央目录签名不符/条目越界）返回 None 并记录错误日志

### func loadFromFile\(String\)
```cj
public static func loadFromFile(path: String): Option < ZipArchive >
```
从本地文件加载并解析 ZIP 归档

参数: 

|名称|类型|描述|
|---|---|---|
|path|String|ZIP 文件路径|

返回: 

- 解析成功返回 Some(ZipArchive)；文件不存在或非 ZIP 返回 None

### func read\(String,Bool\)
```cj
public func read(name: String, verify!: Bool = true): Option < Array < UInt8 >>
```
解压单个条目（默认做 CRC32 完整性校验）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|条目路径|
|verify|Bool|是否校验解压结果的 CRC32（默认 true）|

返回: 

- 成功返回 Some(解压后字节)；条目不存在/加密/压缩方法不支持/解压失败/CRC 不符返回 None 并记录错误日志

### prop entries: ArrayList < ZipEntry >
```cj
public prop entries: ArrayList < ZipEntry >
```
归档内全部条目（按归档顺序，只读视图）

### prop entryCount: Int64
```cj
public prop entryCount: Int64
```
条目数量

