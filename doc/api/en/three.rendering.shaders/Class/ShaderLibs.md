# Class
## class ShaderLibs
```cj
public class ShaderLibs
```
Shader library managing shader programs for all material types

### func get\(String\)
```cj
public static func get(name: String):?ShaderProgram
```
Get shader program by name (resolves source on first call)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Shader program name|

Return: 

- Shader program (None if not found)

### func initialize\(\)
```cj
public static func initialize(): Unit
```
Initialize all shader programs, register ShaderChunks and material shaders

### func release\(\)
```cj
public static func release(): Bool
```
destroy the shader library, release all resources, stop the compiler thread

