# Class
## class SoaTransform
```cj
public class SoaTransform
```
SoA transform struct storing translation/rotation/scale for 4 joints

### func clone\(\)
```cj
public func clone(): SoaTransform
```
Deep copy of this transform

Return: 

- A new SoaTransform with independent array contents

### func fromFour\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public static func fromFour(tx0: Float32, ty0: Float32, tz0: Float32, rx0: Float32, ry0: Float32, rz0: Float32, rw0: Float32, sx0: Float32, sy0: Float32, sz0: Float32, tx1: Float32, ty1: Float32, tz1: Float32, rx1: Float32, ry1: Float32, rz1: Float32, rw1: Float32, sx1: Float32, sy1: Float32, sz1: Float32, tx2: Float32, ty2: Float32, tz2: Float32, rx2: Float32, ry2: Float32, rz2: Float32, rw2: Float32, sx2: Float32, sy2: Float32, sz2: Float32, tx3: Float32, ty3: Float32, tz3: Float32, rx3: Float32, ry3: Float32, rz3: Float32, rw3: Float32, sx3: Float32, sy3: Float32, sz3: Float32): SoaTransform
```
Pack 4 individual transforms into a single SoaTransform

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tx0|Float32||
|ty0|Float32||
|tz0|Float32||
|rx0|Float32||
|ry0|Float32||
|rz0|Float32||
|rw0|Float32||
|sx0|Float32||
|sy0|Float32||
|sz0|Float32||
|tx1|Float32||
|ty1|Float32||
|tz1|Float32||
|rx1|Float32||
|ry1|Float32||
|rz1|Float32||
|rw1|Float32||
|sx1|Float32||
|sy1|Float32||
|sz1|Float32||
|tx2|Float32||
|ty2|Float32||
|tz2|Float32||
|rx2|Float32||
|ry2|Float32||
|rz2|Float32||
|rw2|Float32||
|sx2|Float32||
|sy2|Float32||
|sz2|Float32||
|tx3|Float32||
|ty3|Float32||
|tz3|Float32||
|rx3|Float32||
|ry3|Float32||
|rz3|Float32||
|rw3|Float32||
|sx3|Float32||
|sy3|Float32||
|sz3|Float32||

### func getRotation\(Int\)
```cj
public func getRotation(slot: Int): QuaternionF
```
Get rotation quaternion for a given slot (0-3)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|Int|Slot index (0-3)|

Return: 

- (x, y, z, w)

### func getScale\(Int\)
```cj
public func getScale(slot: Int): Vector3F
```
Get scale for a given slot (0-3)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|Int|Slot index (0-3)|

Return: 

- (sx, sy, sz)

### func getTranslation\(Int\)
```cj
public func getTranslation(slot: Int): Vector3F
```
Get translation for a given slot (0-3)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|Int|Slot index (0-3)|

Return: 

- [tx, ty, tz]

### func identity\(\)
```cj
public static func identity(): SoaTransform
```
Create identity transform (4 slots with zero T, identity R, unit S)

### func init\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public init(tx: Float32, ty: Float32, tz: Float32, rx: Float32, ry: Float32, rz: Float32, rw: Float32, sx: Float32, sy: Float32, sz: Float32)
```
Construct with a single joint in slot 0

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tx|Float32|Translation x|
|ty|Float32|Translation y|
|tz|Float32|Translation z|
|rx|Float32|Rotation x|
|ry|Float32|Rotation y|
|rz|Float32|Rotation z|
|rw|Float32|Rotation w|
|sx|Float32|Scale x|
|sy|Float32|Scale y|
|sz|Float32|Scale z|

### func init\(\)
```cj
public init()
```
Default constructor, initializes to identity transform

### func init\(Array<Float32>,Array<Float32>,Array<Float32>\)
```cj
public init(translations: Array < Float32 >, rotations: Array < Float32 >, scales: Array < Float32 >)
```
Construct from raw arrays

Parameter: 

|Name|Type|Describe|
|---|---|---|
|translations|Array<Float32>|Translation array (12 elements)|
|rotations|Array<Float32>|Rotation array (16 elements)|
|scales|Array<Float32>|Scale array (12 elements)|

### func setRotation\(Int,Float32,Float32,Float32,Float32\)
```cj
public func setRotation(slot: Int, rx: Float32, ry: Float32, rz: Float32, rw: Float32): Unit
```
Set rotation quaternion for a given slot

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|Int|Slot index (0-3)|
|rx|Float32|Rotation x|
|ry|Float32|Rotation y|
|rz|Float32|Rotation z|
|rw|Float32|Rotation w|

### func setScale\(Int,Float32,Float32,Float32\)
```cj
public func setScale(slot: Int, sx: Float32, sy: Float32, sz: Float32): Unit
```
Set scale for a given slot

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|Int|Slot index (0-3)|
|sx|Float32|Scale x|
|sy|Float32|Scale y|
|sz|Float32|Scale z|

### func setTranslation\(Int,Float32,Float32,Float32\)
```cj
public func setTranslation(slot: Int, tx: Float32, ty: Float32, tz: Float32): Unit
```
Set translation for a given slot

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|Int|Slot index (0-3)|
|tx|Float32|Translation x|
|ty|Float32|Translation y|
|tz|Float32|Translation z|

### var rotations
```cj
public var rotations: Array < Float32 >
```
Rotation components for 4 joints (quaternions)

### var scales
```cj
public var scales: Array < Float32 >
```
Scale components for 4 joints

### var translations
```cj
public var translations: Array < Float32 >
```
Translation components for 4 joints

