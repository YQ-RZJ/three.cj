# Class
## class Binding
```cj
public open class Binding
```
Single binding resource description, representing uniform buffer, sampler, or other resource bindings

### func init\(String,Any,String\)
```cj
public init(name: String, value: Any, kind: String)
```
Constructs a binding with the specified name, value, and kind

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Binding namevalue Binding valuekind Binding kind|
|value|Any||
|kind|String||

### func init\(String,Any\)
```cj
public init(name: String, value: Any)
```
Constructs a binding with the specified name and value, defaulting kind to "uniform"

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Binding namevalue Binding value|
|value|Any||

### var kind
```cj
public var kind: String
```
Binding kind (e.g., "uniform", "buffer", etc.)

### var name
```cj
public var name: String
```
Binding name

### var value
```cj
public var value: Any
```
Binding value

### var visibility
```cj
public var visibility: Int64
```
Shader visibility flags

