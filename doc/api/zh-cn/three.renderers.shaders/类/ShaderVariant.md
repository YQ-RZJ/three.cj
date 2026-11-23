# 类
## class ShaderVariant
```cj
public class ShaderVariant
```
Shader 变体管理器

### func getActiveTextureFlags\(Material\)
```cj
public static func getActiveTextureFlags(mat: Material): Array < String >
```
获取激活的纹理标记列表

参数: 

|名称|类型|描述|
|---|---|---|
|mat|Material|材质|

返回: 

- 激活的纹理标记数组

### func getDefines\(Material\)
```cj
public static func getDefines(mat: Material): Array < String >
```
生成 #define 标志字符串数组（如 "USE_MAP=1"）

参数: 

|名称|类型|描述|
|---|---|---|
|mat|Material|材质|

返回: 

- define 字符串数组（空数组表示无变体标志）

### func getVariantKey\(Material\)
```cj
public static func getVariantKey(mat: Material): String
```
从材质生成变体键（用于缓存）

参数: 

|名称|类型|描述|
|---|---|---|
|mat|Material|材质|

返回: 

- 变体键字符串

