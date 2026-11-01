# Class
## class PacketWriter
```cj
public class PacketWriter
```
Packet writer

### func clear\(\)
```cj
public func clear(): Unit
```
Clears the buffer (reuse the writer for the next packet)

### func init\(\)
```cj
public init()
```
Constructs a writer

### func toArray\(\)
```cj
public func toArray(): Array < UInt8 >
```
Takes the full packet bytes

Return: 

- Copy of the accumulated content

### func writeBool\(Bool\)
```cj
public func writeBool(v: Bool): Unit
```
Writes a Bool (1 byte: true=1, false=0)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Bool|Value|

### func writeBytes\(Array<UInt8>\)
```cj
public func writeBytes(data: Array < UInt8 >): Unit
```
Writes raw bytes (no length prefix)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|Byte array|

### func writeF32\(Float32\)
```cj
public func writeF32(v: Float32): Unit
```
Writes a Float32 (4 bytes, big-endian IEEE 754)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float32|Value|

### func writeF64\(Float64\)
```cj
public func writeF64(v: Float64): Unit
```
Writes a Float64 (8 bytes, big-endian IEEE 754)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float64|Value|

### func writeI16\(Int16\)
```cj
public func writeI16(v: Int16): Unit
```
Writes an Int16 (2 bytes, big-endian two's complement)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Int16|Value|

### func writeI32\(Int32\)
```cj
public func writeI32(v: Int32): Unit
```
Writes an Int32 (4 bytes, big-endian two's complement)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Int32|Value|

### func writeI64\(Int64\)
```cj
public func writeI64(v: Int64): Unit
```
Writes an Int64 (8 bytes, big-endian two's complement)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Int64|Value|

### func writeString\(String\)
```cj
public func writeString(s: String): Unit
```
Writes a string (u32 byte length + UTF-8 bytes)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|String|Text (empty string encodes as length 0)|

### func writeU16\(UInt16\)
```cj
public func writeU16(v: UInt16): Unit
```
Writes a UInt16 (2 bytes, big-endian)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|UInt16|Value|

### func writeU32\(UInt32\)
```cj
public func writeU32(v: UInt32): Unit
```
Writes a UInt32 (4 bytes, big-endian)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|UInt32|Value|

### func writeU64\(UInt64\)
```cj
public func writeU64(v: UInt64): Unit
```
Writes a UInt64 (8 bytes, big-endian)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|UInt64|Value|

### func writeU8\(UInt8\)
```cj
public func writeU8(v: UInt8): Unit
```
Writes a single byte

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|UInt8|Byte value|

### prop size: Int64
```cj
public prop size: Int64
```
Current accumulated byte count

