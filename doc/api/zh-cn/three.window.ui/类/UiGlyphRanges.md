# 类
## class UiGlyphRanges
```cj
public class UiGlyphRanges
```
字形范围（Unicode 区间数组）安全包装

### func finalize\(\)
```cj
public func finalize(): Unit
```
释放自建范围占用的堆内存（标准静态范围无操作）

### func init\(\)
```cj
public init()
```
创建空范围（等价 NULL，AddFont* 将回退到默认范围）

### func isNull\(\)
```cj
public func isNull(): Bool
```
是否为空范围

返回: 

- 为空返回 true

