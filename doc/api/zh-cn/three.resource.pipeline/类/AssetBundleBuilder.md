# 类
## class AssetBundleBuilder
```cj
public class AssetBundleBuilder
```
资源包构建器

### func addFile\(String,String\)
```cj
public func addFile(name: String, path: String): Option < AssetBundleBuilder >
```
从本地文件添加资源条目

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|资源名path 本地文件路径|
|path|String||

返回: 

- 读取成功返回自身引用；失败返回 None（条目不加入）

### func add\(String,Array<UInt8>\)
```cj
public func add(name: String, bytes: Array < UInt8 >): AssetBundleBuilder
```
添加一个资源条目

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|资源名（档案内唯一，重复添加覆盖）bytes 资源字节|
|bytes|Array<UInt8>||

返回: 

- 自身引用（链式调用）

### func build\(\)
```cj
public func build(): Array < UInt8 >
```
构建档案字节

返回: 

- 完整档案字节（可直接写入 AssetBundle.loadFromBytes）

### func init\(\)
```cj
public init()
```


### func writeTo\(String\)
```cj
public func writeTo(path: String): Bool
```
构建档案并写入本地文件

参数: 

|名称|类型|描述|
|---|---|---|
|path|String|输出文件路径|

返回: 

- 写入成功返回 true

