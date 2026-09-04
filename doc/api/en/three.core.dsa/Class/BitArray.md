# Class
## class BitArray
```cj
public class BitArray <: Hashable & Equatable < BitArray >
```
Dynamic binary bit manager

### func \!=\(BitArray\)
```cj
public operator func !=(other: BitArray): Bool
```
Inequality comparison

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|BitArray|Another BitArray|

Return: 

- true if not equal

### func ==\(BitArray\)
```cj
public operator func ==(other: BitArray): Bool
```
Equality comparison

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|BitArray|Another BitArray|

Return: 

- true if bitwise equal

### func and\(BitArray\)
```cj
public func and(operand: BitArray): Unit
```
Bitwise AND

Parameter: 

|Name|Type|Describe|
|---|---|---|
|operand|BitArray|Operand|

### func assign\(BitArray\)
```cj
public func assign(operand: BitArray): Unit
```
Assign from another BitArray

Parameter: 

|Name|Type|Describe|
|---|---|---|
|operand|BitArray|Operand|

### func clear\(\)
```cj
public func clear(): Unit
```
Clear all bits to 0

### func copyInnerData\(\)
```cj
public func copyInnerData(): Array < UInt8 >
```
Copy internal data

Return: 

- Copy of internal data

### func copy\(\)
```cj
public func copy(): BitArray
```
Create a copy

Return: 

- A new BitArray copy

### func cover\(BitArray\)
```cj
public func cover(operand: BitArray): Bool
```
Check if all bits set to 1 in the operand are also set in this BitArray

Parameter: 

|Name|Type|Describe|
|---|---|---|
|operand|BitArray|Operand|

Return: 

- true if covers

### func equal\(BitArray\)
```cj
public func equal(operand: BitArray): Bool
```
Check equality

Parameter: 

|Name|Type|Describe|
|---|---|---|
|operand|BitArray|Operand|

Return: 

- true if bitwise equal

### func get\(Int64\)
```cj
public func get(index: Int64): Bool
```
Get the bit value at the specified position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Bit index|

Return: 

- true if the bit is 1

### func hashCode\(\)
```cj
public func hashCode(): Int64
```
Compute hash value

Return: 

- 32-bit unsigned integer hash value (stored in Int64)

### func init\(Int64,Bool\)
```cj
public init(index: Int64, value!: Bool = true)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Initial bit index (automatically expands to this index + 1)value Whether to set the specified position to 1 (defaults to true)|
|value|Bool||

### func not\(\)
```cj
public func not(): Unit
```
Bitwise NOT

### func or\(BitArray\)
```cj
public func or(operand: BitArray): Unit
```
Bitwise OR

Parameter: 

|Name|Type|Describe|
|---|---|---|
|operand|BitArray|Operand|

### func setIdxs\(Array<Int64>,Bool\)
```cj
public func setIdxs(indexs: Array < Int64 >, value!: Bool = true): Unit
```
Batch set bit values at specified positions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|indexs|Array<Int64>|Array of bit indicesvalue true to set to 1, false to clear to 0|
|value|Bool||

### func set\(Int64,Bool\)
```cj
public func set(index: Int64, value!: Bool = true): Unit
```
Set the bit value at the specified position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Bit indexvalue true to set to 1, false to clear to 0|
|value|Bool||

### func toArray\(\)
```cj
public func toArray(): Array < UInt8 >
```
Export as byte array

Return: 

- Copy of the byte array

### func toBinaryString\(\)
```cj
public func toBinaryString(): String
```
Convert to binary string representation

Return: 

- Binary string representation

### prop innerData: Array < UInt8 >
```cj
public prop innerData: Array < UInt8 >
```
Directly expose internal data

### prop length: Int64
```cj
public prop length: Int64
```
Get the bit length

