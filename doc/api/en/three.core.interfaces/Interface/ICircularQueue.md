# Interface
## interface ICircularQueue < T >
```cj
public interface ICircularQueue < T > <: IQueue < T >
```
Circular queue interface

### func next\(\)
```cj
func next():?T
```
Circularly get the next element (without consuming)

Return: 

- Next element; None if empty

