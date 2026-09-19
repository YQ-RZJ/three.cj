# 类
## class ProfFiber
```cj
public class ProfFiber
```
纤维标记 — 自定义调度器/协程切换时告知 Tracy 当前执行流

### func enter\(String\)
```cj
public static func enter(name: String): Unit
```
进入纤维

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func leave\(\)
```cj
public static func leave(): Unit
```
离开纤维

