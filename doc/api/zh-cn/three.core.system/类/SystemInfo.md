# 类
## class SystemInfo
```cj
public class SystemInfo
```
系统信息查询工具（静态方法）

### func copyFile\(String,String\)
```cj
public static func copyFile(oldpath: String, newpath: String): Bool
```
复制文件

参数: 

|名称|类型|描述|
|---|---|---|
|oldpath|String|源文件路径newpath 目标文件路径|
|newpath|String||

返回: 

- 是否成功

### func createDirectory\(String\)
```cj
public static func createDirectory(path: String): Bool
```
创建目录（含父目录）

参数: 

|名称|类型|描述|
|---|---|---|
|path|String|目录路径|

返回: 

- 是否成功

### func getBasePath\(\)
```cj
public static func getBasePath(): String
```
获取应用基路径（可执行文件所在目录，末尾带分隔符）

返回: 

- 基路径字符串

### func getCPUCacheLineSize\(\)
```cj
public static func getCPUCacheLineSize(): Int32
```
获取 CPU 缓存行大小（字节）

返回: 

- CPU 缓存行大小（字节）

### func getClipboardText\(\)
```cj
public static func getClipboardText(): String
```
获取剪贴板文本（无内容返回空串）

返回: 

- 剪贴板文本

### func getDayOfWeek\(Int32,Int32,Int32\)
```cj
public static func getDayOfWeek(year: Int32, month: Int32, day: Int32): Int32
```
获取指定日期是星期几（0=周日，1=周一，...，6=周六）

参数: 

|名称|类型|描述|
|---|---|---|
|year|Int32|年份month 月份day 日|
|month|Int32||
|day|Int32||

返回: 

- 星期几（0=周日，6=周六）

### func getDayOfYear\(Int32,Int32,Int32\)
```cj
public static func getDayOfYear(year: Int32, month: Int32, day: Int32): Int32
```
获取指定日期在一年中的第几天（1~366）

参数: 

|名称|类型|描述|
|---|---|---|
|year|Int32|年份month 月份day 日|
|month|Int32||
|day|Int32||

返回: 

- 一年中的第几天

### func getDaysInMonth\(Int32,Int32\)
```cj
public static func getDaysInMonth(year: Int32, month: Int32): Int32
```
获取指定月份的天数

参数: 

|名称|类型|描述|
|---|---|---|
|year|Int32|年份month 月份（1~12）|
|month|Int32||

返回: 

- 天数

### func getNumLogicalCPUCores\(\)
```cj
public static func getNumLogicalCPUCores(): Int32
```
获取逻辑 CPU 核心数

返回: 

- 逻辑 CPU 核心数

### func getPowerInfo\(\)
```cj
public static func getPowerInfo():(PowerState, Int32, Int32)
```
获取电源状态

返回: 

- (电源状态, 剩余秒数, 电量百分比)，秒数和百分比为 -1 表示未知

### func getPrefPath\(String,String\)
```cj
public static func getPrefPath(org: String, app: String): String
```
获取应用偏好路径（org/app 组成的目录，末尾带分隔符）

参数: 

|名称|类型|描述|
|---|---|---|
|org|String|组织名app 应用名|
|app|String||

返回: 

- 偏好路径字符串

### func getSIMDAlignment\(\)
```cj
public static func getSIMDAlignment(): UIntNative
```
获取 SIMD 对齐要求（字节）

返回: 

- SIMD 对齐要求（字节）

### func getSystemPageSize\(\)
```cj
public static func getSystemPageSize(): Int32
```
获取系统页大小（字节）

返回: 

- 系统页大小（字节）

### func getSystemRAM\(\)
```cj
public static func getSystemRAM(): Int32
```
获取系统内存大小（MB）

返回: 

- 系统内存大小（MB）

### func getUserFolder\(Folder\)
```cj
public static func getUserFolder(folder: Folder): String
```
获取用户文件夹路径

参数: 

|名称|类型|描述|
|---|---|---|
|folder|Folder|用户文件夹类型枚举|

返回: 

- 文件夹路径字符串

### func hasARMSIMD\(\)
```cj
public static func hasARMSIMD(): Bool
```
CPU 是否支持 ARM SIMD

返回: 

- 支持返回 true

### func hasAVX2\(\)
```cj
public static func hasAVX2(): Bool
```
CPU 是否支持 AVX2

返回: 

- 支持返回 true

### func hasAVX512F\(\)
```cj
public static func hasAVX512F(): Bool
```
CPU 是否支持 AVX-512F

返回: 

- 支持返回 true

### func hasAVX\(\)
```cj
public static func hasAVX(): Bool
```
CPU 是否支持 AVX

返回: 

- 支持返回 true

### func hasAltiVec\(\)
```cj
public static func hasAltiVec(): Bool
```
CPU 是否支持 AltiVec

返回: 

- 支持返回 true

### func hasClipboardText\(\)
```cj
public static func hasClipboardText(): Bool
```
剪贴板是否包含文本

返回: 

- 包含返回 true

### func hasLASX\(\)
```cj
public static func hasLASX(): Bool
```
CPU 是否支持 LASX（龙芯）

返回: 

- 支持返回 true

### func hasLSX\(\)
```cj
public static func hasLSX(): Bool
```
CPU 是否支持 LSX（龙芯）

返回: 

- 支持返回 true

### func hasMMX\(\)
```cj
public static func hasMMX(): Bool
```
CPU 是否支持 MMX

返回: 

- 支持返回 true

### func hasNEON\(\)
```cj
public static func hasNEON(): Bool
```
CPU 是否支持 NEON

返回: 

- 支持返回 true

### func hasSSE2\(\)
```cj
public static func hasSSE2(): Bool
```
CPU 是否支持 SSE2

返回: 

- 支持返回 true

### func hasSSE3\(\)
```cj
public static func hasSSE3(): Bool
```
CPU 是否支持 SSE3

返回: 

- 支持返回 true

### func hasSSE41\(\)
```cj
public static func hasSSE41(): Bool
```
CPU 是否支持 SSE4.1

返回: 

- 支持返回 true

### func hasSSE42\(\)
```cj
public static func hasSSE42(): Bool
```
CPU 是否支持 SSE4.2

返回: 

- 支持返回 true

### func hasSSE\(\)
```cj
public static func hasSSE(): Bool
```
CPU 是否支持 SSE

返回: 

- 支持返回 true

### func hasSVE2\(\)
```cj
public static func hasSVE2(): Bool
```
CPU 是否支持 SVE2

返回: 

- 支持返回 true

### func openURL\(String\)
```cj
public static func openURL(url: String): Bool
```
打开 URL（默认浏览器）

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|要打开的 URL|

返回: 

- 是否成功

### func removePath\(String\)
```cj
public static func removePath(path: String): Bool
```
删除文件或目录（目录需为空）

参数: 

|名称|类型|描述|
|---|---|---|
|path|String|路径|

返回: 

- 是否成功

### func renamePath\(String,String\)
```cj
public static func renamePath(oldpath: String, newpath: String): Bool
```
重命名/移动文件或目录

参数: 

|名称|类型|描述|
|---|---|---|
|oldpath|String|原路径newpath 新路径|
|newpath|String||

返回: 

- 是否成功

### func setClipboardText\(String\)
```cj
public static func setClipboardText(text: String): Bool
```
设置剪贴板文本

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|要设置的文本|

返回: 

- 是否成功

### func showSimpleMessageBox\(UInt32,String,String,SDL\_Window\)
```cj
public static func showSimpleMessageBox(flags: UInt32, title: String, message: String, window: SDL_Window): Bool
```
显示简单消息框

参数: 

|名称|类型|描述|
|---|---|---|
|flags|UInt32|消息框标志（SDL_MESSAGEBOX_*，传 0 为普通信息框）title 标题message 消息内容window 父窗口句柄（可为 null）|
|title|String||
|message|String||
|window|SDL_Window||

返回: 

- 是否成功

