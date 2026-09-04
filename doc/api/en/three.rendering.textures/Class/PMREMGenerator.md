# Class
## class PMREMGenerator
```cj
public class PMREMGenerator
```
PMREM generator class

### func fromScene\(IScene,Float64,Float64,Float64\)
```cj
public func fromScene(scene: IScene, sigma: Float64, near: Float64, far: Float64): Any
```
Generate pre-filtered mipmap environment map from scene

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|IScene|Scene interfacesigma Blur strengthnear Near clipping planefar Far clipping plane|
|sigma|Float64||
|near|Float64||
|far|Float64||

Return: 

- Generated environment map

### func init\(\)
```cj
public init()
```
Construct PMREM generator

### var kind
```cj
public var kind: String
```
Type tag

