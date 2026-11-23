# Class
## class ShaderVariant
```cj
public class ShaderVariant
```
Shader variant manager

### func getActiveTextureFlags\(Material\)
```cj
public static func getActiveTextureFlags(mat: Material): Array < String >
```
Get the list of active texture flags

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mat|Material|Material|

Return: 

- Array of active texture flags

### func getDefines\(Material\)
```cj
public static func getDefines(mat: Material): Array < String >
```
Generate #define flag string array (e.g. "USE_MAP=1")

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mat|Material|Material|

Return: 

- Define string array (empty array means no variant flags)

### func getVariantKey\(Material\)
```cj
public static func getVariantKey(mat: Material): String
```
Generate variant key from material (for caching)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mat|Material|Material|

Return: 

- Variant key string

