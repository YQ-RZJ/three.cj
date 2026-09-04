# 类
## class System
```cj
public open class System <: EcsObject
```
系统基类

### func init\(\)
```cj
public init()
```
构造器，new 即分配系统 ID；组件需求掩码在首次访问 cptMask 时惰性收集

### func onUpdate\(Iterator<Entity>,Float64\)
```cj
public open func onUpdate(entities: Iterator < Entity >, dt: Float64): Unit
```
系统更新事件

参数: 

|名称|类型|描述|
|---|---|---|
|entities|Iterator<Entity>|命中组件掩码的实体迭代器（当轮快照）dt 帧间隔（秒）|
|dt|Float64||

### prop cptMask: BitArray
```cj
public prop cptMask: BitArray
```
系统所需的所有组件标记

### prop sysId: SystemId
```cj
public prop sysId: SystemId
```
系统 ID

### var isActive
```cj
public var isActive: Bool = true
```
系统是否激活（需要被更新）

