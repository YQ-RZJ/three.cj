# Class
## class RenderBundles
```cj
public open class RenderBundles
```
Render bundles collection manager

### func add\(BundleGroup\)
```cj
public func add(bundle: BundleGroup): Unit
```
Adds a bundle group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bundle|BundleGroup|Bundle group|

### func clear\(\)
```cj
public func clear(): Unit
```
Clears all render bundles

### func init\(\)
```cj
public init()
```
Constructs a default render bundles collection

### func remove\(BundleGroup\)
```cj
public func remove(bundle: BundleGroup): Unit
```
Removes a bundle group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bundle|BundleGroup|Bundle group|

### var bundles
```cj
public var bundles: HashMap < Int64, BundleGroup >
```
Render bundle map

