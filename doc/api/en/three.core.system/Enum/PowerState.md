# Enum
## enum PowerState
```cj
public enum PowerState
```
Power state enumeration

### Charged
```cj
Charged
```


### Charging
```cj
Charging
```


### Error
```cj
Error
```


### NoBattery
```cj
NoBattery
```


### OnBattery
```cj
OnBattery
```


### Unknown
```cj
Unknown
```


### func fromValue\(UInt32\)
```cj
public static func fromValue(v: UInt32): PowerState
```
Convert from UInt32 back to enumeration value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|UInt32|UInt32 value|

Return: 

- Corresponding PowerState enumeration value

### func value\(\)
```cj
public func value(): UInt32
```
Convert to UInt32 (Error is the two's complement of -1)

Return: 

- UInt32 value corresponding to the enumeration

