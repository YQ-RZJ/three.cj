# Class
## class UiTableSetupColumn
```cj
public class UiTableSetupColumn <: UiWidget
```
Table column setup widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the column setup

Return: 

- Whether drawing completed

### func init\(String,Int32,Float32,UInt32\)
```cj
public init(label!: String, flags!: Int32 = 0, initWidthOrWeight!: Float32 = 0.0, userId!: UInt32 = 0)
```
Constructs a table column setup

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Column label|
|flags|Int32|Column flags (default 0)|
|initWidthOrWeight|Float32|Initial width or weight (default 0.0)|
|userId|UInt32|User-defined ID (default 0)|

