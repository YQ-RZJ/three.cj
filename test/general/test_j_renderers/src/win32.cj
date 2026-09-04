package test_j_renderers

/**
 * Win32 API FFI 声明、常量、窗口过程
 *
 * 基于 boxshow 的 win32.cj，调整窗口标题为 shadowplane。
 */

import std.sync.*

// ========== Win32 API FFI 声明 ==========

@CallingConv[STDCALL]
foreign func GetModuleHandleW(lpModuleName: CPointer<UInt16>): UIntNative

@CallingConv[STDCALL]
foreign func LoadCursorW(hInstance: UIntNative, lpCursorName: CPointer<UInt16>): UIntNative

@CallingConv[STDCALL]
foreign func RegisterClassExW(lpwcx: CPointer<Unit>): UInt16

@CallingConv[STDCALL]
foreign func CreateWindowExW(
    dwExStyle: UInt32,
    lpClassName: CPointer<UInt16>,
    lpWindowName: CPointer<UInt16>,
    dwStyle: UInt32,
    x: Int32, y: Int32,
    nWidth: Int32, nHeight: Int32,
    hWndParent: UIntNative,
    hMenu: UIntNative,
    hInstance: UIntNative,
    lpParam: CPointer<Unit>
): UIntNative

@CallingConv[STDCALL]
foreign func ShowWindow(hWnd: UIntNative, nCmdShow: Int32): Bool

@CallingConv[STDCALL]
foreign func UpdateWindow(hWnd: UIntNative): Bool

@CallingConv[STDCALL]
foreign func PeekMessageW(lpMsg: CPointer<Unit>, hWnd: UIntNative, wMsgFilterMin: UInt32, wMsgFilterMax: UInt32, wRemoveMsg: UInt32): Bool

@CallingConv[STDCALL]
foreign func TranslateMessage(lpMsg: CPointer<Unit>): Bool

@CallingConv[STDCALL]
foreign func DispatchMessageW(lpMsg: CPointer<Unit>): UIntNative

@CallingConv[STDCALL]
foreign func PostQuitMessage(nExitCode: Int32): Unit

@CallingConv[STDCALL]
foreign func DefWindowProcW(hWnd: UIntNative, Msg: UInt32, wParam: UIntNative, lParam: UIntNative): UIntNative

@CallingConv[STDCALL]
foreign func DestroyWindow(hWnd: UIntNative): Bool

@CallingConv[STDCALL]
foreign func GetClientRect(hWnd: UIntNative, lpRect: CPointer<Unit>): Bool

// ========== 常量 ==========

public let WS_OVERLAPPEDWINDOW: UInt32 = 0x00CF0000u32
public let WS_OVERLAPPED: UInt32 = 0x00000000u32
public let WS_CAPTION: UInt32 = 0x00C00000u32
public let WS_SYSMENU: UInt32 = 0x00080000u32
public let WS_THICKFRAME: UInt32 = 0x00040000u32
public let WS_MINIMIZEBOX: UInt32 = 0x00020000u32
public let WS_MAXIMIZEBOX: UInt32 = 0x00010000u32
public let WS_VISIBLE: UInt32 = 0x10000000u32
public let WS_CLIPCHILDREN: UInt32 = 0x02000000u32
public let WS_CLIPSIBLINGS: UInt32 = 0x04000000u32
public let CS_HREDRAW: UInt32 = 0x0002u32
public let CS_VREDRAW: UInt32 = 0x0001u32
public let CS_OWNDC: UInt32 = 0x0020u32
public let COLOR_WINDOW: Int32 = 5
public let SW_SHOW: Int32 = 5
public let WM_DESTROY: UInt32 = 0x0002u32
public let WM_SIZE: UInt32 = 0x0005u32
public let WM_CLOSE: UInt32 = 0x0010u32
public let WM_QUIT: UInt32 = 0x0012u32
public let WM_LBUTTONDOWN: UInt32 = 0x0201u32
public let WM_LBUTTONUP: UInt32 = 0x0202u32
public let WM_MOUSEMOVE: UInt32 = 0x0200u32
public let WM_MOUSEWHEEL: UInt32 = 0x020Au32
public let PM_REMOVE: UInt32 = 0x0001u32

// ========== 全局状态 ==========

public var g_hwnd: UIntNative = 0
public var g_running = AtomicBool(true)
public var g_width = AtomicInt32(1280)
public var g_height = AtomicInt32(720)

// ========== 鼠标/轨道控制状态 ==========

public var g_mouseDown: Bool = false
public var g_mouseX: Int32 = 0
public var g_mouseY: Int32 = 0
public var g_mouseDeltaX: Int32 = 0
public var g_mouseDeltaY: Int32 = 0
public var g_mouseWheelDelta: Int32 = 0

// 窗口过程回调 - 保存 CFunc 引用防止被 GC
var g_wndProcRef: ?CFunc<(UIntNative, UInt32, UIntNative, UIntNative) -> UIntNative> = None

@C
@CallingConv[STDCALL]
func wndProc(hWnd: UIntNative, uMsg: UInt32, wParam: UIntNative, lParam: UIntNative): UIntNative {
    if (uMsg == WM_DESTROY) {
        println("  [wndProc] WM_DESTROY")
        g_running.store(false)
        unsafe{ PostQuitMessage(0) }
        return 0
    } else if (uMsg == WM_SIZE) {
        let w = Int32(lParam & 0xFFFF)
        let h = Int32((lParam >> 16) & 0xFFFF)
        if (w > 0 && h > 0) {
            g_width.store(w)
            g_height.store(h)
        }
    } else if (uMsg == WM_CLOSE) {
        println("  [wndProc] WM_CLOSE")
        g_running.store(false)
        unsafe{ DestroyWindow(hWnd) }
        return 0
    } else if (uMsg == WM_LBUTTONDOWN) {
        g_mouseDown = true
        g_mouseX = Int32(lParam & 0xFFFF)
        g_mouseY = Int32((lParam >> 16) & 0xFFFF)
        g_mouseDeltaX = 0; g_mouseDeltaY = 0
        return 0
    } else if (uMsg == WM_LBUTTONUP) {
        g_mouseDown = false
        return 0
    } else if (uMsg == WM_MOUSEMOVE) {
        let newX = Int32(lParam & 0xFFFF)
        let newY = Int32((lParam >> 16) & 0xFFFF)
        if (g_mouseDown) {
            g_mouseDeltaX += newX - g_mouseX
            g_mouseDeltaY += newY - g_mouseY
        }
        g_mouseX = newX
        g_mouseY = newY
        return 0
    } else if (uMsg == WM_MOUSEWHEEL) {
        let lo32 = UInt32(wParam)
        let raw = (lo32 >> 16) & 0xFFFFu32
        // 高 16 位为有符号 Int16，手动转换避免 Int16() 溢出异常
        let delta = if (raw >= 0x8000u32) { Int32(raw) - 65536 } else { Int32(raw) }
        g_mouseWheelDelta += delta
        return 0
    }
    return unsafe{ DefWindowProcW(hWnd, uMsg, wParam, lParam) }
}

/// 将仓颉字符串转为 UTF-16 LE CPointer（以 null 结尾）
public func stringToWide(s: String): CPointer<UInt16> {
    let runes = s.toRuneArray()
    let len = runes.size
    let bufSize = Int64((len + 2) * 2 + 2)
    let buf = unsafe { LibC.malloc<UInt16>(count: bufSize) }
    let ptr = unsafe { CPointer<UInt16>(buf) }
    unsafe {
        var idx = 0
        for (r in runes) {
            let v = r
            if (UInt32(v) <= 0xFFFF) {
                (ptr + idx).write(UInt16(UInt32(v)))
                idx++
            } else {
                let v2 = Int64(UInt32(v)) - 0x10000
                (ptr + idx).write(UInt16(0xD800 + ((v2 >> 10) & 0x3FF)))
                idx++
                (ptr + idx).write(UInt16(0xDC00 + (v2 & 0x3FF)))
                idx++
            }
        }
        (ptr + idx).write(0u16)
    }
    return ptr
}

/**
 *  将 T类型 转换为 指针
 *  (目前仓颉仅64位运行时，T类型一般就是Int64等)
 */
func utilIntToCPointer<T>(int:T):CPointer<Unit> where T <: CType{
    unsafe{
        let pI = LibC.malloc<T>()
        pI.write(int)
        let retv = CPointer<CPointer<Unit>>(pI).read()
        LibC.free(pI)
        return retv
    }
}

/// 将 UIntNative (HWND) 转换为 CPointer<Unit> (nwh)
public func hwndToNwh(hwnd: UIntNative): CPointer<Unit> {
    return utilIntToCPointer(hwnd)
}

/// 创建 Win32 窗口，返回客户区尺寸 (width, height)
public func createWindow(): (Int32, Int32) {
    let hInstance = unsafe{ GetModuleHandleW(CPointer<UInt16>()) }

    // 注册窗口类
    let wcx = unsafe { LibC.malloc<UInt8>(count: Int64(80)) }
    unsafe {
        for (i in 0..80) { (wcx + i).write(0u8) }
        let sizePtr = CPointer<UInt32>(wcx)
        sizePtr.write(80u32)
        let stylePtr = CPointer<UInt32>(wcx + 4)
        stylePtr.write(CS_HREDRAW | CS_VREDRAW | CS_OWNDC)
        let wndProcFunc: CFunc<(UIntNative, UInt32, UIntNative, UIntNative) -> UIntNative> = wndProc
        g_wndProcRef = wndProcFunc
        let procPtr = CPointer<UIntNative>(wcx + 8)
        let procCPtr = unsafe { CPointer<Unit>(wndProcFunc) }
        procPtr.write(procCPtr.toUIntNative())
        let instPtr = CPointer<UIntNative>(wcx + 24)
        instPtr.write(hInstance)
        let idcArrowBuf = unsafe { LibC.malloc<UInt16>(count: Int64(2)) }
        CPointer<UInt16>(idcArrowBuf).write(32512u16)
        let hCursor = LoadCursorW(0, unsafe { CPointer<UInt16>(idcArrowBuf) })
        let cursorPtr = CPointer<UIntNative>(wcx + 40)
        cursorPtr.write(hCursor)
        unsafe { LibC.free(idcArrowBuf) }
        let bgPtr = CPointer<UIntNative>(wcx + 48)
        bgPtr.write(UIntNative(COLOR_WINDOW + 1))
        let className = stringToWide("sp_test_j_renderersWindow")
        let namePtr = CPointer<CPointer<UInt16>>(wcx + 64)
        namePtr.write(className)
    }
    let atom = unsafe{ RegisterClassExW(CPointer<Unit>(wcx)) }
    unsafe { LibC.free(wcx) }
    if (atom == 0) { println("RegisterClassExW failed!"); return (0, 0) }
    println("  窗口类注册成功")

    // 创建窗口
    let className2 = stringToWide("sp_test_j_renderersWindow")
    let windowTitle = stringToWide("shadowplane - sp_ambientlight 演示")
    let dwStyle = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS
    g_hwnd = unsafe{ CreateWindowExW(0u32, className2, windowTitle, dwStyle, 100, 100, 1280, 720, 0, 0, hInstance, CPointer<Unit>()) }
    unsafe { LibC.free(className2); LibC.free(windowTitle) }
    if (g_hwnd == 0) { println("CreateWindowExW failed!"); return (0, 0) }
    println("  窗口创建成功: hwnd=${g_hwnd}")

    unsafe{ ShowWindow(g_hwnd, SW_SHOW); UpdateWindow(g_hwnd) }

    // 获取客户区大小
    let rectBuf = unsafe { LibC.malloc<UInt8>(count: Int64(16)) }
    unsafe{ GetClientRect(g_hwnd, CPointer<Unit>(rectBuf)) }
    let clientW = Int32(unsafe { CPointer<Int32>(rectBuf + 8).read() })
    let clientH = Int32(unsafe { CPointer<Int32>(rectBuf + 12).read() })
    unsafe { LibC.free(rectBuf) }
    g_width.store(clientW); g_height.store(clientH)
    println("  客户区大小: ${clientW}x${clientH}")

    return (clientW, clientH)
}

/// 处理 Windows 消息循环（非阻塞）
public func processWin32Messages(): Bool {
    let msgBuf = unsafe { LibC.malloc<UInt8>(count: Int64(48)) }
    var running = true
    while (unsafe { PeekMessageW(CPointer<Unit>(msgBuf), 0, 0, 0, PM_REMOVE) }) {
        let msgId = unsafe { CPointer<UInt32>(msgBuf + 8).read() }
        if (msgId == WM_QUIT) {
            println("  [loop] 收到 WM_QUIT, 退出循环")
            g_running.store(false)
            running = false
        } else {
            unsafe{ TranslateMessage(CPointer<Unit>(msgBuf)) }
            unsafe{ DispatchMessageW(CPointer<Unit>(msgBuf)) }
        }
    }
    unsafe { LibC.free(msgBuf) }
    return running
}
