# Class
## class UiGlyphRanges
```cj
public class UiGlyphRanges
```
Safe wrapper for glyph ranges (const ImWchar*)

### func finalize\(\)
```cj
public func finalize(): Unit
```
Frees heap memory owned by a self-built range (no-op for standard static ranges)

### func init\(\)
```cj
public init()
```
Creates an empty range (equivalent to NULL; AddFont* falls back to the default range)

### func isNull\(\)
```cj
public func isNull(): Bool
```
Whether the range is empty

Return: 

- true if empty

