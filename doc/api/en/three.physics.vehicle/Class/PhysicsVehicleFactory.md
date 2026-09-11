# Class
## class PhysicsVehicleFactory
```cj
public class PhysicsVehicleFactory
```
Wheeled vehicle factory

### func createVehicle\(PhysicsWorld\)
```cj
public func createVehicle(world: PhysicsWorld): PhysicsVehicle
```
Creates a runtime vehicle in the given physics world

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The target physics world|

Return: 

- The runtime vehicle

### func init\(PhysicsVehicleDesc\)
```cj
public init(desc!: PhysicsVehicleDesc)
```
Creates a vehicle factory

Parameter: 

|Name|Type|Describe|
|---|---|---|
|desc|PhysicsVehicleDesc|The vehicle description|

