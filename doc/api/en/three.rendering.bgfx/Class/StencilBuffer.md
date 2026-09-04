# Class
## class StencilBuffer
```cj
public class StencilBuffer
```
Stencil buffer state

### func reset\(\)
```cj
public func reset(): Unit
```
Reset stencil buffer state

### func setClear\(Int64\)
```cj
public func setClear(stencil: Int64): Unit
```
Set stencil clear value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stencil|Int64|Stencil clear value|

### func setFunc\(Int64,Int64,Int64\)
```cj
public func setFunc(stencilFunc: Int64, stencilRef: Int64, stencilMask: Int64): Unit
```
Set stencil test function

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stencilFunc|Int64|Stencil test functionstencilRef Stencil reference valuestencilMask Stencil function mask|
|stencilRef|Int64||
|stencilMask|Int64||

### func setLocked\(Bool\)
```cj
public func setLocked(lock: Bool): Unit
```
Set locked state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lock|Bool|Whether to lock|

### func setMask\(Int64\)
```cj
public func setMask(stencilMask: Int64): Unit
```
Set stencil mask

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stencilMask|Int64|Stencil mask|

### func setOp\(Int64,Int64,Int64\)
```cj
public func setOp(stencilFail: Int64, stencilZFail: Int64, stencilZPass: Int64): Unit
```
Set stencil operation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stencilFail|Int64|Stencil fail operationstencilZFail Depth fail operationstencilZPass Depth pass operation|
|stencilZFail|Int64||
|stencilZPass|Int64||

### func setTest\(Bool\)
```cj
public func setTest(stencilTest: Bool): Unit
```
Set stencil test

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stencilTest|Bool|Whether to enable stencil test|

