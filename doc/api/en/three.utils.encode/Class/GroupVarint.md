# Class
## class GroupVarint
```cj
public class GroupVarint
```


### func decodeGroup\(Array<UInt8>,Int,Array<UInt32>\)
```cj
public static func decodeGroup(input: Array < UInt8 >, baseOffset: Int, output: Array < UInt32 >): Int
```
Decode 4 UInt32 values from a buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|Array<UInt8>|Encoded byte buffer|
|baseOffset|Int|Start offset of this group in the buffer (bytes)|
|output|Array<UInt32>|Output array of 4 UInt32 values (must be length 4)|

Return: 

- Number of bytes read

### func decodeStream\(Array<UInt8>,Int\)
```cj
public static func decodeStream(data: Array < UInt8 >, count: Int): Array < UInt32 >
```
Decode a UInt32 stream

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|Encoded byte array|
|count|Int|Expected number of UInt32 values (must be multiple of 4)|

Return: 

- Decoded UInt32 array

### func encodeGroup\(Array<UInt32>,Array<UInt8>\)
```cj
public static func encodeGroup(input: Array < UInt32 >, output: Array < UInt8 >): Int
```
Encode 4 UInt32 values into a buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|Array<UInt32>|Array of 4 UInt32 values (must be length 4)|
|output|Array<UInt8>|Output byte buffer (at least 17 bytes)|

Return: 

- Number of bytes written

### func encodeStream\(Array<UInt32>\)
```cj
public static func encodeStream(stream: Array < UInt32 >): Array < UInt8 >
```
Encode a UInt32 stream (input size must be multiple of 4)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stream|Array<UInt32>|Input UInt32 array (length must be multiple of 4)|

Return: 

- Encoded byte array

### func worstBufferSize\(Int\)
```cj
public static func worstBufferSize(count: Int): Int
```
Compute worst-case buffer size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|count|Int|Number of UInt32 values|

Return: 

- Maximum required bytes

