# Class
## class ShadowMaterial
```cj
public class ShadowMaterial <: Material
```
Shadow material, can receive shadows but is itself fully transparent

### func copy\(ShadowMaterial\)
```cj
public func copy(source: ShadowMaterial): ShadowMaterial
```
Copy the properties from the given ShadowMaterial to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|ShadowMaterial|Source material|

Return: 

- This instance

### func init\(\)
```cj
public init()
```
Construct a new shadow material

