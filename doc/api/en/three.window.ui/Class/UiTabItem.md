# Class
## class UiTabItem
```cj
public class UiTabItem <: UiWidget
```
Tab item widget

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String,\(\)\->Unit,Int32\)
```cj
public init(label!: String, content!:() -> Unit, flags!: Int32 = 0)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||
|content|()->Unit||
|flags|Int32||

### func init\(String,CPointer<Int32>,\(\)\->Unit,Int32\)
```cj
public init(label!: String, open!: CPointer < Int32 >, content!:() -> Unit, flags!: Int32 = 0)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||
|open|CPointer<Int32>||
|content|()->Unit||
|flags|Int32||

