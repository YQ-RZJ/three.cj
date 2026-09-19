# 类
## class ProfPlot
```cj
public class ProfPlot
```
Plot 曲线 — 随时间绘制的数值曲线（FPS/内存/队列深度等）

### func config\(String,TracyPlotFormat,Bool,Bool,UInt32\)
```cj
public static func config(name: String, format: TracyPlotFormat, step: Bool, fill: Bool, color: UInt32): Unit
```
配置曲线显示（首次发射前调用一次即可）

参数: 

|名称|类型|描述|
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
发射单精度数据点

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|v|Float32||

### func pointI64\(String,Int64\)
```cj
public static func pointI64(name: String, v: Int64): Unit
```
发射整型数据点

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|v|Int64||

### func point\(String,Float64\)
```cj
public static func point(name: String, v: Float64): Unit
```
发射浮点数据点

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|v|Float64||

