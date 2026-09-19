# Class
## class ProfZone
```cj
public class ProfZone <: Resource
```
Zone scope controller — one construction/close pair is one Tracy
timing zone

### func close\(\)
```cj
public func close(): Unit
```
Close the zone (idempotent and safe when inactive or already
closed; called automatically by try-with-resources)

### func color\(UInt32\)
```cj
public func color(c: UInt32): Unit
```
Override the zone color (0xAABBGGRR)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|UInt32||

### func init\(String,String,UInt32,String\)
```cj
public init(name: String, file: String, line: UInt32, function: String)
```
Begin a named zone (manual RAII entry, default color)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|file|String||
|line|UInt32||
|function|String||

### func init\(String,UInt32,String,UInt32,String\)
```cj
public init(name: String, color: UInt32, file: String, line: UInt32, function: String)
```
Begin a named zone with color 0xAABBGGRR (0 = Tracy default)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|color|UInt32||
|file|String||
|line|UInt32||
|function|String||

### func init\(String,UInt32,String,UInt32\)
```cj
public init(name: String, color: UInt32, file: String, line: UInt32)
```
Begin a named zone without a function name (macro expression
form; the zone name doubles as the function label)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|color|UInt32||
|file|String||
|line|UInt32||

### func isClosed\(\)
```cj
public func isClosed(): Bool
```
Resource.isClosed: the zone counts as closed once ended or
never activated

### func rename\(String\)
```cj
public func rename(txt: String): Unit
```
Rename the zone (overrides the default source-location name)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|txt|String||

### func text\(String\)
```cj
public func text(txt: String): Unit
```
Attach a text note (shown in the Tracy zone panel)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|txt|String||

### func value\(UInt64\)
```cj
public func value(v: UInt64): Unit
```
Attach a numeric value (zone panel mini-graph, e.g. vertex
or batch count)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|UInt64||

### prop active: Bool
```cj
public prop active: Bool
```
Whether this zone actually started recording

