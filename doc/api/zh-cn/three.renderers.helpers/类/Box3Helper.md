# 类
## class Box3Helper
```cj
public class Box3Helper <: LineSegments & IReleasable
```
Box3 轴对齐包围盒辅助对象

### func init\(\)
```cj
public init()
```
构造 Box3 辅助对象

### func init\(Box3,UInt32\)
```cj
public init(box: Box3, color!: UInt32 = 0xffff00)
```


参数: 

|名称|类型|描述|
|---|---|---|
|box|Box3||
|color|UInt32||

### func release\(\)
```cj
public func release(): Bool
```
释放 GPU 资源

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
更新世界矩阵，根据包围盒中心和尺寸调整位置与缩放

参数: 

|名称|类型|描述|
|---|---|---|
|force|Bool|是否强制更新|

### var box
```cj
public var box: Box3
```
被可视化的包围盒

