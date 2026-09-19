# Class
## class UiCollapsingHeader
```cj
public class UiCollapsingHeader <: UiWidget
```
Collapsing header widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the collapsing header; executes content when expanded

Return: 

- Whether the header is expanded this frame

### func init\(String,Int32\)
```cj
public init(label!: String, flags!: Int32 = 0)
```
Constructs a collapsing header widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Header text|
|flags|Int32|ImGui header flags (default 0)|

### func withContent\(\(\)\->Unit\)
```cj
public func withContent(content:() -> Unit): UiCollapsingHeader
```
Sets the collapsible content closure

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Content closure executed when expanded|

Return: 

- this (for chaining)

