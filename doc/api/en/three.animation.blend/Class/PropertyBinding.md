# Class
## class PropertyBinding
```cj
public class PropertyBinding
```
Property binding that associates an animation track's property path with an actual object property

### func bind\(\)
```cj
public func bind(): Unit
```
Creates getter/setter pairs and binds the property tracked by this binding

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>After binding, getValue/setValue are swapped to their bound versions; they
become no-ops when the property is not found.</p>

### func create\(IPropertyBindingRoot,String,HashMap<String,Any>\)
```cj
public static func create(root: IPropertyBindingRoot, path: String, parsedPath: HashMap < String, Any >): Any
```
Creates a property binding instance; returns a Composite instance if the root is an AnimationObjectGroup

Parameter: 

|Name|Type|Describe|
|---|---|---|
|root|IPropertyBindingRoot|The root objectpath The property pathparsedPath The parsed path information|
|path|String||
|parsedPath|HashMap<String,Any>||

Return: 

- Returns the created binding (PropertyBinding or Composite)

### func findNode\(IPropertyBindingRoot,String\)
```cj
public static func findNode(root: IPropertyBindingRoot, nodeName: String): Option < IPropertyBindingRoot >
```
Searches the root object's hierarchy for a node with the given name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|root|IPropertyBindingRoot|The root objectnodeName The node name|
|nodeName|String||

Return: 

- Returns the found node, or None if not found

### func getValue\(Array<Float64>,Int64\)
```cj
public func getValue(array: Array < Float64 >, offset: Int64): Unit
```
Gets the value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|The target arrayoffset The write offset|
|offset|Int64||

### func init\(IPropertyBindingRoot,String,HashMap<String,Any>\)
```cj
public init(rootNode: IPropertyBindingRoot, path: String, parsedPath: HashMap < String, Any >)
```
Creates a property binding instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rootNode|IPropertyBindingRoot|The root nodepath The property pathparsedPath The parsed path information|
|path|String||
|parsedPath|HashMap<String,Any>||

### func parseTrackName\(String\)
```cj
public static func parseTrackName(trackName: String): HashMap < String, Any >
```
Parses a track name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|trackName|String|The track name|

Return: 

- Returns a map containing nodeName/objectName/objectIndex/propertyName/propertyIndex

Exception: 

- Exception When the track name cannot be parsed or the property name is missing

### func sanitizeNodeName\(String\)
```cj
public static func sanitizeNodeName(name: String): String
```
Sanitizes a node name by replacing whitespace with underscores and removing reserved characters

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|The node name|

Return: 

- Returns the sanitized node name

### func setValue\(Array<Float64>,Int64\)
```cj
public func setValue(array: Array < Float64 >, offset: Int64): Unit
```
Sets the value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|The source arrayoffset The read offset|
|offset|Int64||

### func unbind\(\)
```cj
public func unbind(): Unit
```
Unbinds the property and restores the unbound state

### var node
```cj
public var node: IPropertyBindingRoot
```
The object that owns the animated property

### var parsedPath
```cj
public var parsedPath: HashMap < String, Any >
```
The parsed path information

### var path
```cj
public var path: String
```
The property path

### var propertyIndex
```cj
public var propertyIndex: Option < Any >
```
The property index (may be updated after binding)

### var propertyName
```cj
public var propertyName: String
```
The property name (may be updated after binding)

### var resolvedObject
```cj
public var resolvedObject: Option < Any >
```
The resolved object (set after binding)

### var resolvedProperty
```cj
public var resolvedProperty: Option < Any >
```
The resolved property (set after binding)

### var rootNode
```cj
public var rootNode: IPropertyBindingRoot
```
The root node

### var targetObject
```cj
public var targetObject: Option < IPropertyBindingRoot >
```
The target object (set after binding)

