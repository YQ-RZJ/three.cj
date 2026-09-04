# 类
## class ArrowHelper
```cj
public class ArrowHelper <: Object3D
```
三维箭头辅助对象，用于可视化方向

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
复制另一个箭头辅助对象

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 自身引用

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(Vector3,Vector3,Float64,UInt32,Float64,Float64\)
```cj
public init(dir!: Vector3 = Vector3(0.0, 0.0, 1.0), origin!: Vector3 = Vector3(0.0, 0.0, 0.0), length!: Float64 = 1.0, color!: UInt32 = 0xffff00, headLength!: Float64 = 0.0, headWidth!: Float64 = 0.0)
```
构造箭头辅助对象

参数: 

|名称|类型|描述|
|---|---|---|
|dir|Vector3|方向向量（需归一化），默认 +Z 方向origin 起点位置，默认原点length 箭头长度（世界单位），默认 1color 颜色，默认黄色 0xffff00headLength 头部长度，默认 length * 0.2headWidth 头部宽度，默认 headLength * 0.2|
|origin|Vector3||
|length|Float64||
|color|UInt32||
|headLength|Float64||
|headWidth|Float64||

### func setColor\(Color\)
```cj
public func setColor(color: Color): Unit
```
设置箭头的颜色

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|颜色值|

### func setDirection\(Vector3\)
```cj
public func setDirection(dir: Vector3): Unit
```
设置箭头的方向

参数: 

|名称|类型|描述|
|---|---|---|
|dir|Vector3|归一化的方向向量|

### func setLength\(Float64,Float64,Float64\)
```cj
public func setLength(length: Float64, headLength: Float64, headWidth: Float64): Unit
```
设置箭头的长度

参数: 

|名称|类型|描述|
|---|---|---|
|length|Float64|总长度headLength 头部长度headWidth 头部宽度|
|headLength|Float64||
|headWidth|Float64||

### var cone
```cj
public var cone: Mesh
```
箭头的锥体头部部分

### var line
```cj
public var line: Line
```
箭头的线体部分

