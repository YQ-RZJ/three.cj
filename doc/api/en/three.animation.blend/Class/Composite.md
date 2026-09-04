# Class
## class Composite
```cj
public class Composite
```
Composite compound property binding, used for AnimationObjectGroup

### func bind\(\)
```cj
public func bind(): Unit
```
Binds all active bindings

### func getValue\(Array<Float64>,Int64\)
```cj
public func getValue(array: Array < Float64 >, offset: Int64): Unit
```
Gets the value after binding all bindings, reading from the first valid binding

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|The target arrayoffset The write offset|
|offset|Int64||

### func init\(AnimationObjectGroup,String,HashMap<String,Any>\)
```cj
public init(targetGroup: AnimationObjectGroup, path: String, optionalParsedPath: HashMap < String, Any >)
```
Creates a compound binding, creating a binding for each object in the target group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|targetGroup|AnimationObjectGroup|The target object grouppath The property pathoptionalParsedPath The parsed path information|
|path|String||
|optionalParsedPath|HashMap<String,Any>||

### func setValue\(Array<Float64>,Int64\)
```cj
public func setValue(array: Array < Float64 >, offset: Int64): Unit
```
Sets the value on all active bindings

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|The source arrayoffset The read offset|
|offset|Int64||

### func unbind\(\)
```cj
public func unbind(): Unit
```
Unbinds all active bindings

