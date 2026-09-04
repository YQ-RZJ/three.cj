# Class
## class Logger
```cj
public class Logger
```
Unified logging manager class

### func debug\(Array<String>\)
```cj
public static func debug(params: Array < String >): Unit
```
Emits a Debug-level log message

Parameter: 

|Name|Type|Describe|
|---|---|---|
|params|Array<String>|Message parameters (the first is the tag/module name; a prefix is added automatically)|

### func error\(Array<String>\)
```cj
public static func error(params: Array < String >): Unit
```
Emits an Error-level log message

Parameter: 

|Name|Type|Describe|
|---|---|---|
|params|Array<String>|Message parameters (the first is the tag/module name; a prefix is added automatically)|

### func getConsoleFunction\(\)
```cj
public static func getConsoleFunction(): Option <(String, String) -> Unit >
```
Gets the current custom console function

Return: 

- The current console function (None if unset)

### func getLevel\(\)
```cj
public static func getLevel(): LogLevel
```
Gets the current log level

Return: 

- The current log level

### func info\(Array<String>\)
```cj
public static func info(params: Array < String >): Unit
```
Emits an Info-level log message

Parameter: 

|Name|Type|Describe|
|---|---|---|
|params|Array<String>|Message parameters (the first is the tag/module name; a prefix is added automatically)|

### func setConsoleFunction\(Option<\(String,String\)\->Unit>\)
```cj
public static func setConsoleFunction(fn: Option <(String, String) -> Unit >): Unit
```
Sets a custom console function

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fn|Option<(String,String)->Unit>|A custom function taking (type, message); type is one of"trace", "debug", "info", "warn", "error"|

### func setLevel\(LogLevel\)
```cj
public static func setLevel(level: LogLevel): Unit
```
Sets the current log level

Parameter: 

|Name|Type|Describe|
|---|---|---|
|level|LogLevel|The log level (logs below this level are suppressed)|

### func trace\(Array<String>\)
```cj
public static func trace(params: Array < String >): Unit
```
Emits a Trace-level log message

Parameter: 

|Name|Type|Describe|
|---|---|---|
|params|Array<String>|Message parameters (the first is the tag/module name; a prefix is added automatically)|

### func warnOnce\(Array<String>\)
```cj
public static func warnOnce(params: Array < String >): Unit
```
Emits a Warn-level log message only once

Parameter: 

|Name|Type|Describe|
|---|---|---|
|params|Array<String>|Message parameters|

### func warn\(Array<String>\)
```cj
public static func warn(params: Array < String >): Unit
```
Emits a Warn-level log message

Parameter: 

|Name|Type|Describe|
|---|---|---|
|params|Array<String>|Message parameters (the first is the tag/module name; a prefix is added automatically)|

