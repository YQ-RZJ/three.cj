# 类
## class Background
```cj
public open class Background <: DataMap
```
场景背景渲染类

### func init\(\)
```cj
public init()
```
构造默认背景实例

### func render\(Scene\)
```cj
public func render(scene: Scene): Unit
```
渲染背景，按 three.js 语义决定 view0 的清除色

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|场景对象|

### var color
```cj
public var color: Color
```
背景颜色

### var intensity
```cj
public var intensity: Float64
```
背景强度

### var texture
```cj
public var texture: Texture
```
背景纹理

