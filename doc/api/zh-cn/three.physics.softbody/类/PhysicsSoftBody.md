# 类
## class PhysicsSoftBody
```cj
public class PhysicsSoftBody <: IReleasable
```
软体运行时对象

### func release\(\)
```cj
public func release(): Bool
```
销毁软体（从世界移除并释放刚体）

### prop bodyID: UInt32
```cj
public prop bodyID: UInt32
```
软体刚体 ID

### prop releasable: Bool
```cj
public prop releasable: Bool
```
软体是否有效（创建成功且未销毁）

