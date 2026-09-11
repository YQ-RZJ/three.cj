# Class
## class UiItemQuery
```cj
public class UiItemQuery
```
Widget state query — call after draw() to retrieve interaction state

### func getItemID\(\)
```cj
public static func getItemID(): UInt32
```
Returns the ID of the last widget

Return: 

- Widget ID

### func getItemRectMax\(\)
```cj
public static func getItemRectMax(): Vector2
```
Returns the rect maximum of the last widget

Return: 

- Rect maximum

### func getItemRectMin\(\)
```cj
public static func getItemRectMin(): Vector2
```
Returns the rect minimum of the last widget

Return: 

- Rect minimum

### func getItemRectSize\(\)
```cj
public static func getItemRectSize(): Vector2
```
Returns the size of the last widget

Return: 

- Widget size

### func isAnyItemActive\(\)
```cj
public static func isAnyItemActive(): Bool
```
Whether any widget is active

Return: 

- Whether any widget is active

### func isAnyItemFocused\(\)
```cj
public static func isAnyItemFocused(): Bool
```
Whether any widget is focused

Return: 

- Whether any widget is focused

### func isAnyItemHovered\(\)
```cj
public static func isAnyItemHovered(): Bool
```
Whether any widget is hovered

Return: 

- Whether any widget is hovered

### func isItemActivated\(\)
```cj
public static func isItemActivated(): Bool
```
Whether the last widget was activated

Return: 

- Whether activated

### func isItemActive\(\)
```cj
public static func isItemActive(): Bool
```
Whether the last widget is active (clicked/dragged)

Return: 

- Whether active

### func isItemClicked\(Int32\)
```cj
public static func isItemClicked(mouseButton!: Int32 = 0): Bool
```
Whether the last widget was clicked

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mouseButton|Int32||

Return: 

- Whether clicked

### func isItemDeactivatedAfterEdit\(\)
```cj
public static func isItemDeactivatedAfterEdit(): Bool
```
Whether the last widget was deactivated after edit

Return: 

- Whether deactivated after edit

### func isItemDeactivated\(\)
```cj
public static func isItemDeactivated(): Bool
```
Whether the last widget was deactivated

Return: 

- Whether deactivated

### func isItemEdited\(\)
```cj
public static func isItemEdited(): Bool
```
Whether the last widget was edited

Return: 

- Whether edited

### func isItemFocused\(\)
```cj
public static func isItemFocused(): Bool
```
Whether the last widget is focused

Return: 

- Whether focused

### func isItemHovered\(Int32\)
```cj
public static func isItemHovered(flags!: Int32 = 0): Bool
```
Whether the last widget is hovered

Parameter: 

|Name|Type|Describe|
|---|---|---|
|flags|Int32||

Return: 

- Whether hovered

### func isItemToggledOpen\(\)
```cj
public static func isItemToggledOpen(): Bool
```
Whether the last widget was toggled open/closed

Return: 

- Whether toggled open

### func isItemVisible\(\)
```cj
public static func isItemVisible(): Bool
```
Whether the last widget is visible

Return: 

- Whether visible

### func popID\(\)
```cj
public static func popID(): Unit
```
Pops the ID

### func pushIDInt\(Int32\)
```cj
public static func pushIDInt(intID: Int32): Unit
```
Pushes an integer ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|intID|Int32||

### func pushID\(String\)
```cj
public static func pushID(strID: String): Unit
```
Pushes a string ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|strID|String||

### func setItemDefaultFocus\(\)
```cj
public static func setItemDefaultFocus(): Unit
```
Sets default focus to the last widget

### func setKeyboardFocusHere\(Int32\)
```cj
public static func setKeyboardFocusHere(offset!: Int32 = 0): Unit
```
Sets keyboard focus to the next widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|offset|Int32|Offset (0=next, -1=previous)|

### func setNextItemAllowOverlap\(\)
```cj
public static func setNextItemAllowOverlap(): Unit
```
Sets the next widget to allow overlap

