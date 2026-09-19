# 类
## class ProfZone
```cj
public class ProfZone <: Resource
```
Zone 区间控制器 — 一次构造/close 对应 Tracy 一个耗时区间

### func close\(\)
```cj
public func close(): Unit
```
结束 zone（幂等：重复调用/未激活均安全；
try-with-resources 自动调用）

### func color\(UInt32\)
```cj
public func color(c: UInt32): Unit
```
覆盖 zone 颜色（0xAABBGGRR）

参数: 

|名称|类型|描述|
|---|---|---|
|c|UInt32||

### func init\(String,String,UInt32,String\)
```cj
public init(name: String, file: String, line: UInt32, function: String)
```
开始一个命名 zone（手动 RAII 用法的入口，无颜色）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|file|String||
|line|UInt32||
|function|String||

### func init\(String,UInt32,String,UInt32,String\)
```cj
public init(name: String, color: UInt32, file: String, line: UInt32, function: String)
```
开始一个命名 zone（带颜色 0xAABBGGRR；0 = Tracy 默认配色）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|color|UInt32||
|file|String||
|line|UInt32||
|function|String||

### func init\(String,UInt32,String,UInt32\)
```cj
public init(name: String, color: UInt32, file: String, line: UInt32)
```
开始一个命名 zone（无函数名版本，宏表达式形态用；
函数名一栏以 zone 名兜底）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|color|UInt32||
|file|String||
|line|UInt32||

### func isClosed\(\)
```cj
public func isClosed(): Bool
```
Resource.isClosed：zone 已结束/未激活即视为已关闭

### func rename\(String\)
```cj
public func rename(txt: String): Unit
```
重命名 zone（覆盖源位置默认名）

参数: 

|名称|类型|描述|
|---|---|---|
|txt|String||

### func text\(String\)
```cj
public func text(txt: String): Unit
```
附加文本说明（Tracy zone 面板显示）

参数: 

|名称|类型|描述|
|---|---|---|
|txt|String||

### func value\(UInt64\)
```cj
public func value(v: UInt64): Unit
```
附加数值（zone 面板 mini 图，如顶点数/批次数）

参数: 

|名称|类型|描述|
|---|---|---|
|v|UInt64||

### prop active: Bool
```cj
public prop active: Bool
```
本 zone 是否真正开始记录

