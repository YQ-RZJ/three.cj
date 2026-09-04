# 接口
## interface IPoolObject
```cj
public interface IPoolObject
```
池对象生命周期接口

### func construct\(\)
```cj
func construct(): Unit
```
构造回调（对象被复用前调用）

### func destruct\(\)
```cj
func destruct(): Unit
```
析构回调（对象被回收时调用）

