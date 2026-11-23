# Class
## class ShaderChunks
```cj
public class ShaderChunks
```
Manage registration and composition of all shader chunks

### func define\(String,String\)
```cj
public static func define(name: String, source: String): Unit
```
Register a shader chunk

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Shader chunk namesource Shader chunk source code|
|source|String||

### func get\(String\)
```cj
public static func get(name: String): String
```
Get shader chunk source by name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Shader chunk name|

Return: 

- Shader chunk source code

### func initialize\(\)
```cj
public static func initialize(): Unit
```
Register all base shader chunks

### func resolve\(String\)
```cj
public static func resolve(source: String): String
```
Resolve #include <name> directives in shader source, recursively replacing with corresponding chunk content

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|String|Shader source code|

Return: 

- Complete shader source code after resolution

