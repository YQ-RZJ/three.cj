# Class
## class ProfPlot
```cj
public class ProfPlot
```
Plots — time-series value curves (FPS, memory, queue depth, ...)

### func config\(String,TracyPlotFormat,Bool,Bool,UInt32\)
```cj
public static func config(name: String, format: TracyPlotFormat, step: Bool, fill: Bool, color: UInt32): Unit
```
Configure the plot display (call once before first emission)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|format|TracyPlotFormat||
|step|Bool||
|fill|Bool||
|color|UInt32||

### func pointF32\(String,Float32\)
```cj
public static func pointF32(name: String, v: Float32): Unit
```
Emit a Float32 data point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|v|Float32||

### func pointI64\(String,Int64\)
```cj
public static func pointI64(name: String, v: Int64): Unit
```
Emit an Int64 data point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|v|Int64||

### func point\(String,Float64\)
```cj
public static func point(name: String, v: Float64): Unit
```
Emit a Float64 data point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|v|Float64||

