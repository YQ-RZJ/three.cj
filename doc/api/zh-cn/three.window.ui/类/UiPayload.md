# 类
## class UiPayload
```cj
public class UiPayload
```
拖放载荷包装器

### func clear\(\)
```cj
public func clear(): Unit
```
清空载荷数据

### func getCurrentPayload\(\)
```cj
public static func getCurrentPayload(): UiPayload
```
获取当前活跃的拖放载荷（在 BeginDragDropTarget/EndDragDropTarget 内调用）

### func init\(VoidPtr\)
```cj
public init(payloadPtr: VoidPtr)
```
使用底层载荷指针构造包装器

参数: 

|名称|类型|描述|
|---|---|---|
|payloadPtr|VoidPtr|底层 ImGuiPayload 指针|

### func isDataType\(String\)
```cj
public func isDataType(dataType: String): Bool
```
载荷数据类型是否匹配

参数: 

|名称|类型|描述|
|---|---|---|
|dataType|String|数据类型字符串（如 "MY_TYPE"）|

返回: 

- 是否匹配

### func isDelivery\(\)
```cj
public func isDelivery(): Bool
```
是否为交付状态（释放完成）

### func isPreview\(\)
```cj
public func isPreview(): Bool
```
是否为预览状态（拖拽过程中悬停在目标上）

### func isValid\(\)
```cj
public func isValid(): Bool
```
载荷是否有效

