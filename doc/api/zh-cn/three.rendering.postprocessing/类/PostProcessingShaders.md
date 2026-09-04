# 类
## class PostProcessingShaders
```cj
public class PostProcessingShaders
```
后处理内部 shader 注册表。

各后处理 shader 的注册与使用（按效果族组织）。
取代此前从 ShaderLibs.get() 取后处理 shader 的方式。

### func get\(String\)
```cj
public static func get(name: String):?ShaderProgram
```
取后处理 shader 程序（未注册返回 None）。
惰性初始化：首次调用时自动注册全部后处理 shader（幂等）。

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|shader 注册名（copy/output/bloom 系列/fxaa/smaa 系列/ssao 系列）|

### func initialize\(\)
```cj
public static func initialize(): Unit
```
注册全部后处理 shader（copy/output/bloom/fxaa/smaa/ssao 系列）。
由 BgfxRenderer 初始化或各 pass 首次使用时调用（幂等）。

