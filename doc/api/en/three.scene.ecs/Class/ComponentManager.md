# Class
## class ComponentManager
```cj
public class ComponentManager
```
Component manager class

### func clear\(\)
```cj
public func clear(): Unit
```
Release and clear (clear all pool caches)

### func createComponent\(ComponentId\)where T <: Component
```cj
public func createComponent < T >(cptId: ComponentId):?T where T <: Component
```
Create a component (pooled)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cptId|ComponentId|Component class ID (XxxCpt.typeId())|

Return: 

- Component instance, or None if component class not registered

### func recycle\(Component\)
```cj
public func recycle(c: Component): Unit
```
Recycle a component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Component|Component instance|

Exception: 

- EcsException Component is still attached to an entity

