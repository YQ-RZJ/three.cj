# Class
## class LineBasicMaterial
```cj
public class LineBasicMaterial <: Material
```
Basic line material, supporting linewidth, linecap, and linejoin styles

### func init\(\)
```cj
public init()
```
Construct a new line basic material

### var linecap
```cj
public var linecap: String
```
Line cap style, options 'round'/'butt'/'square', default 'round'

### var linejoin
```cj
public var linejoin: String
```
Line join style, options 'round'/'bevel'/'miter', default 'round'

### var linewidth
```cj
public var linewidth: Float64
```
Line width, default 1

