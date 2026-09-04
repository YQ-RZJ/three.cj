package sp_ssr

/**
 * capture.cj —— SSR 中间 RT GPU→CPU 回读与落盘（调试专用）
 *
 * 触发方式：
 *   - 交互：窗口内按 C 键（win32.cj WM_KEYDOWN → requestCapture()）
 *   - 自动：命令行参数 --capture（main.cj 置 g_capAuto=true），第 45 帧自动抓取，
 *     落盘完成后自动退出渲染循环，便于无人值守诊断。
 *
 * 回读管线（bgfx 标准 readback 模式，经 Three.cj renderer 高阶 API 封装）：
 *   RT 纹理（TEXTURE_RT，不可直接读）
 *     → renderer.blitTexture 拷贝到 TEXTURE_READ_BACK 纹理（同格式同尺寸）
 *     → renderer.readTexture 异步拷贝到 CPU 内存（PtrArray<UInt8>）
 *     → 等待 ≥6 个 bgfx frame（渲染循环推进）后读取落盘。
 *   blit 使用空闲 view id 250（SSA0~SAO 160-175 / SSR 176-181 / composer 230+ 均不冲突）。
 *
 * 分层原则：本测试项目只使用 Three.cj 重公开的接口（renderer 高阶 API /
 * renderers.types 类型 / BgfxConstants 常量），不直接接触 bgfx4cj 底层。
 *
 * 落盘产物（工作目录下 capture/，均为 RGBA8 原始像素，行主序、原点左上）：
 *   scene.raw / scene_a.raw      场景色（composer writeBuffer，RGBA16F）
 *   normal.raw / normal_a.raw    法线 RT（0.5+0.5 编码 view 法线）
 *   depth_ndc.raw                NDC 深度线性灰度（gl_FragCoord.z × 255）
 *   depth_vz.raw                 viewZ/far 灰度（近处亮、远处暗，对比度拉伸）
 *   ssr.raw / ssr_a.raw          SSR 步进结果（模糊前）
 *   blur2.raw / blur2_a.raw      二级模糊结果（最终 SSR）
 * 数值异常（NaN/Inf）像素标记为品红 (255,0,255)。
 * 每张图同时在控制台输出 min/max/NaN 统计（命中像素数等），便于快速数值诊断。
 * .raw 由 raw2png.py 批量转 PNG。
 */

import std.fs.*
import std.io.*
import std.math.*
import std.env.*
import std.sync.*
import std.collection.*
import three.rendering.BgfxRenderer
import three.rendering.postprocessing.BgfxSSRPass
import three.rendering.postprocessing.EffectComposer
import three.rendering.types.*
import three.rendering.bgfx.BgfxConstants
import three.utils.memory.PtrArray

/// 单个回读目标描述
class CaptureEntry {
    var name: String = ""
    var src: TextureHandle = INVALID_TEXTURE_HANDLE
    var rb: TextureHandle = INVALID_TEXTURE_HANDLE
    var data: PtrArray<UInt8> = PtrArray<UInt8>(0)
    var fmt: UInt32 = 0u32
    var isDepth: Bool = false
}

// ===== 抓取状态机 =====
var g_capEntries = ArrayList<CaptureEntry>()
var g_capState: Int64 = 0      // 0=idle，1=已发起回读、等待数据就绪
var g_capWait: Int64 = 0
var g_capAuto: Bool = false    // --capture 自动模式
var g_capW: Int64 = 0
var g_capH: Int64 = 0
var g_capNear: Float64 = 0.1
var g_capFar: Float64 = 100.0
let g_capRequested = AtomicBool(false)

/** 请求抓取一帧的 SSR 全部中间 RT（'C' 键 / --capture 自动模式） */
public func requestCapture(): Unit {
    g_capRequested.store(true)
}

/**
 * 每帧调用（composer.render 之后）：推进抓取状态机。
 *
 * @param frame 当前帧号（自动模式第 45 帧触发）
 * @param near/far 相机近远平面（depth_vz 可视化用）
 */
public func tickCapture(
    renderer: BgfxRenderer,
    ssrPass: BgfxSSRPass,
    composer: EffectComposer,
    frame: Int64,
    near: Float64,
    far: Float64
): Unit {
    if (g_capAuto && g_capState == 0 && frame == 45) {
        println("[capture] --capture 自动模式：第 45 帧触发抓取")
        g_capRequested.store(true)
    }
    if (g_capState == 0) {
        if (g_capRequested.load()) {
            g_capRequested.store(false)
            g_capNear = near
            g_capFar = far
            _issueCapture(renderer, ssrPass, composer)
            g_capState = 1
            g_capWait = 6
        }
    } else {
        g_capWait -= 1
        if (g_capWait <= 0) {
            _dumpAndCleanup(renderer)
            g_capState = 0
            if (g_capAuto) {
                println("[capture] 自动模式落盘完成，退出渲染循环")
                // 诊断模式直接退进程：renderer.shutdown() 的 bgfx 渲染线程同步存在死锁风险
                // （进程退出由 OS 回收全部资源；落盘文件已写完关闭，数据完整）。
                // flush 保证管道重定向下尾部日志不丢失。
                getStdOut().flush()
                exit(0)
            }
        }
    }
}

/** 发起回读：创建 readback 纹理 + blit + read_texture（经 renderer 高阶 API 序列化到渲染线程） */
func _issueCapture(renderer: BgfxRenderer, ssrPass: BgfxSSRPass, composer: EffectComposer): Unit {
    let w = ssrPass.rtWidth()
    let h = ssrPass.rtHeight()
    if (w <= 0 || h <= 0) {
        println("[capture] pass RT 尺寸无效（首帧前？），放弃抓取")
        return
    }
    g_capW = w
    g_capH = h
    g_capEntries.clear()

    let rgba16f = TextureFormat.RGBA16F.value()
    let rgba32f = TextureFormat.RGBA32F.value()

    // 场景色：composer.render 返回时 SSR pass（needsSwap=true）已交换 read/write，
    // 场景（RenderPass 输出，needsSwap=false 未交换）在 writeBuffer 中。
    let sceneTex = renderer.getTexture(composer.writeBuffer(), 0u8)

    _addEntry("scene", sceneTex, rgba16f, false)
    _addEntry("normal", ssrPass.normalTexture(), rgba16f, false)
    _addEntry("depth", ssrPass.depthTexture(), rgba32f, true)
    _addEntry("ssr", ssrPass.ssrTexture(), rgba16f, false)
    _addEntry("blur2", ssrPass.blur2Texture(), rgba16f, false)

    // 地面反射器中间 RT（诊断地面反射失败根因）：反射 RT（color）+ 反射深度 RT（NDC 深度）
    match (ssrPass.groundReflector) {
        case Some(reflector) =>
            let (rtW, rtH) = reflector.getTextureSize()
            if (rtW > 0 && rtH > 0) {
                _addEntry("reflectRT", reflector.getRenderTarget(), rgba16f, false)
                if (reflector.useDepthTexture) {
                    _addEntry("reflectDepthRT", reflector.getReflectDepthTex(), rgba32f, true)
                }
            } else {
                println("[capture] 反射 RT 尺寸无效，跳过反射 RT 抓取")
            }
        case None => println("[capture] 无 groundReflector，跳过反射 RT 抓取")
    }

    for (e in g_capEntries) {
        if (!isValidHandle(e.src)) {
            println("[capture] 警告：${e.name} 源纹理无效，跳过")
            continue
        }
        let bpp = if (e.fmt == rgba32f) { 16i64 } else { 8i64 }
        e.data = PtrArray<UInt8>(w * h * bpp)
    }

    // 逐个走 renderer 高阶 API（内部各自 _execBgfx 序列化，避免嵌套 execBgfx 死锁）
    for (e in g_capEntries) {
        if (!isValidHandle(e.src) || e.data.size() == 0) { continue }
        e.rb = renderer.createTexture2D(
            UInt16(w), UInt16(h), false, 1u16, e.fmt,
            UInt64(BgfxConstants.TEXTURE_READ_BACK), None)
        renderer.blitTexture(250u16, e.rb, e.src, UInt16(w), UInt16(h))
        let readyFrame = renderer.readTexture(e.rb, e.data, mip: 0u8)
        println("[capture] 回读已发起: ${e.name} rb=${handleIdx(e.rb)} readyFrame=${readyFrame}")
    }
    println("[capture] ${g_capEntries.size} 个 RT 回读已提交（scene/normal/depth/ssr/blur2/...），等待帧推进...")
}

func _addEntry(name: String, tex: TextureHandle, fmt: UInt32, isDepth: Bool): Unit {
    let e = CaptureEntry()
    e.name = name
    e.src = tex
    e.fmt = fmt
    e.isDepth = isDepth
    g_capEntries.add(e)
}

/** 数据就绪后：转 RGBA8 落盘 + 控制台统计 + 释放资源 */
func _dumpAndCleanup(renderer: BgfxRenderer): Unit {
    let w = g_capW
    let h = g_capH
    // 防御：目录已存在时 Directory.create 会抛异常致进程以 exit 1 崩溃，先判存在
    if (!exists(Path("capture"))) {
        Directory.create(Path("capture"), recursive: true)
    }
    // 第一遍：全部 raw（PNG 分析所需的最小集合，File.writeTo 小文件从未卡过）
    for (e in g_capEntries) {
        if (e.data.size() == 0) { continue }
        if (e.isDepth) {
            _dumpDepth(e, w, h)
        } else {
            _dumpColor(e, w, h)
        }
        getStdOut().flush()
    }
    // 第二遍：binf（仅供 ssr_repro.py 离线复算；独立文件名避免截断已有文件时偶发阻塞）
    for (e in g_capEntries) {
        if (e.data.size() == 0) { continue }
        _dumpRawBinf(e, w, h)
        e.data.dispose()
        e.data = PtrArray<UInt8>(0)
        getStdOut().flush()
    }
    // 销毁 readback 纹理（经 renderer 高阶 API 序列化）
    for (e in g_capEntries) {
        if (isValidHandle(e.rb)) {
            renderer.destroyTexture(e.rb)
            e.rb = INVALID_TEXTURE_HANDLE
        }
    }
    g_capEntries.clear()
    println("[capture] 落盘完成 → capture/*.raw（执行 python raw2png.py 转 PNG 查看）")
}

/** RGBA16F 颜色纹理 → *_raw（rgb）+ *_a.raw（alpha 灰度），含 NaN 品红标记与统计 */
func _dumpColor(e: CaptureEntry, w: Int64, h: Int64): Unit {
    let npix = w * h
    let out = Array<Byte>(npix * 4, repeat: 0u8)
    let outA = Array<Byte>(npix * 4, repeat: 0u8)
    let p = CPointer<UInt16>(e.data.data())
    var nanCnt: Int64 = 0
    var hitCnt: Int64 = 0       // alpha > 0.5/255 的像素数（SSR 命中）
    var minV = 1e30
    var maxV = -1e30
    for (i in 0..npix) {
        let r = _halfToF64(unsafe { (p + i * 4 + 0).read() })
        let g = _halfToF64(unsafe { (p + i * 4 + 1).read() })
        let b = _halfToF64(unsafe { (p + i * 4 + 2).read() })
        let a = _halfToF64(unsafe { (p + i * 4 + 3).read() })
        if (r.isNaN() || g.isNaN() || b.isNaN() || a.isNaN() ||
            r.isInf() || g.isInf() || b.isInf() || a.isInf()) {
            nanCnt += 1
            _setPx(out, i, 255u8, 0u8, 255u8)
            _setPx(outA, i, 255u8, 0u8, 255u8)
        } else {
            _setPx(out, i, _toByte(r), _toByte(g), _toByte(b))
            let ab = _toByte(a)
            _setPx(outA, i, ab, ab, ab)
            if (a > 0.004) { hitCnt += 1 }
            if (r < minV) { minV = r }
            if (r > maxV) { maxV = r }
        }
    }
    File.writeTo(Path("capture/${e.name}.raw"), out)
    File.writeTo(Path("capture/${e.name}_a.raw"), outA)
    let hitPct = Float64(hitCnt) / Float64(npix) * 100.0
    println("[capture] ${e.name}: ${w}x${h} NaN/Inf=${nanCnt} hit(alpha>0)=${hitCnt} (${hitPct}%) rgb[min,max]=[${minV}, ${maxV}]")
}

/** RGBA32F 深度纹理 → depth_ndc.raw（线性）+ depth_vz.raw（viewZ/far 对比度拉伸） */
func _dumpDepth(e: CaptureEntry, w: Int64, h: Int64): Unit {
    let npix = w * h
    let outNdc = Array<Byte>(npix * 4, repeat: 0u8)
    let outVz = Array<Byte>(npix * 4, repeat: 0u8)
    let p = CPointer<Float32>(e.data.data())
    var nanCnt: Int64 = 0
    var bgCnt: Int64 = 0
    var minD = 1e30
    var maxD = -1e30
    let near = g_capNear
    let far = g_capFar
    for (i in 0..npix) {
        let d = Float64(unsafe { (p + i * 4).read() })
        if (d.isNaN() || d.isInf()) {
            nanCnt += 1
            _setPx(outNdc, i, 255u8, 0u8, 255u8)
            _setPx(outVz, i, 255u8, 0u8, 255u8)
        } else {
            let db = _toByte(d)
            _setPx(outNdc, i, db, db, db)
            // viewZ = near*far / (far - (far-near)*d)（左手系正 viewZ）
            let denom = far - (far - near) * d
            let vz = if (abs(denom) > 1e-6) { near * far / denom } else { far }
            _setPx(outVz, i, _toByte(vz / far), _toByte(vz / far), _toByte(vz / far))
            if (d >= 0.999) { bgCnt += 1 }
            if (d < minD) { minD = d }
            if (d > maxD) { maxD = d }
        }
    }
    File.writeTo(Path("capture/depth_ndc.raw"), outNdc)
    File.writeTo(Path("capture/depth_vz.raw"), outVz)
    let bgPct = Float64(bgCnt) / Float64(npix) * 100.0
    println("[capture] depth: ${w}x${h} NaN/Inf=${nanCnt} 背景(d>=0.999)=${bgCnt} (${bgPct}%) ndc[min,max]=[${minD}, ${maxD}]")
}

// ===== 像素工具 =====

/** 原始浮点 buffer 分块落盘（capture/<name>.binf，供 ssr_repro.py 离线复算步进）。
 *  分块（1MB）而非一次性 Array<Byte>(total)：depth 为 RGBA32F 共 13.7MB，
 *  单块巨型托管数组的分配+填充曾观测到分钟级卡滞，分块可稳定秒级完成。
 *  文件名冲突时加序号后缀：观测到截断已存在的大 binf 时 File.create 偶发长时间阻塞，
 *  写全新文件名可绕开（旧 binf 由外部脚本清理）。 */
func _dumpRawBinf(e: CaptureEntry, w: Int64, h: Int64): Unit {
    let bpp = if (e.isDepth) { 16i64 } else { 8i64 }
    let total = w * h * bpp
    let chunk: Int64 = 1024 * 1024
    let p = CPointer<UInt8>(e.data.data())
    var fname = "capture/${e.name}.binf"
    var idx: Int64 = 0
    while (exists(Path(fname))) {
        idx += 1
        fname = "capture/${e.name}_${idx}.binf"
    }
    let file = File.create(Path(fname))
    var off: Int64 = 0
    while (off < total) {
        let n = min(chunk, total - off)
        let buf = Array<Byte>(n, repeat: 0u8)
        for (i in 0..n) {
            buf[i] = unsafe { (p + off + i).read() }
        }
        file.write(buf)
        off += n
    }
    file.close()
    println("[capture] ${fname} 落盘 ${total} 字节")
    getStdOut().flush()
}

func _setPx(out: Array<Byte>, i: Int64, r: UInt8, g: UInt8, b: UInt8): Unit {
    out[i * 4 + 0] = r
    out[i * 4 + 1] = g
    out[i * 4 + 2] = b
    out[i * 4 + 3] = 255u8
}

func _toByte(v: Float64): UInt8 {
    if (v <= 0.0) { return 0u8 }
    if (v >= 1.0) { return 255u8 }
    return UInt8(v * 255.0)
}

/** IEEE754 half → Float64；Inf/NaN 统一返回 NaN（调用方标记品红） */
func _halfToF64(h: UInt16): Float64 {
    let neg = (h & 0x8000u16) != 0u16
    let e = Int64((h >> 10) & 0x1Fu16)
    let f = Float64(h & 0x03FFu16)
    if (e == 0) {
        let v = f / 1024.0 * 6.103515625e-5
        return if (neg) { -v } else { v }
    }
    if (e == 31) { return Float64.NaN }
    let v = (1.0 + f / 1024.0) * pow(2.0, Float64(e - 15))
    return if (neg) { -v } else { v }
}
