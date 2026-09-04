# 类
## class LoaderUtils
```cj
public class LoaderUtils
```
加载器工具类

### func extractUrlBase\(String\)
```cj
public static func extractUrlBase(url: String): String
```
从 URL 提取基础路径

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|输入 URL|

返回: 

- 基础路径

### func resolveURL\(String,String\)
```cj
public static func resolveURL(url: String, path: String): String
```
解析相对 URL 到给定路径

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|要解析的 URLpath 相对 URL 的基础路径|
|path|String||

返回: 

- 解析后的 URL

