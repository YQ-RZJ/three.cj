# 类
## class UiListClipper
```cj
public class UiListClipper
```
虚拟列表裁剪器，用于高性能渲染大型列表（仅绘制可见项）

### func begin\(Int32,Float32\)
```cj
public func begin(itemsCount: Int32, itemsHeight!: Float32 = - 1.0f32): Unit
```
开始裁剪

参数: 

|名称|类型|描述|
|---|---|---|
|itemsCount|Int32|总项目数|
|itemsHeight|Float32|每项高度（-1.0=自动）|

### func destroy\(\)
```cj
public func destroy(): Unit
```
销毁裁剪器并释放底层资源

### func end\(\)
```cj
public func end(): Unit
```
结束裁剪

### func getDisplayEnd\(\)
```cj
public func getDisplayEnd(): Int32
```
获取当前批次结束索引

返回: 

- 当前批次结束索引

### func getDisplayStart\(\)
```cj
public func getDisplayStart(): Int32
```
获取当前批次起始索引

返回: 

- 当前批次起始索引

### func init\(\)
```cj
public init()
```
构造虚拟列表裁剪器

### func step\(\)
```cj
public func step(): Bool
```
步进到下一批可见项

返回: 

- 是否还有可见项

