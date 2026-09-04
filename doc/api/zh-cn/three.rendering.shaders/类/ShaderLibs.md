# 类
## class ShaderLibs
```cj
public class ShaderLibs
```
着色器库，管理所有材质类型的着色器程序

### func get\(String\)
```cj
public static func get(name: String):?ShaderProgram
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String|着色器程序名称|

返回: 

- 着色器程序（若不存在返回 None）

### func initialize\(\)
```cj
public static func initialize(): Unit
```
初始化所有着色器程序，注册 ShaderChunk 和材质着色器

### func shutdown\(\)
```cj
public static func shutdown(): Unit
```
销毁着色器库，释放所有资源，停止编译器线程

