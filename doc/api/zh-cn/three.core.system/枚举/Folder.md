# 枚举
## enum Folder
```cj
public enum Folder
```
用户文件夹类型枚举（对应 SDL_GetUserFolder 可查询的文件夹）

### Desktop
```cj
Desktop
```
桌面

### Documents
```cj
Documents
```
文档

### Downloads
```cj
Downloads
```
下载

### Home
```cj
Home
```
主目录

### Music
```cj
Music
```
音乐

### Pictures
```cj
Pictures
```
图片

### PublicShare
```cj
PublicShare
```
公共共享目录

### SavedGames
```cj
SavedGames
```
保存游戏目录

### Screenshots
```cj
Screenshots
```
截图目录

### Templates
```cj
Templates
```
模板目录

### Videos
```cj
Videos
```
视频目录

### func fromValue\(UInt32\)
```cj
public static func fromValue(v: UInt32): Folder
```
从 UInt32 转换回枚举值

参数: 

|名称|类型|描述|
|---|---|---|
|v|UInt32|UInt32 值|

返回: 

- 对应的 Folder 枚举值

### func value\(\)
```cj
public func value(): UInt32
```
转换为 UInt32

返回: 

- 枚举值对应的 UInt32

