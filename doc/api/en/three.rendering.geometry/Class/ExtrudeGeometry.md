# Class
## class ExtrudeGeometry
```cj
public class ExtrudeGeometry <: BufferGeometry
```
Extrude geometry class: Shape contour + depth extrusion

### func init\(\)
```cj
public init()
```
无参构造：默认矩形轮廓 + depth=1

### func init\(Shape,HashMap<String,Any>\)
```cj
public init(shape: Shape, options: HashMap < String, Any >)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|Shape||
|options|HashMap<String,Any>||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```


