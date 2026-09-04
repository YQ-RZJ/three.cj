# Class
## class LoadingManager
```cj
public class LoadingManager
```
Loading manager that tracks loaded items and provides callbacks

### func addHandler\(String,Loader\)
```cj
public func addHandler(regex: String, loader: Loader): LoadingManager
```
Add a regex-matched handler

Parameter: 

|Name|Type|Describe|
|---|---|---|
|regex|String|Regex patternloader Corresponding loader|
|loader|Loader||

Return: 

- Self reference

### func getHandler\(String\)
```cj
public func getHandler(file: String): Option < Loader >
```
Find matching handler loader by file name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|file|String|File name|

Return: 

- Matched loader (returns None if no match)

### func init\(Option<\(\)\->Unit>,Option<\(String,Int64,Int64\)\->Unit>,Option<\(String\)\->Unit>\)
```cj
public init(onLoad!: Option <() -> Unit >= None, onProgress!: Option <(String, Int64, Int64) -> Unit >= None, onError!: Option <(String) -> Unit >= None)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|onLoad|Option<()->Unit>||
|onProgress|Option<(String,Int64,Int64)->Unit>||
|onError|Option<(String)->Unit>||

### func itemEnd\(String\)
```cj
public func itemEnd(url: String): Unit
```
Mark an item as finished loading

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Item URL|

### func itemError\(String\)
```cj
public func itemError(url: String): Unit
```
Mark an item as having a load error

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Item URL|

### func itemStart\(String\)
```cj
public func itemStart(url: String): Unit
```
Mark an item as started loading

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Item URL|

### func resolveURL\(String\)
```cj
public func resolveURL(url: String): String
```
Resolve URL through the URL modifier

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Original URL|

Return: 

- Modified URL

### func setURLModifier\(\(String\)\->String\)
```cj
public func setURLModifier(transform:(String) -> String): LoadingManager
```
Set the URL modifier

Parameter: 

|Name|Type|Describe|
|---|---|---|
|transform|(String)->String|URL modifier function|

Return: 

- Self reference

### var onError
```cj
public var onError: Option <(String) -> Unit >
```
Load error callback

### var onLoad
```cj
public var onLoad: Option <() -> Unit >
```
All loads complete callback

### var onProgress
```cj
public var onProgress: Option <(String, Int64, Int64) -> Unit >
```
Load progress callback

### var onStart
```cj
public var onStart: Option <(String, Int64, Int64) -> Unit >
```
Load start callback

