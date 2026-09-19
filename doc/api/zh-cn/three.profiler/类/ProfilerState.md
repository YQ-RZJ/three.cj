# 类
## class ProfilerState
```cj
public class ProfilerState
```
状态查询 — 连接状态/时钟/线程名

### func isConnected\(\)
```cj
public static func isConnected(): Bool
```
profiler GUI 是否已连接

### func now\(\)
```cj
public static func now(): Int64
```
Tracy 高精度时钟当前值

### func threadName\(String\)
```cj
public static func threadName(name: String): Unit
```
设置当前线程显示名（Tracy 线程面板）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

