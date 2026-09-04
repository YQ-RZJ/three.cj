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


### Documents
```cj
Documents
```


### Downloads
```cj
Downloads
```


### Home
```cj
Home
```


### Music
```cj
Music
```


### Pictures
```cj
Pictures
```


### PublicShare
```cj
PublicShare
```


### SavedGames
```cj
SavedGames
```


### Screenshots
```cj
Screenshots
```


### Templates
```cj
Templates
```


### Videos
```cj
Videos
```


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

