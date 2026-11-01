# -*- coding: utf-8 -*-
"""无 GUI 的 Tracy 协议接收端。

被测进程静态链接 libtracyc.a，本身就是 Tracy 服务端并监听 TCP；本脚本扮演
Tracy GUI/Worker 的角色主动连接，完整落盘原始流、解压流、结构化事件与统计结果。

用法：
    python scripts/tracy_receiver.py --out captures/run1
    python scripts/tracy_receiver.py --out captures/run1 --port 8086 --max-seconds 120
    python scripts/tracy_receiver.py --self-test          # 离线路自测，无需被测进程

产物（--out 目录）：
    raw_stream.bin          线上原始流，逐块写入 [uint32 size][compressed bytes]
    decompressed_stream.bin LZ4 流式解压后的连续队列流
    events.jsonl            结构化事件（zone / plot / frame / message）
    metadata.json           握手、Welcome、协议版本、源码位置与名称缓存
    stats.json              热点统计：调用次数 / 耗时 / 均值 / P50 / P95 / P99

协议事实来源（上游源码，已逐项核对）：
    tracy/public/common/TracyProtocol.hpp / TracyQueue.hpp
    tracy/public/client/TracyProfiler.cpp/.hpp
    tracy/server/TracyWorker.cpp

要点：
    握手   -> 接收端先发 "TracyPrf" + uint32(82)，再读 1 字节 HandshakeStatus，再读 1170 字节 WelcomeMessage
    数据块 -> uint32 compressedSize + compressed bytes（LZ4 有状态流，跨块共享 64KiB 字典）
    时间   -> 客户端把 TSC 差值写盘：
                64 位事件：wire = delta - ProtocolOffset32Bit（仅 delta>=0 时），解码时若 wire>=0 加回
                32 位事件：wire = delta - ProtocolOffset16Bit，解码时 + ProtocolOffset16Bit
                16 位事件：wire = delta 原样
                ZoneBeginAllocSrcLoc / PlotData*：wire = delta 原样（不加偏移）
                Message* / MessageLiteral* / FrameMark*：wire 为绝对 TSC
              最终纳秒 = (ref - welcome.initBegin) * welcome.timerMul
    文本   -> SingleStringData = uint16 sz(+256) + 文本；SingleStringData8 = uint8 sz + 文本。
              文本事件本身不携带内容：ZoneText/ZoneName/Message*/MessageAppInfo 消费"前一条" pending single string。
"""

import argparse
import json
import os
import socket
import struct
import sys
import threading
import time
from collections import defaultdict, deque

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from tracy_queue_table import (  # noqa: E402
    NUM_TYPES,
    PROTOCOL_VERSION,
    QUEUE_DATA_SIZE,
    QUEUE_TYPE_ORDER,
    STRING_LEN_BIAS,
    STRING_LEN_KIND,
    STRING_LEN_OFFSET,
    STRING_TYPES,
)

# ---------------------------------------------------------------- 常量

HANDSHAKE_SHIBBOLETH = b"TracyPrf"
HANDSHAKE_STATUS = {
    0: "Pending",
    1: "Welcome",
    2: "ProtocolMismatch",
    3: "NotAvailable",
    4: "Dropped",
}
WELCOME_SIZE = 1170
WELCOME_PROGRAM_NAME_SIZE = 64
WELCOME_HOST_INFO_SIZE = 1024

TARGET_FRAME_SIZE = 256 * 1024
DICT_LIMIT = 64 * 1024
MAX_INFLIGHT_QUERIES = 16
MAX_FRAME_DURATION_NS = 10_000_000_000  # 单帧 10s 上限，用于过滤脏数据

# 客户端写盘时使用的协议偏移（TracyProfiler.cpp Dequeue/DequeueSerial）
PROTOCOL_OFFSET_16_BIT = 1 << 16
PROTOCOL_OFFSET_32_BIT = (1 << 16) + (1 << 32)

SERVER_QUERY_TERMINATE = 0
SERVER_QUERY_STRING = 1
SERVER_QUERY_THREAD_STRING = 2
SERVER_QUERY_SOURCE_LOCATION = 3
SERVER_QUERY_PLOT_NAME = 4
SERVER_QUERY_FRAME_NAME = 5
SERVER_QUERY_FIBER_NAME = 7

CPU_ARCH = {0: "unknown", 1: "x86", 2: "x64", 3: "arm32", 4: "arm64"}

# 按 QueueType 数值下标展开的查表，避免每事件做字典名查找
TYPE_NAME = list(QUEUE_TYPE_ORDER) + ["<invalid>"] * (NUM_TYPES + 1 - len(QUEUE_TYPE_ORDER))
TYPE_SIZE = [QUEUE_DATA_SIZE[QUEUE_TYPE_ORDER[i]] for i in range(NUM_TYPES)]
TYPE_STRING = [False] * (NUM_TYPES + 1)
TYPE_STR_OFF = [0] * (NUM_TYPES + 1)
TYPE_STR_LSIZE = [0] * (NUM_TYPES + 1)
TYPE_STR_BIAS = [0] * (NUM_TYPES + 1)
for _name in STRING_TYPES:
    _i = QUEUE_TYPE_ORDER.index(_name)
    _kind = STRING_LEN_KIND[_name]
    TYPE_STRING[_i] = True
    TYPE_STR_OFF[_i] = STRING_LEN_OFFSET[_name]
    TYPE_STR_LSIZE[_i] = {"u8": 1, "u16": 2, "u32": 4}[_kind]
    TYPE_STR_BIAS[_i] = STRING_LEN_BIAS[_name]

T = {name: QUEUE_TYPE_ORDER.index(name) for name in QUEUE_TYPE_ORDER}

# Message* 系列为"零变长"：固定大小即全部负载，文本来自 pending single string / tagged ptr。
MESSAGE_PLAIN = frozenset({T["Message"], T["MessageColor"], T["MessageCallstack"],
                           T["MessageColorCallstack"], T["MessageAppInfo"]})
MESSAGE_LITERAL = frozenset({T["MessageLiteral"], T["MessageLiteralColor"],
                             T["MessageLiteralCallstack"], T["MessageLiteralColorCallstack"]})

# 事件时间字段的类型：delta64 / delta32 / delta16 / deltaRaw(裸 delta) / abs(绝对 TSC)
TIME_DELTA64 = frozenset({T["ZoneBegin"], T["ZoneBeginCallstack"], T["ZoneEnd"]})
TIME_DELTA32 = frozenset({T["ZoneBegin32"], T["ZoneBeginCallstack32"], T["ZoneEnd32"]})
TIME_DELTA16 = frozenset({T["ZoneBegin16"], T["ZoneBeginCallstack16"], T["ZoneEnd16"]})
TIME_DELTA_RAW = frozenset({T["ZoneBeginAllocSrcLoc"], T["ZoneBeginAllocSrcLocCallstack"]})
TIME_ABS = frozenset({T["FrameMarkMsg"], T["FrameMarkMsgStart"], T["FrameMarkMsgEnd"],
                      T["Message"], T["MessageColor"], T["MessageCallstack"],
                      T["MessageColorCallstack"], T["MessageAppInfo"],
                      T["MessageLiteral"], T["MessageLiteralColor"],
                      T["MessageLiteralCallstack"], T["MessageLiteralColorCallstack"]})

# 会产生 ServerQuery 回包的应答事件（用于计算在途查询配额）
QUERY_REPLY_EVENTS = frozenset({T["StringData"], T["ThreadName"], T["PlotName"], T["FrameName"],
                                T["SourceLocation"], T["CallstackFrameSize"], T["CallstackFrame"],
                                T["SymbolInformation"], T["AckServerQueryNoop"],
                                T["AckSourceCodeNotAvailable"], T["AckSymbolCodeNotAvailable"]})


def u8(b, o):
    return b[o]


def u16(b, o):
    return b[o] | (b[o + 1] << 8)


def u32(b, o):
    return struct.unpack_from("<I", b, o)[0]


def u64(b, o):
    return struct.unpack_from("<Q", b, o)[0]


def i64(b, o):
    return struct.unpack_from("<q", b, o)[0]


def f32(b, o):
    return struct.unpack_from("<f", b, o)[0]


def f64(b, o):
    return struct.unpack_from("<d", b, o)[0]


def cstr(raw: bytes) -> str:
    return raw.split(b"\x00", 1)[0].decode("utf-8", "replace")


def percentile(sorted_vals, p):
    if not sorted_vals:
        return 0
    k = (len(sorted_vals) - 1) * p
    lo = int(k)
    hi = min(lo + 1, len(sorted_vals) - 1)
    return sorted_vals[lo] + (sorted_vals[hi] - sorted_vals[lo]) * (k - lo)


# ---------------------------------------------------------------- LZ4 流式解压


class Lz4StreamDecoder:
    """等价于 LZ4_decompress_safe_continue 的流式解码器（纯 Python，无外部依赖）。

    Tracy 客户端使用 LZ4_compress_fast_continue，跨块共享 64KiB 历史字典，
    因此每块不能当独立 LZ4 block 解压，必须保留字典状态。解码器内部维护
    buf = 上一块保留的 64KiB 字典 + 当前块输出，跨块 match 可直接引用。
    """

    def __init__(self):
        self._buf = bytearray()   # 字典(<=64KiB) + 当前块输出
        self.blocks = 0
        self.src_bytes = 0
        self.out_bytes = 0

    def decompress(self, src: bytes, max_out: int = TARGET_FRAME_SIZE) -> bytes:
        buf = self._buf
        extend = buf.extend
        base = len(buf)
        i = 0
        n = len(src)
        self.blocks += 1
        self.src_bytes += n

        while i < n:
            token = src[i]
            i += 1
            lit = token >> 4
            if lit == 15:
                while True:
                    b = src[i]
                    i += 1
                    lit += b
                    if b != 255:
                        break
            if i + lit > n:
                raise ValueError("lz4: literal overrun at %d" % i)
            if lit:
                extend(src[i:i + lit])
                i += lit
            if i >= n:
                break
            offset = src[i] | (src[i + 1] << 8)
            i += 2
            if offset == 0 or offset > len(buf):
                raise ValueError("lz4: invalid offset %d (avail %d)" % (offset, len(buf)))
            ml = token & 0x0F
            if ml == 15:
                while True:
                    b = src[i]
                    i += 1
                    ml += b
                    if b != 255:
                        break
            ml += 4
            start = len(buf) - offset
            if ml <= offset:
                extend(buf[start:start + ml])
            else:
                pattern = bytes(buf[start:])
                extend((pattern * (-(-ml // offset)))[:ml])
            if len(buf) - base > max_out:
                raise ValueError("lz4: output exceeds TargetFrameSize")

        out = bytes(buf[base:])
        self.out_bytes += len(out)
        keep = min(len(buf), DICT_LIMIT)
        del buf[:len(buf) - keep]
        return out


# ---------------------------------------------------------------- 采集会话


class SrcLoc:
    __slots__ = ("name", "function", "file", "line", "color", "disp", "ptr")

    def __init__(self, name="", function="", file="", line=0, color=0):
        self.name = name
        self.function = function
        self.file = file
        self.line = line
        self.color = color
        # 显示名缓存：zone 事件每条都要取一次显示名，缓存后避免重复 isinstance 判断
        self.disp = ""
        # 静态 srcloc 的指针（动态 payload 路径为 0）：用于事后回填显示名
        self.ptr = 0

    @property
    def resolved(self):
        """名字是否已可读（静态 srcloc 要等 StringData 回包后才可读）。"""
        return isinstance(self.name, str) and self.name != ""

    def as_dict(self):
        return {
            "name": self.name, "function": self.function,
            "file": self.file, "line": self.line, "color": self.color,
        }


class Frame:
    __slots__ = ("depth", "start", "name", "srcloc", "text", "color", "value", "thread")

    def __init__(self, depth, start, name, srcloc, thread):
        self.depth = depth
        self.start = start
        self.name = name
        self.srcloc = srcloc
        self.thread = thread
        self.text = None
        self.color = None
        self.value = None


class TracySession:
    def __init__(self, sock, args, capture_raw=True):
        self.sock = sock
        self.args = args
        self.outdir = args.out
        os.makedirs(self.outdir, exist_ok=True)
        if capture_raw:
            self.f_raw = open(os.path.join(self.outdir, "raw_stream.bin"), "wb")
        else:
            # --replay 模式：raw_stream.bin 是输入，不重复落盘
            self.f_raw = None
        self.f_dec = open(os.path.join(self.outdir, "decompressed_stream.bin"), "wb")
        self.f_evt = open(os.path.join(self.outdir, "events.jsonl"), "w", encoding="utf-8", buffering=1 << 20)

        self.decoder = Lz4StreamDecoder()
        self.pending = bytearray()

        # 名称 / 源码位置缓存
        self.strings = {}
        self.thread_names = {}
        self.plot_names = {}
        self.frame_names = {}
        self.srclocs = {}
        self.pending_srcloc = None          # SourceLocationPayload（动态 srcloc，紧跟其 ZoneBeginAllocSrcLoc）
        self.pending_single = None          # pending single string
        self.pending_second = None          # pending second string（Callstack 用，暂只消费不计语义）

        # 静态 SourceLocation 请求 FIFO：SendServerQuery(SourceLocation, ptr) 后，回包的
        # SourceLocation 事件与队首指针一一对应（TracyWorker.cpp AddSourceLocation）
        self.srcloc_query_fifo = deque()

        # 查询节流（客户端每 10ms 处理一个查询包）
        self._query_queue = deque()
        self._query_inflight = 0
        self._queried_keys = set()

        # 线程与时间轴
        self.thread = 0
        self.ref_thread = 0
        self.stacks = defaultdict(list)
        self.depth = 0

        self.zone_counts = defaultdict(int)
        self.zone_durs = defaultdict(list)
        self.zone_pending = defaultdict(list)  # 静态 srcloc 名字未回包时按指针挂起的耗时
        self.zone_calls = []              # 每帧根 zone，用于退化帧耗时
        self.plot_counts = defaultdict(int)
        self.plot_values = defaultdict(list)
        self.frame_durations = defaultdict(list)   # 按 frame name 分组
        self.frame_timeline = defaultdict(list)   # 连续标记时间线（FrameMarkMsg）
        self.frame_pair_start = {}                # Start/End 配对
        self.messages = []
        self.type_counts = defaultdict(int)
        self.parse_errors = []

        self.welcome = {}
        self.timer_mul = 1.0
        self.init_begin = 0
        self.connected_at = None
        self.ended_at = None
        self.blocks = 0
        self.raw_bytes = 0
        self.stop_flag = False
        self.fatal = False
        self.consecutive_errors = 0
        self._send_lock = threading.Lock()

    # ---------------------------------------------------------- 发送查询

    def _send_query(self, qtype, ptr, extra=0):
        if self.sock is None:
            return
        packet = struct.pack("<BQI", qtype, ptr, extra)
        try:
            with self._send_lock:
                self.sock.sendall(packet)
        except OSError:
            self.stop_flag = True

    def _enqueue_query(self, qtype, ptr, extra=0):
        self._query_queue.append((qtype, ptr, extra))
        self._flush_queries()

    def _flush_queries(self):
        while self._query_inflight < MAX_INFLIGHT_QUERIES and self._query_queue:
            qtype, ptr, extra = self._query_queue.popleft()
            self._send_query(qtype, ptr, extra)
            self._query_inflight += 1

    def _query_acked(self):
        if self._query_inflight > 0:
            self._query_inflight -= 1
        self._flush_queries()

    def _ensure_query(self, key, qtype, ptr, extra=0):
        """同 key 只查一次（key 为去重标识，如 ptr 或 (kind, ptr)）。"""
        if key in self._queried_keys:
            return
        self._queried_keys.add(key)
        self._enqueue_query(qtype, ptr, extra)

    # ---------------------------------------------------------- 握手

    def handshake(self):
        self.sock.sendall(HANDSHAKE_SHIBBOLETH + struct.pack("<I", PROTOCOL_VERSION))
        status = self._recv_exact(1)[0]
        if status != 1:
            raise RuntimeError("握手失败: %s" % HANDSHAKE_STATUS.get(status, status))
        raw = self._recv_exact(WELCOME_SIZE)
        self._parse_welcome(raw)
        return raw

    def _parse_welcome(self, b):
        w = {}
        w["timer_mul"] = f64(b, 0)
        w["init_begin"] = i64(b, 8)
        w["init_end"] = i64(b, 16)
        w["resolution"] = u64(b, 24)
        w["epoch"] = u64(b, 32)
        w["exectime"] = u64(b, 40)
        w["pid"] = u64(b, 48)
        w["sampling_period"] = i64(b, 56)
        flags = b[64]
        w["flags"] = flags
        w["cpu_arch"] = CPU_ARCH.get(b[65], b[65])
        w["cpu_manufacturer"] = b[66:78].split(b"\x00", 1)[0].decode("ascii", "replace")
        w["cpu_id"] = u32(b, 78)
        w["program_name"] = b[82:82 + WELCOME_PROGRAM_NAME_SIZE].split(b"\x00", 1)[0].decode("utf-8", "replace")
        w["host_info"] = b[146:146 + WELCOME_HOST_INFO_SIZE].split(b"\x00", 1)[0].decode("utf-8", "replace")
        w["on_demand"] = bool(flags & 0x01)
        self.welcome = w
        self.timer_mul = w["timer_mul"]
        self.init_begin = w["init_begin"]

    def _recv_exact(self, n):
        buf = bytearray()
        while len(buf) < n:
            chunk = self.sock.recv(min(1 << 16, n - len(buf)))
            if not chunk:
                raise ConnectionError("连接在读取 %d/%d 字节时关闭" % (len(buf), n))
            buf += chunk
        return bytes(buf)

    # ---------------------------------------------------------- 主循环

    def run(self):
        self.connected_at = time.time()
        self.handshake()
        self._write_meta()
        last = time.time()
        while not self.stop_flag and not self.fatal:
            self.sock.settimeout(1.0)
            try:
                head = self.sock.recv(4)
            except socket.timeout:
                # 超时只是"暂时无数据"（如场景初始化停顿），继续等待；
                # 只有对端关闭（recv 返回空）才视为结束。
                now = time.time()
                if now - last > 30.0:
                    print("[recv] 已空闲 %.0fs，累计 %d 块 / %d MB（原 %d MB），继续等待…"
                          % (now - last, self.blocks, self.decoder.out_bytes >> 20,
                             self.decoder.src_bytes >> 20))
                    last = now
                continue
            except OSError:
                break
            if not head:
                break
            while len(head) < 4:
                more = self.sock.recv(4 - len(head))
                if not more:
                    return self._finish()
                head += more
            size = struct.unpack("<I", head)[0]
            if size == 0 or size > TARGET_FRAME_SIZE * 2:
                self.parse_errors.append("异常块长度 %d" % size)
                break
            payload = self._recv_exact(size)
            if self.f_raw is not None:
                self.f_raw.write(head)
                self.f_raw.write(payload)
            self.raw_bytes += 4 + size
            self.blocks += 1
            try:
                data = self.decoder.decompress(payload)
            except ValueError as exc:
                self.parse_errors.append("LZ4 解压失败(块 %d): %s" % (self.blocks, exc))
                break
            self.f_dec.write(data)
            self._parse(data)
            now = time.time()
            last = now
            if self.args.max_seconds and (now - self.connected_at) > self.args.max_seconds:
                self.parse_errors.append("达到 --max-seconds 上限，主动结束")
                break
        return self._finish()

    # ---------------------------------------------------------- 离线重放

    def load_meta(self):
        """从 metadata.json 恢复 welcome / 时钟基准（重放模式用）。"""
        with open(os.path.join(self.outdir, "metadata.json"), "r", encoding="utf-8") as f:
            meta = json.load(f)
        self.welcome = meta["welcome"]
        self.timer_mul = self.welcome["timer_mul"]
        self.init_begin = self.welcome["init_begin"]
        self.connected_at = time.time()

    def replay_file(self, path):
        """离线重放 raw_stream.bin：按 [uint32 size][payload] 块解压并解析，
        用于在修好解析后重产 events.jsonl + stats.json，无需重跑被测程序。"""
        self.load_meta()
        last = time.time()
        with open(path, "rb") as f:
            while not self.stop_flag and not self.fatal:
                hdr = f.read(4)
                if not hdr:
                    break
                size = struct.unpack("<I", hdr)[0]
                if size == 0 or size > TARGET_FRAME_SIZE * 2:
                    self.parse_errors.append("异常块长度 %d(offset 重放)" % size)
                    break
                payload = f.read(size)
                if len(payload) != size:
                    self.parse_errors.append("块数据不完整(期望 %d 实得 %d)" % (size, len(payload)))
                    break
                self.raw_bytes += 4 + size
                self.blocks += 1
                try:
                    data = self.decoder.decompress(payload)
                except ValueError as exc:
                    self.parse_errors.append("LZ4 解压失败(块 %d): %s" % (self.blocks, exc))
                    break
                self.f_dec.write(data)
                self._parse(data)
                now = time.time()
                if now - last > 5.0:
                    print("[replay] 已解析 %d 块 / %d MB（原 %d MB）…"
                          % (self.blocks, self.decoder.out_bytes >> 20, self.decoder.src_bytes >> 20))
                    last = now
        return self._finish()

    # ---------------------------------------------------------- 队列解析

    def _parse(self, data):
        buf = self.pending
        buf += data
        pos = 0
        n = len(buf)
        while pos < n:
            t = buf[pos]
            if t >= NUM_TYPES:
                self.parse_errors.append("未知 QueueType=%d，剩余 %d 字节" % (t, n - pos))
                self.fatal = True
                break
            self.type_counts[TYPE_NAME[t]] += 1
            if TYPE_STRING[t]:
                off = TYPE_STR_OFF[t]
                ls = TYPE_STR_LSIZE[t]
                if pos + off + ls > n:
                    break
                ln = int.from_bytes(buf[pos + off:pos + off + ls], "little") + TYPE_STR_BIAS[t]
                total = off + ls + ln
            else:
                total = TYPE_SIZE[t]
            if pos + total > n:
                break
            try:
                self._handle(t, buf, pos, total)
            except (struct.error, IndexError, ValueError) as exc:
                self.parse_errors.append("事件 %s 解析失败(offset=%d): %s" % (TYPE_NAME[t], pos, exc))
                self.consecutive_errors += 1
                if self.consecutive_errors >= 8:
                    self.fatal = True
                    break
                # 跳过坏事件继续解析，避免同一点反复报错形成忙循环
                pos += total
                continue
            else:
                self.consecutive_errors = 0
            pos += total
            if t == T["Terminate"]:
                self.stop_flag = True
        del buf[:pos]

    # ---------------------------------------------------------- 时间换算

    def _ts(self, ref):
        return (ref - self.init_begin) * self.timer_mul

    def _abs(self, tsc):
        return (tsc - self.init_begin) * self.timer_mul

    # ---------------------------------------------------------- 事件输出

    def _emit(self, obj):
        self.f_evt.write(json.dumps(obj, ensure_ascii=False, separators=(",", ":")))
        self.f_evt.write("\n")

    def _clean(self, raw: bytes) -> str:
        return raw.split(b"\x00", 1)[0].decode("utf-8", "replace")

    def _take_single(self) -> str:
        s = self.pending_single
        self.pending_single = None
        return s or ""

    def _zone_display_name(self, fr):
        if fr.name:
            return fr.name
        return self._srcloc_name(fr.srcloc)

    def _srcloc_name(self, sl):
        """取 srcloc 的显示名。

        静态 srcloc 的 name/function/file 是字符串指针，要等客户端回包
        （SourceLocation + StringData）才可读。名字未到之前**不缓存** "<zone>"：
        否则该 srcloc 的显示名会被永久钉死成 "<zone>"（早期 zone 结束时名字
        尚未回包，后来回包了也刷不回来），整份采集会全部退化成无名 zone。
        """
        if sl is None:
            return "<zone>"
        if sl.disp:
            return sl.disp
        nm = sl.name if isinstance(sl.name, str) and sl.name else None
        fn = sl.function if isinstance(sl.function, str) and sl.function else None
        d = nm or fn
        if not d:
            return "<zone>"
        sl.disp = d
        return d

    # ---------------------------------------------------------- zone 栈

    def _push(self, ref, srcloc):
        stack = self.stacks[self.thread]
        stack.append(Frame(len(stack), self._ts(ref), None, srcloc, self.thread))
        self.depth = len(stack)

    def _push_delta(self, delta):
        ref = self.ref_thread + delta
        self.ref_thread = ref
        self._push(ref, self.pending_srcloc)
        self.pending_srcloc = None

    def _pop(self, delta):
        ref = self.ref_thread + delta
        self.ref_thread = ref
        stack = self.stacks[self.thread]
        if not stack:
            return
        fr = stack.pop()
        self.depth = len(stack)
        dur = self._ts(ref) - fr.start
        sl = fr.srcloc
        name = self._zone_display_name(fr)
        # 静态 srcloc 的名字要等回包；若此刻尚未可读，先把耗时挂到指针上，
        # 等名字解析后（_resolve_src_names）再按名字归并，避免统计退化成 <zone>。
        if sl is not None and sl.ptr and not sl.resolved:
            self.zone_pending[sl.ptr].append(dur)
        else:
            self.zone_counts[name] += 1
            durs = self.zone_durs[name]
            durs.append(dur)
        # ★事件行直接拼装（不再每事件建 dict + json.dumps）：
        #   采集端吞吐实测受此限制（10 万事件/秒即饱和，导致帧标记大量丢失），
        #   直接格式化可把单事件开销降到约 1/3。
        if fr.text or fr.color is not None or fr.value is not None or '"' in name or "\\" in name:
            rec = {
                "k": "zone", "n": name, "d": round(dur, 1), "t": round(fr.start, 1),
                "th": fr.thread, "dep": fr.depth,
            }
            if sl:
                if isinstance(sl.function, str):
                    rec["fn"] = sl.function
                if isinstance(sl.file, str):
                    rec["f"] = sl.file
                if sl.line:
                    rec["ln"] = sl.line
            if fr.text:
                rec["x"] = fr.text
            if fr.color is not None:
                rec["c"] = fr.color
            if fr.value is not None:
                rec["v"] = fr.value
            if sl is not None and sl.ptr:
                rec["sl"] = "0x%x" % sl.ptr
            self._emit(rec)
        else:
            fn = sl.function if (sl is not None and isinstance(sl.function, str)) else ""
            fl = sl.file if (sl is not None and isinstance(sl.file, str)) else ""
            ln = sl.line if sl is not None else 0
            slp = ("0x%x" % sl.ptr) if (sl is not None and sl.ptr) else ""
            self.f_evt.write(
                '{"k":"zone","n":"%s","d":%s,"t":%s,"th":%d,"dep":%d,"fn":"%s","f":"%s","ln":%d,"sl":"%s"}\n'
                % (name, round(dur, 1), round(fr.start, 1), fr.thread, fr.depth, fn, fl, ln, slp)
            )
        if fr.depth == 0:
            self.zone_calls.append({"n": name, "s": fr.start, "d": dur})

    # ---------------------------------------------------------- srcloc

    def _parse_srcloc_payload(self, raw):
        """动态 SourceLocationPayload：4B color + 4B line + function\0 + source\0 + name。
        颜色按上游 AddSourceLocationPayload 做 R/B 交换（0xAABBGGRR -> 0xAARRGGBB）。
        name 字段按官方语义取"到负载末尾的剩余字节"（nsz = sz - (end - start)，
        不保证 NUL 结尾），不能像 function/source 那样按 \0 截断。"""
        color = u32(raw, 0)
        line = u32(raw, 4)
        rest = raw[8:]
        function = ""
        source = ""
        name = ""
        i = rest.find(b"\x00")
        if i < 0:
            function = self._clean(rest)
        else:
            function = self._clean(rest[:i])
            rest = rest[i + 1:]
            j = rest.find(b"\x00")
            if j < 0:
                source = self._clean(rest)
            else:
                source = self._clean(rest[:j])
                name = self._clean(rest[j + 1:])
        color = ((color & 0x00FF0000) >> 16) | (color & 0x0000FF00) | ((color & 0x000000FF) << 16)
        return SrcLoc(name, function, source, line, color)

    def _srcloc_static(self, ptr):
        """静态 SourceLocation：指针查缓存，缺失则发起查询并把 ptr 压入 FIFO。
        （three.cj 的 @Zone 走动态 srcloc，此路径主要用于兼容其它客户端。）"""
        sl = self.srclocs.get(ptr)
        if sl is None:
            sl = SrcLoc()
            sl.ptr = ptr
            self.srclocs[ptr] = sl
            self.srcloc_query_fifo.append(ptr)
            self._ensure_query(("sl", ptr), SERVER_QUERY_SOURCE_LOCATION, ptr)
        return sl

    def _resolve_src_names(self):
        """静态 SourceLocation 的 name/function/file 是指针，等 StringData 回包后回填。

        回填后把此前按指针挂起的耗时（zone_pending）按显示名归并进统计，
        避免整份采集退化成无名 <zone>。
        """
        for ptr, sl in self.srclocs.items():
            for attr in ("name", "function", "file"):
                v = getattr(sl, attr)
                if isinstance(v, int):
                    s = self.strings.get(v)
                    if s is not None:
                        setattr(sl, attr, s)
            if not sl.name:
                sl.name = sl.function
            if sl.resolved and self.zone_pending.get(ptr):
                durs = self.zone_pending.pop(ptr)
                nm = self._srcloc_name(sl)
                self.zone_counts[nm] += len(durs)
                self.zone_durs[nm].extend(durs)

    # ---------------------------------------------------------- 帧与 plot

    def _record_frame_mark(self, name, tsc):
        times = self.frame_timeline[name]
        if times:
            d = tsc - times[-1]
            if 0 < d < MAX_FRAME_DURATION_NS:
                self.frame_durations[name].append(d * self.timer_mul)
        times.append(tsc)

    def _record_frame_pair(self, name, tsc, is_start):
        if is_start:
            self.frame_pair_start[name] = tsc
        else:
            s = self.frame_pair_start.pop(name, None)
            if s is not None:
                d = tsc - s
                if 0 < d < MAX_FRAME_DURATION_NS:
                    self.frame_durations[name].append(d * self.timer_mul)

    def _frame_name(self, ptr):
        if ptr == 0:
            return "frame"
        nm = self.frame_names.get(ptr)
        if nm is None:
            nm = "0x%x" % ptr
            self._ensure_query(("fn", ptr), SERVER_QUERY_FRAME_NAME, ptr)
        return nm

    def _plot_name(self, ptr):
        nm = self.plot_names.get(ptr)
        if nm is None:
            nm = "0x%x" % ptr
            self._ensure_query(("pn", ptr), SERVER_QUERY_PLOT_NAME, ptr)
        return nm

    # ---------------------------------------------------------- 事件分发

    def _handle(self, t, b, p, total):
        # ---------- 变长字符串传输 ----------
        if t in (T["SingleStringData"], T["SingleStringData8"]):
            ps = p + TYPE_STR_OFF[t] + TYPE_STR_LSIZE[t]
            self.pending_single = self._clean(bytes(b[ps:p + total]))
            return
        if t in (T["SecondStringData"], T["SecondStringData8"]):
            ps = p + TYPE_STR_OFF[t] + TYPE_STR_LSIZE[t]
            self.pending_second = self._clean(bytes(b[ps:p + total]))
            return
        if t == T["StringData"]:
            ptr = u64(b, p + 1)
            ps = p + TYPE_STR_OFF[t] + TYPE_STR_LSIZE[t]
            self.strings[ptr] = self._clean(bytes(b[ps:p + total]))
            self._query_acked()
            self._resolve_src_names()
            return
        if t == T["ThreadName"]:
            ps = p + TYPE_STR_OFF[t] + TYPE_STR_LSIZE[t]
            self.thread_names[u64(b, p + 1)] = self._clean(bytes(b[ps:p + total]))
            self._query_acked()
            return
        if t == T["PlotName"]:
            ps = p + TYPE_STR_OFF[t] + TYPE_STR_LSIZE[t]
            self.plot_names[u64(b, p + 1)] = self._clean(bytes(b[ps:p + total]))
            self._query_acked()
            return
        if t == T["FrameName"]:
            ps = p + TYPE_STR_OFF[t] + TYPE_STR_LSIZE[t]
            self.frame_names[u64(b, p + 1)] = self._clean(bytes(b[ps:p + total]))
            self._query_acked()
            return
        if t == T["SourceLocationPayload"]:
            ps = p + TYPE_STR_OFF[t] + TYPE_STR_LSIZE[t]
            self.pending_srcloc = self._parse_srcloc_payload(bytes(b[ps:p + total]))
            return
        if t in (T["CallstackPayload"], T["CallstackAllocPayload"], T["FrameImageData"],
                 T["SymbolCode"], T["SourceCode"], T["ExternalName"], T["ExternalThreadName"],
                 T["FiberName"]):
            # 本接收端不消费 callstack / 图像等负载，仅按长度推进
            return

        # ---------- 线程上下文 ----------
        if t == T["ThreadContext"]:
            self.thread = u32(b, p + 1)
            self.ref_thread = 0            # 上游：服务端在 ThreadContext 处重置 m_refTimeThread
            if self.thread not in self.thread_names:
                self.thread_names[self.thread] = ""
                self._ensure_query(("th", self.thread), SERVER_QUERY_THREAD_STRING, self.thread)
            return

        # ---------- zone 进出 ----------
        if t in TIME_DELTA_RAW:
            self._push_delta(i64(b, p + 1))
            return
        if t in TIME_DELTA64:
            dt = i64(b, p + 1)
            if dt >= 0:
                dt += PROTOCOL_OFFSET_32_BIT
            if t in (T["ZoneBegin"], T["ZoneBeginCallstack"]):
                self._push(self.ref_thread + dt, self._srcloc_static(u64(b, p + 9)))
                self.ref_thread += dt
            else:
                self._pop(dt)
            return
        if t in TIME_DELTA32:
            dt = u32(b, p + 1) + PROTOCOL_OFFSET_16_BIT
            if t == T["ZoneEnd32"]:
                self._pop(dt)
            else:
                self._push(self.ref_thread + dt, self._srcloc_static(u64(b, p + 5)))
                self.ref_thread += dt
            return
        if t in TIME_DELTA16:
            dt = u16(b, p + 1)
            if t == T["ZoneEnd16"]:
                self._pop(dt)
            else:
                self._push(self.ref_thread + dt, self._srcloc_static(u64(b, p + 3)))
                self.ref_thread += dt
            return

        # ---------- zone 文本 / 颜色 / 值 ----------
        if t == T["ZoneText"]:
            txt = self._take_single()
            stack = self.stacks[self.thread]
            if stack and txt:
                fr = stack[-1]
                fr.text = (fr.text + "\n" + txt) if fr.text else txt
            return
        if t == T["ZoneName"]:
            nm = self._take_single()
            stack = self.stacks[self.thread]
            if stack and nm:
                stack[-1].name = nm
            return
        if t == T["ZoneColor"]:
            stack = self.stacks[self.thread]
            if stack:
                stack[-1].color = "#%02x%02x%02x" % (b[p + 3], b[p + 2], b[p + 1])
            return
        if t == T["ZoneValue"]:
            stack = self.stacks[self.thread]
            if stack:
                stack[-1].value = u64(b, p + 1)
            return

        # ---------- 静态 SourceLocation（FIFO 关联） ----------
        if t == T["SourceLocation"]:
            if not self.srcloc_query_fifo:
                self.parse_errors.append("SourceLocation 事件无对应的请求 FIFO")
                return
            ptr = self.srcloc_query_fifo.popleft()
            sl = self.srclocs.get(ptr) or SrcLoc()
            sl.ptr = ptr
            sl.name = u64(b, p + 1)        # 指针，等 StringData 回填
            sl.function = u64(b, p + 9)
            sl.file = u64(b, p + 17)
            sl.line = u32(b, p + 25)
            sl.color = (b[p + 29] << 16) | (b[p + 30] << 8) | b[p + 31]
            self.srclocs[ptr] = sl
            self._query_acked()
            for attr in ("name", "function", "file"):
                qptr = getattr(sl, attr)
                if qptr != 0:
                    self._ensure_query(("s", qptr), SERVER_QUERY_STRING, qptr)
            self._resolve_src_names()
            return

        # ---------- plot ----------
        if t in (T["PlotDataInt"], T["PlotDataFloat"], T["PlotDataDouble"]):
            ptr = u64(b, p + 1)
            dt = i64(b, p + 9)
            if t == T["PlotDataInt"]:
                val, vt = i64(b, p + 17), "i64"
            elif t == T["PlotDataFloat"]:
                val, vt = f32(b, p + 17), "f32"
            else:
                val, vt = f64(b, p + 17), "f64"
            ref = self.ref_thread + dt
            self.ref_thread = ref
            pname = self._plot_name(ptr)
            self.plot_counts[pname] += 1
            self.plot_values[pname].append(val)
            self._emit({"k": "plot", "n": pname, "v": val, "vt": vt, "t": round(self._ts(ref), 1)})
            return

        # ---------- 帧标记（时间字段为绝对 TSC） ----------
        if t in (T["FrameMarkMsg"], T["FrameMarkMsgStart"], T["FrameMarkMsgEnd"]):
            tsc = i64(b, p + 1)
            ptr = u64(b, p + 9)
            nm = self._frame_name(ptr)
            ts_ns = self._abs(tsc)
            self._emit({"k": "frame", "n": nm, "t": round(ts_ns, 1), "sub": TYPE_NAME[t]})
            if t == T["FrameMarkMsg"]:
                self._record_frame_mark(nm, tsc)
            else:
                self._record_frame_pair(nm, tsc, t == T["FrameMarkMsgStart"])
            return

        # ---------- message 系列（固定大小；时间字段为绝对 TSC） ----------
        if t in MESSAGE_PLAIN or t in MESSAGE_LITERAL:
            tsc = i64(b, p + 1)
            color = None
            metadata = 0
            txt = ""
            if t in (T["MessageColor"], T["MessageColorCallstack"],
                     T["MessageLiteralColor"], T["MessageLiteralColorCallstack"]):
                # QueueMessageColor 布局：1 头 + 8 time + 3 (b,g,r)；b/g/r 在 p+9/p+10/p+11
                color = "#%02x%02x%02x" % (b[p + 11], b[p + 10], b[p + 9])
            if t in (T["Message"], T["MessageCallstack"]):
                metadata = b[p + 9]
            elif t in (T["MessageColor"], T["MessageColorCallstack"]):
                metadata = b[p + 12]
            elif t in MESSAGE_LITERAL:
                tagged = u64(b, p + 9 if t in (T["MessageLiteral"], T["MessageLiteralCallstack"]) else p + 12)
                metadata = tagged & 0xFF
                addr = tagged >> 8
                if addr:
                    txt = self.strings.get(addr)
                    if txt is None:
                        txt = "0x%x" % addr
                        self._ensure_query(("m", addr), SERVER_QUERY_STRING, addr)
                else:
                    txt = ""
            if t not in MESSAGE_LITERAL:
                # Message / MessageColor / MessageAppInfo 文本来自前一条 pending single string
                txt = self._take_single()

            source = metadata & 0x0F
            severity = (metadata >> 4) & 0x0F
            ts_ns = self._abs(tsc)
            self.messages.append({
                "t": ts_ns, "text": txt, "thread": self.thread,
                "source": source, "severity": severity, "color": color,
            })
            self._emit({"k": "msg", "t": round(ts_ns, 1), "th": self.thread, "x": txt,
                        "src": source, "sev": severity, "c": color})
            return

        # ---------- 其它固定事件（应答 / 心跳等，仅推进） ----------
        if t == T["Terminate"]:
            return
        if t in QUERY_REPLY_EVENTS:
            self._query_acked()
            return

    # ---------------------------------------------------------- 收尾统计

    def _backfill_event_names(self):
        """用最终解析出的 srcloc 名字回填 events.jsonl 中的 "<zone>"。

        事件行在 zone 结束当场写出，那时静态 srcloc 的 name/function/file 可能
        还只是指针（等客户端回包），只能记 "<zone>"。采集结束后名字已全部解析，
        这里按行内的 "sl" 指针回填，使事件流与 stats.json 的口径一致。
        """
        path = os.path.join(self.outdir, "events.jsonl")
        if not os.path.exists(path):
            return
        info = {}
        for ptr, sl in self.srclocs.items():
            nm = self._srcloc_name(sl)
            if nm == "<zone>":
                continue
            fn = sl.function if isinstance(sl.function, str) else ""
            fl = sl.file if isinstance(sl.file, str) else ""
            info["0x%x" % ptr] = (nm, fn, fl, sl.line)

        def esc(s):
            return s.replace("\\", "\\\\").replace('"', '\\"')

        tmp = path + ".tmp"
        changed = 0
        with open(path, "r", encoding="utf-8") as fi, open(tmp, "w", encoding="utf-8") as fo:
            for line in fi:
                if '"n":"<zone>"' in line and '"sl":"0x' in line:
                    i = line.find('"sl":"')
                    j = line.find('"', i + 6)
                    got = info.get(line[i + 6:j])
                    if got:
                        nm, fn, fl, ln = got
                        line = line.replace('"n":"<zone>"', '"n":"%s"' % esc(nm), 1)
                        line = line.replace('"fn":"",', '"fn":"%s",' % esc(fn), 1)
                        line = line.replace('"f":"",', '"f":"%s",' % esc(fl), 1)
                        line = line.replace('"ln":0,', '"ln":%d,' % ln, 1)
                        changed += 1
                fo.write(line)
        os.replace(tmp, path)
        if changed:
            print("[finish] events 补名 %d 条" % changed, flush=True)

    def _finish(self):
        import time as _t
        _t0 = _t.time()
        self.ended_at = time.time()
        try:
            self._resolve_src_names()
            # 客户端退出时未回包的 StringData 指针：收尾阶段转为可读 hex，避免 int 落入 stats。
            for sl in self.srclocs.values():
                for attr in ("name", "function", "file"):
                    v = getattr(sl, attr)
                    if isinstance(v, int):
                        setattr(sl, attr, "0x%x" % v)
            # 名字转 hex 后再解析一次：把仍挂起的耗时归并掉
            self._resolve_src_names()
        except Exception as exc:  # noqa: BLE001
            self.parse_errors.append("_resolve_src_names 失败: %s" % exc)
        print("[finish] _resolve_src_names %.2fs" % (_t.time() - _t0), flush=True)
        _t0 = _t.time()
        try:
            # 逐线程收尾：_pop 内部按 self.thread 取栈，必须先切换到目标线程，
            # 否则多线程场景下 while stack 恒真、_pop 却弹空栈，形成死循环。
            for tid, stack in list(self.stacks.items()):
                if not stack:
                    continue
                self.thread = tid
                while stack:
                    self._pop(0)
        except Exception as exc:  # noqa: BLE001
            self.parse_errors.append("栈收尾失败: %s" % exc)
        print("[finish] 栈收尾 %.2fs" % (_t.time() - _t0), flush=True)
        if self.sock is not None:
            try:
                self._send_query(SERVER_QUERY_TERMINATE, 0)
            except OSError:
                pass
        if self.f_raw:
            self.f_raw.flush()
            self.f_dec.flush()
            self.f_evt.flush()
        _t0 = _t.time()
        stats = self._stats()
        print("[finish] _stats %.2fs" % (_t.time() - _t0), flush=True)
        # 无论 _stats 内部是否部分失败，都必须落盘 stats.json
        if self.f_dec is not None:
            self._write_meta()
            with open(os.path.join(self.outdir, "stats.json"), "w", encoding="utf-8") as f:
                json.dump(stats, f, ensure_ascii=False, indent=2)
            self.f_dec.close()
            self.f_evt.close()
            self.f_dec = None
            self.f_evt = None
        # events.jsonl 事后补名：静态 srcloc 名字可能在 zone 结束之后才回包，
        # 事件行当时只能记 <zone>；此处用最终解析结果回填。
        try:
            self._backfill_event_names()
        except Exception as exc:  # noqa: BLE001
            self.parse_errors.append("events 补名失败: %s" % exc)
        if self.f_raw is not None:
            self.f_raw.close()
            self.f_raw = None
        return stats

    def _stats(self):
        # 名字始终未回包的 srcloc：挂起的耗时归入 <zone>，不丢样本
        if self.zone_pending:
            leftover = []
            for durs in self.zone_pending.values():
                leftover.extend(durs)
            if leftover:
                self.zone_counts["<zone>"] += len(leftover)
                self.zone_durs["<zone>"].extend(leftover)
            self.zone_pending.clear()
        zones = []
        for nm, cnt in self.zone_counts.items():
            vals = sorted(self.zone_durs[nm])
            zones.append({
                "name": nm,
                "count": cnt,
                "total_ns": round(sum(vals), 1),
                "mean_ns": round(sum(vals) / cnt, 1),
                "p50_ns": round(percentile(vals, 0.50), 1),
                "p95_ns": round(percentile(vals, 0.95), 1),
                "p99_ns": round(percentile(vals, 0.99), 1),
                "max_ns": round(vals[-1], 1),
                "min_ns": round(vals[0], 1),
            })
        zones.sort(key=lambda z: -z["total_ns"])

        plots = []
        for nm, cnt in self.plot_counts.items():
            vals = sorted(self.plot_values[nm])
            plots.append({
                "name": nm, "count": cnt,
                "mean": round(sum(vals), 6),
                "p50": round(percentile(vals, 0.50), 6),
                "p95": round(percentile(vals, 0.95), 6),
                "min": round(vals[0], 6), "max": round(vals[-1], 6),
            })

        # 帧耗时：优先 FrameMark 时间线，退化用根 zone 的开始时间差
        frames = []
        frame_source = "frame_mark"
        per_name = {nm: sorted(ds) for nm, ds in self.frame_durations.items()}
        for ds in per_name.values():
            frames.extend(ds)
        if not frames:
            frame_source = "root_zone"
            src = sorted(c["s"] for c in self.zone_calls)
            for i in range(1, len(src)):
                d = src[i] - src[i - 1]
                if 0 < d < MAX_FRAME_DURATION_NS:
                    frames.append(d)
        frames.sort()
        frame_stats = {}
        if frames:
            frame_stats = {
                "count": len(frames),
                "source": frame_source,
                "per_name": {nm: {"count": len(ds),
                                  "mean_ns": round(sum(ds) / len(ds), 1),
                                  "p50_ns": round(percentile(ds, 0.50), 1),
                                  "p95_ns": round(percentile(ds, 0.95), 1)}
                             for nm, ds in per_name.items()},
                "mean_ns": round(sum(frames) / len(frames), 1),
                "p50_ns": round(percentile(frames, 0.50), 1),
                "p95_ns": round(percentile(frames, 0.95), 1),
                "p99_ns": round(percentile(frames, 0.99), 1),
                "min_ns": round(frames[0], 1),
                "max_ns": round(frames[-1], 1),
                "mean_ms": round(sum(frames) / len(frames) / 1e6, 4),
                "p50_ms": round(percentile(frames, 0.50) / 1e6, 4),
                "p95_ms": round(percentile(frames, 0.95) / 1e6, 4),
            }

        return {
            "welcome": self.welcome,
            "capture": {
                "started_at": self.connected_at,
                "ended_at": self.ended_at,
                "wall_seconds": round((self.ended_at or 0) - (self.connected_at or 0), 3),
                "blocks": self.blocks,
                "raw_bytes": self.raw_bytes,
                "compressed_bytes": self.decoder.src_bytes,
                "decompressed_bytes": self.decoder.out_bytes,
                "compression_ratio": round(self.decoder.src_bytes / self.decoder.out_bytes, 4) if self.decoder.out_bytes else None,
            },
            "frame": frame_stats,
            "zones": zones,
            "plots": plots,
            "messages": self.messages[:2000],
            "event_type_counts": dict(sorted(self.type_counts.items(), key=lambda kv: -kv[1])),
            "errors": self.parse_errors,
        }

    def _write_meta(self):
        meta = {
            "protocol_version": PROTOCOL_VERSION,
            "welcome": self.welcome,
            "threads": {str(k): v for k, v in self.thread_names.items()},
            "plot_names": {hex(k): v for k, v in self.plot_names.items()},
            "frame_names": {hex(k): v for k, v in self.frame_names.items()},
            "source_locations": {hex(k): v.as_dict() for k, v in self.srclocs.items()},
            "unresolved_string_ptrs": sorted(hex(p[1]) for p in self._queried_keys if isinstance(p, tuple)),
        }
        tmp = os.path.join(self.outdir, "metadata.json.tmp")
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(meta, f, ensure_ascii=False, indent=2)
        os.replace(tmp, os.path.join(self.outdir, "metadata.json"))


# ---------------------------------------------------------------- 连接与发现


def try_connect(host, port, timeout=1.0):
    try:
        s = socket.create_connection((host, port), timeout=timeout)
    except OSError:
        return None
    s.settimeout(5.0)
    s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    return s


def discover_port(bind_host="0.0.0.0", wait=30.0):
    """监听 UDP 广播（Tracy 默认 8086）拿 listenPort。"""
    deadline = time.time() + wait
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    except OSError:
        pass
    try:
        sock.bind((bind_host, 8086))
    except OSError as exc:
        print("[warn] UDP 8086 绑定失败(%s)，回退到端口扫描" % exc)
        sock.close()
        return None
    sock.settimeout(1.0)
    while time.time() < deadline:
        try:
            data, _ = sock.recvfrom(2048)
        except socket.timeout:
            continue
        if len(data) < 4:
            continue
        version, listen_port = struct.unpack_from("<HH", data, 0)
        if version != 3:
            continue
        return listen_port
    sock.close()
    return None


def print_summary(stats, outdir):
    cap = stats["capture"]
    print("\n=== 采集概况 ===")
    print("  程序            : %s (pid=%s)" % (stats["welcome"].get("program_name"), stats["welcome"].get("pid")))
    print("  时长            : %.3f s   块数 %d" % (cap["wall_seconds"], cap["blocks"]))
    print("  原始/解压字节   : %d / %d (%.3fx)" % (
        cap["compressed_bytes"], cap["decompressed_bytes"], cap["compression_ratio"] or 0))
    if stats["errors"]:
        print("  错误            : %d 条  %s" % (len(stats["errors"]), stats["errors"][:3]))
    fr = stats.get("frame") or {}
    if fr:
        print("\n=== 帧耗时 (%s) ===" % fr["source"])
        print("  样本 %d   均值 %.3f ms   P50 %.3f ms   P95 %.3f ms   P99 %.3f ms" % (
            fr["count"], fr["mean_ms"], fr["p50_ms"], fr["p95_ms"], fr.get("p99_ns", 0) / 1e6))
    print("\n=== 热点 Top 25 (按总耗时) ===")
    print("  %-34s %8s %12s %11s %11s %11s" % ("zone", "count", "total(ms)", "mean(us)", "p95(us)", "p99(us)"))
    for z in stats["zones"][:25]:
        print("  %-34s %8d %12.3f %11.2f %11.2f %11.2f" % (
            z["name"][:34], z["count"], z["total_ns"] / 1e6,
            z["mean_ns"] / 1e3, z["p95_ns"] / 1e3, z["p99_ns"] / 1e3))
    if stats["plots"]:
        print("\n=== Plot ===")
        for p in stats["plots"][:20]:
            print("  %-30s n=%-7d mean=%-12.6g p50=%-12.6g max=%g" % (
                p["name"][:30], p["count"], p["mean"], p["p50"], p["max"]))
    print("\n产物目录: %s" % os.path.abspath(outdir))


# ---------------------------------------------------------------- 自测（离线伪造协议流）

def _lz4_block_literals(data: bytes) -> bytes:
    """生成纯 literal 的 LZ4 block（用于自测；Tracy 流是合法的 LZ4 block 格式）。"""
    if not data:
        return bytes([0x10])  # 1 个 literal，0 个 match
    out = bytearray()
    run = len(data)
    # 单个 sequence：token = (15<<4)|0 + 扩展长度 + 全部 literal
    out.append((15 << 4))
    rem = run
    while rem >= 255:
        out.append(255)
        rem -= 255
    out.append(rem)
    out += data
    return bytes(out)


def _compress_block(data: bytes) -> bytes:
    try:
        import lz4.block  # type: ignore
        return lz4.block.compress(data, store_size=False)
    except Exception:
        return _lz4_block_literals(data)


def self_test(outdir="captures/selftest"):
    """伪造最小协议流（模拟客户端 Dequeue 后的写盘格式），验证解析器与统计。"""
    init_begin = 1000000
    timer_mul = 1000.0   # 1 TSC = 1 us
    events = bytearray()

    def ev(idx):
        events.append(idx)

    def ev_str16(s):
        nonlocal events
        events.append(T["SingleStringData"])
        bb = s.encode("utf-8")
        events += struct.pack("<H", len(bb) - 256)  # sz = len-256
        events += bb

    def ev_str8(s):
        nonlocal events
        events.append(T["SingleStringData8"])
        bb = s.encode("utf-8")
        events.append(len(bb))
        events += bb

    # ThreadContext: thread=42, 重置 ref
    events.append(T["ThreadContext"])
    events += struct.pack("<I", 42)

    # 动态 srcloc payload + ZoneBeginAllocSrcLoc
    events.append(T["SourceLocationPayload"])
    events += struct.pack("<Q", 0x1000)
    pl = struct.pack("<I", 0xFF00FF00)  # 0xAABBGGRR(AA=FF, B=00, G=FF, R=00)
    pl += struct.pack("<I", 123)
    pl += b"Render::draw\x00" + b"Renderer.cj\x00" + b"myZone\x00"
    events += struct.pack("<H", len(pl))
    events += pl
    events.append(T["ZoneBeginAllocSrcLoc"])
    events += struct.pack("<q", 0)   # delta=0

    # ZoneText / ZoneName（消费 pending single string）
    ev_str8("text line 1")
    events.append(T["ZoneText"])
    ev_str8("text line 2")
    events.append(T["ZoneText"])
    ev_str8("renamed")
    events.append(T["ZoneName"])

    # 子 zone（64 位编码：delta - ProtocolOffset32Bit）
    events.append(T["ZoneBeginAllocSrcLoc"])
    events += struct.pack("<q", 100)   # +100us
    dt64 = 2000000000 + PROTOCOL_OFFSET_32_BIT  # delta 2s + offset
    events.append(T["ZoneEnd"])
    events += struct.pack("<q", dt64)
    events.append(T["ZoneEnd"])
    events += struct.pack("<q", 200)   # +200us

    # plot（裸 delta）
    events.append(T["PlotDataInt"])
    events += struct.pack("<Q", 0x2000) + struct.pack("<q", 50) + struct.pack("<q", 123456)
    events.append(T["PlotDataFloat"])
    events += struct.pack("<Q", 0x2000) + struct.pack("<q", 25) + struct.pack("<f", 1.5)

    # frame mark（绝对 TSC）
    events.append(T["FrameMarkMsg"])
    events += struct.pack("<q", init_begin + 16666) + struct.pack("<Q", 0)      # main frame
    events.append(T["FrameMarkMsg"])
    events += struct.pack("<q", init_begin + 33332) + struct.pack("<Q", 0)
    events.append(T["FrameMarkMsg"])
    events += struct.pack("<q", init_begin + 49998) + struct.pack("<Q", 0)

    # MessageAppInfo（消费 pending single string；绝对 TSC）
    ev_str8("app start")
    events.append(T["MessageAppInfo"])
    events += struct.pack("<q", init_begin + 1000)

    # Message（带 metadata；绝对 TSC）
    ev_str8("hello world")
    events.append(T["Message"])
    events += struct.pack("<q", init_begin + 2000) + struct.pack("<B", 0x12)   # src=2, sev=1

    # MessageLiteral（tagged ptr；绝对 TSC）
    events.append(T["MessageLiteral"])
    events += struct.pack("<q", init_begin + 3000) + struct.pack("<Q", (0x9000 << 8) | 0x21)

    # 静态 ZoneBegin16 + ZoneEnd16
    events.append(T["ZoneBegin16"])
    events += struct.pack("<H", 5) + struct.pack("<Q", 0x3000)
    events.append(T["ZoneEnd16"])
    events += struct.pack("<H", 300)

    # Terminate
    events.append(T["Terminate"])

    # 压缩分块
    stream = bytes(events)
    compressed = _compress_block(stream)

    # 断言
    ok = True
    def check(cond, msg):
        nonlocal ok
        if not cond:
            ok = False
            print("  [FAIL] %s" % msg)

    # LZ4 层验证：流式解码器单块还原 / 多块跨字典还原
    dec = Lz4StreamDecoder()
    check(dec.decompress(compressed) == stream, "LZ4 单块解压还原")
    split = len(stream) // 2
    dec2 = Lz4StreamDecoder()
    out2 = dec2.decompress(_compress_block(stream[:split])) + \
        dec2.decompress(_compress_block(stream[split:]))
    check(out2 == stream, "LZ4 多块(共享字典)解压还原")

    # 用真实会话对象解析（不带 socket）
    args = argparse.Namespace(out=outdir, max_seconds=0)
    sess = TracySession(None, args)
    sess.init_begin = init_begin
    sess.timer_mul = timer_mul
    sess.welcome = {"program_name": "selftest", "pid": 0}
    sess._parse(stream)   # 直接喂解压后的队列流（跳过 LZ4 层）

    z = dict(sess.zone_counts)
    check(z.get("renamed") == 1, "renamed(经 ZoneName) count == 1, got %r" % z)
    # 静态 ZoneBegin16 的 srcloc 名字要等回包，回包前耗时按指针挂起（不计入名字桶）
    check(z.get("<zone>") == 1 and len(sess.zone_pending.get(0x3000, [])) == 1,
          "<zone>(子 zone 无 srcloc) count == 1 且静态 srcloc 挂起 1 条, got %r" % z)
    check(len(sess.messages) == 3, "3 messages, got %d" % len(sess.messages))
    check(sess.messages[0]["text"] == "app start", "appInfo text")
    check(sess.messages[1]["text"] == "hello world", "message text")
    check(sess.messages[1]["source"] == 2 and sess.messages[1]["severity"] == 1, "metadata decode")
    check(sess.messages[2]["text"] == "0x9000", "message literal addr placeholder")
    fd = sess.frame_durations["frame"]
    check(len(fd) == 2 and abs(fd[0] - (16666 * timer_mul)) < 1, "frame duration p1, got %r" % fd)
    check(sess.plot_counts.get("0x2000") == 2, "plot count")
    # zone 文本/名称
    fr_rename = None
    for fr in sess.stacks[42]:
        pass  # 已 pop
    check(sess.zone_durs.get("renamed"), "zone renamed stats key exists")
    check(sess.parse_errors == [], "no parse errors, got %r" % sess.parse_errors[:3])

    print("[self-test] %s (%d bytes queue stream, %d events, %d messages, %d frames)"
          % ("PASS" if ok else "FAIL", len(stream), sum(sess.type_counts.values()),
             len(sess.messages), len(fd)))
    if not ok:
        sys.exit(1)
    return sess


def main():
    ap = argparse.ArgumentParser(description="无 GUI 的 Tracy 协议接收端（落盘 + 统计）")
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=None, help="固定数据端口；缺省先 UDP 发现再扫描 8086-8105")
    ap.add_argument("--out", default="captures/run1", help="产物目录")
    ap.add_argument("--max-seconds", type=float, default=0, help="最长采集时长，0 表示不限")
    ap.add_argument("--scan-timeout", type=float, default=60.0, help="等待被测进程出现的最长时间")
    ap.add_argument("--self-test", action="store_true", help="离线路自测（伪造协议流，无需被测进程）")
    ap.add_argument("--replay", default=None, help="离线重放 raw_stream.bin（同目录须已有 metadata.json）")
    args = ap.parse_args()

    if args.self_test:
        self_test()
        return 0

    if args.replay:
        print("[recv] 离线重放 %s → %s" % (args.replay, args.out))
        session = TracySession(None, args, capture_raw=False)
        try:
            stats = session.replay_file(args.replay)
        except Exception as exc:  # noqa: BLE001
            print("[error] 重放失败: %s" % exc)
            return 3
        print_summary(stats, args.out)
        return 0

    port = args.port
    if port is None:
        print("[recv] 等待 Tracy 广播…")
        port = discover_port(wait=min(args.scan_timeout, 30.0))
        if port:
            print("[recv] 广播发现端口 %d" % port)

    deadline = time.time() + args.scan_timeout
    sock = None
    candidates = [port] if port else list(range(8086, 8106))
    while time.time() < deadline and sock is None:
        for p in candidates:
            sock = try_connect(args.host, p)
            if sock:
                print("[recv] 已连接 %s:%d" % (args.host, p))
                break
        if sock is None:
            time.sleep(0.5)
    if sock is None:
        print("[error] 在 %.1fs 内未能连接 Tracy 服务端" % args.scan_timeout)
        return 2

    session = TracySession(sock, args)
    try:
        stats = session.run()
    except (ConnectionError, RuntimeError, OSError) as exc:
        print("[error] 采集中断: %s" % exc)
        try:
            stats = session._finish()
        except Exception:  # noqa: BLE001
            return 3
    finally:
        try:
            sock.close()
        except OSError:
            pass
    print_summary(stats, args.out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
