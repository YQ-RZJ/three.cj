# Class
## class BgfxProgram
```cj
public class BgfxProgram
```
bgfx shader program

### func createProgram\(ShaderHandle,ShaderHandle,String\)
```cj
public func createProgram(vertexShader: ShaderHandle, fragmentShader: ShaderHandle, name: String): BgfxProgramData
```
Creates shader program

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vertexShader|ShaderHandle|Vertex shader handlefragmentShader Fragment shader handlename Program name|
|fragmentShader|ShaderHandle||
|name|String||

Return: 

- Program data

### func destroyProgram\(BgfxProgramData\)
```cj
public func destroyProgram(data: BgfxProgramData): Unit
```
Destroys shader program

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|BgfxProgramData|Program data|

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|info|BgfxInfo||

### func nextProgramId\(\)
```cj
public static func nextProgramId(): Int64
```
Gets next program ID

Return: 

- Program ID

