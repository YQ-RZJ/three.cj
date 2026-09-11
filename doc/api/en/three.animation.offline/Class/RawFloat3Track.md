# Class
## class RawFloat3Track
```cj
public class RawFloat3Track
```
Offline 3-component vector channel data

### func addKeyframe\(Float32,Vector3F\)
```cj
public func addKeyframe(time: Float32, value: Vector3F): Unit
```
Adds a keyframe

Parameter: 

|Name|Type|Describe|
|---|---|---|
|time|Float32||
|value|Vector3F||

### func init\(String\)
```cj
public init(name: String)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func numKeyframes\(\)
```cj
public func numKeyframes(): Int
```
Returns the number of keyframes

### func sortKeyframes\(\)
```cj
public func sortKeyframes(): Unit
```
Sorts the keyframes by ascending time

### func validate\(\)
```cj
public func validate(): Bool
```
Validates the data

Return: 

- true if the data is valid

### var keyframes
```cj
public var keyframes: ArrayList < RawFloat3Keyframe >
```


### var name
```cj
public var name: String
```


