# 类
## class ProfMessage
```cj
public class ProfMessage
```
消息 — Tracy 消息面板的运行时文本（区别于编译期日志）

### func appInfo\(String\)
```cj
public static func appInfo(txt: String): Unit
```
应用信息（profiler 窗口标题旁一次性显示）

参数: 

|名称|类型|描述|
|---|---|---|
|txt|String||

### func logDebug\(String\)
```cj
public static func logDebug(txt: String): Unit
```
发送 Debug 级消息（

参数: 

|名称|类型|描述|
|---|---|---|
|txt|String||

### func logError\(String\)
```cj
public static func logError(txt: String): Unit
```
发送 Error 级消息（

参数: 

|名称|类型|描述|
|---|---|---|
|txt|String||

### func logFatal\(String\)
```cj
public static func logFatal(txt: String): Unit
```
发送 Fatal 级消息（

参数: 

|名称|类型|描述|
|---|---|---|
|txt|String||

### func logInfo\(String\)
```cj
public static func logInfo(txt: String): Unit
```
发送 Info 级消息（

参数: 

|名称|类型|描述|
|---|---|---|
|txt|String||

### func logTrace\(String\)
```cj
public static func logTrace(txt: String): Unit
```
发送 Trace 级消息（

参数: 

|名称|类型|描述|
|---|---|---|
|txt|String||

### func logWarning\(String\)
```cj
public static func logWarning(txt: String): Unit
```
发送 Warning 级消息（

参数: 

|名称|类型|描述|
|---|---|---|
|txt|String||

### func log\(String,TracyMessageSeverity\)
```cj
public static func log(txt: String, severity: TracyMessageSeverity): Unit
```
发送一条消息（severity/color 全参数版）

参数: 

|名称|类型|描述|
|---|---|---|
|txt|String||
|severity|TracyMessageSeverity||

