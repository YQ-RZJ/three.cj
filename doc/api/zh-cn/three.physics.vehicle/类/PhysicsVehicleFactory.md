# 类
## class PhysicsVehicleFactory
```cj
public class PhysicsVehicleFactory
```
轮式载具工厂

### func createVehicle\(PhysicsWorld\)
```cj
public func createVehicle(world: PhysicsWorld): PhysicsVehicle
```
在指定物理世界创建运行时载具

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|目标物理世界|

返回: 

- 运行时载具

### func init\(PhysicsVehicleDesc\)
```cj
public init(desc!: PhysicsVehicleDesc)
```
构造载具工厂

参数: 

|名称|类型|描述|
|---|---|---|
|desc|PhysicsVehicleDesc|载具描述|

