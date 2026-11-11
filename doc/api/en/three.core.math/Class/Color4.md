# Class
## class Color4
```cj
public class Color4 <: Color
```
Color class with alpha (RGBA, components in [0, 1])

### func clone4\(\)
```cj
public func clone4(): Color4
```
Clones (preserving the alpha component)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The base clone() returns a Color (dropping alpha); use this method to keep it.</p>

Return: 

- A new Color4 instance

### func copy4\(Color4\)
```cj
public func copy4(c: Color4): Color4
```
Copies RGBA from another Color4

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Color4|Source color|

Return: 

- This instance

### func init\(Color,Float64\)
```cj
public init(color: Color, a!: Float64 = 1.0)
```
Copies RGB from an existing Color with a given alpha

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Source color (provides r/g/b)a Alpha component (default 1.0)|
|a|Float64||

### func init\(\)
```cj
public init()
```
Constructs an opaque white color

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(r: Float64, g: Float64, b: Float64, a!: Float64 = 1.0)
```
Constructs from RGBA components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Float64|Red componentg Green componentb Blue componenta Alpha component (default 1.0)|
|g|Float64||
|b|Float64||
|a|Float64||

### func init\(UInt32,Float64\)
```cj
public init(hex: UInt32, a!: Float64 = 1.0)
```
Constructs from a hex value (0xRRGGBB; SRGB input auto-converted to the working color space)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|hex|UInt32|Color hex valuea Alpha component (default 1.0)|
|a|Float64||

### func setAlpha\(Float64\)
```cj
public func setAlpha(a: Float64): Color4
```
Sets the alpha component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Float64|Alpha component ([0, 1])|

Return: 

- This instance (for chaining)

### var a
```cj
public var a: Float64
```
Alpha component ([0, 1]; 0 = fully transparent, 1 = opaque)

