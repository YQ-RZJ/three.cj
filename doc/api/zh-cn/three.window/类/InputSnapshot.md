# 类
## class InputSnapshot
```cj
public class InputSnapshot
```
每循环固定窗口快照

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>仅窗口泵线程读写（分发器只写事件队列），无需锁。</p>

### func init\(\)
```cj
public init()
```
构造空快照

