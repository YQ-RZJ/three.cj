# 枚举
## enum PowerState
```cj
public enum PowerState
```
电源状态枚举

### Charged
```cj
Charged
```
已插电，电池已充满

### Charging
```cj
Charging
```
已插电，充电中

### Error
```cj
Error
```
无法确定电源状态（C 端为 -1）

### NoBattery
```cj
NoBattery
```
已插电，无电池

### OnBattery
```cj
OnBattery
```
未插电，使用电池

### Unknown
```cj
Unknown
```
无法确定电源状态

### func fromValue\(UInt32\)
```cj
public static func fromValue(v: UInt32): PowerState
```
从 UInt32 转换回枚举值

参数: 

|名称|类型|描述|
|---|---|---|
|v|UInt32|UInt32 值|

返回: 

- 对应的 PowerState 枚举值

### func value\(\)
```cj
public func value(): UInt32
```
转换为 UInt32（Error 为 -1 的补码）

返回: 

- 枚举值对应的 UInt32

