# Class
## class ProfMemory
```cj
public class ProfMemory
```
Memory events — manual alloc/free annotations

### func alloc\(CPointer<Unit>,UIntNative,String\)
```cj
public static func alloc(ptr: CPointer < Unit >, size: UIntNative, name: String): Unit
```
Report an allocation (expansion target of

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ptr|CPointer<Unit>||
|size|UIntNative||
|name|String||

### func discard\(String\)
```cj
public static func discard(name: String): Unit
```
Discard a whole named pool (zeroes all bytes booked to name)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func free\(CPointer<Unit>,String\)
```cj
public static func free(ptr: CPointer < Unit >, name: String): Unit
```
Report a free (expansion target of

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ptr|CPointer<Unit>||
|name|String||

