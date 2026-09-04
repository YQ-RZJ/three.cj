# Class
## class SystemInfo
```cj
public class SystemInfo
```
System information query utility (static methods)

### func copyFile\(String,String\)
```cj
public static func copyFile(oldpath: String, newpath: String): Bool
```
Copy file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|oldpath|String|Source file pathnewpath Destination file path|
|newpath|String||

Return: 

- Whether successful

### func createDirectory\(String\)
```cj
public static func createDirectory(path: String): Bool
```
Create directory (including parent directories)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|path|String|Directory path|

Return: 

- Whether successful

### func getBasePath\(\)
```cj
public static func getBasePath(): String
```
Get application base path (directory of the executable, with trailing separator)

Return: 

- Base path string

### func getCPUCacheLineSize\(\)
```cj
public static func getCPUCacheLineSize(): Int32
```
Get CPU cache line size in bytes

Return: 

- CPU cache line size in bytes

### func getClipboardText\(\)
```cj
public static func getClipboardText(): String
```
Get clipboard text (returns empty string if no content)

Return: 

- Clipboard text

### func getDayOfWeek\(Int32,Int32,Int32\)
```cj
public static func getDayOfWeek(year: Int32, month: Int32, day: Int32): Int32
```
Get the day of the week for the specified date (0=Sunday, 1=Monday, ..., 6=Saturday)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|year|Int32|Yearmonth Monthday Day|
|month|Int32||
|day|Int32||

Return: 

- Day of week (0=Sunday, 6=Saturday)

### func getDayOfYear\(Int32,Int32,Int32\)
```cj
public static func getDayOfYear(year: Int32, month: Int32, day: Int32): Int32
```
Get the day of the year for the specified date (1~366)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|year|Int32|Yearmonth Monthday Day|
|month|Int32||
|day|Int32||

Return: 

- Day of the year

### func getDaysInMonth\(Int32,Int32\)
```cj
public static func getDaysInMonth(year: Int32, month: Int32): Int32
```
Get the number of days in the specified month

Parameter: 

|Name|Type|Describe|
|---|---|---|
|year|Int32|Yearmonth Month (1~12)|
|month|Int32||

Return: 

- Number of days

### func getNumLogicalCPUCores\(\)
```cj
public static func getNumLogicalCPUCores(): Int32
```
Get the number of logical CPU cores

Return: 

- Number of logical CPU cores

### func getPowerInfo\(\)
```cj
public static func getPowerInfo():(PowerState, Int32, Int32)
```
Get power status

Return: 

- (power state, remaining seconds, battery percentage), -1 means unknown for seconds and percentage

### func getPrefPath\(String,String\)
```cj
public static func getPrefPath(org: String, app: String): String
```
Get application preference path (directory composed of org/app, with trailing separator)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|org|String|Organization nameapp Application name|
|app|String||

Return: 

- Preference path string

### func getSIMDAlignment\(\)
```cj
public static func getSIMDAlignment(): UIntNative
```
Get SIMD alignment requirement in bytes

Return: 

- SIMD alignment requirement in bytes

### func getSystemPageSize\(\)
```cj
public static func getSystemPageSize(): Int32
```
Get system page size in bytes

Return: 

- System page size in bytes

### func getSystemRAM\(\)
```cj
public static func getSystemRAM(): Int32
```
Get system RAM size in MB

Return: 

- System RAM size in MB

### func getUserFolder\(Folder\)
```cj
public static func getUserFolder(folder: Folder): String
```
Get user folder path

Parameter: 

|Name|Type|Describe|
|---|---|---|
|folder|Folder|User folder type enumeration|

Return: 

- Folder path string

### func hasARMSIMD\(\)
```cj
public static func hasARMSIMD(): Bool
```
Whether CPU supports ARM SIMD

Return: 

- true if supported

### func hasAVX2\(\)
```cj
public static func hasAVX2(): Bool
```
Whether CPU supports AVX2

Return: 

- true if supported

### func hasAVX512F\(\)
```cj
public static func hasAVX512F(): Bool
```
Whether CPU supports AVX-512F

Return: 

- true if supported

### func hasAVX\(\)
```cj
public static func hasAVX(): Bool
```
Whether CPU supports AVX

Return: 

- true if supported

### func hasAltiVec\(\)
```cj
public static func hasAltiVec(): Bool
```
Whether CPU supports AltiVec

Return: 

- true if supported

### func hasClipboardText\(\)
```cj
public static func hasClipboardText(): Bool
```
Whether clipboard contains text

Return: 

- true if clipboard contains text

### func hasLASX\(\)
```cj
public static func hasLASX(): Bool
```
Whether CPU supports LASX (Loongson)

Return: 

- true if supported

### func hasLSX\(\)
```cj
public static func hasLSX(): Bool
```
Whether CPU supports LSX (Loongson)

Return: 

- true if supported

### func hasMMX\(\)
```cj
public static func hasMMX(): Bool
```
Whether CPU supports MMX

Return: 

- true if supported

### func hasNEON\(\)
```cj
public static func hasNEON(): Bool
```
Whether CPU supports NEON

Return: 

- true if supported

### func hasSSE2\(\)
```cj
public static func hasSSE2(): Bool
```
Whether CPU supports SSE2

Return: 

- true if supported

### func hasSSE3\(\)
```cj
public static func hasSSE3(): Bool
```
Whether CPU supports SSE3

Return: 

- true if supported

### func hasSSE41\(\)
```cj
public static func hasSSE41(): Bool
```
Whether CPU supports SSE4.1

Return: 

- true if supported

### func hasSSE42\(\)
```cj
public static func hasSSE42(): Bool
```
Whether CPU supports SSE4.2

Return: 

- true if supported

### func hasSSE\(\)
```cj
public static func hasSSE(): Bool
```
Whether CPU supports SSE

Return: 

- true if supported

### func hasSVE2\(\)
```cj
public static func hasSVE2(): Bool
```
Whether CPU supports SVE2

Return: 

- true if supported

### func openURL\(String\)
```cj
public static func openURL(url: String): Bool
```
Open URL (default browser)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|URL to open|

Return: 

- Whether successful

### func removePath\(String\)
```cj
public static func removePath(path: String): Bool
```
Remove file or directory (directory must be empty)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|path|String|Path|

Return: 

- Whether successful

### func renamePath\(String,String\)
```cj
public static func renamePath(oldpath: String, newpath: String): Bool
```
Rename/move file or directory

Parameter: 

|Name|Type|Describe|
|---|---|---|
|oldpath|String|Original pathnewpath New path|
|newpath|String||

Return: 

- Whether successful

### func setClipboardText\(String\)
```cj
public static func setClipboardText(text: String): Bool
```
Set clipboard text

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|Text to set|

Return: 

- Whether successful

### func showSimpleMessageBox\(UInt32,String,String,SDL\_Window\)
```cj
public static func showSimpleMessageBox(flags: UInt32, title: String, message: String, window: SDL_Window): Bool
```
Show a simple message box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|flags|UInt32|Message box flags (SDL_MESSAGEBOX_*, pass 0 for normal info box)title Titlemessage Message contentwindow Parent window handle (can be null)|
|title|String||
|message|String||
|window|SDL_Window||

Return: 

- Whether successful

