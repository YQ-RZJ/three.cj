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

### func getBufSize\(\)
```cj
public func getBufSize(): Int32
```
缓冲容量（含 '\0' 存储位，只读）

### func getBufTextLen\(\)
```cj
public func getBufTextLen(): Int32
```
文本长度（不含 '\0'）

### func getBufText\(\)
```cj
public func getBufText(): String
```
读取缓冲区当前内容为仓颉字符串

返回: 

- 缓冲区文本（缓冲为空时为空字符串）

### func getCursorPos\(\)
```cj
public func getCursorPos(): Int32
```
光标位置

### func getEventChar\(\)
```cj
public func getEventChar(): UInt16
```
输入字符（[CharFilter] 可读写：替换字符或置 0 丢弃）

### func getEventFlag\(\)
```cj
public func getEventFlag(): Int32
```
回调事件类型（ImGuiInputTextFlags_Callback*，只读）

### func getEventKey\(\)
```cj
public func getEventKey(): Int32
```
事件键（ImGuiKey，只读）

### func getSelectionEnd\(\)
```cj
public func getSelectionEnd(): Int32
```
选区终点

### func getSelectionStart\(\)
```cj
public func getSelectionStart(): Int32
```
选区起点（== selectionEnd 时无选区）

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

### func setCursorPos\(Int32\)
```cj
public func setCursorPos(pos: Int32): Unit
```
设置光标位置

参数: 

|名称|类型|描述|
|---|---|---|
|pos|Int32|光标位置|

### func setEventChar\(UInt16\)
```cj
public func setEventChar(c: UInt16): Unit
```
设置输入字符（置 0 表示丢弃该字符）

参数: 

|名称|类型|描述|
|---|---|---|
|c|UInt16|新字符|

### func setSelectionRange\(Int32,Int32\)
```cj
public func setSelectionRange(start: Int32, end_: Int32): Unit
```
设置选区（同时移动光标到终点）

参数: 

|名称|类型|描述|
|---|---|---|
|start|Int32|起点|
|end_|Int32|终点|

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

