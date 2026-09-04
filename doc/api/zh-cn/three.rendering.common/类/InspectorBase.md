# 类
## class InspectorBase
```cj
public open class InspectorBase
```
调试检查器基类

### func hide\(\)
```cj
public func hide(): Unit
```
隐藏检查器

### func init\(\)
```cj
public init()
```
构造默认检查器（禁用状态）

### func show\(\)
```cj
public func show(): Unit
```
显示检查器

### func update\(\)
```cj
public func update(): Unit
```
更新检查器（子类覆写）

### var enabled
```cj
public var enabled: Bool
```
是否启用检查器

