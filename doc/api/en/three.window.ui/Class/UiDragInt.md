# Class
## class UiDragInt
```cj
public class UiDragInt <: UiWidget
```
Integer drag widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the integer drag widget

Return: 

- Whether the value changed this frame

### func getValue\(\)
```cj
public func getValue(): Int32
```
Gets the current value

Return: 

- The current drag value

### func init\(String,PtrArray<Int32>,Float32,Int32,Int32,String\)
```cj
public init(label!: String, value!: PtrArray < Int32 >, speed!: Float32 = 1.0, min!: Int32 = 0, max!: Int32 = 0, format!: String = "%d")
```
Constructs an integer drag widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Label text|
|value|PtrArray<Int32>|Value buffer (single-element PtrArray<Int32>, updated on drag)|
|speed|Float32|Drag speed (default 1.0)|
|min|Int32|Minimum value (default 0)|
|max|Int32|Maximum value (default 0 means unbounded)|
|format|String|Number display format (default "%d")|

