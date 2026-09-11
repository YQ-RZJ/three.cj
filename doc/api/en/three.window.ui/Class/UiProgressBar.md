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


### func getFraction\(\)
```cj
public func getFraction(): Float32
```


### func init\(Float32,Vector2,String\)
```cj
public init(fraction!: Float32 = 0.0, size!: Vector2 = Vector2(- 1.0, 0.0), overlay!: String = "")
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|fraction|Float32||
|size|Vector2||
|overlay|String||

### func setFraction\(Float32\)
```cj
public func setFraction(f: Float32): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|f|Float32||

