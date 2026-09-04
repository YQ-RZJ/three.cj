# Class
## class LoaderUtils
```cj
public class LoaderUtils
```
Loader utility class

### func extractUrlBase\(String\)
```cj
public static func extractUrlBase(url: String): String
```
Extract base path from URL

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Input URL|

Return: 

- Base path

### func resolveURL\(String,String\)
```cj
public static func resolveURL(url: String, path: String): String
```
Resolve relative URL to a given path

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|URL to resolvepath Base path for relative URLs|
|path|String||

Return: 

- Resolved URL

