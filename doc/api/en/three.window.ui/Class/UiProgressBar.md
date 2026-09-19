# Class
## class UiProgressBar
```cj
public class UiProgressBar <: UiWidget
```
Progress bar widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the progress bar

Return: 

- Always false (no interaction)

### func getFraction\(\)
```cj
public func getFraction(): Float32
```
Gets the progress fraction

Return: 

- The current progress fraction

### func init\(Float32,Vector2,String\)
```cj
public init(fraction!: Float32 = 0.0, size!: Vector2 = Vector2(- 1.0, 0.0), overlay!: String = "")
```
Constructs a progress bar widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fraction|Float32|Progress fraction (0.0~1.0, default 0.0)|
|size|Vector2|Progress bar size (default (-1.0, 0.0) fills the current line width)|
|overlay|String|Overlay text (default empty means no overlay)|

### func setFraction\(Float32\)
```cj
public func setFraction(f: Float32): Unit
```
Sets the progress fraction

Parameter: 

|Name|Type|Describe|
|---|---|---|
|f|Float32|Progress fraction (0.0~1.0)|

