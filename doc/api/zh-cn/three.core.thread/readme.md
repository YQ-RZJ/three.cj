# 包 three.core.thread 

## API列表

### 函数
|  名称   | 描述  |
|  ----  | ----  |
|[getCurrentThreadId()](./函数.md#func-getcurrentthreadid)|获取当前线程 ID（调用者线程）|
|[sleepNS(UInt64)](./函数.md#func-sleepnsuint64)|延时指定纳秒数|
|[sleep(UInt32)](./函数.md#func-sleepuint32)|延时指定毫秒数|

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[Condition](./类/Condition.md#class-condition)|条件变量|
|[FrameFence](./类/FrameFence.md#class-framefence)|帧栅栏：提交者记忆序号，消费者推进完成序号，等待者按序号等待|
|[Mutex](./类/Mutex.md#class-mutex)|互斥锁|
|[RWLock](./类/RWLock.md#class-rwlock)|读写锁（多读者单写者）|
|[RecursiveMutex](./类/RecursiveMutex.md#class-recursivemutex)|可重入互斥锁|
|[SPSCQueue<T>](./类/SPSCQueue.md#class-spscqueue-t-)|单生产者单消费者无锁定长队列|
|[SThread<T>](./类/SThread.md#class-sthread-t-)|系统线程类|
|[Semaphore](./类/Semaphore.md#class-semaphore)|信号量|

### 枚举
|  名称   | 描述  |
|  ----  | ----  |
|[ThreadPriority](./枚举/ThreadPriority.md#enum-threadpriority)|线程优先级（对应 SDL_ThreadPriority）|

