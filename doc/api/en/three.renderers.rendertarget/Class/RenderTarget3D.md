# Class
## class RenderTarget3D
```cj
public class RenderTarget3D <: RenderTarget
```
3D render target class, extends RenderTarget

### func clone\(\)
```cj
public func clone(): RenderTarget3D
```
Return a new 3D render target with values copied from this instance

Return: 

- Clone of this instance

### func copy\(RenderTarget3D\)
```cj
public func copy(source: RenderTarget3D): RenderTarget3D
```
Copy settings from the given 3D render target to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|RenderTarget3D|3D render target to copy from|

Return: 

- Reference to this instance

### func init\(Int64,Int64,Int64\)
```cj
public init(width!: Int64 = 1, height!: Int64 = 1, depth!: Int64 = 1)
```
Construct a new 3D render target

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Render target width, defaults to 1height Render target height, defaults to 1depth Render target depth, defaults to 1|
|height|Int64||
|depth|Int64||

