# 类
## class SPSCQueue < T >
```cj
public class SPSCQueue < T >
```
单生产者单消费者无锁定长队列

### func init\(Int64\)
```cj
public init(capacity!: Int64 = 1024)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|capacity|Int64|槽位数（<=0 时默认 1024）。建议选择不小于单帧最大命令数|

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
是否为空（近似：两次原子读可能不同步，仅供诊断）

返回: 

- 是否为空

### func pop\(\)
```cj
public func pop():?T
```
出队

返回: 

- 队首元素；队列为空返回 null

### func push\(T\)
```cj
public func push(v: T): Bool
```
入队

参数: 

|名称|类型|描述|
|---|---|---|
|v|T|元素|

返回: 

- true 入队成功；false 队列已满（调用方需重试或策略决断）

### func size\(\)
```cj
public func size(): Int64
```
当前元素数量（近似值，仅诊断用）

返回: 

- 近似元素数量

### prop capacity: Int64
```cj
public prop capacity: Int64
```
固定容量（槽位数）

