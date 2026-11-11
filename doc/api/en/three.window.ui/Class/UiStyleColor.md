# Class
## class UiStyleColor
```cj
public class UiStyleColor
```
Style color query utility

### func fromU32\(UInt32,Float32\)
```cj
public static func fromU32(col: UInt32, alphaMul!: Float32 = 1.0): UInt32
```
Gets a color from a packed U32 (modulated by style alpha)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|col|UInt32|Packed IM_COL32 color|
|alphaMul|Float32|Alpha multiplier|

Return: 

- Color in IM_COL32 format

### func fromVec4\(Color4\)
```cj
public static func fromVec4(col: Color4): UInt32
```
Gets a color from a custom RGBA (modulated by style alpha)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|col|Color4|RGBA color|

Return: 

- Color in IM_COL32 format

### func getU32\(Int32,Float32\)
```cj
public static func getU32(col: Int32, alphaMul!: Float32 = 1.0): UInt32
```
Gets a style color by index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|col|Int32|ImGuiCol index|
|alphaMul|Float32|Alpha multiplier (1.0=unchanged)|

Return: 

- Color in IM_COL32 format

### func init\(\)
```cj
public init()
```
Constructs the style color query utility (static-only)

