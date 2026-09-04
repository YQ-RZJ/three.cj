# 类
## class BgfxMorphtargets
```cj
public class BgfxMorphtargets
```
bgfx 变形目标管理

### func disposeAll\(\)
```cj
public func disposeAll(): Unit
```
释放所有变形目标

### func dispose\(Int64\)
```cj
public func dispose(geometryId: Int64): Unit
```
释放变形目标

参数: 

|名称|类型|描述|
|---|---|---|
|geometryId|Int64|几何体 ID|

### func get\(Int64,Int64\)
```cj
public func get(geometryId: Int64, count: Int64): MorphTargetInfo
```
获取变形目标信息

参数: 

|名称|类型|描述|
|---|---|---|
|geometryId|Int64|几何体 IDcount 变形目标数量|
|count|Int64||

返回: 

- 变形目标信息

### func init\(\)
```cj
public init()
```


### func update\(Int64,Array<Float32>\)
```cj
public func update(geometryId: Int64, weights: Array < Float32 >): Unit
```
更新变形目标权重

参数: 

|名称|类型|描述|
|---|---|---|
|geometryId|Int64|几何体 IDweights 权重数组|
|weights|Array<Float32>||

