# Class
## class LOD
```cj
public class LOD <: Object3D
```
LOD (Level of Detail) node that switches between detail levels based on camera distance

### func addLevel\(Object3D,Float64\)
```cj
public func addLevel(object: Object3D, distance!: Float64 = 0.0): Unit
```
distance - 距离阈值（米）。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|Object3D||
|distance|Float64||

### func clone\(\)
```cj
public override func clone(): Object3D
```
返回一个与本实例值相同的新 LOD 实例。

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定 LOD 实例的值复制到本实例。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D||
|recursive|Bool||

### func dispose\(\)
```cj
public func dispose(): Unit
```
注意：JS LOD 没有 dispose() 方法，此为仓颉侧补充的清理功能

### func getCurrentLevel\(\)
```cj
public func getCurrentLevel(): Int64
```
获取当前激活的层级索引。对照 JS: LOD.js getCurrentLevel() { return this._currentLevel; }

### func getObjectForDistance\(Float64\)
```cj
public func getObjectForDistance(distance: Float64): Object3D
```
distance - 相机距离。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|distance|Float64||

### func init\(\)
```cj
public init()
```
构造一个新的 LOD。

### func removeLevel\(Float64\)
```cj
public func removeLevel(distance: Float64): Bool
```
仓颉 ArrayList 无 splice/remove，参考 addLevel 的重建模式实现。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|distance|Float64||

### func setCurrentLevel\(Int64\)
```cj
public func setCurrentLevel(level: Int64): Unit
```
渲染器内部以 update(camera) 自动判定，与 JS side 一致。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|level|Int64||

### func update\(Camera\)
```cj
public func update(camera: Camera): Unit
```
camera - 渲染当前相机。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|camera|Camera||

### func visibleAtDistance\(Float64\)
```cj
public func visibleAtDistance(distance: Float64): Bool
```
是否可见（受 LOD 自动更新影响；渲染器内会按 _currentLevel 显隐各子对象）。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|distance|Float64||

### prop levelsJson: String
```cj
public mut prop levelsJson: String
```
格式：[["uuid1", distance1], ["uuid2", distance2], ...]

### var autoUpdate
```cj
public var autoUpdate: Bool
```
Whether to auto-update (used internally by renderer)

### var hysteresis
```cj
public var hysteresis: Float64
```
距离切换的滞后量，避免在阈值边界来回切换引起闪烁。

### var levels
```cj
public var levels: ArrayList <(Object3D, Float64) >
```
仓颉版用元组 (Object3D, Float64) 替代 JS 的 {distance, object} 对象。

