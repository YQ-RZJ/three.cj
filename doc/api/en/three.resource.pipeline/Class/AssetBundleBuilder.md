# Class
## class AssetBundleBuilder
```cj
public class AssetBundleBuilder
```
Asset bundle builder

### func addFile\(String,String\)
```cj
public func addFile(name: String, path: String): Option < AssetBundleBuilder >
```
Adds one entry from a local file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Entry namepath Local file path|
|path|String||

Return: 

- Self reference on success; None when reading fails (entry not added)

### func add\(String,Array<UInt8>\)
```cj
public func add(name: String, bytes: Array < UInt8 >): AssetBundleBuilder
```
Adds one entry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Entry name (unique in archive; re-adding overwrites)bytes Entry bytes|
|bytes|Array<UInt8>||

Return: 

- Self reference (for chaining)

### func build\(\)
```cj
public func build(): Array < UInt8 >
```
Builds the archive bytes

Return: 

- Full archive bytes (feed directly to AssetBundle.loadFromBytes)

### func init\(\)
```cj
public init()
```


### func writeTo\(String\)
```cj
public func writeTo(path: String): Bool
```
Builds the archive and writes it to a local file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|path|String|Output file path|

Return: 

- True on success

