# 类
## class Safe < T > where T <: IReleasable
```cj
public class Safe < T > <: IReleasable where T <: IReleasable
```
IReleasable 对象的安全托管包装

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>本类刻意保持非 open（仓颉语言约束：带终结器的类不可 open），
需要继承扩展时请继承被托管的资源类而非本包装。</p>

### func init\(T\)
```cj
public init(obj: T)
```
创建托管包装，接管 obj 的释放职责

参数: 

|名称|类型|描述|
|---|---|---|
|obj|T|待托管的 IReleasable 资源对象（此后其释放由本包装负责）|

### func release\(\)
```cj
public func release(): Bool
```
主动释放被托管资源（幂等）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>主动释放后终结器兜底不再重复执行；释放后请勿再经 value 使用资源
（可用 releasable 判断）。</p>

返回: 

- 本次调用真正执行了释放返回 true；此前已释放（手动或兜底）返回 false

### prop releasable: Bool
```cj
public prop releasable: Bool
```
被托管资源当前是否可释放

### let value
```cj
public let value: T
```
被安全接管的资源对象实例

