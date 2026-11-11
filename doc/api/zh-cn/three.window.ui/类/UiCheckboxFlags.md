# 类
## class UiCheckboxFlags
```cj
public class UiCheckboxFlags <: UiWidget
```
位标志复选框控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染位标志复选框

返回: 

- 本次标志位是否变化

### func init\(String,PtrArray<Int32>,Int32\)
```cj
public init(label!: String, flags!: PtrArray < Int32 >, flagsValue!: Int32)
```
构造位标志复选框

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签|
|flags|PtrArray<Int32>|共享标志值（PtrArray<Int32> 单元素）|
|flagsValue|Int32|本复选框控制的位|

