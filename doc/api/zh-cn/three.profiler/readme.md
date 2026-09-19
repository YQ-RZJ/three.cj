# 包 three.profiler 

## API列表

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[FiberScope](./类/FiberScope.md#class-fiberscope)|纤维作用域 — try/finally 或宏包裹纤维主体|
|[Gpu](./类/Gpu.md#class-gpu)|GPU 时间域 — GPU 上下文注册与 zone 时间戳上报|
|[Lock](./类/Lock.md#class-lock)|锁竞争跟踪 — lockable/shared-lockable 上下文的登记与事件|
|[ProfFiber](./类/ProfFiber.md#class-proffiber)|纤维标记 — 自定义调度器/协程切换时告知 Tracy 当前执行流|
|[ProfFrame](./类/ProfFrame.md#class-profframe)|帧标记 — 主帧/命名帧的 start/finish|
|[ProfGpuZone](./类/ProfGpuZone.md#class-profgpuzone)|GPU zone 作用域 — try/finally 或宏包裹 GPU 命令区间|
|[ProfLockZone](./类/ProfLockZone.md#class-proflockzone)|锁跟踪作用域 — 登记 lockable 上下文并在退出时上报 unlock|
|[ProfMemory](./类/ProfMemory.md#class-profmemory)|内存事件 — 手动标注分配/释放（Tracy 内存曲线与泄漏视图）|
|[ProfMessage](./类/ProfMessage.md#class-profmessage)|消息 — Tracy 消息面板的运行时文本（区别于编译期日志）|
|[ProfPlot](./类/ProfPlot.md#class-profplot)|Plot 曲线 — 随时间绘制的数值曲线（FPS/内存/队列深度等）|
|[ProfZone](./类/ProfZone.md#class-profzone)|Zone 区间控制器 — 一次构造/close 对应 Tracy 一个耗时区间|
|[ProfilerState](./类/ProfilerState.md#class-profilerstate)|状态查询 — 连接状态/时钟/线程名|
|[Sampling](./类/Sampling.md#class-sampling)|采样剖析 — 调用栈采样的启停控制|

