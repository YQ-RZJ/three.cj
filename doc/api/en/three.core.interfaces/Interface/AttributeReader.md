# Interface
## interface AttributeReader
```cj
public interface AttributeReader
```
Read-only vertex attribute access interface (getX/getY/getZ/getW + count)

### func getW\(Int64\)
```cj
func getW(index: Int64): Float64
```
Read the w (3rd) component at the specified index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Vertex index|

Return: 

- Component value

### func getX\(Int64\)
```cj
func getX(index: Int64): Float64
```
Read the x (0th) component at the specified index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Vertex index|

Return: 

- Component value

### func getY\(Int64\)
```cj
func getY(index: Int64): Float64
```
Read the y (1st) component at the specified index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Vertex index|

Return: 

- Component value

### func getZ\(Int64\)
```cj
func getZ(index: Int64): Float64
```
Read the z (2nd) component at the specified index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Vertex index|

Return: 

- Component value

### prop count: Int64
```cj
mut prop count: Int64
```
Vertex count

