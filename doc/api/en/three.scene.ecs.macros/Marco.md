# Marco
## macro Component\(Tokens\)
```cj
public macro Component(input: Tokens): Tokens
```
Component decorator macro: auto-registers class-level unique ID for components

## macro Entity\(Tokens\)
```cj
public macro Entity(input: Tokens): Tokens
```
Entity decorator macro (marker + validation)

## macro System\(Tokens, Tokens\)
```cj
public macro System(attr: Tokens, input: Tokens): Tokens
```
System decorator macro: registers component list and injects mask collection

