# Class
## class MaterialState
```cj
public class MaterialState
```
Material state info

### func init\(Int64\)
```cj
public init(materialId: Int64)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|materialId|Int64||

### var fogNeedsUpdate
```cj
public var fogNeedsUpdate: Bool = true
```
Whether fog uniforms need update

### var lastUpdateFrame
```cj
public var lastUpdateFrame: Int64 = - 1
```
Last update frame number

### var materialId
```cj
public var materialId: Int64
```
Material ID

### var programId
```cj
public var programId: Int64 = - 1
```
Last compiled program ID

### var uniformsNeedUpdate
```cj
public var uniformsNeedUpdate: Bool = true
```
Whether uniforms need update

