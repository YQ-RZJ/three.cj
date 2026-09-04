# Class
## class ComponentRegistry
```cj
public class ComponentRegistry
```
Component class registry

### func factoryOf\(Int64\)
```cj
public static func factoryOf(id: Int64):?(() -> Component)
```
Query component factory by class ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Component class ID|

Return: 

- None if not registered

### func idOf\(String\)
```cj
public static func idOf(uniqueKey: String):?Int64
```
Query component class ID by unique key

Parameter: 

|Name|Type|Describe|
|---|---|---|
|uniqueKey|String|Definition-point unique key|

Return: 

- None if not registered

### func registerAlloc\(String,\(\)\->Component\)
```cj
public static func registerAlloc(uniqueKey: String, factory:() -> Component): Int64
```
Register a component class and allocate class ID (idempotent)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|uniqueKey|String|Definition-point unique key (macro-generated)factory Component no-arg factory|
|factory|()->Component||

Return: 

- Allocated component class ID

### prop count: Int64
```cj
public static prop count: Int64
```
Total number of allocated component class IDs

