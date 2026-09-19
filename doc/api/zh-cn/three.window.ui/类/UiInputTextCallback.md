# 类
## class UiInputTextCallback
```cj
public class UiInputTextCallback
```
输入文本回调数据包装器

### func clearSelection\(\)
```cj
public func clearSelection(): Unit
```
清除选区

### func deleteChars\(Int32,Int32\)
```cj
public func deleteChars(pos: Int32, bytesCount: Int32): Unit
```
删除指定范围的字符

参数: 

|名称|类型|描述|
|---|---|---|
|pos|Int32|起始位置|
|bytesCount|Int32|删除的字节数|

### func hasSelection\(\)
```cj
public func hasSelection(): Bool
```
是否有选中文本

### func init\(VoidPtr\)
```cj
public init(dataPtr: VoidPtr)
```
使用底层回调数据指针构造包装器

参数: 

|名称|类型|描述|
|---|---|---|
|dataPtr|VoidPtr|底层 ImGuiInputTextCallbackData 指针|

### func insertChars\(Int32,String\)
```cj
public func insertChars(pos: Int32, text: String): Unit
```
在指定位置插入文本

参数: 

|名称|类型|描述|
|---|---|---|
|pos|Int32|插入位置|
|text|String|要插入的文本|

### func isValid\(\)
```cj
public func isValid(): Bool
```
底层指针是否有效

### func selectAll\(\)
```cj
public func selectAll(): Unit
```
全选文本

### func setSelection\(Int32,Int32\)
```cj
public func setSelection(start: Int32, end_: Int32): Unit
```
设置选区范围

参数: 

|名称|类型|描述|
|---|---|---|
|start|Int32|起始位置|
|end_|Int32|结束位置|

