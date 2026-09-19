# Class
## class UiTreeNodeEx
```cj
public class UiTreeNodeEx <: UiWidget
```
Extended tree node widget (with flags support)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the extended tree node; executes child content when expanded

Return: 

- Whether the node is expanded this frame

### func init\(String,Int32\)
```cj
public init(label!: String, flags!: Int32 = 0)
```
Constructs an extended tree node widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Node label text|
|flags|Int32|ImGui tree node flags (e.g. default-open, default 0)|

### func withContent\(\(\)\->Unit\)
```cj
public func withContent(content:() -> Unit): UiTreeNodeEx
```
Sets the child content closure

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Child content closure executed when expanded|

Return: 

- this (for chaining)

