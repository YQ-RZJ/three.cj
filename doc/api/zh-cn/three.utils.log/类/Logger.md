# 类
## class Logger
```cj
public class Logger
```
统一日志管理类

### func debug\(Array<String>\)
```cj
public static func debug(params: Array < String >): Unit
```
输出 Debug 级别日志

参数: 

|名称|类型|描述|
|---|---|---|
|params|Array<String>|消息参数列表（首参数为标签/模块名，自动添加前缀）|

### func error\(Array<String>\)
```cj
public static func error(params: Array < String >): Unit
```
输出 Error 级别日志

参数: 

|名称|类型|描述|
|---|---|---|
|params|Array<String>|消息参数列表（首参数为标签/模块名，自动添加前缀）|

### func getConsoleFunction\(\)
```cj
public static func getConsoleFunction(): Option <(String, String) -> Unit >
```
获取当前自定义控制台函数

返回: 

- 当前控制台函数（未设置时为 None）

### func getLevel\(\)
```cj
public static func getLevel(): LogLevel
```
获取当前日志等级

返回: 

- 当前日志等级

### func info\(Array<String>\)
```cj
public static func info(params: Array < String >): Unit
```
输出 Info 级别日志

参数: 

|名称|类型|描述|
|---|---|---|
|params|Array<String>|消息参数列表（首参数为标签/模块名，自动添加前缀）|

### func setConsoleFunction\(Option<\(String,String\)\->Unit>\)
```cj
public static func setConsoleFunction(fn: Option <(String, String) -> Unit >): Unit
```
设置自定义控制台函数

参数: 

|名称|类型|描述|
|---|---|---|
|fn|Option<(String,String)->Unit>|自定义函数，接受 (type, message) 参数，type 为 "trace"、"debug"、"info"、"warn"、"error"|

### func setLevel\(LogLevel\)
```cj
public static func setLevel(level: LogLevel): Unit
```
设置当前日志等级

参数: 

|名称|类型|描述|
|---|---|---|
|level|LogLevel|日志等级（低于该等级的日志不会输出）|

### func trace\(Array<String>\)
```cj
public static func trace(params: Array < String >): Unit
```
输出 Trace 级别日志

参数: 

|名称|类型|描述|
|---|---|---|
|params|Array<String>|消息参数列表（首参数为标签/模块名，自动添加前缀）|

### func warnOnce\(Array<String>\)
```cj
public static func warnOnce(params: Array < String >): Unit
```
仅输出一次 Warn 级别日志

参数: 

|名称|类型|描述|
|---|---|---|
|params|Array<String>|消息参数列表|

### func warn\(Array<String>\)
```cj
public static func warn(params: Array < String >): Unit
```
输出 Warn 级别日志

参数: 

|名称|类型|描述|
|---|---|---|
|params|Array<String>|消息参数列表（首参数为标签/模块名，自动添加前缀）|

