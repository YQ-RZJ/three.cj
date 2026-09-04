# 类
## class RenderBundles
```cj
public open class RenderBundles
```
渲染束集合管理器

### func add\(BundleGroup\)
```cj
public func add(bundle: BundleGroup): Unit
```
添加渲染束组

参数: 

|名称|类型|描述|
|---|---|---|
|bundle|BundleGroup|渲染束组|

### func clear\(\)
```cj
public func clear(): Unit
```
清空所有渲染束

### func init\(\)
```cj
public init()
```
构造默认渲染束集合

### func remove\(BundleGroup\)
```cj
public func remove(bundle: BundleGroup): Unit
```
移除渲染束组

参数: 

|名称|类型|描述|
|---|---|---|
|bundle|BundleGroup|渲染束组|

### var bundles
```cj
public var bundles: HashMap < Int64, BundleGroup >
```
渲染束映射表

