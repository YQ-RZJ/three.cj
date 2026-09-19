# Package three.profiler 

## API List

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[FiberScope](./Class/FiberScope.md#class-fiberscope)|Fiber scope — wraps a fiber body; enter on construction, leave on close (strictly paired).|
|[Gpu](./Class/Gpu.md#class-gpu)|GPU timing domain — context registration and timestamp reporting|
|[Lock](./Class/Lock.md#class-lock)|Lock contention tracking — lockable/shared-lockable contexts|
|[ProfFiber](./Class/ProfFiber.md#class-proffiber)|Fiber marks — logical execution flow for custom schedulers|
|[ProfFrame](./Class/ProfFrame.md#class-profframe)|Frame marks — main/named frame boundaries|
|[ProfGpuZone](./Class/ProfGpuZone.md#class-profgpuzone)|GPU zone scope — wraps GPU command recording|
|[ProfLockZone](./Class/ProfLockZone.md#class-proflockzone)|Lock-tracking scope — announces a lockable context and reports unlock on exit. Scope-lock semantics: enter = held, close = afterUnlock.|
|[ProfMemory](./Class/ProfMemory.md#class-profmemory)|Memory events — manual alloc/free annotations|
|[ProfMessage](./Class/ProfMessage.md#class-profmessage)|Messages — runtime text in the Tracy message panel|
|[ProfPlot](./Class/ProfPlot.md#class-profplot)|Plots — time-series value curves (FPS, memory, queue depth, ...)|
|[ProfZone](./Class/ProfZone.md#class-profzone)|Zone scope controller — one construction/close pair is one Tracy timing zone|
|[ProfilerState](./Class/ProfilerState.md#class-profilerstate)|State queries — connection status, clock, thread name.|
|[Sampling](./Class/Sampling.md#class-sampling)|Sampling — start/stop control of call-stack sampling.|

