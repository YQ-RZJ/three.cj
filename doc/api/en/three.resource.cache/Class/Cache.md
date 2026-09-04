# Class
## class Cache
```cj
public class Cache
```
Resource cache class providing global caching for loaders

### func add\(String,ILoadResult\)
```cj
public static func add(key: String, file: ILoadResult): Unit
```
Add a resource to the cache

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Cache key (typically a URL)file Load result|
|file|ILoadResult||

### func clear\(\)
```cj
public static func clear(): Unit
```
Clear all cached resources

### func get\(String\)
```cj
public static func get(key: String): Option < ILoadResult >
```
Get a resource from the cache

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Cache key|

Return: 

- Cached load result, or None if not found

### func remove\(String\)
```cj
public static func remove(key: String): Unit
```
Remove a resource from the cache

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Cache key|

### var enabled
```cj
public static var enabled: Bool = false
```
Whether caching is enabled

### var files
```cj
public static var files: HashMap < String, ILoadResult >= HashMap < String, ILoadResult >()
```
Cached files dictionary

