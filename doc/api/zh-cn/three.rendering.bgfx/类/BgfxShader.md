# 类
## class BgfxShader
```cj
public class BgfxShader
```
bgfx 着色器编译

### func compileShader\(BgfxMemory,String\)
```cj
public func compileShader(code: BgfxMemory, name: String): ShaderHandle
```
编译着色器

参数: 

|名称|类型|描述|
|---|---|---|
|code|BgfxMemory|着色器代码（BgfxMemory，内部取指针）name 着色器名称（用于调试）|
|name|String||

返回: 

- 着色器句柄

### func destroyShader\(ShaderHandle\)
```cj
public func destroyShader(handle: ShaderHandle): Unit
```
销毁着色器

参数: 

|名称|类型|描述|
|---|---|---|
|handle|ShaderHandle|着色器句柄|

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


参数: 

|名称|类型|描述|
|---|---|---|
|info|BgfxInfo||

