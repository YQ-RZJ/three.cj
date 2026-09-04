# Class
## class DepthBuffer
```cj
public class DepthBuffer
```
Depth buffer state

### func getReversed\(\)
```cj
public func getReversed(): Bool
```
Get whether depth is reversed

Return: 

- Whether reversed

### func reset\(\)
```cj
public func reset(): Unit
```
Reset depth buffer state

### func setClear\(Float64\)
```cj
public func setClear(depth: Float64): Unit
```
Set depth clear value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|depth|Float64|Depth clear value|

### func setFunc\(Int64\)
```cj
public func setFunc(depthFunc: Int64): Unit
```
Set depth test function

Parameter: 

|Name|Type|Describe|
|---|---|---|
|depthFunc|Int64|Depth test function|

### func setLocked\(Bool\)
```cj
public func setLocked(lock: Bool): Unit
```
Set locked state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lock|Bool|Whether to lock|

### func setMask\(Bool\)
```cj
public func setMask(depthMask: Bool): Unit
```
Set depth mask

Parameter: 

|Name|Type|Describe|
|---|---|---|
|depthMask|Bool|Depth mask|

### func setReversed\(Bool\)
```cj
public func setReversed(reversed: Bool): Unit
```
Set whether depth is reversed

Parameter: 

|Name|Type|Describe|
|---|---|---|
|reversed|Bool|Whether reversed|

### func setTest\(Bool\)
```cj
public func setTest(depthTest: Bool): Unit
```
Set depth test

Parameter: 

|Name|Type|Describe|
|---|---|---|
|depthTest|Bool|Whether to enable depth test|

