# Class
## class BgfxExtensions
```cj
public class BgfxExtensions
```
bgfx extension compatibility layer

### func \`init\`\(\)
```cj
public func `init`(): Unit
```
Initializes extensions

### func get\(String\)
```cj
public func get(name: String): Option < String >
```
Gets an extension object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Extension name|

Return: 

- Extension marker (Some if available)

### func has\(String\)
```cj
public func has(name: String): Bool
```
Checks if an extension is available

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Extension name|

Return: 

- Whether available

### func init\(\)
```cj
public init()
```


