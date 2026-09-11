# Class
## class UiTableSetupScrollFreeze
```cj
public class UiTableSetupScrollFreeze <: UiWidget
```
Scroll freeze widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the scroll freeze setup

Return: 

- Whether drawing completed

### func init\(Int32,Int32\)
```cj
public init(cols!: Int32 = 0, rows!: Int32 = 0)
```
Constructs a scroll freeze setup

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cols|Int32|Number of frozen columns (default 0)|
|rows|Int32|Number of frozen rows (default 0)|

