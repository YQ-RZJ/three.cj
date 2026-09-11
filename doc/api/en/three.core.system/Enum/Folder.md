# Enum
## enum Folder
```cj
public enum Folder
```
User folder type enumeration (corresponding to folders queryable by SDL_GetUserFolder)

### Desktop
```cj
Desktop
```
Desktop

### Documents
```cj
Documents
```
Documents

### Downloads
```cj
Downloads
```
Downloads

### Home
```cj
Home
```
Home directory

### Music
```cj
Music
```
Music

### Pictures
```cj
Pictures
```
Pictures

### PublicShare
```cj
PublicShare
```
Public share directory

### SavedGames
```cj
SavedGames
```
Saved games directory

### Screenshots
```cj
Screenshots
```
Screenshots directory

### Templates
```cj
Templates
```
Templates directory

### Videos
```cj
Videos
```
Videos directory

### func fromValue\(UInt32\)
```cj
public static func fromValue(v: UInt32): Folder
```
Convert from UInt32 back to enumeration value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|UInt32|UInt32 value|

Return: 

- Corresponding Folder enumeration value

### func value\(\)
```cj
public func value(): UInt32
```
Convert to UInt32

Return: 

- UInt32 value corresponding to the enumeration

