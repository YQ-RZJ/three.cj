# Class
## class ProfMessage
```cj
public class ProfMessage
```
Messages — runtime text in the Tracy message panel

### func appInfo\(String\)
```cj
public static func appInfo(txt: String): Unit
```
Application info (shown once next to the profiler window title)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|txt|String||

### func logDebug\(String\)
```cj
public static func logDebug(txt: String): Unit
```
Send a Debug-level message (

Parameter: 

|Name|Type|Describe|
|---|---|---|
|txt|String||

### func logError\(String\)
```cj
public static func logError(txt: String): Unit
```
Send an Error-level message (

Parameter: 

|Name|Type|Describe|
|---|---|---|
|txt|String||

### func logFatal\(String\)
```cj
public static func logFatal(txt: String): Unit
```
Send a Fatal-level message (

Parameter: 

|Name|Type|Describe|
|---|---|---|
|txt|String||

### func logInfo\(String\)
```cj
public static func logInfo(txt: String): Unit
```
Send an Info-level message (

Parameter: 

|Name|Type|Describe|
|---|---|---|
|txt|String||

### func logTrace\(String\)
```cj
public static func logTrace(txt: String): Unit
```
Send a Trace-level message (

Parameter: 

|Name|Type|Describe|
|---|---|---|
|txt|String||

### func logWarning\(String\)
```cj
public static func logWarning(txt: String): Unit
```
Send a Warning-level message (

Parameter: 

|Name|Type|Describe|
|---|---|---|
|txt|String||

### func log\(String,TracyMessageSeverity\)
```cj
public static func log(txt: String, severity: TracyMessageSeverity): Unit
```
Send a message (full severity/color form)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|txt|String||
|severity|TracyMessageSeverity||

