# Class
## class UiTreeNode
```cj
public class UiTreeNode <: UiWidget
```
Tree node widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the tree node; executes child content when expanded

Return: 

- Whether the node is expanded this frame

### func init\(String\)
```cj
public init(label!: String)
```
Constructs a tree node widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Node label text|

### func withContent\(\(\)\->Unit\)
```cj
public func withContent(content:() -> Unit): UiTreeNode
```
Sets the child content closure

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Child content closure executed when expanded|

Return: 

- this (for chaining)

