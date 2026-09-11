# Class
## class Fog
```cj
public class Fog
```
Linear fog class, linearly increasing opacity with distance

### func clone\(\)
```cj
public func clone(): Fog
```
Return a new fog instance with the same values as this instance

Return: 

- New fog instance

### func init\(Color,Float64,Float64\)
```cj
public init(color: Color, near!: Float64 = 1.0, far!: Float64 = 1000.0)
```
Construct a new linear fog

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Fog colornear Fog start distance, default 1far Fog end distance, default 1000|
|near|Float64||
|far|Float64||

### func init\(UInt32,Float64,Float64\)
```cj
public init(hex: UInt32, near!: Float64 = 1.0, far!: Float64 = 1000.0)
```
Construct a new linear fog with a hex color value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|hex|UInt32|Hex color valuenear Fog start distance, default 1far Fog end distance, default 1000|
|near|Float64||
|far|Float64||

### func init\(\)
```cj
public init()
```
No-argument constructor (for fastjson deserialization)

### var color
```cj
public var color: Color
```
Fog color

### var far
```cj
public var far: Float64
```
Fog end distance (fully obscured), default 1000

### var name
```cj
public var name: String
```
User-namable tag

### var near
```cj
public var near: Float64
```
Fog start distance (no fog), default 1

