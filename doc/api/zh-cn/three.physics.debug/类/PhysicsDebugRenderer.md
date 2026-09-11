# 类
## class PhysicsDebugRenderer
```cj
public class PhysicsDebugRenderer
```
Jolt 调试渲染器桥接

### func clear\(\)
```cj
public func clear(): Unit
```
清空已收集的图元缓存

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁渲染器（释放回调表与 Jolt 实例）

### func drawBodies\(PhysicsWorld,Bool\)
```cj
public func drawBodies(world: PhysicsWorld, wireframe!: Bool = true): Unit
```
采集一帧调试图元：绘制全部刚体形状（线框 + 着色可选）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|物理世界wireframe 是否线框（默认 true）|
|wireframe|Bool||

### func drawConstraints\(PhysicsWorld\)
```cj
public func drawConstraints(world: PhysicsWorld): Unit
```
采集一帧调试图元：绘制全部约束

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|物理世界|

### func init\(\)
```cj
public init()
```
构造并注册调试渲染器回调

### func nextFrame\(\)
```cj
public func nextFrame(): Unit
```
结束本帧采集（触发 Jolt NextFrame，清空内部状态）

### prop isValid: Bool
```cj
public prop isValid: Bool
```
渲染器是否有效

### prop lineCount: Int64
```cj
public prop lineCount: Int64
```
本帧收集的线段数量

