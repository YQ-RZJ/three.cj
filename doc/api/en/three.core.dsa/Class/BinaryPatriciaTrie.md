# Class
## class BinaryPatriciaTrie < V >
```cj
public class BinaryPatriciaTrie < V >
```
Binary Patricia Trie (Radix/Compressed Prefix Tree)

### func bitLongestSubset\(Array<UInt8>\)
```cj
public func bitLongestSubset(query: Array < UInt8 >):?(Array < UInt8 >, V)
```
Longest match in bit-level subset query

Parameter: 

|Name|Type|Describe|
|---|---|---|
|query|Array<UInt8>|Query byte array|

Return: 

- Longest matched key-value pair, or None if not found

### func bitSubsetOf\(Array<UInt8>,Bool,Bool\)
```cj
public func bitSubsetOf(query: Array < UInt8 >, longestFirst!: Bool = true, includeEmpty!: Bool = false): Array <(Array < UInt8 >, V) >
```
Bit-level subset query

Parameter: 

|Name|Type|Describe|
|---|---|---|
|query|Array<UInt8>|Query byte arraylongestFirst Whether longer keys come first (default true)includeEmpty Whether to include empty keys (default false)|
|longestFirst|Bool||
|includeEmpty|Bool||

Return: 

- Array of matching key-value pairs

### func clear\(\)
```cj
public func clear(): Unit
```
Clear the tree

### func delete\(Array<UInt8>\)
```cj
public func delete(key: Array < UInt8 >): Bool
```
Delete the specified key

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Array<UInt8>||

Return: 

- true if deletion succeeded

### func fBitLongestSubset\(Array<UInt8>\)
```cj
public func fBitLongestSubset(query: Array < UInt8 >):?(Array < UInt8 >, V)
```
Bit-level subset longest match (high-performance version)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|query|Array<UInt8>|Query byte array|

Return: 

- Longest matched key-value pair, or None if not found

### func fBitSubsetOf\(Array<UInt8>,Bool,Bool\)
```cj
public func fBitSubsetOf(query: Array < UInt8 >, longestFirst!: Bool = true, includeEmpty!: Bool = false): Array <(Array < UInt8 >, V) >
```
Bit-level subset query (high-performance version, submask enumeration + pruning)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|query|Array<UInt8>|Query byte arraylongestFirst Whether longer keys come first (default true)includeEmpty Whether to include empty keys (default false)|
|longestFirst|Bool||
|includeEmpty|Bool||

Return: 

- Array of matching key-value pairs

### func get\(Array<UInt8>\)
```cj
public func get(key: Array < UInt8 >):?V
```
Get the value for an exact match

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Array<UInt8>|Key|

Return: 

- Value, or None if not found

### func has\(Array<UInt8>\)
```cj
public func has(key: Array < UInt8 >): Bool
```
Whether the specified key exists

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Array<UInt8>||

### func init\(\)
```cj
public init()
```


### func longestPrefix\(Array<UInt8>\)
```cj
public func longestPrefix(query: Array < UInt8 >):?(Array < UInt8 >, V)
```
Longest prefix match: returns the longest item whose key is a prefix of query

Parameter: 

|Name|Type|Describe|
|---|---|---|
|query|Array<UInt8>|Query bytes|

Return: 

- Longest prefix-matched key-value pair, or None if not found

### func prefixOf\(Array<UInt8>,Bool,Bool\)
```cj
public func prefixOf(query: Array < UInt8 >, longestFirst!: Bool = true, includeEmpty!: Bool = false): Array <(Array < UInt8 >, V) >
```
Fuzzy search (prefix match): returns all items whose key is a prefix of query

Parameter: 

|Name|Type|Describe|
|---|---|---|
|query|Array<UInt8>|Query byteslongestFirst Whether longer keys come first (default true)includeEmpty Whether to include empty keys (default false)|
|longestFirst|Bool||
|includeEmpty|Bool||

Return: 

- Array of matching key-value pairs

### func set\(Array<UInt8>,V\)
```cj
public func set(key: Array < UInt8 >, value: V): Unit
```
Set a new value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Array<UInt8>|Keyvalue Value|
|value|V||

### func startsWith\(Array<UInt8>\)
```cj
public func startsWith(prefix: Array < UInt8 >): Array <(Array < UInt8 >, V) >
```
Prefix query: returns all items whose key starts with prefix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|prefix|Array<UInt8>|Prefix|

Return: 

- Array of matching key-value pairs

### prop size: Int64
```cj
public prop size: Int64
```
Number of members

