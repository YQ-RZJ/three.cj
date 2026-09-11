# 类
## class UiPopupModal
```cj
public class UiPopupModal <: UiWidget
```
模态弹出窗口控件（阻塞交互）

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String,CPointer<Int32>,\(\)\->Unit,Int32\)
```cj
public init(name!: String, open!: CPointer < Int32 >, content!:() -> Unit, flags!: Int32 = 0)
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|open|CPointer<Int32>||
|content|()->Unit||
|flags|Int32||

### func init\(String,\(\)\->Unit,Int32\)
```cj
public init(name!: String, content!:() -> Unit, flags!: Int32 = 0)
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|content|()->Unit||
|flags|Int32||

