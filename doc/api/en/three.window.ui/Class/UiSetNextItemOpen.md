# Class
## class UiSetNextItemOpen
```cj
public class UiSetNextItemOpen <: UiWidget
```
Set next tree node open state

### func draw\(\)
```cj
public override func draw(): Bool
```
Sets the open state of the next tree node

Return: 

- Always false (no interaction)

### func init\(Bool,Int32\)
```cj
public init(isOpen!: Bool = true, cond!: Int32 = 0)
```
Constructs a next-tree-node-state widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|isOpen|Bool|Whether the next tree node is open (default true)|
|cond|Int32|Activation condition (ImGui condition enum value, default 0 means always)|

