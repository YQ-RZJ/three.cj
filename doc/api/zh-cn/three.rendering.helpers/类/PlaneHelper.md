# 类
## class PlaneHelper
```cj
public class PlaneHelper <: Line
```
平面辅助对象，用于可视化 Plane 平面

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(\)
```cj
public init()
```
构造平面辅助对象

### func init\(Plane,Float64,UInt32\)
```cj
public init(plane: Plane, size!: Float64 = 1.0, hex!: UInt32 = 0xffff00)
```


参数: 

|名称|类型|描述|
|---|---|---|
|plane|Plane||
|size|Float64||
|hex|UInt32||

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
更新矩阵世界，将平面变换到正确位置

参数: 

|名称|类型|描述|
|---|---|---|
|force|Bool|是否强制更新|

### var plane
```cj
public var plane: Plane
```
被可视化的平面

### var size
```cj
public var size: Float64
```
辅助线的边长

