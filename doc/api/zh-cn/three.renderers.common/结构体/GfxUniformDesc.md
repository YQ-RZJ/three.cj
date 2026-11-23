# 结构体
## struct GfxUniformDesc
```cj
public struct GfxUniformDesc
```
uniform 反射信息

### func init\(String,GfxUniformType,UInt16\)
```cj
public init(name!: String, uniformType!: GfxUniformType, num!: UInt16 = 1u16)
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|uniformType|GfxUniformType||
|num|UInt16||

### let name
```cj
public let name: String
```
uniform 名称

### let num
```cj
public let num: UInt16
```
数组长度

### let uniformType
```cj
public let uniformType: GfxUniformType
```
数据类型

