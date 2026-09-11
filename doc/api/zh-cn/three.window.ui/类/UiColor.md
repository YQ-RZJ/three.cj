# 类
## class UiColor
```cj
public class UiColor
```
颜色构造辅助类

### func a\(\)
```cj
public func a(): Float32
```
获取 A 分量

### func b\(\)
```cj
public func b(): Float32
```
获取 B 分量

### func fromHSV\(Float32,Float32,Float32,Float32\)
```cj
public static func fromHSV(h: Float32, s: Float32, v: Float32, a!: Float32 = 1.0f32): UiColor
```
从 HSV 构造

参数: 

|名称|类型|描述|
|---|---|---|
|h|Float32||
|s|Float32||
|v|Float32||
|a|Float32||

### func fromRGBA\(Float32,Float32,Float32,Float32\)
```cj
public static func fromRGBA(r: Float32, g: Float32, b: Float32, a: Float32): UiColor
```
从 RGBA float 构造

参数: 

|名称|类型|描述|
|---|---|---|
|r|Float32||
|g|Float32||
|b|Float32||
|a|Float32||

### func fromU32\(UInt32\)
```cj
public static func fromU32(col: UInt32): UiColor
```
从 ImU32（RGBA packed）构造

参数: 

|名称|类型|描述|
|---|---|---|
|col|UInt32||

### func g\(\)
```cj
public func g(): Float32
```
获取 G 分量

### func getVec4\(\)
```cj
public func getVec4(): ImVec4
```
获取底层 ImVec4

### func init\(ImVec4\)
```cj
public init(col: ImVec4)
```


参数: 

|名称|类型|描述|
|---|---|---|
|col|ImVec4||

### func r\(\)
```cj
public func r(): Float32
```
获取 R 分量

### func setHSV\(Float32,Float32,Float32\)
```cj
public func setHSV(h: Float32, s: Float32, v: Float32): Unit
```
设置 HSV（就地修改）

参数: 

|名称|类型|描述|
|---|---|---|
|h|Float32||
|s|Float32||
|v|Float32||

### func toU32\(\)
```cj
public func toU32(): UInt32
```
转换为 ImU32

