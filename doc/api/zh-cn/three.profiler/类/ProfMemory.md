# 类
## class ProfMemory
```cj
public class ProfMemory
```
内存事件 — 手动标注分配/释放（Tracy 内存曲线与泄漏视图）

### func alloc\(CPointer<Unit>,UIntNative,String\)
```cj
public static func alloc(ptr: CPointer < Unit >, size: UIntNative, name: String): Unit
```
上报一次分配（

参数: 

|名称|类型|描述|
|---|---|---|
|ptr|CPointer<Unit>||
|size|UIntNative||
|name|String||

### func discard\(String\)
```cj
public static func discard(name: String): Unit
```
按名丢弃整池（该 name 的全部已分配字节归零）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func free\(CPointer<Unit>,String\)
```cj
public static func free(ptr: CPointer < Unit >, name: String): Unit
```
上报一次释放（

参数: 

|名称|类型|描述|
|---|---|---|
|ptr|CPointer<Unit>||
|name|String||

