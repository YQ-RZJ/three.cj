# Class
## class Hash
```cj
public class Hash
```
Non-cryptographic hash algorithm utility class

### func fnv1a32\(Array<UInt8>\)
```cj
public static func fnv1a32(data: Array < UInt8 >): Int64
```
Computes an FNV-1a 32-bit hash value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The byte array to hash|

Return: 

- The 32-bit unsigned hash value (stored in an Int64, preserving the bit pattern)

### func murmurHash32\(Array<UInt8>,UInt32\)
```cj
public static func murmurHash32(data: Array < UInt8 >, seed!: UInt32 = 1102u32): Int64
```
Computes a MurmurHash3 32-bit hash value (x86 variant)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The byte array to hashseed Hash seed (default 1102) used to derive different hash spaces|
|seed|UInt32||

Return: 

- The 32-bit unsigned hash value (stored in an Int64, preserving the bit pattern)

