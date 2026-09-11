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

### func b\(\)
```cj
public func b(): Float32
```
Gets the B component

### func fromHSV\(Float32,Float32,Float32,Float32\)
```cj
public static func fromHSV(h: Float32, s: Float32, v: Float32, a!: Float32 = 1.0f32): UiColor
```
Constructs from HSV

Parameter: 

|Name|Type|Describe|
|---|---|---|
|h|Float32||
|s|Float32||
|v|Float32||
|a|Float32||

### func fromRGBA\(Float32,Float32,Float32,Float32\)
```cj
public static func fromRGBA(r: Float32, g: Float32, b: Float32, a: Float32): UiColor
```
Constructs from RGBA float

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Float32||
|g|Float32||
|b|Float32||
|a|Float32||

### func fromU32\(UInt32\)
```cj
public static func fromU32(col: UInt32): UiColor
```
Constructs from ImU32 (RGBA packed)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|col|UInt32||

### func g\(\)
```cj
public func g(): Float32
```
Gets the G component

### func getVec4\(\)
```cj
public func getVec4(): ImVec4
```
Gets the underlying ImVec4

### func init\(ImVec4\)
```cj
public init(col: ImVec4)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|col|ImVec4||

### func r\(\)
```cj
public func r(): Float32
```
Gets the R component

### func setHSV\(Float32,Float32,Float32\)
```cj
public func setHSV(h: Float32, s: Float32, v: Float32): Unit
```
Sets HSV (in-place modification)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|h|Float32||
|s|Float32||
|v|Float32||

### func toU32\(\)
```cj
public func toU32(): UInt32
```
Converts to ImU32

