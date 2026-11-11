# Class
## class UiCursor
```cj
public class UiCursor
```
Cursor positioning, content region queries, ID stack and line metrics (all static)

### func getContentRegionAvail\(\)
```cj
public static func getContentRegionAvail(): Vector2
```
Gets the remaining available space in the content region
(from the cursor to the region's bottom-right)

Return: 

- Available size (logical pixels; the basis for auto-fit custom widgets)

### func getCursorPos\(\)
```cj
public static func getCursorPos(): Vector2
```
Gets the cursor position within the window content region (window-relative)

Return: 

- Window-relative position (logical pixels)

### func getCursorScreenPos\(\)
```cj
public static func getCursorScreenPos(): Vector2
```
Gets the screen position where the next widget will be placed
(window content origin + cursor offset)

Return: 

- Screen position (logical pixels)

### func getFrameHeightWithSpacing\(\)
```cj
public static func getFrameHeightWithSpacing(): Float32
```
Standard frame height + vertical spacing

Return: 

- Frame height including spacing (logical pixels)

### func getFrameHeight\(\)
```cj
public static func getFrameHeight(): Float32
```
Standard widget frame height (default height of buttons/inputs etc.)

Return: 

- Frame height (logical pixels; aligning custom widgets keeps visual consistency)

### func getTextLineHeightWithSpacing\(\)
```cj
public static func getTextLineHeightWithSpacing(): Float32
```
Text line height + vertical spacing (ItemSpacing.y)

Return: 

- Line height including spacing (logical pixels)

### func getTextLineHeight\(\)
```cj
public static func getTextLineHeight(): Float32
```
Text line height (FontSize + small padding)

Return: 

- Line height (logical pixels)

### func popId\(\)
```cj
public static func popId(): Unit
```
Pops the ID namespace (paired with pushId/pushIdInt)

### func pushIdInt\(Int32\)
```cj
public static func pushIdInt(id: Int32): Unit
```
Pushes an integer ID namespace (paired with popId; loop indices are common)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int32|Integer identifier (e.g. loop index)|

### func pushId\(String\)
```cj
public static func pushId(id: String): Unit
```
Pushes a string ID namespace (paired with popId)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|String||

### func setCursorPos\(Vector2\)
```cj
public static func setCursorPos(pos: Vector2): Unit
```
Sets the cursor position within the window content region (window-relative)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pos|Vector2|Window-relative position (logical pixels)|

### func setCursorScreenPos\(Vector2\)
```cj
public static func setCursorScreenPos(pos: Vector2): Unit
```
Sets the screen position of the next widget (landing point for
free layout / overlay drawing)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pos|Vector2|Screen position (logical pixels)|

