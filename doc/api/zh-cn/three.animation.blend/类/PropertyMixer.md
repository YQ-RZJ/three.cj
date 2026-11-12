# 类
## class PropertyMixer
```cj
public class PropertyMixer
```
属性混合器，缓冲场景图属性，允许加权累积

### func apply\(Int64\)
```cj
public func apply(accuIndex: Int64): Unit
```
当 accu 区域与原始值不同时，将 accu<i> 的状态应用到绑定

参数: 

|名称|类型|描述|
|---|---|---|
|accuIndex|Int64|累积索引|

### func init\(PropertyBinding,String,Int64\)
```cj
public init(binding: PropertyBinding, typeName: String, valueSize: Int64)
```
构造一个新的属性混合器

参数: 

|名称|类型|描述|
|---|---|---|
|binding|PropertyBinding|属性绑定|
|typeName|String|关键帧轨道类型名称|
|valueSize|Int64|关键帧轨道值大小|

### var cumulativeWeightAdditive
```cj
public var cumulativeWeightAdditive: Float64
```
加法累积权重

### var cumulativeWeight
```cj
public var cumulativeWeight: Float64
```
累积权重

### var referenceCount
```cj
public var referenceCount: Int64
```
引用此属性绑定的关键帧轨道数量

### var useCount
```cj
public var useCount: Int64
```
使用此属性绑定的活跃关键帧轨道数量

