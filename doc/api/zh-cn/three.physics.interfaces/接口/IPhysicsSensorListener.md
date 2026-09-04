# 接口
## interface IPhysicsSensorListener
```cj
public interface IPhysicsSensorListener
```
传感器回调（后端无关）

### func onBodyActivated\(UInt32\)
```cj
func onBodyActivated(bodyID: UInt32): Unit
```
刚体被激活（开始模拟）

参数: 

|名称|类型|描述|
|---|---|---|
|bodyID|UInt32|被激活刚体的 BodyID|

### func onBodyDeactivated\(UInt32\)
```cj
func onBodyDeactivated(bodyID: UInt32): Unit
```
刚体休眠（停止模拟）

参数: 

|名称|类型|描述|
|---|---|---|
|bodyID|UInt32|休眠刚体的 BodyID|

### func onContact\(UInt32,UInt32,PhysicsContactEvent\)
```cj
func onContact(bodyID1: UInt32, bodyID2: UInt32, event: PhysicsContactEvent): Unit
```
接触事件回调（Added/Persisted/Removed）

参数: 

|名称|类型|描述|
|---|---|---|
|bodyID1|UInt32|刚体 1 的 BodyIDbodyID2 刚体 2 的 BodyIDevent 接触事件类型|
|bodyID2|UInt32||
|event|PhysicsContactEvent||

