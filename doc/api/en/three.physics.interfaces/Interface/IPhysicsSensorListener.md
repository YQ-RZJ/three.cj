# Interface
## interface IPhysicsSensorListener
```cj
public interface IPhysicsSensorListener
```
Sensor callbacks (backend-agnostic)

### func onBodyActivated\(UInt32\)
```cj
func onBodyActivated(bodyID: UInt32): Unit
```
A body was activated (starts simulating)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bodyID|UInt32|The activated body's BodyID|

### func onBodyDeactivated\(UInt32\)
```cj
func onBodyDeactivated(bodyID: UInt32): Unit
```
A body went to sleep (stops simulating)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bodyID|UInt32|The sleeping body's BodyID|

### func onContact\(UInt32,UInt32,PhysicsContactEvent\)
```cj
func onContact(bodyID1: UInt32, bodyID2: UInt32, event: PhysicsContactEvent): Unit
```
Contact event callback (Added/Persisted/Removed)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bodyID1|UInt32|The BodyID of body 1bodyID2 The BodyID of body 2event The contact event type|
|bodyID2|UInt32||
|event|PhysicsContactEvent||

