# 类
## class PropertyBinding
```cj
public class PropertyBinding
```
属性绑定，将动画轨道的属性路径与实际对象属性关联

### func bind\(\)
```cj
public func bind(): Unit
```
创建 getter/setter 对，绑定此绑定跟踪的属性

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>绑定后 getValue/setValue 会被替换为绑定状态的版本；属性未找到时变为空操作。</p>

### func create\(IPropertyBindingRoot,String,HashMap<String,Any>\)
```cj
public static func create(root: IPropertyBindingRoot, path: String, parsedPath: HashMap < String, Any >): Any
```
创建属性绑定实例；如果根是 AnimationObjectGroup，则返回 Composite 实例

参数: 

|名称|类型|描述|
|---|---|---|
|root|IPropertyBindingRoot|根对象path 属性路径parsedPath 已解析的路径信息|
|path|String||
|parsedPath|HashMap<String,Any>||

返回: 

- 返回创建的绑定（PropertyBinding 或 Composite）

### func findNode\(IPropertyBindingRoot,String\)
```cj
public static func findNode(root: IPropertyBindingRoot, nodeName: String): Option < IPropertyBindingRoot >
```
在根对象的层级中搜索指定名称的节点

参数: 

|名称|类型|描述|
|---|---|---|
|root|IPropertyBindingRoot|根对象nodeName 节点名称|
|nodeName|String||

返回: 

- 返回找到的节点；未找到返回 None

### func getValue\(Array<Float64>,Int64\)
```cj
public func getValue(array: Array < Float64 >, offset: Int64): Unit
```
获取值

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|目标数组offset 写入偏移|
|offset|Int64||

### func init\(IPropertyBindingRoot,String,HashMap<String,Any>\)
```cj
public init(rootNode: IPropertyBindingRoot, path: String, parsedPath: HashMap < String, Any >)
```
创建属性绑定实例

参数: 

|名称|类型|描述|
|---|---|---|
|rootNode|IPropertyBindingRoot|根节点path 属性路径parsedPath 已解析的路径信息|
|path|String||
|parsedPath|HashMap<String,Any>||

### func parseTrackName\(String\)
```cj
public static func parseTrackName(trackName: String): HashMap < String, Any >
```
解析轨道名称

参数: 

|名称|类型|描述|
|---|---|---|
|trackName|String|轨道名称|

返回: 

- 返回包含 nodeName/objectName/objectIndex/propertyName/propertyIndex 的映射

异常: 

- Exception 当轨道名称无法解析或缺少属性名时

### func sanitizeNodeName\(String\)
```cj
public static func sanitizeNodeName(name: String): String
```
清理节点名称：将空白替换为下划线，移除保留字符

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|节点名称|

返回: 

- 返回清理后的节点名称

### func setValue\(Array<Float64>,Int64\)
```cj
public func setValue(array: Array < Float64 >, offset: Int64): Unit
```
设置值

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|源数组offset 读取偏移|
|offset|Int64||

### func unbind\(\)
```cj
public func unbind(): Unit
```
解绑属性，恢复到未绑定状态

### var node
```cj
public var node: IPropertyBindingRoot
```
拥有动画属性的对象

### var parsedPath
```cj
public var parsedPath: HashMap < String, Any >
```
解析后的路径信息

### var path
```cj
public var path: String
```
属性路径

### var propertyIndex
```cj
public var propertyIndex: Option < Any >
```
属性索引（bind 后可能更新）

### var propertyName
```cj
public var propertyName: String
```
属性名（bind 后可能更新）

### var resolvedObject
```cj
public var resolvedObject: Option < Any >
```
已解析的对象（bind 后设置）

### var resolvedProperty
```cj
public var resolvedProperty: Option < Any >
```
已解析的属性（bind 后设置）

### var rootNode
```cj
public var rootNode: IPropertyBindingRoot
```
根节点

### var targetObject
```cj
public var targetObject: Option < IPropertyBindingRoot >
```
目标对象（bind 后设置）

