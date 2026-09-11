# 类
## class UiTableSetupScrollFreeze
```cj
public class UiTableSetupScrollFreeze <: UiWidget
```
冻结列/行控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制冻结设置

返回: 

- 是否完成绘制

### func init\(Int32,Int32\)
```cj
public init(cols!: Int32 = 0, rows!: Int32 = 0)
```
构造冻结设置

参数: 

|名称|类型|描述|
|---|---|---|
|cols|Int32|冻结列数（默认 0）|
|rows|Int32|冻结行数（默认 0）|

