# 类
## class ShaderChunks
```cj
public class ShaderChunks
```
管理所有着色器块的注册和组合

### func define\(String,String\)
```cj
public static func define(name: String, source: String): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String|着色器块名称source 着色器块源码|
|source|String||

### func get\(String\)
```cj
public static func get(name: String): String
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String|着色器块名称|

返回: 

- 着色器块源码

### func initialize\(\)
```cj
public static func initialize(): Unit
```
注册所有基础着色器块

### func resolve\(String\)
```cj
public static func resolve(source: String): String
```
解析着色器源码中的 #include <name> 指令，递归替换为对应的 chunk 内容

参数: 

|名称|类型|描述|
|---|---|---|
|source|String|着色器源码|

返回: 

- 替换后的完整着色器源码

