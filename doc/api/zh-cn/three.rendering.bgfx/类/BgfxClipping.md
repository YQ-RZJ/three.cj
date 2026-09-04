# 类
## class BgfxClipping
```cj
public class BgfxClipping
```
bgfx 裁剪平面管理

### func \`init\`\(ArrayList<Plane>,Bool\)
```cj
public func `init`(planes: ArrayList < Plane >, enableLocalClipping: Bool): Bool
```
初始化裁剪平面

参数: 

|名称|类型|描述|
|---|---|---|
|planes|ArrayList<Plane>|全局裁剪平面数组enableLocalClipping 是否启用局部裁剪|
|enableLocalClipping|Bool||

返回: 

- 是否启用裁剪

### func beginShadows\(\)
```cj
public func beginShadows(): Unit
```
开始阴影渲染

### func endShadows\(\)
```cj
public func endShadows(): Unit
```
结束阴影渲染

### func init\(\)
```cj
public init()
```


### func setGlobalState\(ArrayList<Plane>,Camera\)
```cj
public func setGlobalState(planes: ArrayList < Plane >, camera: Camera): Unit
```
设置全局裁剪状态

参数: 

|名称|类型|描述|
|---|---|---|
|planes|ArrayList<Plane>|全局裁剪平面数组camera 相机|
|camera|Camera||

### func setState\(Material,Camera,Bool\)
```cj
public func setState(material: Material, camera: Camera, useCache: Bool): Unit
```
设置材质裁剪状态

参数: 

|名称|类型|描述|
|---|---|---|
|material|Material|材质camera 相机useCache 是否使用缓存|
|camera|Camera||
|useCache|Bool||

### var numIntersection
```cj
public var numIntersection: Int64 = 0
```
交叉裁剪平面数量

### var numPlanes
```cj
public var numPlanes: Int64 = 0
```
裁剪平面数量

### let uniform
```cj
public let uniform: ClippingUniform
```
裁剪平面 uniform

