# 接口
## interface IReleasable
```cj
public interface IReleasable
```
可释放资源接口

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>实现要求：
1. release() 必须幂等——重复调用应直接返回 false，不得二次释放句柄；
2. release() 后 releasable 应返回 false；
3. 释放动作应能在终结器上下文中安全执行（不依赖调用线程）。
配合 Safe<T> 使用可实现"主动释放 + GC 兜底"双保险。</p>

### func release\(\)
```cj
func release(): Bool
```
主动释放资源

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>实现必须幂等：重复调用安全，不得二次释放底层句柄</p>

返回: 

- 本次调用真正执行了释放时返回 true；资源此前已释放（幂等命中）返回 false

### prop releasable: Bool
```cj
prop releasable: Bool
```
资源当前是否可释放（未被释放且仍持有底层资源）

