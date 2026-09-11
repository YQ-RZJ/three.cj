# Class
## class UiPopupModal
```cj
public class UiPopupModal <: UiWidget
```
Modal popup window widget (blocks interaction)

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String,CPointer<Int32>,\(\)\->Unit,Int32\)
```cj
public init(name!: String, open!: CPointer < Int32 >, content!:() -> Unit, flags!: Int32 = 0)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|open|CPointer<Int32>||
|content|()->Unit||
|flags|Int32||

### func init\(String,\(\)\->Unit,Int32\)
```cj
public init(name!: String, content!:() -> Unit, flags!: Int32 = 0)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|content|()->Unit||
|flags|Int32||

