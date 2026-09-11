# 类
## class UiTabItem
```cj
public class UiTabItem <: UiWidget
```
标签页控件

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String,\(\)\->Unit,Int32\)
```cj
public init(label!: String, content!:() -> Unit, flags!: Int32 = 0)
```


参数: 

|名称|类型|描述|
|---|---|---|
|label|String||
|content|()->Unit||
|flags|Int32||

### func init\(String,CPointer<Int32>,\(\)\->Unit,Int32\)
```cj
public init(label!: String, open!: CPointer < Int32 >, content!:() -> Unit, flags!: Int32 = 0)
```


参数: 

|名称|类型|描述|
|---|---|---|
|label|String||
|open|CPointer<Int32>||
|content|()->Unit||
|flags|Int32||

