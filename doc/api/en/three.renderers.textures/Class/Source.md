# Class
## class Source
```cj
public open class Source <: ILoadResult
```
Texture data source class

### func getSize\(\)
```cj
public func getSize():(Int64, Int64)
```
Get texture width and height

Return: 

- (width, height) tuple

### func init\(Array<UInt8>,Int64,Int64\)
```cj
public init(data!: Array < UInt8 >= Array < UInt8 >(), width!: Int64 = 0, height!: Int64 = 0)
```
Construct a new texture data source

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|Pixel array, defaults to emptywidth Data width in pixels, defaults to 0height Data height in pixels, defaults to 0|
|width|Int64||
|height|Int64||

### prop needsUpdate: Bool
```cj
public mut prop needsUpdate: Bool
```
Renderer internal incremental update flag, when true the next render will re-upload GPU buffer

### var dataReady
```cj
public var dataReady: Bool
```
Data ready flag

### var data
```cj
public var data: Array < UInt8 >
```
Pixel data array (interpreted by format/type in the renderer)

### var height
```cj
public var height: Int64
```
Data height in pixels

### var kind
```cj
public var kind: String
```
Type tag

### var version
```cj
public var version: Int64
```
Renderer internal version number, incremented after render when needsUpdate=true

### var width
```cj
public var width: Int64
```
Data width in pixels

