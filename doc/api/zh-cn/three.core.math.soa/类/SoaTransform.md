# 类
## class SoaTransform
```cj
public class SoaTransform
```
SoA 变换结构体，存储 4 个关节的平移、旋转、缩放

### func clone\(\)
```cj
public func clone(): SoaTransform
```
深拷贝当前变换

返回: 

- 一个新的 SoaTransform，数组内容独立

### func fromFour\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public static func fromFour(tx0: Float32, ty0: Float32, tz0: Float32, rx0: Float32, ry0: Float32, rz0: Float32, rw0: Float32, sx0: Float32, sy0: Float32, sz0: Float32, tx1: Float32, ty1: Float32, tz1: Float32, rx1: Float32, ry1: Float32, rz1: Float32, rw1: Float32, sx1: Float32, sy1: Float32, sz1: Float32, tx2: Float32, ty2: Float32, tz2: Float32, rx2: Float32, ry2: Float32, rz2: Float32, rw2: Float32, sx2: Float32, sy2: Float32, sz2: Float32, tx3: Float32, ty3: Float32, tz3: Float32, rx3: Float32, ry3: Float32, rz3: Float32, rw3: Float32, sx3: Float32, sy3: Float32, sz3: Float32): SoaTransform
```
将 4 个单关节 Transform 拼装为一个 SoaTransform

参数: 

|名称|类型|描述|
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
获取指定槽位的旋转

参数: 

|名称|类型|描述|
|---|---|---|
|slot|Int|槽位索引 (0-3)|

返回: 

- (x, y, z, w)

### func getScale\(Int\)
```cj
public func getScale(slot: Int): Vector3F
```
获取指定槽位的缩放

参数: 

|名称|类型|描述|
|---|---|---|
|slot|Int|槽位索引 (0-3)|

返回: 

- (sx, sy, sz)

### func getTranslation\(Int\)
```cj
public func getTranslation(slot: Int): Vector3F
```
获取指定槽位的平移

参数: 

|名称|类型|描述|
|---|---|---|
|slot|Int|槽位索引 (0-3)|

返回: 

- [tx, ty, tz]

### func identity\(\)
```cj
public static func identity(): SoaTransform
```
创建单位变换（4 个槽位均为零平移、单位旋转、单位缩放）

### func init\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public init(tx: Float32, ty: Float32, tz: Float32, rx: Float32, ry: Float32, rz: Float32, rw: Float32, sx: Float32, sy: Float32, sz: Float32)
```
从单个关节的平移、旋转、缩放构造第0个槽位

参数: 

|名称|类型|描述|
|---|---|---|
|tx|Float32|平移 x|
|ty|Float32|平移 y|
|tz|Float32|平移 z|
|rx|Float32|旋转 x|
|ry|Float32|旋转 y|
|rz|Float32|旋转 z|
|rw|Float32|旋转 w|
|sx|Float32|缩放 x|
|sy|Float32|缩放 y|
|sz|Float32|缩放 z|

### func init\(\)
```cj
public init()
```
默认构造函数，初始化为单位变换（零平移、单位旋转、单位缩放）

### func init\(Array<Float32>,Array<Float32>,Array<Float32>\)
```cj
public init(translations: Array < Float32 >, rotations: Array < Float32 >, scales: Array < Float32 >)
```
从原始数组构造

参数: 

|名称|类型|描述|
|---|---|---|
|translations|Array<Float32>|平移数组（12 个元素）|
|rotations|Array<Float32>|旋转数组（16 个元素）|
|scales|Array<Float32>|缩放数组（12 个元素）|

### func setRotation\(Int,Float32,Float32,Float32,Float32\)
```cj
public func setRotation(slot: Int, rx: Float32, ry: Float32, rz: Float32, rw: Float32): Unit
```
设置指定槽位的旋转

参数: 

|名称|类型|描述|
|---|---|---|
|slot|Int|槽位索引 (0-3)|
|rx|Float32|旋转 x|
|ry|Float32|旋转 y|
|rz|Float32|旋转 z|
|rw|Float32|旋转 w|

### func setScale\(Int,Float32,Float32,Float32\)
```cj
public func setScale(slot: Int, sx: Float32, sy: Float32, sz: Float32): Unit
```
设置指定槽位的缩放

参数: 

|名称|类型|描述|
|---|---|---|
|slot|Int|槽位索引 (0-3)|
|sx|Float32|缩放 x|
|sy|Float32|缩放 y|
|sz|Float32|缩放 z|

### func setTranslation\(Int,Float32,Float32,Float32\)
```cj
public func setTranslation(slot: Int, tx: Float32, ty: Float32, tz: Float32): Unit
```
设置指定槽位的平移

参数: 

|名称|类型|描述|
|---|---|---|
|slot|Int|槽位索引 (0-3)|
|tx|Float32|平移 x|
|ty|Float32|平移 y|
|tz|Float32|平移 z|

### var rotations
```cj
public var rotations: Array < Float32 >
```
4 个关节的旋转分量（四元数）

### var scales
```cj
public var scales: Array < Float32 >
```
4 个关节的缩放分量

### var translations
```cj
public var translations: Array < Float32 >
```
4 个关节的平移分量

