# Class
## class ColorBuffer
```cj
public class ColorBuffer
```
Color buffer state

### func reset\(\)
```cj
public func reset(): Unit
```
Reset color buffer state

### func setClear\(Float64,Float64,Float64,Float64,Bool\)
```cj
public func setClear(r: Float64, g: Float64, b: Float64, a: Float64, premultipliedAlpha: Bool): Unit
```
Set clear color

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Float64|Red componentg Green componentb Blue componenta Alpha componentpremultipliedAlpha Whether premultiplied alpha|
|g|Float64||
|b|Float64||
|a|Float64||
|premultipliedAlpha|Bool||

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
public func setMask(colorMask: Bool): Unit
```
Set color mask

Parameter: 

|Name|Type|Describe|
|---|---|---|
|colorMask|Bool|Color mask|

