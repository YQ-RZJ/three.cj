# 类
## class EcsObject
```cj
public open class EcsObject <: IPoolObject
```
ECS 对象生命周期基类，对接对象池

### func construct\(\)
```cj
public func construct(): Unit
```
构造（池复用入口），仅在未构造时执行 onConstruct，保证幂等

### func destruct\(\)
```cj
public func destruct(): Unit
```
析构（回收/删除入口），仅在已构造时执行 onDestruct，保证幂等

### func restruct\(\)
```cj
public func restruct(): Unit
```
重构（强制重建），仓颉依靠 onConstruct 重写链中的 super 调用达到同等效果

### prop constructed: Bool
```cj
public prop constructed: Bool
```
是否已构造

