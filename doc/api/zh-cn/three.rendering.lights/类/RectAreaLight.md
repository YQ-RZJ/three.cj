# 类
## class RectAreaLight
```cj
public class RectAreaLight <: Light
```
以矩形面积发光的光源

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定矩形面光源实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 本实例

### func init\(Color,Float64,Float64,Float64\)
```cj
public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0, width!: Float64 = 10.0, height!: Float64 = 10.0)
```
构造一个新的矩形面光源

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|光源颜色，默认0xffffffintensity 光源强度，默认1width 矩形宽度，默认10height 矩形高度，默认10|
|intensity|Float64||
|width|Float64||
|height|Float64||

### prop power: Float64
```cj
public mut prop power: Float64
```
直接访问矩形面光源功率（流明）

### var height
```cj
public var height: Float64
```
矩形高度，默认10

### var width
```cj
public var width: Float64
```
矩形宽度，默认10

