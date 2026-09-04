# 类
## class LuaHotReload
```cj
public class LuaHotReload
```
Lua 脚本热更新器

### func init\(LuaVM,String\)
```cj
public init(vm: LuaVM, path: String)
```
构造热更新器

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|目标虚拟机（脚本在此执行）path Lua 脚本文件路径（相对当前工作目录）|
|path|String||

### func load\(\)
```cj
public func load(): Bool
```
首次加载并执行脚本文件

返回: 

- 是否加载成功

### func poll\(\)
```cj
public func poll(): Bool
```
轮询检测文件变更，变化则自动重新加载

返回: 

- true = 检测到变化并已重新加载；false = 无变化或加载失败

### func reload\(\)
```cj
public func reload(): Bool
```
立即重新加载（无论是否变化）

返回: 

- 是否重新加载成功

### func setAfterReload\(\(\)\->Unit\)
```cj
public func setAfterReload(cb:() -> Unit): Unit
```
注册 reload 后回调（如刷新场景状态）

参数: 

|名称|类型|描述|
|---|---|---|
|cb|()->Unit|reload 后执行的回调|

### func setBeforeReload\(\(\)\->Unit\)
```cj
public func setBeforeReload(cb:() -> Unit): Unit
```
注册 reload 前回调（如保存场景状态）

参数: 

|名称|类型|描述|
|---|---|---|
|cb|()->Unit|reload 前执行的回调|

### prop exists: Bool
```cj
public prop exists: Bool
```
脚本文件当前是否存在

### prop lastReloadOk: Bool
```cj
public prop lastReloadOk: Bool
```
最近一次 reload 是否成功

### prop loaded: Bool
```cj
public prop loaded: Bool
```
是否已成功加载过

### prop path: String
```cj
public prop path: String
```
脚本路径

