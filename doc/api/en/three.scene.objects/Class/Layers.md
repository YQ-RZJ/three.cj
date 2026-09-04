# Class
## class Layers
```cj
public class Layers
```
Layers class, managing 32 layer memberships using a bitmask

### func disableAll\(\)
```cj
public func disableAll(): Unit
```
Disable all layers

### func disable\(UInt32\)
```cj
public func disable(layer: UInt32): Unit
```
Disable the specified layer (remove membership)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layer|UInt32|Layer number (0~31)|

### func enableAll\(\)
```cj
public func enableAll(): Unit
```
Enable all layers

### func enable\(UInt32\)
```cj
public func enable(layer: UInt32): Unit
```
Enable the specified layer (add membership)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layer|UInt32|Layer number (0~31)|

### func init\(\)
```cj
public init()
```
Construct a new layers instance, default belonging to layer 0

### func isEnabled\(UInt32\)
```cj
public func isEnabled(layer: UInt32): Bool
```
Test whether the specified layer is enabled

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layer|UInt32|Layer number (0~31)|

Return: 

- Returns true if the specified layer is enabled

### func set\(UInt32\)
```cj
public func set(layer: UInt32): Unit
```
Set to belong only to the specified layer, removing all other layer memberships

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layer|UInt32|Layer number (0~31)|

### func test\(Layers\)
```cj
public func test(layers: Layers): Bool
```
Test whether this layers object shares at least one layer with the given layers object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layers|Layers|The layers object to test against|

Return: 

- Returns true if at least one layer is shared

### func toggle\(UInt32\)
```cj
public func toggle(layer: UInt32): Unit
```
Toggle the specified layer's membership

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layer|UInt32|Layer number (0~31)|

### var mask
```cj
public var mask: UInt32
```
Bitmask storing the current object's layer memberships

