# 类
## class BgfxProgram
```cj
public class BgfxProgram
```
bgfx 着色器程序

### func createProgram\(ShaderHandle,ShaderHandle,String\)
```cj
public func createProgram(vertexShader: ShaderHandle, fragmentShader: ShaderHandle, name: String): BgfxProgramData
```
创建着色器程序

参数: 

|名称|类型|描述|
|---|---|---|
|vertexShader|ShaderHandle|顶点着色器句柄fragmentShader 片段着色器句柄name 程序名称|
|fragmentShader|ShaderHandle||
|name|String||

返回: 

- 程序数据

### func destroyProgram\(BgfxProgramData\)
```cj
public func destroyProgram(data: BgfxProgramData): Unit
```
销毁着色器程序

参数: 

|名称|类型|描述|
|---|---|---|
|data|BgfxProgramData|程序数据|

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


参数: 

|名称|类型|描述|
|---|---|---|
|info|BgfxInfo||

### func nextProgramId\(\)
```cj
public static func nextProgramId(): Int64
```
获取下一个程序 ID

返回: 

- 程序 ID

