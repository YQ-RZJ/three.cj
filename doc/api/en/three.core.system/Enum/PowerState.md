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
Plugged in, battery fully charged

### Charging
```cj
Charging
```
Plugged in, charging

### Error
```cj
Error
```
Unable to determine power state (-1 on the C side)

### NoBattery
```cj
NoBattery
```
Plugged in, no battery

### OnBattery
```cj
OnBattery
```
Not plugged in, running on battery

### Unknown
```cj
Unknown
```
Unable to determine power state

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

