# Class
## class PacketReader
```cj
public class PacketReader
```
Packet reader

### func init\(Array<UInt8>\)
```cj
public init(data: Array < UInt8 >)
```
Constructs a reader

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|Packet bytes (held by reference, not copied)|

### func readBool\(\)
```cj
public func readBool(): Bool
```
Reads a Bool (1 byte: nonzero is true)

Return: 

- Value

### func readBytes\(\)
```cj
public func readBytes(): Array < UInt8 >
```
Reads a length-prefixed byte block (u32 length + bytes)

Return: 

- Copy of the byte array

### func readF32\(\)
```cj
public func readF32(): Float32
```
Reads a Float32 (4 bytes, big-endian IEEE 754)

Return: 

- Value

### func readF64\(\)
```cj
public func readF64(): Float64
```
Reads a Float64 (8 bytes, big-endian IEEE 754)

Return: 

- Value

### func readI16\(\)
```cj
public func readI16(): Int16
```
Reads an Int16 (2 bytes, big-endian two's complement)

Return: 

- Value

### func readI32\(\)
```cj
public func readI32(): Int32
```
Reads an Int32 (4 bytes, big-endian two's complement)

Return: 

- Value

### func readI64\(\)
```cj
public func readI64(): Int64
```
Reads an Int64 (8 bytes, big-endian two's complement)

Return: 

- Value

### func readString\(\)
```cj
public func readString(): String
```
Reads a string (u32 byte length + UTF-8)

Return: 

- Text

### func readU16\(\)
```cj
public func readU16(): UInt16
```
Reads a UInt16 (2 bytes, big-endian)

Return: 

- Value

### func readU32\(\)
```cj
public func readU32(): UInt32
```
Reads a UInt32 (4 bytes, big-endian)

Return: 

- Value

### func readU64\(\)
```cj
public func readU64(): UInt64
```
Reads a UInt64 (8 bytes, big-endian)

Return: 

- Value

### func readU8\(\)
```cj
public func readU8(): UInt8
```
Reads a single byte

Return: 

- Byte value

### func skip\(Int64\)
```cj
public func skip(n: Int64): Unit
```
Skips n bytes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n|Int64|Number of bytes to skip|

### prop hasMore: Bool
```cj
public prop hasMore: Bool
```
Whether unread bytes remain

### prop position: Int64
```cj
public prop position: Int64
```
Current cursor position (byte offset, for debugging/skipping)

### prop remaining: Int64
```cj
public prop remaining: Int64
```
Remaining unread byte count

