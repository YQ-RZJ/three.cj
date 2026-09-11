# Class
## class SkinningJob
```cj
public class SkinningJob
```
CPU vertex skinning job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
Runs the skinning

Return: 

- true on success

### func validate\(\)
```cj
public func validate(): Bool
```
Validates the inputs

### var input
```cj
public var input:?SkinInput
```
Skinning input

### var jointMatrices
```cj
public var jointMatrices: Array < Float32 >
```
Joint model-space matrix array

### var output
```cj
public var output: SkinOutput
```
Skinning output

### var weights
```cj
public var weights:?SkinWeights
```
Skinning weights

