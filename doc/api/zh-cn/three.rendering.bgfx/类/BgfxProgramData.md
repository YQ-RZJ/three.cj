# 类
## class BgfxProgramData
```cj
public class BgfxProgramData
```
着色器程序缓存数据

### func init\(\)
```cj
public init()
```


### var destroyed
```cj
public var destroyed: Bool = false
```
是否已销毁

### var fragmentShader
```cj
public var fragmentShader: ShaderHandle = ShaderHandle()
```
片段着色器句柄

### var id
```cj
public var id: Int64 = 0
```
程序 ID

### var name
```cj
public var name: String = ""
```
程序名称

### var program
```cj
public var program: ProgramHandle = ProgramHandle()
```
bgfx 程序句柄

### var usedTimes
```cj
public var usedTimes: Int64 = 0
```
使用次数

### var vertexShader
```cj
public var vertexShader: ShaderHandle = ShaderHandle()
```
顶点着色器句柄

