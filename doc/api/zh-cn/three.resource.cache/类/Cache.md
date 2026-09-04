# 类
## class Cache
```cj
public class Cache
```
资源缓存类，为加载器提供已加载资源的全局缓存

### func add\(String,ILoadResult\)
```cj
public static func add(key: String, file: ILoadResult): Unit
```
向缓存中添加资源

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|缓存键（通常为 URL）file 加载结果|
|file|ILoadResult||

### func clear\(\)
```cj
public static func clear(): Unit
```
清空所有缓存

### func get\(String\)
```cj
public static func get(key: String): Option < ILoadResult >
```
从缓存中获取资源

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|缓存键|

返回: 

- 缓存的加载结果，不存在时返回 None

### func remove\(String\)
```cj
public static func remove(key: String): Unit
```
从缓存中移除资源

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|缓存键|

### var enabled
```cj
public static var enabled: Bool = false
```
是否启用缓存

### var files
```cj
public static var files: HashMap < String, ILoadResult >= HashMap < String, ILoadResult >()
```
缓存文件字典

