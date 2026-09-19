# Class
## class UiColor
```cj
public class UiColor
```
Color construction helper class

### func a\(\)
```cj
public func a(): Float32
```
Gets the A component

Return: 

- Alpha component

### func b\(\)
```cj
public func b(): Float32
```
Gets the B component

Return: 

- Blue component

### func fromHSV\(Float32,Float32,Float32,Float32\)
```cj
public static func fromHSV(h: Float32, s: Float32, v: Float32, a!: Float32 = 1.0f32): UiColor
```
Constructs from HSV

Parameter: 

|Name|Type|Describe|
|---|---|---|
|h|Float32|Hue (0~360)|
|s|Float32|Saturation (0~1)|
|v|Float32|Value (0~1)|
|a|Float32|Alpha component, defaults to 1.0|

Return: 

- The color object

### func fromRGBA\(Float32,Float32,Float32,Float32\)
```cj
public static func fromRGBA(r: Float32, g: Float32, b: Float32, a: Float32): UiColor
```
Constructs from RGBA float

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Float32|Red component|
|g|Float32|Green component|
|b|Float32|Blue component|
|a|Float32|Alpha component|

Return: 

- The color object

### func fromU32\(UInt32\)
```cj
public static func fromU32(col: UInt32): UiColor
```
Constructs from ImU32 (RGBA packed)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|col|UInt32|Packed ImU32 color value|

Return: 

- The color object

### func g\(\)
```cj
public func g(): Float32
```
Gets the G component

Return: 

- Green component

### func getVec4\(\)
```cj
public func getVec4(): ImVec4
```
Gets the underlying ImVec4

Return: 

- The underlying ImVec4 color value

### func init\(ImVec4\)
```cj
public init(col: ImVec4)
```
Constructs from an ImVec4 color value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|col|ImVec4|ImVec4 color value (RGBA, components in [0, 1])|

### func r\(\)
```cj
public func r(): Float32
```
Gets the R component

Return: 

- Red component

### func setHSV\(Float32,Float32,Float32\)
```cj
public func setHSV(h: Float32, s: Float32, v: Float32): Unit
```
Sets HSV (in-place modification)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|h|Float32|Hue (0~360)|
|s|Float32|Saturation (0~1)|
|v|Float32|Value (0~1)|

### func toU32\(\)
```cj
public func toU32(): UInt32
```
Converts to ImU32

Return: 

- Packed ImU32 color value

