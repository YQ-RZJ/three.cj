# 类
## class ExtrudeGeometry
```cj
public class ExtrudeGeometry <: BufferGeometry
```
挤出几何体类：Shape 轮廓 + 深度挤出

### func init\(\)
```cj
public init()
```
无参构造：默认矩形轮廓 + depth=1

### func init\(Shape,HashMap<String,Any>\)
```cj
public init(shape: Shape, options: HashMap < String, Any >)
```


参数: 

|名称|类型|描述|
|---|---|---|
|shape|Shape||
|options|HashMap<String,Any>||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```


