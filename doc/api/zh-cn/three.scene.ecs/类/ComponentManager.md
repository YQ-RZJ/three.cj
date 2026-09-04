# 类
## class ComponentManager
```cj
public class ComponentManager
```
组件管理类

### func clear\(\)
```cj
public func clear(): Unit
```
释放清理（清空全部池缓存）

### func createComponent\(ComponentId\)where T <: Component
```cj
public func createComponent < T >(cptId: ComponentId):?T where T <: Component
```
创建组件（池化）

参数: 

|名称|类型|描述|
|---|---|---|
|cptId|ComponentId|组件类 ID（XxxCpt.typeId()）|

返回: 

- 组件实例，组件类未注册返回 None

### func recycle\(Component\)
```cj
public func recycle(c: Component): Unit
```
回收组件

参数: 

|名称|类型|描述|
|---|---|---|
|c|Component|组件实例|

异常: 

- EcsException 组件仍挂在实体上

