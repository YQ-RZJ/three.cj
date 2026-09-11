# 类
## class PhysicsRagdollSettings
```cj
public class PhysicsRagdollSettings
```
布娃娃设置：骨骼 + 部件数组，可创建运行时布娃娃

### func createRagdoll\(PhysicsWorld\)
```cj
public func createRagdoll(world: PhysicsWorld): PhysicsRagdoll
```
在指定物理世界中创建运行时布娃娃

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|目标物理世界|

返回: 

- 运行时布娃娃

### func init\(PhysicsSkeleton,Array<RagdollPartSettings>\)
```cj
public init(skeleton!: PhysicsSkeleton, parts!: Array < RagdollPartSettings >)
```
创建布娃娃设置

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|PhysicsSkeleton|骨骼（部件数须与关节数一致）parts 部件数组（索引与关节索引对应）|
|parts|Array<RagdollPartSettings>||

### var disableParentChildCollisions
```cj
public var disableParentChildCollisions: Bool = true
```


### var minSeparationDistance
```cj
public var minSeparationDistance: Float32 = 0.0f32
```


### var stabilize
```cj
public var stabilize: Bool = true
```


