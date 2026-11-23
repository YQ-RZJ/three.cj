# 类
## class RenderTarget3D
```cj
public class RenderTarget3D <: RenderTarget
```
3D 渲染目标类，继承自 RenderTarget

### func clone\(\)
```cj
public func clone(): RenderTarget3D
```
返回从此实例复制值的新 3D 渲染目标

返回: 

- 此实例的克隆

### func copy\(RenderTarget3D\)
```cj
public func copy(source: RenderTarget3D): RenderTarget3D
```
将给定 3D 渲染目标的设置复制到此实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|RenderTarget3D|要复制的 3D 渲染目标|

返回: 

- 当前实例的引用

### func init\(Int64,Int64,Int64\)
```cj
public init(width!: Int64 = 1, height!: Int64 = 1, depth!: Int64 = 1)
```
构造新的 3D 渲染目标

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|渲染目标宽度，默认为 1height 渲染目标高度，默认为 1depth 渲染目标深度，默认为 1|
|height|Int64||
|depth|Int64||

