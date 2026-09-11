# Class
## class UiTextFilter
```cj
public class UiTextFilter
```
=============================================================================

### func clear\(\)
```cj
public func clear(): Unit
```
Clears the filter condition

### func destroy\(\)
```cj
public func destroy(): Unit
```


### func draw\(String\)
```cj
public func draw(label!: String = "Filter"): Bool
```
Draws the filter input box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||

### func init\(String\)
```cj
public init(defaultFilter!: String = "")
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|defaultFilter|String||

### func isActive\(\)
```cj
public func isActive(): Bool
```
Whether active (has a filter condition)

### func passFilter\(String\)
```cj
public func passFilter(text: String): Bool
```
Tests whether text passes the filter

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String||

