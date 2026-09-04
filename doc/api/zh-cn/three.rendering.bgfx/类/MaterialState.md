# 类
## class MaterialState
```cj
public class MaterialState
```
材质状态信息

### func init\(Int64\)
```cj
public init(materialId: Int64)
```


参数: 

|名称|类型|描述|
|---|---|---|
|materialId|Int64||

### var fogNeedsUpdate
```cj
public var fogNeedsUpdate: Bool = true
```
fog uniform 是否需要更新

### var lastUpdateFrame
```cj
public var lastUpdateFrame: Int64 = - 1
```
上次更新的帧号

### var materialId
```cj
public var materialId: Int64
```
材质 ID

### var programId
```cj
public var programId: Int64 = - 1
```
上次编译的程序 ID

### var uniformsNeedUpdate
```cj
public var uniformsNeedUpdate: Bool = true
```
是否需要更新 uniform

