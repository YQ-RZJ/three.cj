# 包 three.network.transport 

## API列表

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[Connection](./类/Connection.md#class-connection)|TCP 游戏连接|
|[ReliableChannel](./类/ReliableChannel.md#class-reliablechannel)|可靠 UDP 通道|

### 变量与常量
|  名称   | 描述  |
|  ----  | ----  |
|[FRAME_DATA](./变量与常量.md#const-frame_data)|数据帧（载荷上抛 onMessage）|
|[FRAME_PING](./变量与常量.md#const-frame_ping)|心跳帧（保活探测）|
|[FRAME_PONG](./变量与常量.md#const-frame_pong)|心跳应答帧|
|[MAX_FRAME_SIZE](./变量与常量.md#const-max_frame_size)|单帧最大字节数（帧长字段校验上限，防恶意长度声明炸内存；默认 8MB）|
|[RELIABLE_ACK_SEQ](./变量与常量.md#const-reliable_ack_seq)|纯 ack 帧的 seq 标记（不承载载荷，接收端跳过数据派发）|
|[RELIABLE_HEADER_SIZE](./变量与常量.md#const-reliable_header_size)|可靠包头部字节数（seq + ack + ackBits，各 4 字节大端）|
|[RELIABLE_MAX_PAYLOAD](./变量与常量.md#const-reliable_max_payload)|单个可靠包载荷上限（保守取以太网友好的 1200 字节，避免 IP 分片；|

