# Class
## class UiListClipper
```cj
public class UiListClipper
```
=============================================================================

### func begin\(Int32,Float32\)
```cj
public func begin(itemsCount: Int32, itemsHeight!: Float32 = - 1.0f32): Unit
```
Begins clipping

Parameter: 

|Name|Type|Describe|
|---|---|---|
|itemsCount|Int32|Total item count|
|itemsHeight|Float32|Height per item (-1.0 = auto)|

### func destroy\(\)
```cj
public func destroy(): Unit
```


### func end\(\)
```cj
public func end(): Unit
```
Ends clipping

### func getDisplayEnd\(\)
```cj
public func getDisplayEnd(): Int32
```
Gets the current batch end index

### func getDisplayStart\(\)
```cj
public func getDisplayStart(): Int32
```
Gets the current batch start index

### func init\(\)
```cj
public init()
```


### func step\(\)
```cj
public func step(): Bool
```
Steps to the next batch of visible items

Return: 

- Whether there are more visible items

