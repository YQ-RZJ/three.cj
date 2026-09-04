# 类
## class StencilBuffer
```cj
public class StencilBuffer
```
模板缓冲状态

### func reset\(\)
```cj
public func reset(): Unit
```
重置模板缓冲状态

### func setClear\(Int64\)
```cj
public func setClear(stencil: Int64): Unit
```
设置模板清除值

参数: 

|名称|类型|描述|
|---|---|---|
|stencil|Int64|模板清除值|

### func setFunc\(Int64,Int64,Int64\)
```cj
public func setFunc(stencilFunc: Int64, stencilRef: Int64, stencilMask: Int64): Unit
```
设置模板测试函数

参数: 

|名称|类型|描述|
|---|---|---|
|stencilFunc|Int64|模板测试函数stencilRef 模板参考值stencilMask 模板函数掩码|
|stencilRef|Int64||
|stencilMask|Int64||

### func setLocked\(Bool\)
```cj
public func setLocked(lock: Bool): Unit
```
设置锁定状态

参数: 

|名称|类型|描述|
|---|---|---|
|lock|Bool|是否锁定|

### func setMask\(Int64\)
```cj
public func setMask(stencilMask: Int64): Unit
```
设置模板掩码

参数: 

|名称|类型|描述|
|---|---|---|
|stencilMask|Int64|模板掩码|

### func setOp\(Int64,Int64,Int64\)
```cj
public func setOp(stencilFail: Int64, stencilZFail: Int64, stencilZPass: Int64): Unit
```
设置模板操作

参数: 

|名称|类型|描述|
|---|---|---|
|stencilFail|Int64|模板测试失败操作stencilZFail 深度测试失败操作stencilZPass 深度测试通过操作|
|stencilZFail|Int64||
|stencilZPass|Int64||

### func setTest\(Bool\)
```cj
public func setTest(stencilTest: Bool): Unit
```
设置模板测试

参数: 

|名称|类型|描述|
|---|---|---|
|stencilTest|Bool|是否启用模板测试|

