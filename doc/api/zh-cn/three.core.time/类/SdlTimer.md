# 类
## class SdlTimer
```cj
public class SdlTimer
```
SDL 定时器工具（静态方法）

### func delayNS\(UInt64\)
```cj
public static func delayNS(ns: UInt64): Unit
```
延时指定纳秒数

参数: 

|名称|类型|描述|
|---|---|---|
|ns|UInt64|延时的纳秒数|

### func delay\(UInt32\)
```cj
public static func delay(ms: UInt32): Unit
```
延时指定毫秒数

参数: 

|名称|类型|描述|
|---|---|---|
|ms|UInt32|延时的毫秒数|

### func getPerformanceCounter\(\)
```cj
public static func getPerformanceCounter(): UInt64
```
获取高精度性能计数器值

返回: 

- 性能计数器当前值

### func getPerformanceFrequency\(\)
```cj
public static func getPerformanceFrequency(): UInt64
```
获取性能计数器频率（每秒计数次数）

返回: 

- 性能计数器频率

### func getTicksNS\(\)
```cj
public static func getTicksNS(): UInt64
```
获取自 SDL 初始化以来的纳秒数

返回: 

- 自 SDL 初始化以来的纳秒数

### func getTicks\(\)
```cj
public static func getTicks(): UInt64
```
获取自 SDL 初始化以来的毫秒数

返回: 

- 自 SDL 初始化以来的毫秒数

