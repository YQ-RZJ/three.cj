# Class
## class UiTextFilter
```cj
public class UiTextFilter
```
Text filter supporting filtering of text lists by conditions

### func clear\(\)
```cj
public func clear(): Unit
```
Clears the filter condition

### func destroy\(\)
```cj
public func destroy(): Unit
```
Destroys the filter and releases underlying resources

### func draw\(String\)
```cj
public func draw(label!: String = "Filter"): Bool
```
Draws the filter input box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Input label text (default "Filter")|

Return: 

- Whether the filter condition changed this frame

### func init\(String\)
```cj
public init(defaultFilter!: String = "")
```
Constructs a text filter

Parameter: 

|Name|Type|Describe|
|---|---|---|
|defaultFilter|String|Default filter condition text (default empty string)|

### func isActive\(\)
```cj
public func isActive(): Bool
```
Whether active (has a filter condition)

Return: 

- Whether there is currently an active filter condition

### func passFilter\(String\)
```cj
public func passFilter(text: String): Bool
```
Tests whether text passes the filter

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|Text to test|

Return: 

- Whether the text passes the filter condition

