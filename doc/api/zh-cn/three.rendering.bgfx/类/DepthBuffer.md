# 类
## class DepthBuffer
```cj
public class DepthBuffer
```
深度缓冲状态

### func getReversed\(\)
```cj
public func getReversed(): Bool
```
获取深度是否反转

返回: 

- 是否反转

### func reset\(\)
```cj
public func reset(): Unit
```
重置深度缓冲状态

### func setClear\(Float64\)
```cj
public func setClear(depth: Float64): Unit
```
设置深度清除值

参数: 

|名称|类型|描述|
|---|---|---|
|depth|Float64|深度清除值|

### func setFunc\(Int64\)
```cj
public func setFunc(depthFunc: Int64): Unit
```
设置深度测试函数

参数: 

|名称|类型|描述|
|---|---|---|
|depthFunc|Int64|深度测试函数|

### func setLocked\(Bool\)
```cj
public func setLocked(lock: Bool): Unit
```
设置锁定状态

参数: 

|名称|类型|描述|
|---|---|---|
|lock|Bool|是否锁定|

### func setMask\(Bool\)
```cj
public func setMask(depthMask: Bool): Unit
```
设置深度掩码

参数: 

|名称|类型|描述|
|---|---|---|
|depthMask|Bool|深度掩码|

### func setReversed\(Bool\)
```cj
public func setReversed(reversed: Bool): Unit
```
设置深度是否反转

参数: 

|名称|类型|描述|
|---|---|---|
|reversed|Bool|是否反转|

### func setTest\(Bool\)
```cj
public func setTest(depthTest: Bool): Unit
```
设置深度测试

参数: 

|名称|类型|描述|
|---|---|---|
|depthTest|Bool|是否启用深度测试|

