# 类
## class Textures
```cj
public open class Textures <: DataMap
```
纹理管理类

### func createSampler\(Sampler\)
```cj
public func createSampler(sampler: Sampler): Unit
```
创建采样器

参数: 

|名称|类型|描述|
|---|---|---|
|sampler|Sampler|采样器对象|

### func createTexture\(Texture\)
```cj
public func createTexture(texture: Texture): Unit
```
创建纹理，递增纹理内存计数

参数: 

|名称|类型|描述|
|---|---|---|
|texture|Texture|纹理对象|

### func destroyTexture\(Texture\)
```cj
public func destroyTexture(texture: Texture): Unit
```
销毁纹理，递减纹理内存计数

参数: 

|名称|类型|描述|
|---|---|---|
|texture|Texture|纹理对象|

### func getMaxAnisotropy\(\)
```cj
public func getMaxAnisotropy(): Int64
```
获取最大各向异性过滤值

返回: 

- 最大各向异性过滤值

### func init\(Backend,Info\)
```cj
public init(backend: Backend, info: Info)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|backend|Backend|渲染后端实例info 渲染统计信息|
|info|Info||

### func updateTexture\(Texture\)
```cj
public func updateTexture(texture: Texture): Unit
```
更新纹理

参数: 

|名称|类型|描述|
|---|---|---|
|texture|Texture|纹理对象|

### var backend
```cj
public var backend: Backend
```
渲染后端引用

### var info
```cj
public var info: Info
```
渲染统计信息

