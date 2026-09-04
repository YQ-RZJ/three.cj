# Package three.core.thread 

## API List

### Function
|  Name   | Describe  |
|  ----  | ----  |
|[getCurrentThreadId()](./Function.md#func-getcurrentthreadid)|Get current thread ID (caller thread)|
|[sleepNS(UInt64)](./Function.md#func-sleepnsuint64)|Sleep for the specified number of nanoseconds|
|[sleep(UInt32)](./Function.md#func-sleepuint32)|Sleep for the specified number of milliseconds|

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[Condition](./Class/Condition.md#class-condition)|Condition variable|
|[Mutex](./Class/Mutex.md#class-mutex)|Mutex|
|[RWLock](./Class/RWLock.md#class-rwlock)|Read-write lock (multiple readers, single writer)|
|[RecursiveMutex](./Class/RecursiveMutex.md#class-recursivemutex)|Reentrant mutex|
|[SThread<T>](./Class/SThread.md#class-sthread-t-)|System thread class|
|[Semaphore](./Class/Semaphore.md#class-semaphore)|Semaphore|

### Enum
|  Name   | Describe  |
|  ----  | ----  |
|[ThreadPriority](./Enum/ThreadPriority.md#enum-threadpriority)|Thread priority (corresponds to SDL_ThreadPriority)|

