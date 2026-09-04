# 类
## class BgfxUniformsGroups
```cj
public class BgfxUniformsGroups
```
bgfx Uniform 组管理

### func bind\(Int64,Int64\)
```cj
public func bind(groupId: Int64, programId: Int64): Unit
```
绑定 uniform 组

参数: 

|名称|类型|描述|
|---|---|---|
|groupId|Int64|uniform 组 IDprogramId 着色器程序 ID|
|programId|Int64||

### func disposeAll\(\)
```cj
public func disposeAll(): Unit
```
释放所有 uniform 组

### func dispose\(Int64\)
```cj
public func dispose(groupId: Int64): Unit
```
释放 uniform 组

参数: 

|名称|类型|描述|
|---|---|---|
|groupId|Int64|uniform 组 ID|

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


参数: 

|名称|类型|描述|
|---|---|---|
|info|BgfxInfo||

### func update\(Int64,Int64\)
```cj
public func update(groupId: Int64, programId: Int64): Unit
```
更新 uniform 组数据

参数: 

|名称|类型|描述|
|---|---|---|
|groupId|Int64|uniform 组 IDprogramId 着色器程序 ID|
|programId|Int64||

