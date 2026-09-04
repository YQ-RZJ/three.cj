# 类
## class Layers
```cj
public class Layers
```
图层类，使用位掩码管理 32 个图层的成员关系

### func disableAll\(\)
```cj
public func disableAll(): Unit
```
禁用所有图层

### func disable\(UInt32\)
```cj
public func disable(layer: UInt32): Unit
```
禁用指定图层（移除成员关系）

参数: 

|名称|类型|描述|
|---|---|---|
|layer|UInt32|图层编号（0~31）|

### func enableAll\(\)
```cj
public func enableAll(): Unit
```
启用所有图层

### func enable\(UInt32\)
```cj
public func enable(layer: UInt32): Unit
```
启用指定图层（添加成员关系）

参数: 

|名称|类型|描述|
|---|---|---|
|layer|UInt32|图层编号（0~31）|

### func init\(\)
```cj
public init()
```
构造一个新的图层实例，默认属于图层 0

### func isEnabled\(UInt32\)
```cj
public func isEnabled(layer: UInt32): Bool
```
测试指定图层是否已启用

参数: 

|名称|类型|描述|
|---|---|---|
|layer|UInt32|图层编号（0~31）|

返回: 

- 如果指定图层已启用则返回 true

### func set\(UInt32\)
```cj
public func set(layer: UInt32): Unit
```
设置仅属于指定图层，移除其他所有图层的成员关系

参数: 

|名称|类型|描述|
|---|---|---|
|layer|UInt32|图层编号（0~31）|

### func test\(Layers\)
```cj
public func test(layers: Layers): Bool
```
测试此图层对象与给定图层对象是否共享至少一个图层

参数: 

|名称|类型|描述|
|---|---|---|
|layers|Layers|要测试的图层对象|

返回: 

- 如果共享至少一个图层则返回 true

### func toggle\(UInt32\)
```cj
public func toggle(layer: UInt32): Unit
```
切换指定图层的成员关系

参数: 

|名称|类型|描述|
|---|---|---|
|layer|UInt32|图层编号（0~31）|

### var mask
```cj
public var mask: UInt32
```
位掩码，存储当前对象所属的图层

