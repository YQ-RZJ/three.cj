# Class
## class Color4
```cj
public open class Color4
```
RGBA four-channel color representation

### func init\(\)
```cj
public init()
```
Constructs default white (1, 1, 1, 1)

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(r: Float64, g: Float64, b: Float64, a: Float64)
```
Constructs a color with specified RGBA values

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Float64|Red channelg Green channelb Blue channela Alpha channel|
|g|Float64||
|b|Float64||
|a|Float64||

### func toUint32\(\)
```cj
public func toUint32(): UInt32
```
Converts RGBA to UInt32 format (R<<24 | G<<16 | B<<8 | A)

Return: 

- UInt32 color value

### var a
```cj
public var a: Float64
```
Alpha channel

### var b
```cj
public var b: Float64
```
Blue channel

### var g
```cj
public var g: Float64
```
Green channel

### var r
```cj
public var r: Float64
```
Red channel

