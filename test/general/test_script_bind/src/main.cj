/**
 * @file main
 * @brief three.script.prebind LuaBindingFactory 集成验证测试
 *
 * 真实调用 LuaBindingFactory.installAll 装入全部 prebind 绑定后，
 * 从 Lua 侧创建引擎对象、调用方法、读写属性，逐场景断言 PASS/FAIL，
 * 最后返回 0/1 并落盘 script_bind_test.log。
 *
 * 场景覆盖：
 *   1. installAll 全量安装（数量/清单一致性）
 *   2. Vector3 纯 Lua 链式（set/normalize 返回自身）
 *   3. 仓颉↔Lua 对象互操作（clone/add + getGlobal）
 *   4. Matrix4（identity/multiply/determinant/elements）
 *   5. MathUtils 静态方法
 *   6. dsa：RingBuffer（未绑则 WARN）/ UnionFind / SpatialHashGrid
 *   7. EventDispatcher 事件分发（Lua 回调计数）
 *   8. utils：Logger / UUID / Constants
 *   9. time/thread 轻量调用（Timer/Clock/Mutex 不抛即可）
 *   9b~9t. 数据类型（LruCache/BinaryHeap/…/interpolants/ColorManagement）、
 *         animation（轨道/剪辑/离线/骨骼）、audio（设备/音源/回调投递）、
 *         network（协议编解码/HTTP/Socket/长连接/可靠 UDP/帧同步/快照）、
 *         physics（枚举/形状/描述/句柄/刚体/世界/高级描述）、
 *         profiler（Tracy 门面 zone/frame/plot/message/memory/gpu/lock/scope/state）、
 *         resource（工具/缓存/加载结果/GltfTypes/ZIP/加载器构造/资源管线）、
 *         scene（ECS 运行时 + Lua 装饰器 / Object3D / SceneGraph / 全部实体）
 *   10. 已登记绑定类在 Lua 侧全部可访问
 */
package threeScriptBindTest

import std.io.*
import std.fs.{File, Path as FsPath}
import std.collection.*
import std.math.*
import three.script.vm.*
import three.script.prebind.*

// =============================================================================
// 简易断言工具（同时落盘，绕开 stdout 缓冲以便崩溃定位）
// =============================================================================

private var _passCount: Int64 = 0
private var _failCount: Int64 = 0
private var _warnCount: Int64 = 0

/// 落盘一条测试记录
private func _logLine(line: String): Unit {
    try {
        File.appendTo(FsPath("./script_bind_test.log"), (line + "\n").toArray())
    } catch (_) {
        // 忽略落盘失败
    }
}

/// 断言：布尔条件
private func check(name: String, cond: Bool): Unit {
    if (cond) {
        _passCount += 1
        println("  [PASS] ${name}")
        _logLine("[PASS] ${name}")
    } else {
        _failCount += 1
        println("  [FAIL] ${name}")
        _logLine("[FAIL] ${name}")
    }
}

/// 断言：数值相等（容差）
private func checkEq(name: String, got: Float64, expected: Float64, tol!: Float64 = 0.0001): Unit {
    let diff = if (got > expected) { got - expected } else { expected - got }
    check(name, diff <= tol)
}

/// 警告（不算 FAIL，如"某类本来未绑被跳过"）
private func warn(msg: String): Unit {
    _warnCount += 1
    println("  [WARN] ${msg}")
    _logLine("[WARN] ${msg}")
}

/// 执行 Lua 脚本；执行失败记 FAIL 并返回空结果
private func runLua(vm: LuaVM, name: String, script: String): Array<LuaValue> {
    try {
        return vm.doString(script)
    } catch (e: LuaError) {
        _failCount += 1
        let msg = "${name}: LuaError ${e.message}"
        println("  [FAIL] ${msg}")
        _logLine("[FAIL] ${msg}")
    } catch (e: Exception) {
        _failCount += 1
        let msg = "${name}: Exception ${e.message}"
        println("  [FAIL] ${msg}")
        _logLine("[FAIL] ${msg}")
    }
    return []
}

// =============================================================================
// 测试入口
// =============================================================================

main(): Int64 {
    println("=== three.script.prebind LuaBindingFactory 集成验证 ===\n")

    let vm = LuaVM(openLibs: true)
    check("LuaVM 创建成功", vm.releasable)

    // ---------- 1. installAll 全量安装 ----------
    println("[1] LuaBindingFactory.installAll")
    var installed: Int64 = 0
    var installOk: Bool = true
    try {
        installed = LuaBindingFactory.installAll(vm)
    } catch (e: Exception) {
        installOk = false
        println("  [FAIL] installAll 抛异常: ${e.message}")
        _logLine("[FAIL] installAll 抛异常: ${e.message}")
        _failCount += 1
    }
    if (installOk) {
        check("installAll 返回 ≥ 50（实际 ${installed}）", installed >= 50)
        println("  installAll 返回: ${installed}")
    }
    let cnt = LuaBindingFactory.count
    let classes = LuaBindingFactory.boundClasses
    check("count ≥ 50（实际 ${cnt}）", cnt >= 50)
    check("count == boundClasses.size", cnt == classes.size)
    if (installOk) {
        check("installAll 新增数 == count（一次装入无跳过）", installed == cnt)
    }
    if (cnt != 477) {
        warn("绑定登记数 = ${cnt}，与任务预期 477 不符")
    }
    let r3exists = runLua(vm, "全局 three 命名空间", "return three ~= nil")
    check("Lua 侧存在 three 全局表", r3exists.size > 0 && r3exists[0].boolValue())
    println("")

    // ---------- 2. Vector3 纯 Lua 链式 ----------
    println("[2] Vector3 纯 Lua 链式（set/clone/normalize 返回自身）")
    let r2 = runLua(vm, "Vector3 链式",
        "local v = three.core.math.Vector3.new(1,2,3); v:set(4,5,6):normalize(); return v:length(), v.x, v.y, v.z")
    check("Vector3 链式返回有效（4 个值）", r2.size == 4)
    if (r2.size >= 4) {
        checkEq("normalize 后 length ≈ 1", r2[0].numberValue(), 1.0)
        checkEq("normalized x ≈ 0.45584", r2[1].numberValue(), 0.455842, tol: 0.001)
        checkEq("normalized y ≈ 0.56980", r2[2].numberValue(), 0.569803, tol: 0.001)
        check("normalized z 非空", !r2[3].isNil)
    }
    println("")

    // ---------- 3. 仓颉↔Lua 对象互操作 ----------
    println("[3] 仓颉↔Lua（clone/add + getGlobal）")
    let r3 = runLua(vm, "clone/add",
        "v = three.core.math.Vector3.new(1,2,3); w = v:clone(); w:add(v); return w.x, w.y, w.z")
    check("clone/add 返回有效（3 个值）", r3.size == 3)
    if (r3.size >= 3) {
        checkEq("w.x = 1+1 = 2", r3[0].numberValue(), 2.0)
        checkEq("w.y = 2+2 = 4", r3[1].numberValue(), 4.0)
        checkEq("w.z = 3+3 = 6", r3[2].numberValue(), 6.0)
    }
    check("getGlobal v 是对象", vm.getGlobal("v").isObject)
    check("getGlobal w 是对象", vm.getGlobal("w").isObject)
    let rv = runLua(vm, "读 v.x", "return v.x, v:length()")
    check("clone 不影响原对象（v.x 仍 = 1）", rv.size >= 1 && rv[0].numberValue() == 1.0)
    println("")

    // ---------- 4. Matrix4 ----------
    println("[4] Matrix4（identity/multiply/determinant/elements）")
    let r4 = runLua(vm, "Matrix4",
        "local a = three.core.math.Matrix4.new():identity(); " +
        "local b = three.core.math.Matrix4.new():identity(); " +
        "a:multiply(b); " +
        "local el = a.elements; " +
        "return a:determinant(), el[1], el[6], el[11], el[16]")
    check("Matrix4 返回有效（5 个值）", r4.size == 5)
    if (r4.size >= 5) {
        checkEq("identity*identity determinant ≈ 1", r4[0].numberValue(), 1.0)
        checkEq("elements[1]（m11）≈ 1", r4[1].numberValue(), 1.0)
        checkEq("elements[6]（m22）≈ 1", r4[2].numberValue(), 1.0)
        checkEq("elements[11]（m33）≈ 1", r4[3].numberValue(), 1.0)
        checkEq("elements[16]（m44）≈ 1", r4[4].numberValue(), 1.0)
    }
    println("")

    // ---------- 5. MathUtils 静态 ----------
    println("[5] MathUtils 静态方法")
    let r5 = runLua(vm, "MathUtils 静态",
        "return three.core.math.MathUtils.clamp(5,0,10), " +
        "three.core.math.MathUtils.clamp(15,0,10), " +
        "three.core.math.MathUtils.lerp(0,10,0.5), " +
        "three.core.math.MathUtils.degToRad(180), " +
        "three.core.math.MathUtils.euclideanModulo(7,3)")
    check("MathUtils 返回有效（5 个值）", r5.size == 5)
    if (r5.size >= 5) {
        checkEq("clamp(5,0,10) = 5", r5[0].numberValue(), 5.0)
        checkEq("clamp(15,0,10) = 10", r5[1].numberValue(), 10.0)
        checkEq("lerp(0,10,0.5) = 5", r5[2].numberValue(), 5.0)
        checkEq("degToRad(180) ≈ π", r5[3].numberValue(), 3.14159265, tol: 0.000001)
        checkEq("euclideanModulo(7,3) = 1", r5[4].numberValue(), 1.0)
    }
    println("")

    // ---------- 6. dsa ----------
    println("[6] dsa：RingBuffer（未绑则 WARN）/ UnionFind / SpatialHashGrid")
    // RingBuffer 为泛型类（绑定清单标注"暂不绑"）→ nil 时 WARN 不算 FAIL
    let rb = runLua(vm, "RingBuffer 存在性", "return three.core.dsa.RingBuffer ~= nil")
    if (rb.size > 0 && rb[0].boolValue()) {
        let rrb = runLua(vm, "RingBuffer push/pop",
            "local q = three.core.dsa.RingBuffer.new(4); q:add(1); q:add(2); return q:remove()")
        check("RingBuffer pop 返回有效", rrb.size >= 1)
        if (rrb.size >= 1) {
            checkEq("RingBuffer pop = 1（FIFO）", rrb[0].numberValue(), 1.0)
        }
    } else {
        warn("three.core.dsa.RingBuffer 未绑定（泛型类暂不绑，绑定清单已标注）——跳过，不算 FAIL")
    }
    let ru = runLua(vm, "UnionFind",
        "local u = three.core.dsa.UnionFind.new(4); " +
        "u:union(0,1); u:union(2,3); u:union(1,2); " +
        "return u:connected(0,3), u.componentCount, u.size")
    check("UnionFind 返回有效（3 个值）", ru.size == 3)
    if (ru.size >= 3) {
        check("connected(0,3) = true（四元素全连通）", ru[0].boolValue())
        check("componentCount == 1", ru[1].intValue() == 1)
        check("size == 4", ru[2].intValue() == 4)
    }
    let rg = runLua(vm, "SpatialHashGrid",
        "local g = three.core.dsa.SpatialHashGrid.new(1.0); " +
        "g:insert(7, 0.5, 0.5, 0.5, 0.1); " +
        "return g.elementCount, g.cellCount")
    check("SpatialHashGrid 返回有效（2 个值）", rg.size == 2)
    if (rg.size >= 2) {
        check("elementCount == 1", rg[0].intValue() == 1)
        check("cellCount >= 1", rg[1].intValue() >= 1)
    }
    println("")

    // ---------- 7. event ----------
    println("[7] EventDispatcher 事件分发（Lua 回调计数）")
    let r7 = runLua(vm, "EventDispatcher",
        "evCount = 0; " +
        "local d = three.core.event.EventDispatcher.new(); " +
        "d:addEventListener('boom', function(e) evCount = evCount + 1 end); " +
        "local e = three.core.event.Event.new('boom'); " +
        "d:dispatchEvent(e); d:dispatchEvent(e); " +
        "return evCount, d:hasEventListener('boom')")
    check("事件返回有效（2 个值）", r7.size == 2)
    if (r7.size >= 2) {
        check("监听回调执行 2 次", r7[0].intValue() == 2)
        check("hasEventListener('boom') = true", r7[1].boolValue())
    }
    println("")

    // ---------- 8. utils ----------
    println("[8] utils：Logger / UUID / Constants")
    let r8a = runLua(vm, "Logger",
        "three.utils.log.Logger.setLevel(3); return three.utils.log.Logger.getLevel()")
    check("Logger.setLevel(3) → getLevel() == 3", r8a.size >= 1 && r8a[0].intValue() == 3)
    let r8b = runLua(vm, "UUID", "return three.utils.encode.UUID.uuid()")
    check("UUID.uuid() 返回非空字符串", r8b.size >= 1 && !r8b[0].isNil && r8b[0].stringValue().size > 0)
    let r8c = runLua(vm, "Constants",
        "return three.utils.constants.Constants.MOUSE_LEFT(), " +
        "three.utils.constants.Constants.CullFaceBack(), " +
        "three.utils.constants.Constants.REVISION()")
    check("Constants 返回有效（3 个值）", r8c.size == 3)
    if (r8c.size >= 3) {
        check("MOUSE_LEFT == 0", r8c[0].intValue() == 0)
        check("CullFaceBack == 1", r8c[1].intValue() == 1)
        check("REVISION 为非空字符串", !r8c[2].isNil && r8c[2].stringValue().size > 0)
    }
    println("")

    // ---------- 9. time / thread 轻量调用 ----------
    println("[9] time/thread 轻量调用（不抛即可）")
    let r9 = runLua(vm, "Timer/Clock/Mutex",
        "local t = three.core.time.Timer.new(); t:update(); t:reset(); " +
        "local c = three.core.time.Clock.new(); c:start(); c:stop(); " +
        "local m = three.core.thread.Mutex.new(); m:lock(); m:unlock(); " +
        "return true")
    check("Timer/Clock/Mutex 调用不抛异常", r9.size >= 1 && r9[0].boolValue())
    println("")

    // ---------- 9b. LruCache 泛型容器（LuaValue Hashable/Equatable 通道） ----------
    println("[9b] LruCache 泛型容器（LuaValue 键值，定容淘汰）")
    let r9b = runLua(vm, "LruCache",
        "local c = three.core.dsa.LruCache.new(3); " +
        "c:put('a', 1); c:put('b', 2); c:put('c', 3); " +
        "local v = c:get('b'); " +              // 命中 b → 2
        "c:put('d', 4); " +                      // 容量 3，淘汰最久未用 a
        "local hasA = c:contains('a'); " +
        "local stats = c.capacity .. ':' .. c.size .. ':' .. c.hits .. ':' .. c.misses .. ':' .. c.evictions; " +
        "local clearOk = true; " +
        "return v, hasA, stats")
    check("LruCache 返回有效（3 个值）", r9b.size == 3)
    if (r9b.size >= 3) {
        checkEq("get('b') = 2", r9b[0].numberValue(), 2.0)
        check("容量满后逐出最久未用（contains('a') = false）", r9b[1].isObject == false && r9b[1].boolValue() == false)
        check("capacity=3 size=3 hits=1 misses=0 evictions=1",
            r9b[2].stringValue() == "3:3:1:0:1")
    }
    println("")

    // ---------- 9c. BinaryHeap 泛型堆（LuaValue 实现 IHeapNode，索引可维护） ----------
    println("[9c] BinaryHeap 泛型堆（LuaValue 作为堆节点）")
    let r9c = runLua(vm, "BinaryHeap",
        "local h = three.core.dsa.BinaryHeap.new(); " +
        "h:push(3); h:push(1); h:push(2); " +
        "local a = h:pop(); local b = h:pop(); local c = h:pop(); " +
        "return a, b, c, h:isEmpty()")
    check("BinaryHeap 返回有效（4 个值）", r9c.size == 4)
    if (r9c.size >= 4) {
        check("最小堆 pop 序 1,2,3", r9c[0].intValue() == 1 && r9c[1].intValue() == 2 && r9c[2].intValue() == 3)
        check("pop 后 isEmpty() = true", r9c[3].boolValue())
    }
    println("")

    // ---------- 9d. BinaryPatriciaTrie（UInt8 字节键）+ setFromPoints（对象数组） ----------
    println("[9d] BinaryPatriciaTrie（字节键）+ Sphere/Box3 setFromPoints（对象数组）")
    let r9d = runLua(vm, "BinaryPatriciaTrie/setFromPoints",
        "local t = three.core.dsa.BinaryPatriciaTrie.new(); " +
        "t:set({1, 2, 3}, 'abc'); t:set({1, 2, 4}, 'abd'); " +
        "local v = t:get({1, 2, 3}); " +
        "local hasKey = t:has({1, 2, 4}); " +
        "local del = t:delete({1, 2, 3}); " +
        "local sz = t.size; " +
        "local p1 = three.core.math.Vector3.new(0,0,0); " +
        "local p2 = three.core.math.Vector3.new(1,2,3); " +
        "local s = three.core.math.Sphere.new(); s:setFromPoints({p1, p2}); " +
        "local r = s.radius; " +
        "return v, hasKey, del, sz, r")
    check("BinaryPatriciaTrie/setFromPoints 返回有效（5 个值）", r9d.size == 5)
    if (r9d.size >= 5) {
        check("get({1,2,3}) = 'abc'", r9d[0].stringValue() == "abc")
        check("has({1,2,4}) = true", r9d[1].boolValue())
        check("delete({1,2,3}) = true", r9d[2].boolValue())
        check("删除后 size = 1", r9d[3].intValue() == 1)
        let sq2 = 14.0
        let r = sqrt(sq2)
        checkEq("Sphere 两散点半径 ≈ √14", r9d[4].numberValue(), r)
    }
    println("")

    // ---------- 9e. SphericalHarmonics3.set（对象数组系数） ----------
    println("[9e] SphericalHarmonics3.set（对象数组系数，9 项）")
    let r9e = runLua(vm, "SH3.set",
        "local sh = three.core.math.SphericalHarmonics3.new(); " +
        "local pts = {}; " +
        "for i = 1, 9 do pts[i] = three.core.math.Vector3.new(i, 0, 0) end " +
        "sh:set(pts); " +
        "c = sh.coefficients; " +
        "return #c, c[1].x, c[5].x, c[9].x")
    check("SH3.set 返回有效（4 个值）", r9e.size == 4)
    if (r9e.size >= 4) {
        check("set 后 coefficients 长度 = 9", r9e[0].intValue() == 9)
        check("c[1].x = 1", r9e[1].intValue() == 1)
        check("c[5].x = 5", r9e[2].intValue() == 5)
        check("c[9].x = 9", r9e[3].intValue() == 9)
    }
    println("")

    // ---------- 9f. 插值器（Interpolant 家族） ----------
    println("[9f] 插值器（LinearInterpolant.interpolate_ / 属性 / 结果缓冲）")
    let r9f = runLua(vm, "Interpolant",
        "local lp = three.core.math.interpolants.LinearInterpolant.new({0, 10}, {0, 100}, 1, {0}); " +
        "local out = lp:interpolate_(1, 0, 5, 10); " +
        "local rbuf = lp.resultBuffer; " +
        "local dv = lp.valueSize; " +
        "local sv = lp.sampleValues; " +
        "local bz = three.core.math.interpolants.BezierInterpolant.new({0, 1}, {0, 1}, 1); " +
        "local bb = bz.resultBuffer; " +
        "return out[1], rbuf[1], dv, #sv, #bb")
    check("Interpolant 返回有效（5 个值）", r9f.size == 5)
    if (r9f.size >= 5) {
        checkEq("线性插值中点 = 50", r9f[0].numberValue(), 50.0)
        checkEq("resultBuffer[1] = 50（就地写入）", r9f[1].numberValue(), 50.0)
        check("valueSize = 1", r9f[2].intValue() == 1)
        check("sampleValues 长度 = 2", r9f[3].intValue() == 2)
        check("无 resultBuffer 构造自动生成长度 1 缓冲", r9f[4].intValue() == 1)
    }
    println("")

    // ---------- 9g. ColorManagement（静态属性 / 转换 / 矩阵） ----------
    println("[9g] ColorManagement（get/set 静态属性、sRGB 往返、getMatrix）")
    let r9g = runLua(vm, "ColorManagement",
        "local CM = three.core.math.ColorManagement; " +
        "local en = CM.getEnabled(); " +
        "CM.setEnabled(false); local en2 = CM.getEnabled(); CM.setEnabled(true); " +
        "local ws = CM.getWorkingColorSpace(); " +
        "local lin = CM.sRGBToLinear(0.5); " +
        "local c = three.core.math.Color.new(0.5, 0.5, 0.5); " +
        "CM.convert(c, 'srgb', 'srgb-linear'); local g1 = c.g; " +
        "CM.convert(c, 'srgb-linear', 'srgb'); local g2 = c.g; " +
        "local m = CM.getMatrix(three.core.math.Matrix3.new(), 'srgb', 'srgb-linear'); " +
        "local prim = CM.getPrimaries('srgb'); " +
        "return en, en2, ws, lin, g1, g2, m.elements[1], #prim")
    check("ColorManagement 返回有效（8 个值）", r9g.size == 8)
    if (r9g.size >= 8) {
        check("enabled 默认 true", r9g[0].boolValue())
        check("setEnabled(false) 生效", !r9g[1].boolValue())
        check("workingColorSpace 非空", r9g[2].stringValue().size > 0)
        checkEq("sRGBToLinear(0.5) ≈ 0.2140", r9g[3].numberValue(), 0.214041, tol: 0.0001)
        checkEq("srgb→linear 后 g ≈ 0.2140", r9g[4].numberValue(), 0.214041, tol: 0.0001)
        checkEq("linear→srgb 往返 g ≈ 0.5", r9g[5].numberValue(), 0.5, tol: 0.001)
        checkEq("getMatrix(srgb→linear) m11 ≈ 1", r9g[6].numberValue(), 1.0, tol: 0.001)
        check("getPrimaries 长度 = 6", r9g[7].intValue() == 6)
    }
    println("")

    // ---------- 9h. animation：KeyframeTrack + tracks ----------
    println("[9h] animation：KeyframeTrack 基类 / NumberKeyframeTrack / 插值器工厂")
    let r9h = runLua(vm, "KeyframeTrack",
        "local K = three.animation.blend.KeyframeTrack; " +
        "local t = three.animation.tracks.NumberKeyframeTrack.new('demo.x', {0, 1, 2}, {0, 10, 20}); " +
        "local vs = t:getValueSize(); " +
        "local it = t:getInterpolation(); " +
        "local nm = t.name; " +
        "local tt = t.times; " +
        "t:shift(1); local t2 = t.times; " +
        "t:scale(2); local t3 = t.times; " +
        "local ok = t:validate(); " +
        "local interp = t:createInterpolant(); " +
        "local cloned = t:clone(); " +
        "return vs, it, nm, #tt, t2[1], t3[1], ok, interp ~= nil, cloned.name")
    check("KeyframeTrack 返回有效（9 个值）", r9h.size == 9)
    if (r9h.size >= 9) {
        check("getValueSize = 1", r9h[0].intValue() == 1)
        check("getInterpolation 默认 = InterpolateLinear(2301)", r9h[1].intValue() == 2301)
        check("name = 'demo.x'", r9h[2].stringValue() == "demo.x")
        check("times 长度 = 3", r9h[3].intValue() == 3)
        checkEq("shift(1) 后 times[1] = 1", r9h[4].numberValue(), 1.0)
        checkEq("scale(2) 后 times[1] = 2", r9h[5].numberValue(), 2.0)
        check("validate() = true", r9h[6].boolValue())
        check("createInterpolant() 返回对象", r9h[7].boolValue())
        check("clone() 保持 name", r9h[8].stringValue() == "demo.x")
    }
    println("")

    // ---------- 9i. animation：AnimationClip + AnimationUtils ----------
    println("[9i] animation：AnimationClip（resetDuration / trim / clone）+ AnimationUtils")
    let r9i1 = runLua(vm, "AnimationClip 构造",
        "local NumberTrack = three.animation.tracks.NumberKeyframeTrack; " +
        "local t1 = NumberTrack.new('a.x', {0, 2}, {0, 20}); " +
        "local t2 = NumberTrack.new('a.y', {0, 4}, {0, 40}); " +
        "local clip = three.animation.clip.AnimationClip.new('demo', -1, {t1, t2}); " +
        "return clip.duration, #clip.tracks, clip.blendMode, clip.name")
    check("AnimationClip 构造返回有效（4 个值）", r9i1.size == 4)
    if (r9i1.size >= 4) {
        checkEq("duration 由关键帧推导 = 4", r9i1[0].numberValue(), 4.0)
        check("tracks 长度 = 2", r9i1[1].intValue() == 2)
        check("blendMode = NormalAnimationBlendMode(2500)", r9i1[2].intValue() == 2500)
        check("name = 'demo'", r9i1[3].stringValue() == "demo")
    }
    let r9i2 = runLua(vm, "AnimationClip 方法",
        "local NumberTrack = three.animation.tracks.NumberKeyframeTrack; " +
        "local t1 = NumberTrack.new('a.x', {0, 2}, {0, 20}); " +
        "local clip = three.animation.clip.AnimationClip.new('demo', 4, {t1}); " +
        "local okv = clip:validate(); " +
        "local c2 = clip:clone(); " +
        "return okv, c2.name, #c2.tracks")
    check("AnimationClip 方法返回有效（3 个值）", r9i2.size == 3)
    if (r9i2.size >= 3) {
        check("validate() = true", r9i2[0].boolValue())
        check("clone 保持 name", r9i2[1].stringValue() == "demo")
        check("clone 保持 tracks 长度 = 1", r9i2[2].intValue() == 1)
    }
    let r9i3 = runLua(vm, "AnimationUtils 静态",
        "local AU = three.animation.clip.AnimationUtils; " +
        "local order = AU.getKeyframeOrder({2, 0, 1}); " +
        "local sorted = AU.sortedArray({10, 20, 30}, 1, {2, 0, 1}); " +
        "return order[1], order[2], order[3], sorted[1], sorted[2], sorted[3]")
    check("AnimationUtils 静态返回有效（6 个值）", r9i3.size == 6)
    if (r9i3.size >= 6) {
        check("getKeyframeOrder = 1,2,0（0 基）",
            r9i3[0].intValue() == 1 && r9i3[1].intValue() == 2 && r9i3[2].intValue() == 0)
        checkEq("sortedArray[1] = 30", r9i3[3].numberValue(), 30.0)
        checkEq("sortedArray[2] = 10", r9i3[4].numberValue(), 10.0)
        checkEq("sortedArray[3] = 20", r9i3[5].numberValue(), 20.0)
    }
    println("")

    // ---------- 9j. animation：offline（RawAnimation / RawSkeleton / 优化器） ----------
    println("[9j] animation.offline：RawAnimation / RawJoint / RawSkeleton / 优化器 / 工具")
    let r9j = runLua(vm, "offline",
        "local O = three.animation.offline; " +
        "local v3f = three.core.math.Vector3F; " +
        "local raw = O.RawAnimation.new(); raw:initTracks(1); " +
        "raw:addTranslationKeyframe(0, 0, v3f.new(0, 0, 0)); " +
        "raw:addTranslationKeyframe(0, 1, v3f.new(1, 2, 3)); " +
        "raw:addRotationKeyframe(0, 0, 0, 0, 0, 1); " +
        "raw:recalcDuration(); " +
        "local nTr = raw:numTranslationKeyframes(0); " +
        "local nRot = raw:numRotationKeyframes(0); " +
        "local dur = raw.duration; " +
        "local rok = raw:validate(); " +
        "local sk = O.RawSkeleton.new(); " +
        "local j0 = sk:addJoint('root', -1); " +
        "local j1 = sk:addJoint('spine', 0); " +
        "j1.localTranslation = v3f.new(0, 1, 0); " +
        "local nj = sk:numJoints(); " +
        "local sok = sk:validate(); " +
        "local jy = j1.localTranslation.y; " +
        "local opt = O.AnimationOptimizer.new(); " +
        "local copy = opt:optimizeCopy(raw); " +
        "local res = O.RawAnimationUtils.resample(raw, 10); " +
        "local maxj = O.RawSkeleton.MAX_JOINTS(); " +
        "return nTr, nRot, dur, rok, nj, sok, jy, copy.trackCount, res.name, maxj")
    check("offline 返回有效（10 个值）", r9j.size == 10)
    if (r9j.size >= 10) {
        check("RawAnimation 平移关键帧 = 2", r9j[0].intValue() == 2)
        check("RawAnimation 旋转关键帧 = 1", r9j[1].intValue() == 1)
        checkEq("recalcDuration 后 duration = 1", r9j[2].numberValue(), 1.0)
        check("RawAnimation validate = true", r9j[3].boolValue())
        check("RawSkeleton 关节数 = 2", r9j[4].intValue() == 2)
        check("RawSkeleton validate = true", r9j[5].boolValue())
        checkEq("RawJoint.localTranslation.y = 1（对象属性）", r9j[6].numberValue(), 1.0)
        check("optimizeCopy 保留轨道数 = 1", r9j[7].intValue() == 1)
        check("resample 返回新动画（名称带 _resampled）", r9j[8].stringValue().endsWith("_resampled"))
        check("RawSkeleton.MAX_JOINTS = 1024", r9j[9].intValue() == 1024)
    }
    println("")

    // ---------- 9k. animation：skeletal 数据 / 状态机 ----------
    println("[9k] animation.skeletal：JointTrack / SkeletalAnimationData / AnimatorController")
    let r9k = runLua(vm, "skeletal",
        "local S = three.animation.skeletal; " +
        "local jt = S.JointTrack.new(); " +
        "jt.transTimes = {0, 1}; jt.transValues = {0, 0, 0, 1, 2, 3}; " +
        "local nt = jt:numTransKeyframes(); " +
        "local data = S.SkeletalAnimationData.new(1.5, 1, {jt}); " +
        "local d = data.duration; local ntr = data.numTracks; local soa = data:numSoaJoints(); " +
        "local tk = data:track(0); " +
        "local ctrl = S.AnimatorController.new(); " +
        "local st = S.AnimatorState.new('idle', 'clipIdle'); " +
        "ctrl:addState(st); " +
        "local p = S.AnimatorParam.new('go', 0); ctrl:addParam(p); " +
        "ctrl:setBool('go', true); " +
        "local cur = ctrl:getCurrentStateName(); " +
        "local pv = p.boolValue; " +
        "local trans = S.AnimatorTransition.new('idle', 'run', 0.2, 0.0); " +
        "trans:addCondition('go', 0, 0); " +
        "ctrl:addTransition(trans); " +
        "local run = S.AnimatorState.new('run', 'clipRun'); ctrl:addState(run); " +
        "local skd = S.SkeletonData.new(); " +
        "local nj = skd:numJoints(); " +
        "local stats = S.SkeletonUtils.getStats(skd); " +
        "return nt, d, ntr, soa, cur, pv, nj, stats ~= nil")
    check("skeletal 返回有效（8 个值）", r9k.size == 8)
    if (r9k.size >= 8) {
        check("JointTrack 平移关键帧 = 2", r9k[0].intValue() == 2)
        checkEq("SkeletalAnimationData.duration = 1.5", r9k[1].numberValue(), 1.5)
        check("numTracks = 1", r9k[2].intValue() == 1)
        check("numSoaJoints = 1", r9k[3].intValue() == 1)
        check("AnimatorController 当前状态 = 'idle'", r9k[4].stringValue() == "idle")
        check("setBool 生效", r9k[5].boolValue())
        check("SkeletonData.numJoints = 0", r9k[6].intValue() == 0)
        check("SkeletonUtils.getStats 返回字符串", r9k[7].boolValue())
    }
    println("")

    // ---------- 9l. audio：上下文 / 变换槽 / 缓冲区 / 监听器 / 效果 / 音频源 ----------
    println("[9l] audio：AudioContext / AudioTransformSlot / AudioBuffer / 音源（不初始化设备）")
    let r9l = runLua(vm, "audio",
        "local A = three.audio; " +
        // 上下文单例（不调用 initialize，避免依赖真实音频设备）
        "local ctx = A.device.AudioContext.instance(); " +
        "local inited = ctx.initialized; " +
        // 变换槽：11 个可读写字段
        "local slot = A.device.AudioTransformSlot.new(); " +
        "slot.sourceId = 7; slot.isListener = true; slot.px = 1.5; slot.py = -2.5; slot.gain = 0.25; " +
        // 缓冲区
        "local buf = A.source.AudioBuffer.new(); " +
        "buf.channels = 2; buf.sampleRate = 44100; buf.frameCount = 100; buf.dataSize = 400; " +
        "local bufOk = buf.releasable; " +
        // 监听器
        "local lis = A.listener.AudioListener.new(); " +
        "lis:setMasterVolume(0.5); local mg = lis:getMasterVolume(); " +
        // EFX 对象（不 create，避免在未初始化设备上调用 OpenAL）
        "local fx = A.mixer.AudioEffect.new(); " +
        "local fxRel = fx.releasable; local fxId = fx.effectId; " +
        "local flt = A.mixer.AudioFilter.new(); flt.filterId = 3; local fltId = flt.filterId; " +
        "local es = A.mixer.AudioEffectSlot.new(); local esRel = es.releasable; " +
        // 音频源
        "local a = A.source.Audio.new(); " +
        "local st0 = a:getSourceState(); local vol = a:getVolume(); local isAud = a.isAudio; " +
        "local pa = A.source.PositionalAudio.new(); " +
        "pa:setRefDistance(2.5); local rd = pa:getRefDistance(); local dm = pa:getDistanceModel(); " +
        "local vel = pa:getVelocity(); local vx = vel.x; " +
        "local sa = A.source.StreamingAudio.new(); local stype = sa.sourceType; " +
        // 录音器（不打开设备）
        "local rec = A.capture.AudioRecorder.new(); " +
        "return ctx ~= nil, inited, slot.sourceId, slot.px, slot.py, slot.gain, " +
        "buf.channels, buf.sampleRate, buf.frameCount, buf.dataSize, bufOk, mg, " +
        "fxRel, fxId, fltId, esRel, st0, vol, isAud, rd, dm, vx, stype, rec.opened")
    check("audio 返回有效（24 个值）", r9l.size == 24)
    if (r9l.size >= 24) {
        check("AudioContext.instance() 非 nil", r9l[0].boolValue())
        check("未初始化设备的 initialized = false", !r9l[1].boolValue())
        check("AudioTransformSlot.sourceId = 7", r9l[2].intValue() == 7)
        checkEq("AudioTransformSlot.px = 1.5", r9l[3].numberValue(), 1.5)
        checkEq("AudioTransformSlot.py = -2.5", r9l[4].numberValue(), -2.5)
        checkEq("AudioTransformSlot.gain = 0.25", r9l[5].numberValue(), 0.25)
        check("AudioBuffer.channels = 2", r9l[6].intValue() == 2)
        check("AudioBuffer.sampleRate = 44100", r9l[7].intValue() == 44100)
        check("AudioBuffer.frameCount = 100", r9l[8].intValue() == 100)
        check("AudioBuffer.dataSize = 400", r9l[9].intValue() == 400)
        check("AudioBuffer.releasable = true", r9l[10].boolValue())
        checkEq("AudioListener 主音量 = 0.5", r9l[11].numberValue(), 0.5)
        check("AudioEffect.releasable = true", r9l[12].boolValue())
        check("AudioEffect.effectId = 0（未 create）", r9l[13].intValue() == 0)
        check("AudioFilter.filterId = 3", r9l[14].intValue() == 3)
        check("AudioEffectSlot.releasable = true", r9l[15].boolValue())
        check("Audio.getSourceState() = 0x1011 Initial", r9l[16].intValue() == 0x1011)
        checkEq("Audio.getVolume() = 1.0", r9l[17].numberValue(), 1.0)
        check("Audio.isAudio = true", r9l[18].boolValue())
        checkEq("PositionalAudio.refDistance = 2.5", r9l[19].numberValue(), 2.5)
        check("PositionalAudio.distanceModel = 2", r9l[20].intValue() == 2)
        checkEq("PositionalAudio.velocity.x = 0", r9l[21].numberValue(), 0.0)
        check("StreamingAudio.sourceType = 'streaming'", r9l[22].stringValue() == "streaming")
        check("AudioRecorder.opened = false", !r9l[23].boolValue())
    }
    println("")

    // ---------- 9m. audio：Lua 回调投递（execAudio / postAudio / pumpAudioCallbacks） ----------
    println("[9m] audio：execAudio 同步 / postAudio 延迟 / pumpAudioCallbacks 抽干 / FIFO")
    let r9m = runLua(vm, "audio callbacks",
        "local A = three.audio; " +
        "local ctx = A.device.AudioContext.instance(); " +
        "local log = {}; " +
        // 1. execAudio：同步执行（未初始化设备 → 不取音频线程屏障）
        "local okSync = ctx:execAudio(function() log[#log + 1] = 'sync' end); " +
        "local afterSync = #log; " +
        // 2. postAudio：投递即返回，回调此刻不执行
        "local okPost1 = ctx:postAudio(function() log[#log + 1] = 'post1' end); " +
        "local okPost2 = ctx:postAudio(function() log[#log + 1] = 'post2' end); " +
        "local pend1 = ctx.pendingAudioCallbacks; " +
        "local afterPost = #log; " +
        // 3. pumpAudioCallbacks：抽干并按执行顺序运行
        "local pumped = ctx:pumpAudioCallbacks(); " +
        "local pend2 = ctx.pendingAudioCallbacks; " +
        // 4. execAudio 先抽干延迟队列再执行自身（保序）
        "ctx:postAudio(function() log[#log + 1] = 'p3' end); " +
        "local okE2 = ctx:execAudio(function() log[#log + 1] = 'e2' end); " +
        // 5. 入参非法时返回 false（不抛错）
        "local missRet = ctx:execAudio(); " +
        "local typeRet = ctx:postAudio(123); " +
        "local pend3 = ctx.pendingAudioCallbacks; " +
        "return okSync, okPost1, okPost2, okE2, " +
        "afterSync, afterPost, pend1, pumped, pend2, #log, " +
        "log[1], log[2], log[3], log[4], log[5], missRet, typeRet, pend3")
    check("audio 回调返回有效（18 个值）", r9m.size == 18)
    if (r9m.size >= 18) {
        check("execAudio 返回 true", r9m[0].boolValue())
        check("postAudio#1 返回 true", r9m[1].boolValue())
        check("postAudio#2 返回 true", r9m[2].boolValue())
        check("execAudio(e2) 返回 true", r9m[3].boolValue())
        check("execAudio 同步执行（执行后 1 条）", r9m[4].intValue() == 1)
        check("postAudio 投递后不执行（仍 1 条）", r9m[5].intValue() == 1)
        check("pendingAudioCallbacks = 2", r9m[6].intValue() == 2)
        check("pumpAudioCallbacks 执行 2 条", r9m[7].intValue() == 2)
        check("抽干后 pendingAudioCallbacks = 0", r9m[8].intValue() == 0)
        check("累计执行 5 条", r9m[9].intValue() == 5)
        check("顺序 log[1] = 'sync'", r9m[10].stringValue() == "sync")
        check("顺序 log[2] = 'post1'", r9m[11].stringValue() == "post1")
        check("顺序 log[3] = 'post2'", r9m[12].stringValue() == "post2")
        check("execAudio 先抽干延迟队列（log[4] = 'p3'）", r9m[13].stringValue() == "p3")
        check("自身回调最后执行（log[5] = 'e2'）", r9m[14].stringValue() == "e2")
        check("execAudio 缺参返回 false", !r9m[15].boolValue())
        check("postAudio 非函数返回 false", !r9m[16].boolValue())
        check("非法投递不入队（pending = 0）", r9m[17].intValue() == 0)
    }
    println("")

    // ---------- 9n. network.protocol：PacketWriter / PacketReader ----------
    println("[9n] network.protocol：PacketWriter 写出 / PacketReader 大端读取 / 越界保护")
    let r9n = runLua(vm, "packet codec",
        "local P = three.network.protocol; " +
        "local w = P.PacketWriter.new(); " +
        "w:writeU16(7); w:writeString('hi'); w:writeF32(0.5); w:writeBool(true); " +
        "w:writeU8(1); w:writeU8(2); w:writeU8(3); " +
        "local size = w.size; " +
        "local bytes = w:toArray(); " +
        "local r = P.PacketReader.new(bytes); " +
        "local u16 = r:readU16(); local str = r:readString(); local f = r:readF32(); " +
        "local b = r:readBool(); " +
        "local x1 = r:readU8(); local x2 = r:readU8(); local x3 = r:readU8(); " +
        "local remaining = r.remaining; local hasMore = r.hasMore; local pos = r.position; " +
        "local bad = P.PacketReader.new({}); " +
        "local badU16 = bad:readU16(); local badRem = bad.remaining; local badStr = bad:readString(); " +
        "local w2 = P.PacketWriter.new(); w2:writeU32(2); w2:writeU8(9); w2:writeU8(8); " +
        "local r2 = P.PacketReader.new(w2:toArray()); local rb = r2:readBytes(); " +
        "return size, u16, str, f, b, x1, x2, x3, remaining, hasMore, pos, " +
        "badU16, badRem, badStr, #rb, rb[1], rb[2], P.PacketWriter.MAX_STRING_BYTES()")
    check("PacketWriter/Reader 返回有效（18 个值）", r9n.size == 18)
    if (r9n.size >= 18) {
        check("写出总字节 = 16", r9n[0].intValue() == 16)
        check("readU16 = 7", r9n[1].intValue() == 7)
        check("readString = 'hi'", r9n[2].stringValue() == "hi")
        checkEq("readF32 = 0.5", r9n[3].numberValue(), 0.5)
        check("readBool = true", r9n[4].boolValue())
        check("后续字节 1,2,3", r9n[5].intValue() == 1 && r9n[6].intValue() == 2 && r9n[7].intValue() == 3)
        check("读完 remaining = 0", r9n[8].intValue() == 0)
        check("hasMore = false", !r9n[9].boolValue())
        check("position = 16", r9n[10].intValue() == 16)
        check("空包 readU16 越界返回 0（不抛错）", r9n[11].intValue() == 0)
        check("越界后 remaining 仍为 0", r9n[12].intValue() == 0)
        check("越界 readString 返回空串", r9n[13].stringValue() == "")
        check("readBytes 长度前缀读回 2 字节", r9n[14].intValue() == 2)
        check("readBytes 内容 9,8", r9n[15].intValue() == 9 && r9n[16].intValue() == 8)
        check("MAX_STRING_BYTES = 16MB", r9n[17].intValue() == 16 * 1024 * 1024)
    }
    println("")

    // ---------- 9o. network.http + network.socket（纯构造，不发起真实连接） ----------
    println("[9o] network.http：请求/响应/客户端；network.socket：客户端/服务端/UDP")
    let r9o = runLua(vm, "http/socket",
        "local H = three.network.http; " +
        "local req = H.HttpRequest.post('https://x/y', '{\"a\":1}'); " +
        "local method = req.method; " +
        "local hName = req.headers[1][1]; local hValue = req.headers[1][2]; " +
        "local body = req.body; " +
        "local g = H.HttpRequest.get('https://x', {{'X-A', '1'}}); local gm = g.method; " +
        "local resp = H.HttpResponse.new(200, 'OK', {{'Content-Type', 'application/json'}}, '{}'); " +
        "local ok = resp.isSuccess; local redir = resp.isRedirect; " +
        "local ct = resp.contentType; local ctHdr = resp:header('Content-Type'); " +
        "local bs = resp:bodyString(); local code = resp.code; " +
        "local client = H.HttpClient.new(1000, 2000, 3000); " +
        "local ct1 = client.connectTimeoutMs; local rel = client.releasable; " +
        "local enqOk = client:enqueue(req, 1, function() end); " +
        "local pend = client.pendingCallbacks; local pumped = client:pumpCallbacks(); " +
        "local relRet = client:release(); local nh = H.NetworkHttp ~= nil; " +
        "local S = three.network.socket; " +
        "local c = S.SocketClient.new('127.0.0.1', 1); " +
        "local cConn = c.isConnected; local wOk = c:writeString('x'); local relC = c:release(); " +
        "c.listener = { onMessage = function(cl, d) end }; c.listener = nil; " +
        "local srv = S.SocketServer.new(0); local sb = srv.isBound; " +
        "local accNil = srv:accept() == nil; local srvRel = srv:release(); " +
        "local udp = S.SocketUdp.new(0); local ub = udp:bind(); local ub2 = udp.isBound; " +
        "local urel = udp:release(); " +
        "return method, hName, hValue, body, gm, ok, redir, ct, ctHdr, bs, code, " +
        "ct1, rel, enqOk, pend, pumped, relRet, nh, cConn, wOk, relC, sb, accNil, srvRel, ub, ub2, urel")
    check("http/socket 返回有效（27 个值）", r9o.size == 27)
    if (r9o.size >= 27) {
        check("HttpRequest.post method = 'POST'", r9o[0].stringValue() == "POST")
        check("post 自动加 Content-Type 名", r9o[1].stringValue() == "Content-Type")
        check("post 自动加 JSON Content-Type 值",
            r9o[2].stringValue() == "application/json; charset=utf-8")
        check("post body = {\"a\":1}", r9o[3].stringValue() == "{\"a\":1}")
        check("HttpRequest.get method = 'GET'", r9o[4].stringValue() == "GET")
        check("HttpResponse.isSuccess = true", r9o[5].boolValue())
        check("HttpResponse.isRedirect = false", !r9o[6].boolValue())
        check("contentType = 'application/json'", r9o[7].stringValue() == "application/json")
        check("header('Content-Type') = 'application/json'", r9o[8].stringValue() == "application/json")
        check("bodyString = '{}'", r9o[9].stringValue() == "{}")
        check("code = 200", r9o[10].intValue() == 200)
        check("HttpClient.connectTimeoutMs = 1000", r9o[11].intValue() == 1000)
        check("HttpClient.releasable = true", r9o[12].boolValue())
        check("enqueue 回调非函数返回 false", !r9o[13].boolValue())
        check("未入队 pendingCallbacks = 0", r9o[14].intValue() == 0)
        check("pumpCallbacks 执行 0 条", r9o[15].intValue() == 0)
        check("HttpClient.release() = true", r9o[16].boolValue())
        check("NetworkHttp 类表存在", r9o[17].boolValue())
        check("未连接 isConnected = false", !r9o[18].boolValue())
        check("未连接 writeString 返回 false", !r9o[19].boolValue())
        check("未连接 release 返回 false", !r9o[20].boolValue())
        check("SocketServer.isBound = false", !r9o[21].boolValue())
        check("未绑定 accept() = nil", r9o[22].boolValue())
        check("未绑定服务端 release 返回 false", !r9o[23].boolValue())
        check("SocketUdp.bind() = true", r9o[24].boolValue())
        check("SocketUdp.isBound = true", r9o[25].boolValue())
        check("SocketUdp.release() = true", r9o[26].boolValue())
    }
    println("")

    // ---------- 9p. network.transport：Connection / ReliableChannel ----------
    println("[9p] network.transport：Connection 配置/常量；ReliableChannel 只读属性/常量")
    let r9p = runLua(vm, "transport",
        "local T = three.network.transport; " +
        "local C = T.Connection; " +
        "local ping = C.FRAME_PING(); local dataC = C.FRAME_DATA(); local maxF = C.MAX_FRAME_SIZE(); " +
        "local conn = C.new('127.0.0.1', 9000); " +
        "local hb = conn.heartbeatIntervalMs; conn.heartbeatIntervalMs = 1000; " +
        "local hb2 = conn.heartbeatIntervalMs; " +
        "conn.autoReconnect = true; local ar = conn.autoReconnect; " +
        "local ic = conn.isConnected; local sent = conn:send({1, 2}); " +
        "conn.onMessage = function(d) end; " +
        "local upd = conn:update(); local pendConn = conn.pendingCallbacks; " +
        "local relConn = conn:release(); " +
        "local R = T.ReliableChannel; " +
        "local ch = R.new('127.0.0.1', 9000); " +
        "local rh = ch.remoteHost; local rp = ch.remotePort; " +
        "local rtt = ch.rttMs; local pc = ch.pendingCount; " +
        "local hsz = R.RELIABLE_HEADER_SIZE(); local ackSeq = R.RELIABLE_ACK_SEQ(); " +
        "local maxp = R.RELIABLE_MAX_PAYLOAD(); " +
        "local sendB = ch:send({1}); local relCh = ch:release(); " +
        "return ping, dataC, maxF, hb, hb2, ar, ic, sent, upd, pendConn, relConn, " +
        "rh, rp, rtt, pc, hsz, ackSeq, maxp, sendB, relCh")
    check("transport 返回有效（20 个值）", r9p.size == 20)
    if (r9p.size >= 20) {
        check("FRAME_PING = 0x01", r9p[0].intValue() == 1)
        check("FRAME_DATA = 0x03", r9p[1].intValue() == 3)
        check("MAX_FRAME_SIZE = 8MB", r9p[2].intValue() == 8 * 1024 * 1024)
        checkEq("heartbeatIntervalMs 默认 5000", r9p[3].numberValue(), 5000.0)
        checkEq("heartbeatIntervalMs 可写为 1000", r9p[4].numberValue(), 1000.0)
        check("autoReconnect 可写为 true", r9p[5].boolValue())
        check("未连接 isConnected = false", !r9p[6].boolValue())
        check("未连接 send 返回 false", !r9p[7].boolValue())
        check("update 抽干 0 条回调", r9p[8].intValue() == 0)
        check("pendingCallbacks = 0", r9p[9].intValue() == 0)
        check("Connection.release() = true", r9p[10].boolValue())
        check("ReliableChannel.remoteHost = '127.0.0.1'", r9p[11].stringValue() == "127.0.0.1")
        check("ReliableChannel.remotePort = 9000", r9p[12].intValue() == 9000)
        check("rttMs 初始 = 0", r9p[13].intValue() == 0)
        check("pendingCount 初始 = 0", r9p[14].intValue() == 0)
        check("RELIABLE_HEADER_SIZE = 12", r9p[15].intValue() == 12)
        checkEq("RELIABLE_ACK_SEQ = 0xFFFFFFFF", r9p[16].numberValue(), 4294967295.0, tol: 0.0)
        check("RELIABLE_MAX_PAYLOAD = 1200", r9p[17].intValue() == 1200)
        check("未 bind 时 send 返回 false", !r9p[18].boolValue())
        check("ReliableChannel.release() = true", r9p[19].boolValue())
    }
    println("")

    // ---------- 9q. network.sync：LockstepSession / SnapshotBuffer ----------
    println("[9q] network.sync：帧同步推进（onAdvance 回调）/ 快照插值采样")
    let r9q = runLua(vm, "sync",
        "local N = three.network.sync; " +
        "local s = N.LockstepSession.new(1); " +
        "local added = s:addPlayer(2); local dup = s:addPlayer(2); " +
        "s.inputDelayTicks = 1; s.tickIntervalMs = 50; s.maxWaitMs = 0; " +
        "local advances = 0; local lastTick = -1; local idCount = 0; local inputCount = 0; " +
        "s.onAdvance = function(tick, ids, inputs) " +
        "advances = advances + 1; lastTick = tick; idCount = #ids; inputCount = #inputs end; " +
        "s:submitLocalInput({1, 2}); s:submitRemoteInput(2, 0, {3, 4}); " +
        "s:update(0.05); " +
        "local confirmed = s.confirmedTick; local target = s.targetTick; local lp = s.localPlayerId; " +
        "local unk = s:submitRemoteInput(99, 0, {}); " +
        "s:reset(); local resetTick = s.confirmedTick; " +
        "local buf = N.SnapshotBuffer.new(1000); " +
        "buf:addSnapshot(0, {0, 0}); buf:addSnapshot(100, {10, 20}); " +
        "local cnt = buf.count; local comps = buf.components; " +
        "local oldest = buf.oldestTimeMs; local newest = buf.newestTimeMs; " +
        "local okS, vals = buf:sampleValues(50); " +
        "local out = {0, 0}; local okS2 = buf:sample(50, out); " +
        "buf:clear(); local cnt2 = buf.count; local oldestNil = buf.oldestTimeMs == nil; " +
        "return added, dup, advances, lastTick, idCount, inputCount, confirmed, target, lp, unk, " +
        "resetTick, cnt, comps, oldest, newest, okS, vals[1], vals[2], okS2, out[1], out[2], " +
        "cnt2, oldestNil")
    check("sync 返回有效（23 个值）", r9q.size == 23)
    if (r9q.size >= 23) {
        check("addPlayer(2) = true", r9q[0].boolValue())
        check("重复 addPlayer(2) = false", !r9q[1].boolValue())
        check("update 推进 1 个 tick（onAdvance 回调 1 次）", r9q[2].intValue() == 1)
        check("onAdvance tick = 0", r9q[3].intValue() == 0)
        check("onAdvance ids 长度 = 2", r9q[4].intValue() == 2)
        check("onAdvance inputs 长度 = 2", r9q[5].intValue() == 2)
        check("推进后 confirmedTick = 0", r9q[6].intValue() == 0)
        check("推进后 targetTick = 1", r9q[7].intValue() == 1)
        check("localPlayerId = 1", r9q[8].intValue() == 1)
        check("未知玩家 submitRemoteInput = false", !r9q[9].boolValue())
        check("reset 后 confirmedTick = -1", r9q[10].intValue() == -1)
        check("快照数 = 2", r9q[11].intValue() == 2)
        check("分量数 = 2", r9q[12].intValue() == 2)
        checkEq("oldestTimeMs = 0", r9q[13].numberValue(), 0.0)
        checkEq("newestTimeMs = 100", r9q[14].numberValue(), 100.0)
        check("sampleValues 成功", r9q[15].boolValue())
        checkEq("插值 vals[1] = 5", r9q[16].numberValue(), 5.0)
        checkEq("插值 vals[2] = 10", r9q[17].numberValue(), 10.0)
        check("sample(50, out) 成功", r9q[18].boolValue())
        checkEq("就地写回 out[1] = 5", r9q[19].numberValue(), 5.0)
        checkEq("就地写回 out[2] = 10", r9q[20].numberValue(), 10.0)
        check("clear 后 count = 0", r9q[21].intValue() == 0)
        check("无快照时 oldestTimeMs = nil", r9q[22].boolValue())
    }
    println("")

    // ---------- 9r. physics：枚举 / 形状 / 描述 / 句柄 / 刚体构建器 / 世界 ----------
    println("[9r] physics：枚举 / 形状工厂 / 描述 / 句柄 / RigidBody / PhysicsWorld / 高级描述")
    let r9r = runLua(vm, "physics",
        "local I = three.physics.common; " +
        "local V3 = three.core.math.Vector3; " +
        // 枚举序号
        "local mtDynamic = I.PhysicsMotionType.Dynamic(); " +
        "local mtStatic = I.PhysicsMotionType.Static(); " +
        "local layerMoving = I.PhysicsLayer.Moving(); " +
        "local stSphere = I.PhysicsShapeType.Sphere(); " +
        "local ctHinge = I.PhysicsConstraintType.Hinge(); " +
        "local msPosition = I.PhysicsMotorState.Position(); " +
        "local csWorld = I.PhysicsConstraintSpace.WorldSpace(); " +
        "local ceRemoved = I.PhysicsContactEvent.Removed(); " +
        // 形状工厂
        "local box = I.PhysicsShape.box(2, 4, 6); " +
        "local hx = box.halfExtent.x; local hy = box.halfExtent.y; local hz = box.halfExtent.z; " +
        "local sph = I.PhysicsShape.sphere(0.5); " +
        "local cap = I.PhysicsShape.capsule(1.0, 0.5); " +
        "local plane = I.PhysicsShape.plane(); " +
        "local mesh = I.PhysicsShape.mesh({V3.new(0,0,0), V3.new(1,0,0), V3.new(0,1,0)}, {0,1,2}); " +
        "local triCount = #mesh.triangles; " +
        "local part = I.PhysicsCompoundPart.new(sph, V3.new(1,0,0)); " +
        "local comp = I.PhysicsShape.compound({part}); local partsLen = #comp.parts; " +
        // 刚体描述
        "local desc = I.PhysicsBodyDesc.new(box); " +
        "local dMt = desc.motionType; local dLayer = desc.layer; " +
        "local dAuto = desc.autoSync; local dMass = desc.mass; " +
        "desc.friction = 0.5; local dFric = desc.friction; " +
        // 约束描述
        "local cdesc = I.PhysicsConstraintDesc.new(ctHinge); " +
        "local csSpace = cdesc.space; local axis1y = cdesc.axis1.y; " +
        "cdesc.limitMin = -1.0; local cLimit = cdesc.limitMin; " +
        // 句柄 / 命中
        "local bh = I.PhysicsBodyHandle.new(7); local bhId = bh.bodyID; local bhValid = bh:isValid(); " +
        "local bhInvalid = I.PhysicsBodyHandle.INVALID():isValid(); " +
        "local chh = I.PhysicsConstraintHandle.new(3); local chId = chh.constraintID; " +
        "local rh = I.PhysicsRayHit.new(); rh.bodyID = 5; rh.fraction = 0.25; rh.point = V3.new(1,2,3); " +
        "local rhBody = rh.bodyID; local rhX = rh.point.x; " +
        // 世界 + 刚体（不 start，避免依赖原生初始化）
        "local W = three.physics.world; local world = W.PhysicsWorld.new(); " +
        "local inited = world:isInitialized(); local hasBackend = world.backend ~= nil; " +
        "local rb = three.physics.body.RigidBody.new(world, box); " +
        "local rbAttached = rb.attached; local rbSensor = rb.isSensor; local rbRel = rb.releasable; " +
        "local chainOk = rb:setDynamic():setPosition(1, 2, 3) ~= nil; " +
        "local rbPosX = rb:getPosition().x; local rbReleased = rb:release(); " +
        // 约束封装（不触后端）
        "local cons = three.physics.constraint.PhysicsConstraint.new(world, I.PhysicsConstraintHandle.new(99)); " +
        "local consRel = cons.releasable; " +
        // 角色描述 / 工厂
        "local cd = three.physics.character.PhysicsCharacterDesc.new(cap); " +
        "local cdLayer = cd.layer; local cdMass = cd.mass; " +
        "local cfOk = three.physics.character.PhysicsCharacterFactory.new(cd) ~= nil; " +
        // 高度场描述
        "local hfd = three.physics.heightfield.PhysicsHeightFieldDesc.new(); " +
        "hfd.sampleCount = 4; hfd.samples = {0, 1, 2, 3}; hfd.sizeX = 10; " +
        "local hfCnt = hfd.sampleCount; local hfSamples = #hfd.samples; local hfSize = hfd.sizeX; " +
        // 软体描述
        "local sbd = three.physics.softbody.PhysicsSoftBodyDesc.new(); " +
        "sbd.vertices = {V3.new(0,0,0), V3.new(1,0,0)}; sbd.indices = {0, 1, 0}; " +
        "sbd.pinnedVertices = {0}; " +
        "local sbVerts = #sbd.vertices; local sbIdx = #sbd.indices; local sbPinned = #sbd.pinnedVertices; " +
        // 载具描述
        "local wheel = three.physics.vehicle.PhysicsVehicleWheelDesc.new(V3.new(0.5, 0, 0.5)); " +
        "local wheelR = wheel.radius; " +
        "local eng = three.physics.vehicle.PhysicsVehicleEngineDesc.new(); local gears = #eng.gearRatios; " +
        "local vd = three.physics.vehicle.PhysicsVehicleDesc.new(desc); " +
        "local vdFric = vd.chassisDesc.friction; " +
        // 布娃娃关节 / 部件（不创建原生对象）
        "local rj = three.physics.ragdoll.RagdollJoint.cone(V3.new(0,1,0), V3.new(0,1,0), 0.5); " +
        "local coneAngle = rj.normalHalfConeAngle; " +
        "local partS = three.physics.ragdoll.RagdollPartSettings.new(sph, V3.new(0,1,0)); " +
        "local partMass = partS.mass; " +
        // 调试图元
        "local dl = three.physics.debug.PhysicsDebugLine.new(V3.new(0,0,0), V3.new(1,0,0), 4278255360); " +
        "local dlColor = dl.color; " +
        "local dt = three.physics.debug.PhysicsDebugTriangle.new(V3.new(0,0,0), V3.new(1,0,0), V3.new(0,1,0)); " +
        "local dtX = dt.v2.x; " +
        // 后端
        "local be = three.physics.backend.JoltBackend.new(); " +
        "local beInit = be:isInitialized(); local beName = be:backendName(); " +
        "local pbOk = three.physics.binding.PhysicsBinding ~= nil; " +
        "local wRel = world:release(); " +
        "return mtDynamic, mtStatic, layerMoving, stSphere, ctHinge, msPosition, csWorld, ceRemoved, " +
        "hx, hy, hz, sph.radius, cap.halfHeight, plane.shapeType, triCount, partsLen, " +
        "dMt, dLayer, dAuto, dMass, dFric, csSpace, axis1y, cLimit, " +
        "bhId, bhValid, bhInvalid, chId, rhBody, rhX, " +
        "inited, hasBackend, rbAttached, rbSensor, rbRel, chainOk, rbPosX, rbReleased, consRel, " +
        "cdLayer, cdMass, cfOk, hfCnt, hfSamples, hfSize, " +
        "sbVerts, sbIdx, sbPinned, wheelR, gears, vdFric, coneAngle, partMass, " +
        "dlColor, dtX, beInit, beName, pbOk, wRel")
    check("physics 返回有效（59 个值）", r9r.size == 59)
    if (r9r.size >= 59) {
        check("PhysicsMotionType.Dynamic = 2", r9r[0].intValue() == 2)
        check("PhysicsMotionType.Static = 0", r9r[1].intValue() == 0)
        check("PhysicsLayer.Moving = 1", r9r[2].intValue() == 1)
        check("PhysicsShapeType.Sphere = 1", r9r[3].intValue() == 1)
        check("PhysicsConstraintType.Hinge = 2", r9r[4].intValue() == 2)
        check("PhysicsMotorState.Position = 2", r9r[5].intValue() == 2)
        check("PhysicsConstraintSpace.WorldSpace = 1", r9r[6].intValue() == 1)
        check("PhysicsContactEvent.Removed = 2", r9r[7].intValue() == 2)
        checkEq("box(2,4,6).halfExtent.x = 1", r9r[8].numberValue(), 1.0)
        checkEq("box(2,4,6).halfExtent.y = 2", r9r[9].numberValue(), 2.0)
        checkEq("box(2,4,6).halfExtent.z = 3", r9r[10].numberValue(), 3.0)
        checkEq("sphere(0.5).radius = 0.5", r9r[11].numberValue(), 0.5)
        checkEq("capsule(1,0.5).halfHeight = 1", r9r[12].numberValue(), 1.0)
        check("plane().shapeType = 4", r9r[13].intValue() == 4)
        check("mesh 三角形索引数 = 3", r9r[14].intValue() == 3)
        check("compound 子部件数 = 1", r9r[15].intValue() == 1)
        check("BodyDesc 默认 motionType = 2（Dynamic）", r9r[16].intValue() == 2)
        check("BodyDesc 默认 layer = 1（Moving）", r9r[17].intValue() == 1)
        check("BodyDesc 默认 autoSync = true", r9r[18].boolValue())
        checkEq("BodyDesc 默认 mass = -1", r9r[19].numberValue(), -1.0)
        checkEq("BodyDesc.friction 可写为 0.5", r9r[20].numberValue(), 0.5)
        check("ConstraintDesc 默认 space = 1（WorldSpace）", r9r[21].intValue() == 1)
        checkEq("ConstraintDesc.axis1 默认 (0,1,0)", r9r[22].numberValue(), 1.0)
        checkEq("ConstraintDesc.limitMin 可写为 -1", r9r[23].numberValue(), -1.0)
        check("PhysicsBodyHandle.bodyID = 7", r9r[24].intValue() == 7)
        check("PhysicsBodyHandle.isValid() = true", r9r[25].boolValue())
        check("PhysicsBodyHandle.INVALID 无效", !r9r[26].boolValue())
        check("PhysicsConstraintHandle.constraintID = 3", r9r[27].intValue() == 3)
        check("PhysicsRayHit.bodyID 可写为 5", r9r[28].intValue() == 5)
        checkEq("PhysicsRayHit.point.x = 1", r9r[29].numberValue(), 1.0)
        check("未 start 时 isInitialized = false", !r9r[30].boolValue())
        check("PhysicsWorld.backend 为 JoltBackend 对象", r9r[31].boolValue())
        check("RigidBody.attached = false", !r9r[32].boolValue())
        check("RigidBody.isSensor = false", !r9r[33].boolValue())
        check("RigidBody.releasable = true", r9r[34].boolValue())
        check("RigidBody 链式 setDynamic/setPosition 返回自身", r9r[35].boolValue())
        checkEq("未 attach 时 getPosition().x = 0", r9r[36].numberValue(), 0.0)
        check("未 attach 时 release() = true", r9r[37].boolValue())
        check("PhysicsConstraint.releasable（有效句柄）= true", r9r[38].boolValue())
        check("CharacterDesc.layer = 1", r9r[39].intValue() == 1)
        checkEq("CharacterDesc.mass 默认 70", r9r[40].numberValue(), 70.0)
        check("PhysicsCharacterFactory 构造成功", r9r[41].boolValue())
        check("HeightFieldDesc.sampleCount = 4", r9r[42].intValue() == 4)
        check("HeightFieldDesc.samples 长度 = 4", r9r[43].intValue() == 4)
        checkEq("HeightFieldDesc.sizeX = 10", r9r[44].numberValue(), 10.0)
        check("SoftBodyDesc.vertices 长度 = 2", r9r[45].intValue() == 2)
        check("SoftBodyDesc.indices 长度 = 3", r9r[46].intValue() == 3)
        check("SoftBodyDesc.pinnedVertices 长度 = 1", r9r[47].intValue() == 1)
        checkEq("VehicleWheelDesc.radius 默认 0.3", r9r[48].numberValue(), 0.3)
        check("VehicleEngineDesc.gearRatios 长度 = 4", r9r[49].intValue() == 4)
        checkEq("VehicleDesc.chassisDesc 引用同一刚体描述", r9r[50].numberValue(), 0.5)
        checkEq("RagdollJoint.cone halfConeAngle = 0.5", r9r[51].numberValue(), 0.5, tol: 0.0001)
        checkEq("RagdollPartSettings.mass 默认 0", r9r[52].numberValue(), 0.0)
        check("PhysicsDebugLine.color = 0xFF00FF00",
            r9r[53].numberValue() == 4278255360.0)
        checkEq("PhysicsDebugTriangle.v2.x = 1", r9r[54].numberValue(), 1.0)
        check("JoltBackend 未初始化 isInitialized = false", !r9r[55].boolValue())
        check("JoltBackend.backendName = 'JoltPhysics'", r9r[56].stringValue() == "JoltPhysics")
        check("PhysicsBinding 类表存在", r9r[57].boolValue())
        check("PhysicsWorld.release() = true", r9r[58].boolValue())
    }
    println("")

    // ---------- 9s. profiler：Tracy 门面（zone / frame / plot / message / memory /
    //                gpu / lock / fiber / scope / state） ----------
    println("[9s] profiler：ProfZone / ProfFrame / ProfPlot / ProfMessage / ProfMemory / Gpu / Lock / 作用域 / 状态")
    let r9s = runLua(vm, "profiler",
        "local P = three.profiler; " +
        // 枚举
        "local pn = P.TracyPlotFormat.Number(); local pm = P.TracyPlotFormat.Memory(); " +
        "local sv = P.TracyMessageSeverity.Warning(); local sf = P.TracyMessageSeverity.Fatal(); " +
        // Zone
        "local z = P.ProfZone.new('z', 'f.lua', 1, 'fn'); " +
        "local zActive = z.active; " +
        "z:text('t'); z:value(42); z:color(255); z:rename('z2'); " +
        "local zBefore = z:isClosed(); z:close(); local zAfter = z:isClosed(); " +
        // Frame / Plot / Message
        "P.ProfFrame.mark(); P.ProfFrame.mark('Render'); P.ProfFrame.start('Sim'); P.ProfFrame.finish('Sim'); " +
        "P.ProfPlot.config('fps', pn, false, false, 4294967295); " +
        "P.ProfPlot.point('fps', 60.0); P.ProfPlot.pointF32('fps32', 0.5); P.ProfPlot.pointI64('mem', 1024); " +
        "P.ProfMessage.log('msg', 2); P.ProfMessage.logInfo('info'); P.ProfMessage.logWarning('warn'); " +
        // Memory（整数块 id 适配）
        "local memId = P.ProfMemory.alloc(64, 'pool'); local memOk = memId > 0; " +
        "local freed = P.ProfMemory.free(memId, 'pool'); " +
        "local freedAgain = P.ProfMemory.free(memId, 'pool'); " +
        "P.ProfMemory.discard('pool'); " +
        // Gpu
        "P.Gpu.newContext(0, 0, 0, 0, 0); P.Gpu.zoneBegin(0, 1, 0); P.Gpu.zoneEnd(1, 0); " +
        "P.Gpu.time(0, 1, 0); P.Gpu.contextName(0, 'gpu'); " +
        "P.Gpu.calibration(0, 0, 0); P.Gpu.timeSync(0, 0); " +
        // Lock（整数上下文 id 适配）
        "local lockId = P.Lock.announce('lk', 'f.lua', 1, 'fn'); local lockOk = lockId > 0; " +
        "local before = P.Lock.beforeLock(lockId); " +
        "P.Lock.afterLock(lockId); P.Lock.afterUnlock(lockId); P.Lock.afterTryLock(lockId, true); " +
        "P.Lock.terminate(lockId); " +
        "local beforeUnknown = P.Lock.beforeLock(lockId); " +
        // Fiber / 作用域
        "P.ProfFiber.enter('fiber'); P.ProfFiber.leave(); " +
        "local gz = P.ProfGpuZone.new('gz', 0, 'f.lua', 1); " +
        "local gq = gz.query; local gc = gz.ctx; " +
        "local gzBefore = gz:isClosed(); gz:close(); local gzAfter = gz:isClosed(); " +
        "local lz = P.ProfLockZone.new('lz', 'f.lua', 1); " +
        "local lzBefore = lz:isClosed(); lz:close(); local lzAfter = lz:isClosed(); " +
        "local fs = P.FiberScope.new('fs'); " +
        "local fsBefore = fs:isClosed(); fs:close(); local fsAfter = fs:isClosed(); " +
        // 状态
        "local conn = P.ProfilerState.isConnected(); P.ProfilerState.threadName('main'); " +
        "local now = P.ProfilerState.now(); " +
        "return pn, pm, sv, sf, zActive, zBefore, zAfter, memOk, freed, freedAgain, " +
        "lockOk, before, beforeUnknown, gq, gc, gzBefore, gzAfter, " +
        "lzBefore, lzAfter, fsBefore, fsAfter, conn, now")
    check("profiler 返回有效（23 个值）", r9s.size == 23)
    if (r9s.size >= 23) {
        check("TracyPlotFormat.Number = 0", r9s[0].intValue() == 0)
        check("TracyPlotFormat.Memory = 1", r9s[1].intValue() == 1)
        check("TracyMessageSeverity.Warning = 3", r9s[2].intValue() == 3)
        check("TracyMessageSeverity.Fatal = 5", r9s[3].intValue() == 5)
        check("ProfZone.active = true", r9s[4].boolValue())
        check("ProfZone 关闭前 isClosed = false", !r9s[5].boolValue())
        check("ProfZone.close 后 isClosed = true", r9s[6].boolValue())
        check("ProfMemory.alloc 返回 id > 0", r9s[7].boolValue())
        check("ProfMemory.free 命中返回 true", r9s[8].boolValue())
        check("重复 free 返回 false", !r9s[9].boolValue())
        check("Lock.announce 返回上下文 id > 0", r9s[10].boolValue())
        check("Lock.beforeLock = true", r9s[11].boolValue())
        check("注销后 beforeLock 仍安全返回 true", r9s[12].boolValue())
        check("ProfGpuZone.query >= 0", r9s[13].intValue() >= 0)
        check("ProfGpuZone.ctx = 0", r9s[14].intValue() == 0)
        check("ProfGpuZone 关闭前 isClosed = false", !r9s[15].boolValue())
        check("ProfGpuZone.close 后 isClosed = true", r9s[16].boolValue())
        check("ProfLockZone 关闭前 isClosed = false", !r9s[17].boolValue())
        check("ProfLockZone.close 后 isClosed = true", r9s[18].boolValue())
        check("FiberScope 关闭前 isClosed = false", !r9s[19].boolValue())
        check("FiberScope.close 后 isClosed = true", r9s[20].boolValue())
        check("未连接时 ProfilerState.isConnected = false", !r9s[21].boolValue())
        check("ProfilerState.now() 返回数值", !r9s[22].isNil)
    }
    println("")

    // ---------- 9t. resource：LoaderUtils / Cache / 加载结果 / GltfTypes / ZIP /
    //                FileLoader / LoadingManager / 各加载器构造 / AssetCache / AssetManager ----------
    println("[9t] resource：工具 / 缓存 / 加载结果 / GltfTypes / ZIP / 加载器构造 / 资源管线")
    let r9t = runLua(vm, "resource",
        "local R = three.resource.loader; " +
        // LoaderUtils
        "local base = R.LoaderUtils.extractUrlBase('models/part.glb'); " +
        "local resolved = R.LoaderUtils.resolveURL('a/b.png'); " +
        // Cache（静态）
        "local C = three.resource.cache.Cache; " +
        "local en0 = C.getEnabled(); C.setEnabled(true); local en1 = C.getEnabled(); " +
        "C.add('k', R.StringLoadResult.new('hello')); " +
        "local hit = C.get('k'); local hitVal = hit.value; " +
        "C.remove('k'); local missNil = C.get('k') == nil; " +
        "C.clear(); C.setEnabled(false); local en2 = C.getEnabled(); " +
        // 加载结果包装
        "local strVal = R.StringLoadResult.new('abc').value; " +
        "local bytes = R.BytesLoadResult.new({1, 2, 3}).value; " +
        "local bytesLen = #bytes; local bytesVal3 = bytes[3]; " +
        // GltfTypes
        "local G = three.resource.loader; " +
        "local ch = G.GltfAnimationChannel.new(2, 3, 'translation'); " +
        "local sp = G.GltfAnimationSampler.new(1, 2, 'LINEAR'); " +
        "local ad = G.GltfAnimationData.new('anim', {ch}, {sp}); " +
        "local sk = G.GltfSkinData.new('skin', {{1, 2}, {3, 4}}, 0, {5, 6}); " +
        "local chSampler = ch.sampler; local chPath = ch.targetPath; " +
        "local spInput = sp.input; local spInterp = sp.interpolation; " +
        "local dataName = ad.name; local dataChLen = #ad.channels; local dataSpLen = #ad.samplers; " +
        "local skinName = sk.name; local skinMatLen = #sk.inverseBindMatrices; " +
        "local skinJoint1 = sk.joints[1]; local skinRoot = sk.skeletonRoot; " +
        // ZIP：非法字节 / 不存在文件均安全返回 nil
        "local A = three.resource.archive.ZipArchive; " +
        "local zipBytesNil = A.loadFromBytes({1, 2, 3}) == nil; " +
        "local zipFileNil = A.loadFromFile('__no_such__.zip') == nil; " +
        // FileLoader 配置
        "local fl = R.FileLoader.new(); fl:setResponseType('arraybuffer'); " +
        "fl:setMimeType('application/json'); " +
        "local fileResp = fl.responseType; local fileMime = fl.mimeType; " +
        // LoadingManager
        "local mgr = R.LoadingManager.new(); local mgrResolve = mgr:resolveURL('a/b.png'); " +
        // 各加载器可构造
        "local objOk = R.OBJLoader.new() ~= nil; local stlOk = R.STLLoader.new() ~= nil; " +
        "local texOk = R.TextureLoader.new() ~= nil; local gltfOk = R.GltfLoader.new() ~= nil; " +
        // AssetCache
        "local P = three.resource.pipeline; local ac = P.AssetCache.new(); " +
        "local ac0 = ac.count; ac:add('k', R.StringLoadResult.new('v')); local ac1 = ac.count; " +
        "local acVal = ac:get('k').value; local acRef = ac:retain('k'); local acRefN = ac:refCount('k'); " +
        "ac:remove('k'); local ac2 = ac.count; " +
        // AssetManager
        "local am = P.AssetManager.new(); " +
        "local amCache = am.cache ~= nil; local amPending = am.pendingCount; " +
        // JsonSerializer：非可序列化参数安全返回 nil
        "local jsonNil = three.resource.serializer.JsonSerializer.toJson(123) == nil; " +
        "return base, en0, en1, hitVal, missNil, en2, strVal, bytesLen, bytesVal3, " +
        "chSampler, chPath, spInput, spInterp, dataName, dataChLen, dataSpLen, " +
        "skinName, skinMatLen, skinJoint1, skinRoot, zipBytesNil, zipFileNil, " +
        "fileResp, fileMime, resolved, mgrResolve, objOk, stlOk, texOk, gltfOk, " +
        "ac0, ac1, acVal, acRef, acRefN, ac2, amCache, amPending, jsonNil")
    check("resource 返回有效（39 个值）", r9t.size == 39)
    if (r9t.size >= 39) {
        check("LoaderUtils.extractUrlBase = 'models/'", r9t[0].stringValue() == "models/")
        check("Cache.enabled 初始为 false", !r9t[1].boolValue())
        check("Cache.setEnabled(true) 生效", r9t[2].boolValue())
        check("Cache.add/get 返回缓存值", r9t[3].stringValue() == "hello")
        check("Cache.remove 后 get = nil", r9t[4].boolValue())
        check("Cache.setEnabled(false) 生效", !r9t[5].boolValue())
        check("StringLoadResult.value = 'abc'", r9t[6].stringValue() == "abc")
        check("BytesLoadResult 长度 = 3", r9t[7].intValue() == 3)
        check("BytesLoadResult[3] = 3", r9t[8].intValue() == 3)
        check("GltfAnimationChannel.sampler = 2", r9t[9].intValue() == 2)
        check("GltfAnimationChannel.targetPath = 'translation'",
            r9t[10].stringValue() == "translation")
        check("GltfAnimationSampler.input = 1", r9t[11].intValue() == 1)
        check("GltfAnimationSampler.interpolation = 'LINEAR'", r9t[12].stringValue() == "LINEAR")
        check("GltfAnimationData.name = 'anim'", r9t[13].stringValue() == "anim")
        check("GltfAnimationData.channels 长度 = 1", r9t[14].intValue() == 1)
        check("GltfAnimationData.samplers 长度 = 1", r9t[15].intValue() == 1)
        check("GltfSkinData.name = 'skin'", r9t[16].stringValue() == "skin")
        check("GltfSkinData.inverseBindMatrices 长度 = 2", r9t[17].intValue() == 2)
        check("GltfSkinData.joints[1] = 5", r9t[18].intValue() == 5)
        check("GltfSkinData.skeletonRoot = 0", r9t[19].intValue() == 0)
        check("ZipArchive.loadFromBytes 非法字节返回 nil", r9t[20].boolValue())
        check("ZipArchive.loadFromFile 不存在文件返回 nil", r9t[21].boolValue())
        check("FileLoader.responseType 可写为 'arraybuffer'",
            r9t[22].stringValue() == "arraybuffer")
        check("FileLoader.mimeType 可写为 'application/json'",
            r9t[23].stringValue() == "application/json")
        check("LoaderUtils.resolveURL = 'a/b.png'", r9t[24].stringValue() == "a/b.png")
        check("LoadingManager.resolveURL = 'a/b.png'", r9t[25].stringValue() == "a/b.png")
        check("OBJLoader 可构造", r9t[26].boolValue())
        check("STLLoader 可构造", r9t[27].boolValue())
        check("TextureLoader 可构造", r9t[28].boolValue())
        check("GltfLoader 可构造", r9t[29].boolValue())
        check("AssetCache 初始 count = 0", r9t[30].intValue() == 0)
        check("AssetCache.add 后 count = 1", r9t[31].intValue() == 1)
        check("AssetCache.get 返回缓存值", r9t[32].stringValue() == "v")
        check("AssetCache.retain 返回 true", r9t[33].boolValue())
        check("AssetCache.refCount = 1", r9t[34].intValue() == 1)
        check("AssetCache.remove 后 count = 0", r9t[35].intValue() == 0)
        check("AssetManager.cache 非空", r9t[36].boolValue())
        check("AssetManager.pendingCount = 0", r9t[37].intValue() == 0)
        check("JsonSerializer.toJson 非法参数返回 nil", r9t[38].boolValue())
    }
    println("")

    // ---------- 9u. scene：ECS 运行时 / Lua 装饰器（Component/Entity/System/world）/ 场景对象 ----------
    println("[9u] scene：ECS 运行时 / Lua 装饰器 / Object3D / Scene / Fog / 各类实体")
    let r9u = runLua(vm, "scene",
        // 装饰器位于 resources/lua/three/scene/ecs.lua，按真实使用方式 require 加载
        "package.path = '../../../resources/lua/?.lua;' .. package.path; " +
        "require('three.scene.ecs'); " +
        "local ecs = three.scene.ecs; " +
        // ===== 绑定运行时 =====
        "local Reg = ecs.ComponentRegistry; " +
        "local idA = Reg.registerType('lua.test.cpt'); local idB = Reg.registerType('lua.test.cpt'); " +
        "local idOf = Reg.idOf('lua.test.cpt'); local cnt = Reg.count(); " +
        "local comp = ecs.Component.new(); local compId = comp.cptId; " +
        "local none = ecs.EcsObject.NUM_NONE(); " +
        "local ent = ecs.Entity.new(); local etyId = ent.etyId; " +
        "local etyConstructed = ent.constructed; local etyCount = ent.componentCount; " +
        "local world = ecs.World.new(); local wid = world:addEntity(ent); " +
        "local got = world:getEntity(wid) ~= nil; local entsLen = #world:getEntities(); " +
        "local hasMgr = world.entityMgr ~= nil and world.componentMgr ~= nil and world.systemMgr ~= nil; " +
        "local sys = ecs.System.new(); local sysId = sys.sysId; local sysActive = sys.isActive; " +
        "local many = ecs.SystemManager.new(ecs.EntityManager.new(), ecs.ArrSysEtyMapManager.new()); " +
        "local added = many:addSystem(sys); local sysLen = #many:getSystems(); " +
        "local mapMgr = ecs.ArrSysEtyMapManager.new(); " +
        "local n, list = mapMgr:getSystemEntitys(sys); local listLen = #list; " +
        "world:clear(); " +
        // ===== Lua 装饰器：Component / Entity / System / world =====
        "local D = ecs.decorator; " +
        "local Position = D.Component('Position', { x = 0, y = 0 }); " +
        "local ptId = Position.typeId(); local cp = Position.new(); " +
        "local cpX = cp.x; local cpIdOk = cp.cptId == ptId; " +
        "local Player = D.Entity('Player'); local p = Player.new(); local pid = p.etyId; " +
        "local addOk = p:addComponent(Position.new()); local hasOk = p:hasComponent(ptId); " +
        "local gotX = p:getComponent(ptId).x; local cnum = p:componentCount(); " +
        "local removedOk = p:removeComponentById(ptId) ~= nil; local hasAfter = p:hasComponent(ptId); " +
        "local hits, lastDt = 0, 0; " +
        "local Move = D.System('Move', { Position }, function(s, l, dt) hits = #l; lastDt = dt end); " +
        "local maskOk = Move.new():cptMask():get(ptId); " +
        "local Base = D.System('Base', { Position }); " +
        "local Child = D.System('Child', {}, nil, Base); " +
        "local childMaskOk = Child.new():cptMask():get(ptId); " +
        "local e3 = Player.new(); e3:addComponent(Position.new()); " +
        "local lw = D.world(); lw:addEntity(e3); lw:addSystem(Move.new()); lw:onUpdate(0.5); " +
        // ===== 场景对象 =====
        "local O = three.scene.objects; local o = O.Object3D.new(); local ox = o.position.x; " +
        "o.position = three.core.math.Vector3.new(1, 2, 3); local ox2 = o.position.x; " +
        "local g = three.scene.scenegraph.Group.new(); o:add(g); " +
        "local childCount = o:getChildCount(); local childrenLen = #o.children; o:remove(g); " +
        "local vis = o.visible; " +
        "local sg = three.scene.scenegraph.Scene.new(); local fogDefault = sg.fog == nil; " +
        "sg.fog = three.scene.scenegraph.Fog.new(16777215, 1.0, 100.0); " +
        "local fogOk = sg.fog ~= nil; local fogFar = sg.fog.far; " +
        "local feDensity = three.scene.scenegraph.FogExp2.new(255).density; " +
        "local rcFar = O.Raycaster.new().far; " +
        "local meshOk = three.scene.entity.Mesh.new() ~= nil; " +
        "local lineOk = three.scene.entity.Line.new() ~= nil; " +
        "local ptsOk = three.scene.entity.Points.new() ~= nil; " +
        "local sprOk = three.scene.entity.Sprite.new() ~= nil; " +
        "local lodOk = three.scene.entity.LOD.new() ~= nil; " +
        "return idA, idB, idOf, cnt, compId, none, etyId, etyConstructed, etyCount, " +
        "wid, got, entsLen, hasMgr, sysId, sysActive, added, sysLen, n, listLen, " +
        "ptId, cpX, cpIdOk, pid, addOk, hasOk, gotX, cnum, removedOk, hasAfter, " +
        "maskOk, childMaskOk, hits, lastDt, ox, ox2, childCount, childrenLen, vis, " +
        "fogDefault, fogOk, fogFar, feDensity, rcFar, meshOk, lineOk, ptsOk, sprOk, lodOk")
    check("scene 返回有效（48 个值）", r9u.size == 48)
    if (r9u.size >= 48) {
        check("ComponentRegistry.registerType 返回 id ≥ 0", r9u[0].intValue() >= 0)
        check("同一 key 幂等分配同一 id", r9u[0].intValue() == r9u[1].intValue())
        check("ComponentRegistry.idOf 与分配结果一致", r9u[2].intValue() == r9u[0].intValue())
        check("ComponentRegistry.count ≥ 1", r9u[3].intValue() >= 1)
        check("基类 Component.cptId = NUM_NONE(-1)", r9u[4].intValue() == -1)
        check("EcsObject.NUM_NONE() = -1", r9u[5].intValue() == -1)
        check("Entity.new 分配 etyId", r9u[6].intValue() >= 0)
        check("Entity.constructed = true", r9u[7].boolValue())
        check("Entity.componentCount = 0", r9u[8].intValue() == 0)
        check("World.addEntity 返回实体 id", r9u[9].intValue() >= 0)
        check("World.getEntity 可回查", r9u[10].boolValue())
        check("World.getEntities 长度 = 1", r9u[11].intValue() == 1)
        check("World 三个管理器均可用", r9u[12].boolValue())
        check("System.new 分配 sysId", r9u[13].intValue() >= 0)
        check("System.isActive 默认 true", r9u[14].boolValue())
        check("SystemManager.addSystem 返回 id", r9u[15].intValue() >= 0)
        check("SystemManager.getSystems 长度 = 1", r9u[16].intValue() == 1)
        check("ArrSysEtyMapManager.getSystemEntitys 数量 = 0", r9u[17].intValue() == 0)
        check("ArrSysEtyMapManager 实体列表为空", r9u[18].intValue() == 0)
        check("装饰器 Component 分配 typeId", r9u[19].intValue() >= 0)
        checkEq("装饰器组件实例默认字段 x = 0", r9u[20].numberValue(), 0.0)
        check("实例 cptId 与 typeId 一致", r9u[21].boolValue())
        check("装饰器 Entity 分配 etyId", r9u[22].intValue() > 0)
        check("addComponent 成功", r9u[23].boolValue())
        check("hasComponent = true", r9u[24].boolValue())
        checkEq("getComponent 取回组件字段", r9u[25].numberValue(), 0.0)
        check("componentCount = 1", r9u[26].intValue() == 1)
        check("removeComponentById 返回被删组件", r9u[27].boolValue())
        check("移除后 hasComponent = false", !r9u[28].boolValue())
        check("System 掩码包含所需组件", r9u[29].boolValue())
        check("子 System 叠加父系统掩码", r9u[30].boolValue())
        check("Lua world.onUpdate 过滤命中 1 个实体", r9u[31].intValue() == 1)
        checkEq("Lua world.onUpdate 传入 dt = 0.5", r9u[32].numberValue(), 0.5)
        checkEq("Object3D.position.x 默认 0", r9u[33].numberValue(), 0.0)
        checkEq("Object3D.position 可写为 (1,2,3)", r9u[34].numberValue(), 1.0)
        check("Object3D.add 后子对象数 = 1", r9u[35].intValue() == 1)
        check("Object3D.children 长度 = 1", r9u[36].intValue() == 1)
        check("Object3D.visible 默认 true", r9u[37].boolValue())
        check("Scene.fog 默认 nil", r9u[38].boolValue())
        check("Scene.fog 可写", r9u[39].boolValue())
        checkEq("Fog.far = 100", r9u[40].numberValue(), 100.0)
        checkEq("FogExp2.density 默认 0.00025", r9u[41].numberValue(), 0.00025)
        check("Raycaster.far 默认为无穷大", r9u[42].numberValue() > 1e300)
        check("Mesh 可构造", r9u[43].boolValue())
        check("Line 可构造", r9u[44].boolValue())
        check("Points 可构造", r9u[45].boolValue())
        check("Sprite 可构造", r9u[46].boolValue())
        check("LOD 可构造", r9u[47].boolValue())
    }
    println("")

    // ---------- 9v. window：配置 / 事件 / 输入 / UI 上下文 / 控件类与声明式门面 ----------
    println("[9v] window：WindowConfig / InputEvent / WindowEngine / InputEngine / ui 控件与门面")
    let r9v = runLua(vm, "window",
        "package.path = '../../../resources/lua/?.lua;' .. package.path; " +
        "require('three.window'); " +
        "local W = three.window; local U = W.ui; local M = three.utils.memory; " +
        // ===== 枚举与键码 =====
        "local curHand = W.SystemCursor.Hand(); local axLeftX = W.GamepadAxis.LeftX(); " +
        "local btnSouth = W.GamepadButton.South(); " +
        "local keyA = W.KeyCode.A(); local keySpace = W.KeyCode.SPACE(); " +
        "local mLeft = W.MouseButton.LEFT(); " +
        // ===== WindowConfig =====
        "local cfg = W.WindowConfig.new(); local cfgResizable = cfg.resizable; " +
        "cfg.resizable = false; local cfgResizable2 = cfg.resizable; cfg.opacity = 0.5; " +
        "local cfgOpacity = cfg.opacity; " +
        // ===== 输入事件 =====
        "local ke = W.KeyEvent.new(4, 4, 0, true, false); " +
        "local keScan = ke.scancode; local keDown = ke.down; " +
        "local mm = W.MouseMotionEvent.new(1.5, 2.5, 0.5, 0.5); local mmX = mm.x; " +
        "local mb = W.MouseButtonEvent.new(1, true, 1, 10.0, 20.0); local mbBtn = mb.button; " +
        "local mw = W.MouseWheelEvent.new(0.0, 1.0); local mwY = mw.y; " +
        "local we = W.WindowEvent.new(512, 800, 600); local weW = we.data1; " +
        "local te = W.TouchEvent.new(7, 0.5, 0.5, 0.1, 0.1, 0.8); local tePressure = te.pressure; " +
        "local tp = W.TouchPoint.new(3, 0.25, 0.75, 0.0, 0.0, 0.5); local tpx = tp.x; " +
        // ===== 引擎 =====
        "local eng = W.WindowEngine.new(); eng.targetFrameRate = 60.0; " +
        "local tfr = eng.targetFrameRate; local engInit = eng.initialized; " +
        "local engW = eng:getWidth(); eng.bindOnFrame = function(dt) end; " +
        "local inp = W.InputEngine.new(); local mx = inp:getMouseX(); local keyDown = inp:isKeyDown(4); " +
        "local kb = W.KeyboardProvider.new(); local kbBound = kb:isBound(); " +
        "local kbWin = kb:getWindow() == nil; " +
        "local mprov = W.MouseProvider.new(); local mprovX = mprov:getMouseX(); " +
        "local tprov = W.TouchProvider.new(); local tCount = tprov:getTouchCount(); " +
        "local gprov = W.GamepadProvider.new(); local gConnected = gprov:isGamepadConnected(); " +
        "local uctx = W.UiContext.new(); local uctxInit = uctx.initialized; " +
        "local pxRatio = W.UiContext.currentPixelRatio(); " +
        // ===== 声明式窗口 =====
        "local win = W.Window.new('Demo', 640, 480, cfg); local winW = win.width; " +
        "local winStarted = win.started; local winEng = win:getEngine() ~= nil; " +
        // ===== 数值缓冲 =====
        "local fbuf = M.PtrArrayFloat32.new({ 0.5 }); local fv = fbuf.value; " +
        "fbuf.value = 0.75; local fv2 = fbuf.value; local farr = fbuf:toArray(); " +
        "local ibuf = M.PtrArrayInt32.new(2); ibuf:set(0, 7); local iv = ibuf:get(0); " +
        "local ilen = ibuf.length; " +
        // ===== 控件（不调用 draw，避免依赖 ImGui 上下文） =====
        "local txt = U.UiText.new('hi'); local txtId = txt:getId(); local txtV = txt:getText(); " +
        "txt:setText('yo'); local txtV2 = txt:getText(); " +
        "local cb = U.UiCheckbox.new('c', ibuf); local cbVal = cb:getValue(); " +
        "local lbl = U.UiLabelText.new('k', 'v'); local lblOk = lbl ~= nil; " +
        "local btn = U.UiButton.new('b'); local btnId = btn:getId(); " +
        "local winCls = U.UiWindow ~= nil; local dlCls = U.UiDrawList ~= nil; " +
        // ===== 声明式门面 =====
        "local fw = type(W.window); local fb = type(U.button); local fs = type(U.sliderFloat); " +
        "local fi = type(U.i32); local buf2 = U.f32(0.25); local buf2v = buf2.value; " +
        "return curHand, axLeftX, btnSouth, keyA, keySpace, mLeft, " +
        "cfgResizable, cfgResizable2, cfgOpacity, " +
        "keScan, keDown, mmX, mbBtn, mwY, weW, tePressure, tpx, " +
        "tfr, engInit, engW, mx, keyDown, kbBound, kbWin, mprovX, tCount, gConnected, " +
        "uctxInit, pxRatio, winW, winStarted, winEng, " +
        "fv, fv2, farr[1], iv, ilen, txtId, txtV, txtV2, cbVal, lblOk, btnId, winCls, dlCls, " +
        "fw, fb, fs, fi, buf2v")
    check("window 返回有效（50 个值）", r9v.size == 50)
    if (r9v.size >= 50) {
        check("SystemCursor.Hand() = 4", r9v[0].intValue() == 4)
        check("GamepadAxis.LeftX() = 0", r9v[1].intValue() == 0)
        check("GamepadButton.South() = 0", r9v[2].intValue() == 0)
        check("KeyCode.A() = 4", r9v[3].intValue() == 4)
        check("KeyCode.SPACE() = 44", r9v[4].intValue() == 44)
        check("MouseButton.LEFT() = 1", r9v[5].intValue() == 1)
        check("WindowConfig.resizable 默认 true", r9v[6].boolValue())
        check("WindowConfig.resizable 可写为 false", !r9v[7].boolValue())
        checkEq("WindowConfig.opacity 可写为 0.5", r9v[8].numberValue(), 0.5)
        check("KeyEvent.scancode 可读", r9v[9].intValue() == 4)
        check("KeyEvent.down = true", r9v[10].boolValue())
        checkEq("MouseMotionEvent.x = 1.5", r9v[11].numberValue(), 1.5)
        check("MouseButtonEvent.button = 1", r9v[12].intValue() == 1)
        checkEq("MouseWheelEvent.y = 1.0", r9v[13].numberValue(), 1.0)
        check("WindowEvent.data1 = 800", r9v[14].intValue() == 800)
        checkEq("TouchEvent.pressure = 0.8", r9v[15].numberValue(), 0.8)
        checkEq("TouchPoint.x = 0.25", r9v[16].numberValue(), 0.25)
        checkEq("WindowEngine.targetFrameRate 可读写", r9v[17].numberValue(), 60.0)
        check("WindowEngine.initialized 默认 false", !r9v[18].boolValue())
        check("WindowEngine.getWidth 默认 0", r9v[19].intValue() == 0)
        checkEq("InputEngine.getMouseX 默认 0", r9v[20].numberValue(), 0.0)
        check("InputEngine.isKeyDown 可调用", !r9v[21].boolValue())
        check("KeyboardProvider.isBound 默认 false", !r9v[22].boolValue())
        check("KeyboardProvider.getWindow 未绑定为 nil", r9v[23].boolValue())
        checkEq("MouseProvider.getMouseX 默认 0", r9v[24].numberValue(), 0.0)
        check("TouchProvider.getTouchCount 默认 0", r9v[25].intValue() == 0)
        check("GamepadProvider.isGamepadConnected 可调用", !r9v[26].boolValue())
        check("UiContext.initialized 默认 false", !r9v[27].boolValue())
        checkEq("UiContext.currentPixelRatio = 1.0", r9v[28].numberValue(), 1.0)
        check("Window.width 默认 0", r9v[29].intValue() == 0)
        check("Window.started 默认 false", !r9v[30].boolValue())
        check("Window.getEngine 返回引擎对象", r9v[31].boolValue())
        checkEq("PtrArrayFloat32 初值 0.5", r9v[32].numberValue(), 0.5)
        checkEq("PtrArrayFloat32.value 可写为 0.75", r9v[33].numberValue(), 0.75)
        checkEq("PtrArrayFloat32.toArray 回读 0.75", r9v[34].numberValue(), 0.75)
        check("PtrArrayInt32.set/get 一致", r9v[35].intValue() == 7)
        check("PtrArrayInt32.length = 2", r9v[36].intValue() == 2)
        check("UiText.getId 为空字符串", r9v[37].stringValue() == "")
        check("UiText.getText = 'hi'", r9v[38].stringValue() == "hi")
        check("UiText.setText 生效", r9v[39].stringValue() == "yo")
        check("UiCheckbox.getValue = 7（同一缓冲）", r9v[40].intValue() == 7)
        check("UiLabelText 可构造", r9v[41].boolValue())
        check("UiButton.getId 可调用", r9v[42].stringValue() == "")
        check("UiWindow 类表可用", r9v[43].boolValue())
        check("UiDrawList 类表可用", r9v[44].boolValue())
        check("声明式门面 window.window 可用", r9v[45].stringValue() == "function")
        check("声明式门面 ui.button 可用", r9v[46].stringValue() == "function")
        check("声明式门面 ui.sliderFloat 可用", r9v[47].stringValue() == "function")
        check("声明式门面 ui.i32 可用", r9v[48].stringValue() == "function")
        checkEq("声明式缓冲 ui.f32(0.25)", r9v[49].numberValue(), 0.25)
    }
    println("")

    // ---------- 9w. renderers：buffer 属性族 + textures 纹理族 ----------
    println("[9w] renderers：BufferAttribute / InterleavedBuffer / Texture / DataTexture / CubeTexture")
    let r9w = runLua(vm, "renderers",
        "local R = three.renderers; local B = R.buffer; local T = R.textures; " +
        // ===== BufferAttribute =====
        "local ba = B.Float32BufferAttribute.new({0, 1, 2, 3, 4, 5}, 3); " +
        "local baItems = ba.itemSize; local baLen = #ba.array; " +
        "local baY = ba:getY(0); ba:setXYZ(0, 7, 8, 9); local baX2 = ba:getX(0); " +
        "local baZ2 = ba:getZ(0); ba.usage = 35048; local baUsage = ba.usage; " +
        "ba:markNeedsUpdate(); local baVer = ba.version; " +
        "local baClone = ba:clone(); " +
        // ===== 交错缓冲 =====
        "local ib = B.InterleavedBuffer.new({1, 2, 3, 4, 5, 6}, 2); " +
        "local ibStride = ib.stride; local ibCount = ib.count; " +
        "local iba = B.InterleavedBufferAttribute.new(ib, 2, 0); " +
        "local ibaCount = iba:count(); local ibaX = iba:getX(1); " +
        "local ur = B.UpdateRange.new(3, 5); local urStart = ur.start; local urCount = ur.count; " +
        // ===== InstancedBufferAttribute =====
        "local inst = B.InstancedBufferAttribute.new({0, 0, 0, 0}, 2); " +
        "inst.meshPerAttribute = 4; local instMpa = inst.meshPerAttribute; " +
        // ===== Texture =====
        "local tex = T.Texture.new({1, 2, 3, 4}, 2, 2); " +
        "local texW = tex.width; local texH = tex.height; local texImg = #tex.image; " +
        "tex.wrapS = 1000; local texRepX = tex['repeat'].x; " +
        "local texUuid = #tex.uuid > 0; local texIsRT = tex.isRenderTargetTexture; " +
        // ===== DataTexture / CubeTexture =====
        "local dt = T.DataTexture.new({0, 0, 0, 255}, 1, 1); local dtW = dt.width; " +
        "local ct = T.CubeTexture.new(); local ctFaces = #ct.images; " +
        // ===== 工具类 =====
        "local bl = T.TextureUtils.getByteLength(4, 4, 1023, 1009); " +
        "local dt3 = T.Data3DTexture.new({0, 0, 0, 0, 0, 0, 0, 0}, 1, 1, 2); " +
        "local dt3Depth = #dt3.image; " +
        "local src = T.Source.new({9, 8}, 1, 2); local srcW = src.width; " +
        "local sz = {src:getSize()}; local srcSzW = sz[1]; " +
        "return baItems, baLen, baY, baX2, baZ2, baUsage, baVer, baClone ~= nil, " +
        "ibStride, ibCount, ibaCount, ibaX, urStart, urCount, instMpa, " +
        "texW, texH, texImg, texRepX, texUuid, texIsRT, dtW, ctFaces, bl, dt3Depth, srcW, srcSzW")
    check("renderers 返回有效（27 个值）", r9w.size == 27)
    if (r9w.size >= 27) {
        check("BufferAttribute.itemSize = 3", r9w[0].intValue() == 3)
        check("BufferAttribute.array 长度 = 6", r9w[1].intValue() == 6)
        checkEq("getY(0) = 1", r9w[2].numberValue(), 1.0)
        checkEq("setXYZ 后 getX(0) = 7", r9w[3].numberValue(), 7.0)
        checkEq("setXYZ 后 getZ(0) = 9", r9w[4].numberValue(), 9.0)
        check("usage = 35048", r9w[5].intValue() == 35048)
        check("markNeedsUpdate 后 version > 0", r9w[6].intValue() > 0)
        check("clone() 返回新实例", r9w[7].boolValue())
        check("InterleavedBuffer.stride = 2", r9w[8].intValue() == 2)
        check("InterleavedBuffer.count = 3", r9w[9].intValue() == 3)
        check("InterleavedBufferAttribute.count() = 3", r9w[10].intValue() == 3)
        checkEq("InterleavedBufferAttribute.getX(1) = 3", r9w[11].numberValue(), 3.0)
        check("UpdateRange.start = 3", r9w[12].intValue() == 3)
        check("UpdateRange.count = 5", r9w[13].intValue() == 5)
        check("InstancedBufferAttribute.meshPerAttribute = 4", r9w[14].intValue() == 4)
        check("Texture.width = 2", r9w[15].intValue() == 2)
        check("Texture.height = 2", r9w[16].intValue() == 2)
        check("Texture.image 长度 = 4", r9w[17].intValue() == 4)
        checkEq("Texture.repeat.x 默认 1.0", r9w[18].numberValue(), 1.0)
        check("Texture.uuid 非空", r9w[19].boolValue())
        check("Texture.isRenderTargetTexture = false", !r9w[20].boolValue())
        check("DataTexture.width = 1", r9w[21].intValue() == 1)
        check("CubeTexture.images 初始 0 面", r9w[22].intValue() == 0)
        check("getByteLength(4,4,RGBA,UBYTE) = 64", r9w[23].intValue() == 64)
        check("Data3DTexture.image 长度 = 8", r9w[24].intValue() == 8)
        check("Source.width = 1", r9w[25].intValue() == 1)
        check("Source.getSize() 宽 = 1", r9w[26].intValue() == 1)
    }
    println("")

    // ---------- 9x. renderers.geometry：BufferGeometry / 图元几何 / 曲线 / Shape ----------
    println("[9x] renderers.geometry：BufferGeometry / 图元几何 / 曲线 / Shape / Tube")
    let r9x = runLua(vm, "renderers.geometry",
        "local G = three.renderers.geometry; local B = three.renderers.buffer; local M = three.core.math; " +
        // ===== BufferGeometry：属性 / 绘制组 / 包围体 / 变换 =====
        "local g = G.BufferGeometry.new(); " +
        "g:setAttribute('position', B.Float32BufferAttribute.new({0, 0, 0, 1, 0, 0, 0, 1, 0}, 3)); " +
        "local hasPos = g:hasAttribute('position'); " +
        "local posCount = g:getAttribute('position').count; " +
        "g:addGroup(0, 3, 0); local gn = #g.groups; " +
        "local gStart = g.groups[1].start; local gCount = g.groups[1].count; " +
        "g:setDrawRange(0, 3); local dr = g.drawRange; " +
        "g:computeBoundingBox(); local bb = g:getBoundingBox(); " +
        "local bbMinY = bb.min.y; local bbMaxX = bb.max.x; " +
        "local selfOk = g:translate(1, 2, 3) ~= nil; local movedX = g:getAttribute('position'):getX(0); " +
        "g:deleteAttribute('position'); local hasPos2 = g:hasAttribute('position'); " +
        "local gClone = g:clone() ~= nil; " +
        // ===== 图元几何 =====
        "local box = G.BoxGeometry.new(2, 4, 6); local boxKind = box.kind; " +
        "local boxVerts = box:getAttribute('position').count; local boxIdx = box:getIndex().count; " +
        "local plane = G.PlaneGeometry.new(1, 1, 1, 1); " +
        "local planeVerts = plane:getAttribute('position').count; local planeIdx = plane:getIndex().count; " +
        "local sph = G.SphereGeometry.new(2, 8, 6); local sphVerts = sph:getAttribute('position').count; " +
        "sph:computeBoundingSphere(); local sphR = sph:getBoundingSphere().radius; " +
        "local ibg = G.InstancedBufferGeometry.new(); ibg.instanceCount = 5; local ibgCount = ibg.instanceCount; " +
        "local edges = G.EdgesGeometry.new(box); local edgeVerts = edges:getAttribute('position').count; " +
        "local wf = G.WireframeGeometry.new(box); local wfVerts = wf:getAttribute('position').count; " +
        // ===== 曲线族 =====
        "local ec = G.EllipseCurve.new(0, 0, 2, 2, 0, math.pi, false, 0); " +
        "local ecX = ec:getPoint(0).x; local ecLen = ec:getLength(); local ecN = #ec:getPoints(4); " +
        "local arc = G.ArcCurve.new(0, 0, 2, 0, math.pi); local arcLen = arc:getLength(); " +
        "local lc = G.LineCurve3.new(M.Vector3.new(0, 0, 0), M.Vector3.new(4, 0, 0)); local lcMid = lc:getPoint(0.5).x; " +
        "local cm = G.CatmullRomCurve3.new({M.Vector3.new(0, 0, 0), M.Vector3.new(1, 0, 0), " +
        "M.Vector3.new(2, 0, 0), M.Vector3.new(3, 0, 0)}); " +
        "local cmLen = cm:getLength(); local cmEnd = cm:getPoint(1).x; " +
        // ===== Path / Shape / ShapeGeometry / TubeGeometry =====
        "local path = G.Path.new(); path:moveTo(0, 0); path:lineTo(1, 0); path:lineTo(1, 1); " +
        "local pathLen = path:getLength(); " +
        "local shape = G.Shape.new(); shape:moveTo(0, 0); shape:lineTo(1, 0); shape:lineTo(0, 1); " +
        "local sg = G.ShapeGeometry.new(shape); " +
        "local sgVerts = sg:getAttribute('position').count; local sgIdx = sg:getIndex().count; " +
        "local tube = G.TubeGeometry.new(cm, 8, 0.5, 4, false); " +
        "local tubeVerts = tube:getAttribute('position').count; " +
        "return hasPos, posCount, gn, gStart, gCount, dr[1], dr[2], bbMinY, bbMaxX, selfOk, movedX, hasPos2, " +
        "gClone, boxKind, boxVerts, boxIdx, planeVerts, planeIdx, sphVerts, sphR, ibgCount, edgeVerts, wfVerts, " +
        "ecX, ecLen, ecN, arcLen, lcMid, cmLen, cmEnd, pathLen, sgVerts, sgIdx, tubeVerts")
    check("renderers.geometry 返回有效（34 个值）", r9x.size == 34)
    if (r9x.size >= 34) {
        check("BufferGeometry.setAttribute 后 hasAttribute = true", r9x[0].boolValue())
        check("BufferGeometry.getAttribute('position').count = 3", r9x[1].intValue() == 3)
        check("addGroup 后 groups 数量 = 1", r9x[2].intValue() == 1)
        check("groups[1].start = 0", r9x[3].intValue() == 0)
        check("groups[1].count = 3", r9x[4].intValue() == 3)
        check("setDrawRange 后 drawRange.start = 0", r9x[5].intValue() == 0)
        check("setDrawRange 后 drawRange.count = 3", r9x[6].intValue() == 3)
        checkEq("computeBoundingBox 后 min.y = 0", r9x[7].numberValue(), 0.0)
        checkEq("computeBoundingBox 后 max.x = 1", r9x[8].numberValue(), 1.0)
        check("translate 返回自身（可链式）", r9x[9].boolValue())
        checkEq("translate(1,2,3) 后 position.getX(0) = 1", r9x[10].numberValue(), 1.0)
        check("deleteAttribute 后 hasAttribute = false", !r9x[11].boolValue())
        check("BufferGeometry.clone() 返回新实例", r9x[12].boolValue())
        check("BoxGeometry.kind = 'BoxGeometry'", r9x[13].stringValue() == "BoxGeometry")
        check("BoxGeometry(2,4,6) 顶点数 = 24", r9x[14].intValue() == 24)
        check("BoxGeometry(2,4,6) 索引数 = 36", r9x[15].intValue() == 36)
        check("PlaneGeometry(1,1,1,1) 顶点数 = 4", r9x[16].intValue() == 4)
        check("PlaneGeometry(1,1,1,1) 索引数 = 6", r9x[17].intValue() == 6)
        check("SphereGeometry(2,8,6) 顶点数 = 63", r9x[18].intValue() == 63)
        checkEq("SphereGeometry 包围球半径 = 2", r9x[19].numberValue(), 2.0)
        checkEq("InstancedBufferGeometry.instanceCount = 5", r9x[20].numberValue(), 5.0)
        check("EdgesGeometry(box) 顶点数 = 24", r9x[21].intValue() == 24)
        check("WireframeGeometry(box) 顶点数 > 0", r9x[22].intValue() > 0)
        checkEq("EllipseCurve.getPoint(0).x = 2", r9x[23].numberValue(), 2.0)
        checkEq("EllipseCurve 半圆长度 ≈ 2π", r9x[24].numberValue(), 6.283185, tol: 0.01)
        check("EllipseCurve.getPoints(4) 返回 5 点", r9x[25].intValue() == 5)
        checkEq("ArcCurve 半圆长度 ≈ 2π", r9x[26].numberValue(), 6.283185, tol: 0.01)
        checkEq("LineCurve3.getPoint(0.5).x = 2", r9x[27].numberValue(), 2.0)
        checkEq("CatmullRomCurve3 折线长度 ≈ 3", r9x[28].numberValue(), 3.0, tol: 0.05)
        checkEq("CatmullRomCurve3.getPoint(1).x = 3", r9x[29].numberValue(), 3.0)
        checkEq("Path(L 形) 长度 = 2", r9x[30].numberValue(), 2.0, tol: 0.01)
        check("ShapeGeometry(三角形) 顶点数 = 3", r9x[31].intValue() == 3)
        check("ShapeGeometry(三角形) 索引数 = 3", r9x[32].intValue() == 3)
        check("TubeGeometry(8,4) 顶点数 = 45", r9x[33].intValue() == 45)
    }
    println("")

    // ---------- 9y. renderers.rendertarget：选项 / 渲染目标 / 3D 渲染目标 ----------
    println("[9y] renderers.rendertarget：RenderTargetOptions / RenderTarget / RenderTarget3D")
    let r9y = runLua(vm, "renderers.rendertarget",
        "local RT = three.renderers.rendertarget; " +
        "local opts = RT.RenderTargetOptions.new(); " +
        "opts.samples = 4; opts.generateMipmaps = false; opts.internalFormat = 'RGBA8'; " +
        "opts.depthBuffer = true; opts.count = 2; " +
        "local oSamples = opts.samples; local oMip = opts.generateMipmaps; " +
        "local oFmt = opts.internalFormat; local oCount = opts.count; " +
        "local rt = RT.RenderTarget.new(64, 32, opts); " +
        "local w = rt.width; local h = rt.height; local s = rt.samples; " +
        "local hasScissor = rt.scissor ~= nil; local vp = rt.viewport; local vpZ = vp.z; " +
        "rt:setSize(128, 96); local w2 = rt.width; local h2 = rt.height; " +
        "local c = rt:clone(); local cw = c.width; " +
        "local rt3 = RT.RenderTarget3D.new(4, 8, 16); " +
        "local w3 = rt3.width; local d3 = rt3.depth; " +
        "local relOk = rt:release() ~= nil; " +
        "return oSamples, oMip, oFmt, oCount, w, h, s, hasScissor, vpZ, w2, h2, cw, w3, d3, relOk")
    check("renderers.rendertarget 返回有效（15 个值）", r9y.size == 15)
    if (r9y.size >= 15) {
        check("RenderTargetOptions.samples = 4", r9y[0].intValue() == 4)
        check("RenderTargetOptions.generateMipmaps = false", !r9y[1].boolValue())
        check("RenderTargetOptions.internalFormat = 'RGBA8'", r9y[2].stringValue() == "RGBA8")
        check("RenderTargetOptions.count = 2", r9y[3].intValue() == 2)
        check("RenderTarget(64,32).width = 64", r9y[4].intValue() == 64)
        check("RenderTarget(64,32).height = 32", r9y[5].intValue() == 32)
        check("RenderTarget 继承 options.samples = 4", r9y[6].intValue() == 4)
        check("RenderTarget.scissor 为 Vector4 对象", r9y[7].boolValue())
        checkEq("RenderTarget.viewport.z = 64", r9y[8].numberValue(), 64.0)
        check("setSize 后 width = 128", r9y[9].intValue() == 128)
        check("setSize 后 height = 96", r9y[10].intValue() == 96)
        check("RenderTarget.clone().width = 128", r9y[11].intValue() == 128)
        check("RenderTarget3D.width = 4", r9y[12].intValue() == 4)
        check("RenderTarget3D.depth = 16", r9y[13].intValue() == 16)
        check("RenderTarget.release() 调用成功", r9y[14].boolValue())
    }
    println("")

    // ---------- 9z. renderers.textures 扩展：TypeByteLength / PMREMGenerator / 各类纹理 ----------
    println("[9z] renderers.textures 扩展：TypeByteLength / PMREMGenerator / Depth / Canvas / Compressed")
    let r9z = runLua(vm, "renderers.textures.ext",
        "local T = three.renderers.textures; " +
        "local tb = T.TypeByteLength.new(4, 4); local tbLen = tb.byteLength; local tbComp = tb.components; " +
        "local nl = T.PMREMGenerator.NUM_LEVELS(); local lf = T.PMREMGenerator.LEVEL_FACE_SIZES(); " +
        "local lf0 = lf[1]; local tw = T.PMREMGenerator.TEX_WIDTH(); " +
        "local depthTex = T.DepthTexture.new(4, 4); local dtw = depthTex.width; " +
        "local canvasTex = T.CanvasTexture.new({1, 2, 3, 4}, 2, 2); local cvw = canvasTex.width; " +
        "local compTex = T.CompressedTexture.new({1, 2, 3, 4}, 2, 2); local cmpW = compTex.width; " +
        "local extTex = T.ExternalTexture.new(); local extKind = extTex.kind; " +
        "local fbTex = T.FramebufferTexture.new(2, 2); local fbw = fbTex.width; " +
        "local daTex = T.DataArrayTexture.new({1, 2, 3, 4}, 1, 1, 2); local daw = daTex.width; " +
        "return tbLen, tbComp, nl, lf0, tw, dtw, cvw, cmpW, extKind, fbw, daw")
    check("renderers.textures 扩展返回有效（11 个值）", r9z.size == 11)
    if (r9z.size >= 11) {
        check("TypeByteLength(4,4).byteLength = 4", r9z[0].intValue() == 4)
        check("TypeByteLength(4,4).components = 4", r9z[1].intValue() == 4)
        check("PMREMGenerator.NUM_LEVELS() = 5", r9z[2].intValue() == 5)
        check("PMREMGenerator.LEVEL_FACE_SIZES()[1] = 256", r9z[3].intValue() == 256)
        check("PMREMGenerator.TEX_WIDTH() = 768", r9z[4].intValue() == 768)
        check("DepthTexture(4,4).width = 4", r9z[5].intValue() == 4)
        check("CanvasTexture(2,2).width = 2", r9z[6].intValue() == 2)
        check("CompressedTexture(2,2).width = 2", r9z[7].intValue() == 2)
        check("ExternalTexture.kind = 'ExternalTexture'", r9z[8].stringValue() == "ExternalTexture")
        check("FramebufferTexture(2,2).width = 2", r9z[9].intValue() == 2)
        check("DataArrayTexture(1,1,2).width = 1", r9z[10].intValue() == 1)
    }
    println("")

    // ---------- 9A. renderers.materials：Material 基类 + 常用材质子类 ----------
    println("[9A] renderers.materials：Material / Standard / Basic / Phong / Points / Line / Shader")
    let r9A = runLua(vm, "renderers.materials",
        "local MT = three.renderers.materials; local M = three.core.math; local T = three.renderers.textures; " +
        "local m = MT.Material.new(); " +
        "m.opacity = 0.5; m.transparent = true; m.side = 2; m.wireframe = true; m.flatShading = true; " +
        "m.depthTest = false; m.visible = false; m.toneMapped = false; m.alphaTest = 0.25; " +
        "m.name = 'mat'; m.envMapIntensity = 2; " +
        "m.color = M.Color.new(1, 0, 0); local cr = m.color.r; " +
        "local uuidOk = #m.uuid > 0; local idOk = m.id > 0; " +
        "local clone = m:clone(); local cloneOpacity = clone.opacity; " +
        "local std = MT.MeshStandardMaterial.new(); " +
        "std.roughness = 0.25; std.metalness = 0.75; std.emissiveIntensity = 2; " +
        "std.map = T.Texture.new({1, 2, 3, 4}, 2, 2); local mapW = std.map.width; " +
        "local basic = MT.MeshBasicMaterial.new(); basic.reflectivity = 0.7; " +
        "local phong = MT.MeshPhongMaterial.new(); phong.shininess = 50; " +
        "local pts = MT.PointsMaterial.new(); pts.size = 0.5; pts.sizeAttenuation = false; " +
        "local line = MT.LineBasicMaterial.new(); line.linewidth = 3; " +
        "local dashed = MT.LineDashedMaterial.new(); dashed.dashSize = 2; dashed.gapSize = 1; " +
        "local sh = MT.ShaderMaterial.new('void main() {}', 'void main() {}'); " +
        "local vsOk = #sh.vertexShader > 0; " +
        "m:dispose(); " +
        "return m.opacity, m.transparent, m.side, m.wireframe, m.flatShading, m.depthTest, m.visible, " +
        "m.toneMapped, m.alphaTest, m.envMapIntensity, cr, uuidOk, idOk, m.name, cloneOpacity, " +
        "std.roughness, std.metalness, std.emissiveIntensity, mapW, basic.reflectivity, phong.shininess, " +
        "pts.size, pts.sizeAttenuation, line.linewidth, dashed.dashSize, dashed.gapSize, vsOk")
    check("renderers.materials 返回有效（27 个值）", r9A.size == 27)
    if (r9A.size >= 27) {
        checkEq("Material.opacity = 0.5", r9A[0].numberValue(), 0.5)
        check("Material.transparent = true", r9A[1].boolValue())
        check("Material.side = 2", r9A[2].intValue() == 2)
        check("Material.wireframe = true", r9A[3].boolValue())
        check("Material.flatShading = true", r9A[4].boolValue())
        check("Material.depthTest = false", !r9A[5].boolValue())
        check("Material.visible = false", !r9A[6].boolValue())
        check("Material.toneMapped = false", !r9A[7].boolValue())
        checkEq("Material.alphaTest = 0.25", r9A[8].numberValue(), 0.25)
        checkEq("Material.envMapIntensity = 2", r9A[9].numberValue(), 2.0)
        checkEq("Material.color 读写（r = 1）", r9A[10].numberValue(), 1.0)
        check("Material.uuid 非空", r9A[11].boolValue())
        check("Material.id > 0", r9A[12].boolValue())
        check("Material.name = 'mat'", r9A[13].stringValue() == "mat")
        checkEq("Material.clone().opacity = 0.5", r9A[14].numberValue(), 0.5)
        checkEq("MeshStandardMaterial.roughness = 0.25", r9A[15].numberValue(), 0.25)
        checkEq("MeshStandardMaterial.metalness = 0.75", r9A[16].numberValue(), 0.75)
        checkEq("MeshStandardMaterial.emissiveIntensity = 2", r9A[17].numberValue(), 2.0)
        check("MeshStandardMaterial.map 往返（width = 2）", r9A[18].intValue() == 2)
        checkEq("MeshBasicMaterial.reflectivity = 0.7", r9A[19].numberValue(), 0.7)
        checkEq("MeshPhongMaterial.shininess = 50", r9A[20].numberValue(), 50.0)
        checkEq("PointsMaterial.size = 0.5", r9A[21].numberValue(), 0.5)
        check("PointsMaterial.sizeAttenuation = false", !r9A[22].boolValue())
        checkEq("LineBasicMaterial.linewidth = 3", r9A[23].numberValue(), 3.0)
        checkEq("LineDashedMaterial.dashSize = 2", r9A[24].numberValue(), 2.0)
        checkEq("LineDashedMaterial.gapSize = 1", r9A[25].numberValue(), 1.0)
        check("ShaderMaterial.vertexShader 非空", r9A[26].boolValue())
    }
    println("")

    // ---------- 9B. renderers.cameras：Camera / Perspective / Orthographic / Stereo / Array / Cube ----------
    println("[9B] renderers.cameras：Camera / Perspective / Orthographic / CameraView / Stereo / Array / Cube")
    let r9B = runLua(vm, "renderers.cameras",
        "local C = three.renderers.cameras; local M = three.core.math; " +
        "local cam = C.Camera.new(0.5, 500); " +
        "local camNear = cam.near; local camFar = cam.far; " +
        "cam.position = M.Vector3.new(1, 2, 3); local camX = cam.position.x; " +
        "local persp = C.PerspectiveCamera.new(60, 1.5, 0.1, 1000); " +
        "local pFov = persp.fov; local pAspect = persp.aspect; " +
        "local focal = persp:getFocalLength(); " +
        "persp.zoom = 2; persp:updateProjectionMatrix(); local pZoom = persp.zoom; " +
        "local effFov = persp:getEffectiveFOV(); " +
        "local filmW = persp:getFilmWidth(); " +
        "local ortho = C.OrthographicCamera.new(-2, 2, 3, -3, 0.1, 100); " +
        "local oLeft = ortho.left; local oRight = ortho.right; " +
        "local view = C.CameraView.new(true, 2, 2, 0, 0, 1, 1); " +
        "local vEnabled = view.enabled; local vWidth = view.width; " +
        "local vClone = view:clone(); local vcWidth = vClone.width; " +
        "local stereo = C.StereoCamera.new(); stereo.eyeSep = 0.1; local sep = stereo.eyeSep; " +
        "local cube = C.CubeCamera.new(); cube.activeMipmapLevel = 3; local mip = cube.activeMipmapLevel; " +
        "local arr = C.ArrayCamera.new({persp}); arr.isMultiViewCamera = true; local multi = arr.isMultiViewCamera; " +
        "return camNear, camFar, camX, pFov, pAspect, pZoom, effFov, focal, filmW, " +
        "oLeft, oRight, vEnabled, vWidth, vcWidth, sep, mip, multi")
    check("renderers.cameras 返回有效（17 个值）", r9B.size == 17)
    if (r9B.size >= 17) {
        checkEq("Camera(0.5,500).near = 0.5", r9B[0].numberValue(), 0.5)
        checkEq("Camera(0.5,500).far = 500", r9B[1].numberValue(), 500.0)
        checkEq("Camera 继承 Object3D.position.x = 1", r9B[2].numberValue(), 1.0)
        checkEq("PerspectiveCamera.fov = 60", r9B[3].numberValue(), 60.0)
        checkEq("PerspectiveCamera.aspect = 1.5", r9B[4].numberValue(), 1.5)
        checkEq("PerspectiveCamera.zoom = 2", r9B[5].numberValue(), 2.0)
        checkEq("getEffectiveFOV() ≈ 32.204（zoom=2）", r9B[6].numberValue(), 32.204, tol: 0.01)
        checkEq("getFocalLength() ≈ 20.21（fov=60, filmHeight=35/1.5）", r9B[7].numberValue(), 20.21, tol: 0.01)
        checkEq("getFilmWidth() = 35", r9B[8].numberValue(), 35.0)
        checkEq("OrthographicCamera.left = -2", r9B[9].numberValue(), -2.0)
        checkEq("OrthographicCamera.right = 2", r9B[10].numberValue(), 2.0)
        check("CameraView.enabled = true", r9B[11].boolValue())
        checkEq("CameraView.width = 1", r9B[12].numberValue(), 1.0)
        checkEq("CameraView.clone().width = 1", r9B[13].numberValue(), 1.0)
        checkEq("StereoCamera.eyeSep = 0.1", r9B[14].numberValue(), 0.1)
        check("CubeCamera.activeMipmapLevel = 3", r9B[15].intValue() == 3)
        check("ArrayCamera.isMultiViewCamera = true", r9B[16].boolValue())
    }
    println("")

    // ---------- 9C. renderers.lights：光源族 / 阴影 / 常量 ----------
    println("[9C] renderers.lights：Ambient / Directional / Hemisphere / Point / Spot / RectArea / Shadow / 常量")
    let r9C = runLua(vm, "renderers.lights",
        "local L = three.renderers.lights; " +
        "local amb = L.AmbientLight.new(0xffffff, 0.5); " +
        "local ambI = amb.intensity; local ambR = amb.color.r; " +
        "local dir = L.DirectionalLight.new(0xff0000, 2); " +
        "local dirI = dir.intensity; local dirR = dir.color.r; " +
        "dir.shadow.bias = 0.001; local shBias = dir.shadow.bias; " +
        "local hem = L.HemisphereLight.new(0x00ff00, 0x0000ff, 3); " +
        "local hemI = hem.intensity; local skyG = hem.skyColor.g; " +
        "local pt = L.PointLight.new(0xffffff, 1.5, 100, 2); " +
        "local ptD = pt.distance; local ptDecay = pt.decay; local ptShadow = pt.shadow ~= nil; " +
        "local sp = L.SpotLight.new(0xffffff, 1, 50, math.pi / 4, 0.5, 2); " +
        "local spA = sp.angle; local spP = sp.penumbra; " +
        "local rect = L.RectAreaLight.new(0xffffff, 1, 4, 8); " +
        "local rw = rect.width; local rh = rect.height; " +
        "local probe = L.LightProbe.new(); local probeI = probe.intensity; " +
        "local pcf = L.ShadowConstants.PCF_SHADOW_MAP(); " +
        "local csm = L.ShadowConstants.CSM_CASCADE_COUNT(); " +
        "return ambI, ambR, dirI, dirR, shBias, hemI, skyG, ptD, ptDecay, spA, spP, rw, rh, probeI, pcf, csm, ptShadow")
    check("renderers.lights 返回有效（17 个值）", r9C.size == 17)
    if (r9C.size >= 17) {
        checkEq("AmbientLight.intensity = 0.5", r9C[0].numberValue(), 0.5)
        checkEq("AmbientLight.color.r = 1", r9C[1].numberValue(), 1.0)
        checkEq("DirectionalLight.intensity = 2", r9C[2].numberValue(), 2.0)
        checkEq("DirectionalLight.color.r = 1", r9C[3].numberValue(), 1.0)
        checkEq("DirectionalLight.shadow.bias = 0.001", r9C[4].numberValue(), 0.001)
        checkEq("HemisphereLight.intensity = 3", r9C[5].numberValue(), 3.0)
        checkEq("HemisphereLight.skyColor.g = 1", r9C[6].numberValue(), 1.0)
        checkEq("PointLight.distance = 100", r9C[7].numberValue(), 100.0)
        checkEq("PointLight.decay = 2", r9C[8].numberValue(), 2.0)
        checkEq("SpotLight.angle = π/4", r9C[9].numberValue(), 0.785398, tol: 0.0001)
        checkEq("SpotLight.penumbra = 0.5", r9C[10].numberValue(), 0.5)
        checkEq("RectAreaLight.width = 4", r9C[11].numberValue(), 4.0)
        checkEq("RectAreaLight.height = 8", r9C[12].numberValue(), 8.0)
        checkEq("LightProbe.intensity = 1", r9C[13].numberValue(), 1.0)
        check("ShadowConstants.PCF_SHADOW_MAP() = 1", r9C[14].intValue() == 1)
        check("ShadowConstants.CSM_CASCADE_COUNT() = 4", r9C[15].intValue() == 4)
        check("PointLight.shadow 对象可访问", r9C[16].boolValue())
    }
    println("")

    // ---------- 9D. renderers.helpers：Axes / Grid / PolarGrid / Arrow / Box3 / Box ----------
    println("[9D] renderers.helpers：Axes / Grid / PolarGrid / Arrow / Box3 / Box")
    let r9D = runLua(vm, "renderers.helpers",
        "local H = three.renderers.helpers; local M = three.core.math; local O = three.scene.objects; " +
        "local axes = H.AxesHelper.new(2); " +
        "local axVerts = axes.geometry:getAttribute('position').count; " +
        "axes.position = M.Vector3.new(1, 0, 0); local axX = axes.position.x; " +
        "local grid = H.GridHelper.new(10, 10); " +
        "local gridVerts = grid.geometry:getAttribute('position').count; " +
        "local polar = H.PolarGridHelper.new(10, 16, 8, 64); " +
        "local polarVerts = polar.geometry:getAttribute('position').count; " +
        "local arrow = H.ArrowHelper.new(M.Vector3.new(0, 1, 0), M.Vector3.new(0, 0, 0), 2); " +
        "arrow:setLength(3, 0.5, 0.25); arrow:setDirection(M.Vector3.new(1, 0, 0)); " +
        "arrow:setColor(M.Color.new(0, 1, 0)); " +
        "local lineOk = arrow.line ~= nil; local coneOk = arrow.cone ~= nil; " +
        "local box = M.Box3.new(M.Vector3.new(0, 0, 0), M.Vector3.new(1, 1, 1)); " +
        "local b3 = H.Box3Helper.new(box); local b3MinX = b3.box.min.x; " +
        "local obj = O.Object3D.new(); local bh = H.BoxHelper.new(obj); " +
        "local objOk = bh.object ~= nil; bh:update(); " +
        "local bhVerts = bh.geometry:getAttribute('position').count; " +
        "return axVerts, axX, gridVerts, polarVerts, lineOk, coneOk, b3MinX, objOk, bhVerts")
    check("renderers.helpers 返回有效（9 个值）", r9D.size == 9)
    if (r9D.size >= 9) {
        check("AxesHelper(2) 顶点数 = 6", r9D[0].intValue() == 6)
        checkEq("AxesHelper 继承 Object3D.position.x = 1", r9D[1].numberValue(), 1.0)
        check("GridHelper(10,10) 顶点数 > 0", r9D[2].intValue() > 0)
        check("PolarGridHelper 顶点数 > 0", r9D[3].intValue() > 0)
        check("ArrowHelper.line 可访问", r9D[4].boolValue())
        check("ArrowHelper.cone 可访问", r9D[5].boolValue())
        checkEq("Box3Helper.box.min.x = 0", r9D[6].numberValue(), 0.0)
        check("BoxHelper.object 可访问", r9D[7].boolValue())
        check("BoxHelper.update() 后顶点数 > 0", r9D[8].intValue() > 0)
    }
    println("")

    // ---------- 9E. renderers.ThreeRenderer：构造 / 清屏色属性 / 常量 ----------
    println("[9E] renderers.ThreeRenderer：构造 / viewId / clearColor 属性 / 常量")
    let r9E = runLua(vm, "renderers.ThreeRenderer",
        "local R = three.renderers; local M = three.core.math; " +
        "local r = R.ThreeRenderer.new(); " +
        "local v0 = r.viewId; " +
        "r.viewId = 3; local v3 = r.viewId; " +
        // setClearColor 会经渲染命令线程同步执行，测试环境没有渲染线程会阻塞；
        // 这里改测 clearColor 属性通道（绑定 getter/setter）。
        "r.clearColor = 4278190335; local cc = r.clearColor; " +
        "local ccFlag = R.ThreeRenderer.CLEAR_COLOR(); " +
        "local cdFlag = R.ThreeRenderer.CLEAR_DEPTH(); " +
        "local rt = R.ThreeRenderer.DEFAULT_RENDERER_TYPE(); local rtOk = rt >= 0; " +
        "local rel = r.releasable; local relOk = rel == true or rel == false; " +
        "return v0, v3, cc, ccFlag, cdFlag, rtOk, relOk")
    check("ThreeRenderer 返回有效（7 个值）", r9E.size == 7)
    if (r9E.size >= 7) {
        check("ThreeRenderer.viewId 默认 0", r9E[0].intValue() == 0)
        check("ThreeRenderer.viewId 可写为 3", r9E[1].intValue() == 3)
        check("clearColor 属性写读 → 0xFF0000FF", r9E[2].numberValue() == 4278190335.0)
        check("ThreeRenderer.CLEAR_COLOR() = 1", r9E[3].intValue() == 1)
        check("ThreeRenderer.CLEAR_DEPTH() = 2", r9E[4].intValue() == 2)
        check("ThreeRenderer.DEFAULT_RENDERER_TYPE() 可读", r9E[5].boolValue())
        check("ThreeRenderer.releasable 可读", r9E[6].boolValue())
    }
    println("")

    // ---------- 9E2. renderers.EngineDataTexture：invalid / 常用常量 ----------
    println("[9E2] renderers.EngineDataTexture：invalid / 只读属性 / 常量")
    let r9E2 = runLua(vm, "renderers.EngineDataTexture",
        "local E = three.renderers.textures.EngineDataTexture; " +
        "local t = E.invalid(); " +
        "local ok = (t.isValid == false) and (t.width == 0) and (t.depth == 1); " +
        "local f8 = E.FORMAT_RGBA8(); local f16 = E.FORMAT_RGBA16F(); local f32 = E.FORMAT_RGBA32F(); " +
        "local uv = E.FLAGS_CLAMP_UV(); local uvw = E.FLAGS_CLAMP_UVW_POINT(); " +
        "local rel = t.releasable; local relOk = rel == true or rel == false; " +
        "return ok, f8, f16, f32, uv, uvw, relOk")
    check("EngineDataTexture 返回有效（7 个值）", r9E2.size == 7)
    if (r9E2.size >= 7) {
        check("EngineDataTexture.invalid() 的 isValid = false / width = 0 / depth = 1", r9E2[0].boolValue())
        check("EngineDataTexture.FORMAT_RGBA8() 可读", r9E2[1].intValue() >= 0)
        check("EngineDataTexture.FORMAT_RGBA16F() 可读", r9E2[2].intValue() >= 0)
        check("EngineDataTexture.FORMAT_RGBA32F() 可读", r9E2[3].intValue() >= 0)
        check("EngineDataTexture.FLAGS_CLAMP_UV() > 0", r9E2[4].intValue() > 0)
        check("EngineDataTexture.FLAGS_CLAMP_UVW_POINT() > 0", r9E2[5].intValue() > 0)
        check("EngineDataTexture.releasable 可读", r9E2[6].boolValue())
    }
    println("")

    // ---------- 9F. renderers.postprocessing：Pass / ClearPass / ShaderPass / TexturePass / RenderPass / EffectComposer ----------
    println("[9F] renderers.postprocessing：Pass / Clear / Shader / Texture / Render / EffectComposer")
    let r9F = runLua(vm, "renderers.postprocessing",
        "local PP = three.renderers.postprocessing; local R = three.renderers; " +
        "local S = three.scene.scenegraph; local C = three.renderers.cameras; " +
        "local p = PP.Pass.new(); " +
        "local isPass = p.isPass; local en = p.enabled; local swap = p.needsSwap; " +
        "local clr = p.clear; local rts = p.renderToScreen; " +
        "p.enabled = false; local en2 = p.enabled; " +
        "p.renderToScreen = true; local rts2 = p.renderToScreen; " +
        "local cp = PP.ClearPass.new(287454207, 0.5); " +
        "local cpColor = cp.clearColor; local cpAlpha = cp.clearAlpha; " +
        "local sp = PP.ShaderPass.new('testShader'); " +
        "local spName = sp.shaderName; local spTex = sp.textureID; " +
        "local tp = PP.TexturePass.new(); tp.opacity = 0.25; local tpOp = tp.opacity; " +
        "local rp = PP.RenderPass.new(S.Scene.new(), C.Camera.new()); " +
        "local rpScene = rp.scene ~= nil; local rpClearDepth = rp.clearDepth; " +
        "local renderer = R.ThreeRenderer.new(); " +
        "local comp = PP.EffectComposer.new(renderer); " +
        "local compRenderer = comp.renderer ~= nil; local compPasses = #comp.passes; " +
        "local compRTS = comp.renderToScreen; local compQuad = comp.quad ~= nil; " +
        "return isPass, en, swap, clr, rts, en2, rts2, cpColor, cpAlpha, spName, spTex, tpOp, " +
        "rpScene, rpClearDepth, compRenderer, compPasses, compRTS, compQuad")
    check("renderers.postprocessing 返回有效（18 个值）", r9F.size == 18)
    if (r9F.size >= 18) {
        check("Pass.isPass = true", r9F[0].boolValue())
        check("Pass.enabled 默认 true", r9F[1].boolValue())
        check("Pass.needsSwap 默认 true", r9F[2].boolValue())
        check("Pass.clear 默认 false", !r9F[3].boolValue())
        check("Pass.renderToScreen 默认 false", !r9F[4].boolValue())
        check("Pass.enabled 可写为 false", !r9F[5].boolValue())
        check("Pass.renderToScreen 可写为 true", r9F[6].boolValue())
        check("ClearPass.clearColor = 0x112233FF", r9F[7].numberValue() == 287454207.0)
        checkEq("ClearPass.clearAlpha = 0.5", r9F[8].numberValue(), 0.5)
        check("ShaderPass.shaderName = 'testShader'", r9F[9].stringValue() == "testShader")
        check("ShaderPass.textureID = 'tDiffuse'", r9F[10].stringValue() == "tDiffuse")
        checkEq("TexturePass.opacity = 0.25", r9F[11].numberValue(), 0.25)
        check("RenderPass.scene 可访问", r9F[12].boolValue())
        check("RenderPass.clearDepth 默认 false", !r9F[13].boolValue())
        check("EffectComposer.renderer 可访问", r9F[14].boolValue())
        check("EffectComposer.passes 初始为空", r9F[15].intValue() == 0)
        check("EffectComposer.renderToScreen 默认 true", r9F[16].boolValue())
        check("EffectComposer.quad 可访问", r9F[17].boolValue())
    }
    println("")

    // ---------- 9G. resources/lua/three/renderers*.lua 模块可加载 ----------
    println("[9G] renderers Lua 模块加载（three.renderers.* 命名空间代理）")
    let r9G = runLua(vm, "renderers.modules",
        "package.path = '../../../resources/lua/?.lua;' .. package.path; " +
        "local r0 = require('three.renderers'); " +
        "local r1 = require('three.renderers.buffer'); " +
        "local r2 = require('three.renderers.geometry'); " +
        "local r3 = require('three.renderers.materials'); " +
        "local r4 = require('three.renderers.cameras'); " +
        "local r5 = require('three.renderers.lights'); " +
        "local r6 = require('three.renderers.rendertarget'); " +
        "local r7 = require('three.renderers.helpers'); " +
        "local r8 = require('three.renderers.postprocessing'); " +
        "return r0 ~= nil, r1 ~= nil, r2 ~= nil, r3 ~= nil, r4 ~= nil, r5 ~= nil, " +
        "r6 ~= nil, r7 ~= nil, r8 ~= nil, r2.BoxGeometry ~= nil, r3.MeshStandardMaterial ~= nil")
    check("renderers 模块返回有效（11 个值）", r9G.size == 11)
    if (r9G.size >= 11) {
        check("require('three.renderers') 可加载", r9G[0].boolValue())
        check("require('three.renderers.buffer') 可加载", r9G[1].boolValue())
        check("require('three.renderers.geometry') 可加载", r9G[2].boolValue())
        check("require('three.renderers.materials') 可加载", r9G[3].boolValue())
        check("require('three.renderers.cameras') 可加载", r9G[4].boolValue())
        check("require('three.renderers.lights') 可加载", r9G[5].boolValue())
        check("require('three.renderers.rendertarget') 可加载", r9G[6].boolValue())
        check("require('three.renderers.helpers') 可加载", r9G[7].boolValue())
        check("require('three.renderers.postprocessing') 可加载", r9G[8].boolValue())
        check("geometry 命名空间暴露 BoxGeometry", r9G[9].boolValue())
        check("materials 命名空间暴露 MeshStandardMaterial", r9G[10].boolValue())
    }
    println("")


    // ---------- 9H. renderers.gfx / interfaces：枚举 / 标志 / 结构 / 句柄 / 抽象层工厂 ----------
    println("[9H] renderers.gfx / interfaces：枚举 / 标志 / 结构 / 句柄 / 抽象层工厂")
    let r9H = runLua(vm, "renderers.gfx",
        "package.path = '../../../resources/lua/?.lua;' .. package.path; " +
        "local G = require('three.renderers.common'); " +
        "local I = require('three.renderers._interfaces'); " +
        "local R = three.renderers; local PP = three.renderers.postprocessing; " +
        "local fmt = G.GfxTextureFormat.RGBA16F(); local ut = G.GfxUniformType.Vec4(); " +
        "local rt = G.GfxRendererType.Direct3D11(); local flag = G.GfxTextureFlag.RT(); " +
        "local state = G.GfxState.DEFAULT(); local clear = G.GfxClearFlag.COLOR(); " +
        "local th = G.GfxTextureHandle.new(123); local thOk = th.idx == 123 and th.isValid == true; " +
        "local inv = G.GfxTextureHandle.INVALID(); " +
        "local ad = G.GfxAttributeDesc.new(0, 3, 6); " +
        "local adOk = ad.attrib == 0 and ad.num == 3 and ad.attribType == 6; " +
        "local cs = G.GfxCapsSummary.new(2, 16, 32, 0, true, 8192, 16); " +
        "local csOk = cs.rendererType == 2 and cs.maxTextureSize == 8192 and cs.maxViews == 16; " +
        "local prog = R.ThreeRenderer.makeShaderProgram('t', '', ''); " +
        "local progOk = prog ~= nil; " +
        "prog:resetHandles(); local ph = prog.gfxProgramHandle; " +
        "local reg = R.ThreeRenderer.makeUniformRegistry(); local regOk = reg ~= nil; " +
        "local p = PP.Pass.new(); p:submitQuad(0, 65535); local pq = p.quad; " +
        "local rd = R.ThreeRenderer.new(); local sz = rd:getSize(); " +
        "local szOk = sz[1] == 800 and sz[2] == 600; " +
        "local prOk = rd:getPixelRatio() == 1.0; " +
        "return fmt, ut, rt, flag, state, clear, thOk, inv, adOk, csOk, progOk, ph, regOk, pq == nil, szOk, prOk")
    check("renderers.gfx 返回有效（16 个值）", r9H.size == 16)
    if (r9H.size >= 16) {
        check("GfxTextureFormat.RGBA16F() = 81", r9H[0].intValue() == 81)
        check("GfxUniformType.Vec4() = 2", r9H[1].intValue() == 2)
        check("GfxRendererType.Direct3D11() = 2", r9H[2].intValue() == 2)
        check("GfxTextureFlag.RT() > 0", r9H[3].intValue() > 0)
        check("GfxState.DEFAULT() > 0", r9H[4].intValue() > 0)
        check("GfxClearFlag.COLOR() = 1", r9H[5].intValue() == 1)
        check("GfxTextureHandle.new(123) 的 idx/isValid 正确", r9H[6].boolValue())
        check("GfxTextureHandle.INVALID() = 65535", r9H[7].intValue() == 65535)
        check("GfxAttributeDesc 构造与属性正确", r9H[8].boolValue())
        check("GfxCapsSummary 构造与属性正确", r9H[9].boolValue())
        check("ThreeRenderer.makeShaderProgram() 返回对象", r9H[10].boolValue())
        check("IShaderProgram.gfxProgramHandle 未编译时为 65535", r9H[11].intValue() == 65535)
        check("ThreeRenderer.makeUniformRegistry() 返回对象", r9H[12].boolValue())
        check("Pass.submitQuad 在 quad 未注入时静默跳过", r9H[13].boolValue())
        check("ThreeRenderer.getSize() = [800, 600]", r9H[14].boolValue())
        check("ThreeRenderer.getPixelRatio() = 1.0", r9H[15].boolValue())
    }
    println("")

    // ---------- 9I. renderers.xr：XR 会话 / 控制器空间 / 深度感知 ----------
    println("[9I] renderers.xr：XR 会话 / 控制器空间 / 深度感知")
    let r9I = runLua(vm, "renderers.xr",
        "package.path = '../../../resources/lua/?.lua;' .. package.path; " +
        "local X = require('three.renderers.xr'); local R = three.renderers; " +
        "local S = X.XRSessionState; local P = X.XRReferenceSpaceType; " +
        "local noneOk = S.None() == 0 and S.Creating() == 1 and S.Active() == 2 and S.Ending() == 3; " +
        "local lfOk = P.LocalFloor() == 0 and P.Local() == 1 and P.Bounded() == 2 and P.Unbounded() == 3; " +
        "local rd = R.ThreeRenderer.new(); local xr = X.XRManager.new(rd); " +
        "local present0 = xr:isXRPresenting(); " +
        "xr:setReferenceSpaceType(P.Local()); local refOk = xr:getReferenceSpaceType() == 1; " +
        "xr:requestSession('immersive-vr'); local present1 = xr:isXRPresenting(); " +
        "local camOk = xr:getCamera() ~= nil; " +
        "local ctrl = xr:getController(0); " +
        "local ctrlOk = ctrl ~= nil and ctrl.spaceType == 'targetRay'; " +
        "ctrl.visible = true; ctrl.positionX = 1.5; " +
        "local ctrlValOk = ctrl.visible == true and ctrl.positionX == 1.5; " +
        "local dc = X.XRController.new(); local ray = dc:getTargetRaySpace(); " +
        "dc:setInputSource('left'); local srcOk = dc:getInputSource() == 'left'; " +
        "local rt = X.XRRenderTarget.new(1024, 512); rt:setSize(800, 600); " +
        "local rtOk = rt.width == 800 and rt.height == 600; " +
        "local ds = X.XRDepthSensing.new(); " +
        "local mesh0 = ds:getMesh(); local avail0 = ds:isAvailable(); " +
        "ds:update(0.1, 100.0, 32, 32); local avail1 = ds:isAvailable(); " +
        "local texIdx = ds:getTextureIdx(); " +
        "local blendOk = xr:getEnvironmentBlendMode() == 'opaque'; " +
        "xr:endSession(); " +
        "return noneOk, lfOk, present0, refOk, present1, camOk, ctrlOk, ctrlValOk, srcOk, rtOk, " +
        "mesh0 == nil, avail0, avail1, texIdx, blendOk, xr:isXRPresenting()")
    check("renderers.xr 返回有效（16 个值）", r9I.size == 16)
    if (r9I.size >= 16) {
        check("XRSessionState 声明顺序取值正确", r9I[0].boolValue())
        check("XRReferenceSpaceType 声明顺序取值正确", r9I[1].boolValue())
        check("XRManager 初始未呈现", !r9I[2].boolValue())
        check("setReferenceSpaceType(Local) 后读回 1", r9I[3].boolValue())
        check("requestSession 后正在呈现", r9I[4].boolValue())
        check("getCamera 返回 ArrayCamera", r9I[5].boolValue())
        check("getController(0).spaceType = 'targetRay'", r9I[6].boolValue())
        check("XRControllerSpace 位姿属性可读写", r9I[7].boolValue())
        check("XRController.setInputSource/getInputSource 往返", r9I[8].boolValue())
        check("XRRenderTarget.setSize 生效", r9I[9].boolValue())
        check("XRDepthSensing 无深度纹理时 getMesh = nil", r9I[10].boolValue())
        check("XRDepthSensing.update 前不可用", !r9I[11].boolValue())
        check("XRDepthSensing.update 后可用", r9I[12].boolValue())
        check("XRDepthSensing.getTextureIdx = 65535", r9I[13].intValue() == 65535)
        check("getEnvironmentBlendMode = 'opaque'", r9I[14].boolValue())
        check("endSession 后不再呈现", !r9I[15].boolValue())
    }
    println("")

    // ---------- 9J. renderers.common Info / Constants 与 renderers.shaders ----------
    println("[9J] renderers.common Info / Constants 与 renderers.shaders")
    let r9J = runLua(vm, "renderers.common.shaders",
        "package.path = '../../../resources/lua/?.lua;' .. package.path; " +
        "local C = require('three.renderers.common'); local S = require('three.renderers.shaders'); " +
        "local R = three.renderers; local rd = R.ThreeRenderer.new(); " +
        "local info = rd.info; " +
        "local infoOk = info ~= nil and info.calls == 0 and info.frame == 0; " +
        "info.calls = 5; info:update(7); " +
        "local infoValOk = info.calls == 5 and info.frame == 7; " +
        "info.render.triangles = 12; local subOk = info.render.triangles == 12; " +
        "info.memory.textures = 3; local memOk = info.memory.textures == 3; " +
        "local cc = C.Constants; " +
        "local constOk = cc.TRIANGLES() == 0 and cc.LINES() == 1 and cc.BACKEND() == 'bgfx'; " +
        "S.ShaderChunks.define('ut_chunk', 'float ut_value;'); " +
        "local chunkOk = S.ShaderChunks.get('ut_chunk') == 'float ut_value;'; " +
        "local missNil = S.ShaderChunks.get('__missing_chunk__') == nil; " +
        "local resolved = S.ShaderChunks.resolve('#include <ut_chunk>\\nvoid main() {}'); " +
        "local resolveOk = string.find(resolved, 'float ut_value', 1, true) ~= nil; " +
        "local mat = three.renderers.materials.MeshStandardMaterial.new(); " +
        "local defs = S.ShaderVariant.getDefines(mat); local defsOk = type(defs) == 'table'; " +
        "local key = S.ShaderVariant.getVariantKey(mat); " +
        "local keyOk = type(key) == 'string' and #key > 0; " +
        "return infoOk, infoValOk, subOk, memOk, constOk, chunkOk, missNil, resolveOk, defsOk, keyOk, " +
        "rd.info.frame == 7")
    check("renderers.common / shaders 返回有效（11 个值）", r9J.size == 11)
    if (r9J.size >= 11) {
        check("ThreeRenderer.info 初始统计为 0", r9J[0].boolValue())
        check("Info.calls 写回 / update(frame) 生效", r9J[1].boolValue())
        check("Info.render 子统计为同一实例", r9J[2].boolValue())
        check("Info.memory 子统计为同一实例", r9J[3].boolValue())
        check("Constants.TRIANGLES/LINES/BACKEND 正确", r9J[4].boolValue())
        check("ShaderChunks.define/get 往返", r9J[5].boolValue())
        check("ShaderChunks.get 缺失返回 nil", r9J[6].boolValue())
        check("ShaderChunks.resolve 展开 #include", r9J[7].boolValue())
        check("ShaderVariant.getDefines 返回数组", r9J[8].boolValue())
        check("ShaderVariant.getVariantKey 返回非空字符串", r9J[9].boolValue())
        check("再次读取 rd.info.frame 仍为 7（同一实例）", r9J[10].boolValue())
    }
    println("")

    // ---------- 9K. renderers.shaders 其余类（UniformsLib / SamplerStages / ShaderCompiler） ----------
    println("[9K] renderers.shaders 其余类：UniformsLib / SamplerStages / ShaderCompiler")
    let r9K = runLua(vm, "renderers.shaders.full",
        "local S = require('three.renderers.shaders'); " +
        "S.UniformsLib.initialize(); " +
        "local cu = S.ShaderChunks.get('common_uniforms'); " +
        "local libOk = cu ~= nil and string.find(cu, 'uniform mat4 u_model', 1, true) ~= nil; " +
        "local ss = S.SamplerStages; " +
        "local constOk = ss.STAGE_MAP() == 8 and ss.STAGE_ENV_MAP() == 14 and ss.STAGE_DFGLUT() == 15; " +
        "local maxOk = ss.MAX_DIR_SHADOW() == 4 and ss.MAX_SPOT_SHADOW() == 2 and ss.MAX_POINT_SHADOW() == 2; " +
        "local dynOk = ss.dynamicShadowEnd(1, 1, 1) == 3; " +
        "local valOk = ss.validate(1, 1, 1) == true and ss.validate(9, 0, 0) == false; " +
        "local phOk = ss.applyPlaceholders('__STAGE_MAP__') == '8'; " +
        "local rep = ss.getPlaceholderReplacements(); " +
        "local repOk = type(rep) == 'table' and #rep == 9 and rep[1][1] == '__STAGE_MAP__' and rep[1][2] == '8'; " +
        "local sc = S.ShaderCompiler; " +
        "local stackOk = sc.DEFAULT_STACK_SIZE() == 8388608; " +
        "local statsOk = sc.totalSubmitted() == 0 and sc.totalCompleted() == 0 and sc.totalErrors() == 0; " +
        "local runOk = sc.isRunning() == false and sc.progress() == 1.0; " +
        "local jobOk = three.renderers.shaders.ShaderCompileJob ~= nil; " +
        "return libOk, constOk, maxOk, dynOk, valOk, phOk, repOk, stackOk, statsOk, runOk, jobOk")
    check("renderers.shaders 其余类返回有效（11 个值）", r9K.size == 11)
    if (r9K.size >= 11) {
        check("UniformsLib.initialize 注册 common_uniforms", r9K[0].boolValue())
        check("SamplerStages 固定段 STAGE_* 取值正确", r9K[1].boolValue())
        check("SamplerStages shadow 数组上限正确", r9K[2].boolValue())
        check("SamplerStages.dynamicShadowEnd(1,1,1) = 3", r9K[3].boolValue())
        check("SamplerStages.validate 边界判定正确", r9K[4].boolValue())
        check("SamplerStages.applyPlaceholders 替换正确", r9K[5].boolValue())
        check("getPlaceholderReplacements 返回 9 项", r9K[6].boolValue())
        check("ShaderCompiler.DEFAULT_STACK_SIZE = 8388608", r9K[7].boolValue())
        check("ShaderCompiler 统计初值为 0", r9K[8].boolValue())
        check("ShaderCompiler 未启动 / progress = 1.0", r9K[9].boolValue())
        check("ShaderCompileJob 类表可访问", r9K[10].boolValue())
    }
    println("")

    // ---------- 10. 已登记类在 Lua 侧全部可访问 ----------
    println("[10] 已登记绑定类在 Lua 侧全部可访问")
    let missing = ArrayList<String>()
    for (name in classes) {
        var ok: Bool = false
        try {
            let res = vm.doString("return ${name} ~= nil")
            ok = res.size > 0 && res[0].boolValue()
        } catch (_) {
            ok = false
        }
        if (!ok) {
            missing.add(name)
        }
    }
    check("${classes.size} 个已登记类全部可访问（missing = ${missing.size}）", missing.size == 0)
    for (m in missing) {
        warn("已登记但 Lua 侧 nil: ${m}")
    }
    println("")

    // ========== 结果汇总 ==========
    println("=== 测试结果 ===")
    println("  PASS: ${_passCount}")
    println("  FAIL: ${_failCount}")
    if (_warnCount > 0) {
        println("  WARN: ${_warnCount}")
    }
    let allPass = _failCount == 0
    if (allPass) {
        println("  == 全部通过 ==")
    } else {
        println("  == 存在失败用例 ==")
    }
    try {
        vm.release()
    } catch (_) {
        // 忽略释放异常
    }
    return if (allPass) { 0 } else { 1 }
}
