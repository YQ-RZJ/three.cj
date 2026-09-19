# 包 three.profiler.macros 

## API列表

### 宏
|  名称   | 描述  |
|  ----  | ----  |
|[Fiber(Tokens, Tokens)](./宏.md#macro-fibertokens-tokens)|`|
|[FrameEnd(Tokens, Tokens)](./宏.md#macro-frameendtokens-tokens)||
|[FrameMark(Tokens, Tokens)](./宏.md#macro-framemarktokens-tokens)|`|
|[FrameStart(Tokens, Tokens)](./宏.md#macro-framestarttokens-tokens)||
|[GpuZone(Tokens, Tokens)](./宏.md#macro-gpuzonetokens-tokens)|`|
|[LockTrack(Tokens, Tokens)](./宏.md#macro-locktracktokens-tokens)|`|
|[MemAlloc(Tokens, Tokens)](./宏.md#macro-memalloctokens-tokens)|`let p =|
|[MemFree(Tokens, Tokens)](./宏.md#macro-memfreetokens-tokens)||
|[Message(Tokens, Tokens)](./宏.md#macro-messagetokens-tokens)|`let s =|
|[PlotI64(Tokens, Tokens)](./宏.md#macro-ploti64tokens-tokens)||
|[Plot(Tokens, Tokens)](./宏.md#macro-plottokens-tokens)|`let fps =|
|[Zone(Tokens, Tokens)](./宏.md#macro-zonetokens-tokens)|双形态： 1. 函数级：`@Zone[链路] func f(): Unit {...}` → 函数体重写为 try{}finally{} 包裹的 zone（异常/return 都正确结束计时）； 2. 区间级：`|

