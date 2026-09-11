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


### func init\(String\)
```cj
public init(label!: String)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||

### func withContent\(\(\)\->Unit\)
```cj
public func withContent(content:() -> Unit): UiTreeNode
```
Sets the child content closure

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit||

Return: 

- this (for chaining)

