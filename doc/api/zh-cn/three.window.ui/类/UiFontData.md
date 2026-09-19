# 类
## class UiFontData
```cj
public class UiFontData
```
内存字体数据（TTF/OTF 二进制）安全包装

### func finalize\(\)
```cj
public func finalize(): Unit
```
释放堆内存（所有权已转移给图集时无操作）

### func init\(Array<UInt8>\)
```cj
public init(bytes: Array < UInt8 >)
```
从字节数组构造（拷贝到 LibC 连续堆内存）

参数: 

|名称|类型|描述|
|---|---|---|
|bytes|Array<UInt8>|字体文件原始字节|

