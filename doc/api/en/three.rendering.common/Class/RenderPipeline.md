# Class
## class RenderPipeline
```cj
public open class RenderPipeline
```
TSL render pipeline

### func \_update\(\)
```cj
public func _update(): Unit
```
Detects config changes and updates contextData

### func dispose\(\)
```cj
public func dispose(): Unit
```
Disposes render pipeline resources

### func init\(Renderer,Option<Any>\)
```cj
public init(renderer: Renderer, outputNode: Option < Any >)
```
Constructs a render pipeline

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer instanceoutputNode TSL output node|
|outputNode|Option<Any>||

### func init\(\)
```cj
public init()
```
No-argument constructor (backward compatible)

### func renderAsync\(\)
```cj
public func renderAsync(): Unit
```
Deprecated async render method, use render() instead

### func render\(\)
```cj
public func render(): Unit
```
Executes the render pipeline

### let isRenderPipeline
```cj
public let isRenderPipeline: Bool = true
```
Type test flag

### var needsUpdate
```cj
public var needsUpdate: Bool = true
```
Whether update is needed

### var outputColorTransform
```cj
public var outputColorTransform: Bool = true
```
Whether to enable output color transform

### var outputNode
```cj
public var outputNode: Option < Any >
```
TSL output node (placeholder Option<Any>)

### let renderer
```cj
public let renderer: Renderer
```
Renderer reference

