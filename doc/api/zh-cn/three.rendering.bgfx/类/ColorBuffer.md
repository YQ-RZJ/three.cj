# 类
## class ColorBuffer
```cj
public class ColorBuffer
```
颜色缓冲状态

### func reset\(\)
```cj
public func reset(): Unit
```
重置颜色缓冲状态

### func setClear\(Float64,Float64,Float64,Float64,Bool\)
```cj
public func setClear(r: Float64, g: Float64, b: Float64, a: Float64, premultipliedAlpha: Bool): Unit
```
设置清除颜色

参数: 

|名称|类型|描述|
|---|---|---|
|r|Float64|红色分量g 绿色分量b 蓝色分量a 透明度分量premultipliedAlpha 是否预乘 Alpha|
|g|Float64||
|b|Float64||
|a|Float64||
|premultipliedAlpha|Bool||

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
public func setMask(colorMask: Bool): Unit
```
设置颜色掩码

参数: 

|名称|类型|描述|
|---|---|---|
|colorMask|Bool|颜色掩码|

