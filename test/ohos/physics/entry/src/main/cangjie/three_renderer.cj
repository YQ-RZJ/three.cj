package ohos_app_cangjie_entry

/**
 * 仓颉侧 three 渲染引擎 + 物理（Jolt）场景与 ArkTS 侧 XComponent 的桥接（纯仓颉实现，无 C++）。
 *
 * 本文件由 test/ohos/base 复制而来，场景迁移自 test/windows/physics（物理能力示例）：
 *  - 一个大平面作为静态地面（Plane + PhysicsShape.Plane，Static 刚体）
 *  - 若干彩色立方体从空中下落（Box + Dynamic 刚体，受重力）
 *  - 球体（Sphere + Dynamic，高弹性）、胶囊体（Capsule + Dynamic）、圆柱体（Cylinder，力演示）
 *  - 铰链约束钟摆、距离约束双球链、Mesh 三角网格坡道、ConvexHull 凸包、Compound 复合形状
 *  - 碰撞事件监听器 + 碰撞查询（raycastAll/collidePoint/collideShape/castShape）验证
 *  - 渲染循环中每帧步进物理世界，刚体 transform 同步到 Mesh
 *
 * OHOS 说明：surfaceId 绑定式（WindowEngine.startWithBind）创建 native window 的
 * 能力已移除（绑定式拿不到 NativeWindow、绑定不了事件）；本文件改用 SDL 窗口
 * （WindowEngine.start()，nm 注册模式）：XComponent 设 libraryname='SDL3'，
 * SDL 的 OHOS_XcomponentExport 把 XComponent 注册进 SDL 注册表并挂接触摸/键鼠
 * 回调；SDL 建窗时直接从注册表取 native window，经 SDL_PROP_WINDOW_OHOS_WINDOW_POINTER
 * 交给 BgfxRenderer。仓颉侧仅保留生命周期驱动（ThreeWindow <: WindowEngine）。
 */

import std.sync.*
import std.time.*
import std.runtime.*
import std.collection.*
import std.math.*
import ohos.app.ability.ui_ability.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.window.WindowConfig
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.scene.entity.*
import three.rendering.cameras.*
import three.rendering.geometry.*
import three.rendering.buffer.*
import three.rendering.materials.*
import three.physics.interfaces.*
import three.physics.world.*
import three.physics.body.*
import three.physics.binding.*
import three.physics.constraint.*
import std.convert.RadixConvertible

// ===== 全局状态 =====
var g_windowEngine: Option<WindowEngine> = None

var g_renderRunning = AtomicBool(false)
var g_renderFrame: Int64 = 0
// ArkTS onAreaChange 事件驱动的待应用尺寸（0 = 无更新）。写入后渲染线程每帧
// 读原子并应用，curW/curH 更新后自然不再触发，无需清零，无竞争。
var g_resizeW = AtomicInt32(0)
var g_resizeH = AtomicInt32(0)

// 物理世界全局引用（供 createPhysicsScene / runRenderLoop 共享）
// 必须在使用前定义（仓颉顶层 let 规则）
public let physicsWorld: PhysicsWorld = PhysicsWorld()

/// 碰撞事件监听器全局引用（createPhysicsScene 注册，循环结束输出统计）
public let sensorListener: TestSensorListener = TestSensorListener()

/// 格式化浮点数为 3 位小数（日志可读性；截断不四舍五入）
func _fmt3(n: Float64): String {
    let v = floor(n * 1000.0) / 1000.0
    return v.toString()
}

// =============================================================================
// 碰撞事件监听器（IPhysicsSensorListener 测试）：记录接触/激活/休眠事件
// =============================================================================

/// 测试监听器：统计各类事件数量，供碰撞监听验证
public class TestSensorListener <: IPhysicsSensorListener {
    /// 接触建立计数
    public var addedCount: Int64 = 0
    /// 接触持续计数
    public var persistedCount: Int64 = 0
    /// 接触移除计数
    public var removedCount: Int64 = 0
    /// 激活计数
    public var activatedCount: Int64 = 0
    /// 休眠计数
    public var deactivatedCount: Int64 = 0
    /// 最近一次接触的刚体对
    public var lastPair: (UInt32, UInt32) = (0u32, 0u32)

    public func onContact(bodyID1: UInt32, bodyID2: UInt32, event: PhysicsContactEvent): Unit {
        match (event) {
            case PhysicsContactEvent.Added => this.addedCount += 1
            case PhysicsContactEvent.Persisted => this.persistedCount += 1
            case PhysicsContactEvent.Removed => this.removedCount += 1
        }
        this.lastPair = (bodyID1, bodyID2)
    }

    public func onBodyActivated(bodyID: UInt32): Unit {
        this.activatedCount += 1
    }

    public func onBodyDeactivated(bodyID: UInt32): Unit {
        this.deactivatedCount += 1
    }
}

// =============================================================================
// 着色器源码（迁移自 windows/physics renderer.cj）
//   GROUND_VS/FS    — 地面网格着色器（冷色调网格）
//   BOX_VS/FS       — 下落立方体着色器（暖色调，按面着色）
//   SPHERE_VS/FS    — 球体着色器（高光，高弹性视觉标识）
//   CAPSULE_VS/FS   — 胶囊体着色器（金属质感）
//   CYLINDER_VS/FS  — 圆柱体着色器（蓝绿渐变，用于铰链钟摆/力演示体）
//   HINGE_VS/FS     — 约束演示体着色器（铰链连接的钟摆杆）
//   MESH_VS/FS      — Mesh 三角网格形状（青绿色，静态坡道）
//   CONVEX_VS/FS    — ConvexHull 凸包形状（亮紫色，下落翻滚）
//   COMPOUND_VS/FS  — Compound 复合形状（亮黄色，哑铃形）
//
// 着色器统一遵循 bgfx .sc 格式：$input / $output 声明 varying，
// #include <bgfx_shader.sh> 引入 bgfx 内置宏/函数。
// =============================================================================

// ---- 地面着色器 ----

public let GROUND_VS: String = """
$input a_position, a_normal, a_color0
$output v_normal, v_color, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_color   = a_color0;
    v_worldPos = worldPos.xyz;
}
"""

public let GROUND_FS: String = """
$input v_normal, v_color, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 冷色调网格
    vec3 gridColor = v_color.xyz * (ambient + diff * 0.5);
    gl_FragColor = vec4(gridColor, 1.0);
}
"""

// ---- 下落立方体着色器（按法线着色，让 6 个面有不同颜色） ----

public let BOX_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let BOX_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.3;

    // 按法线着色：+X 红、-X 青、+Y 绿、-Y 蓝、+Z 黄、-Z 紫
    vec3 n = abs(normal);
    vec3 baseColor;
    if (normal.x > 0.5)        baseColor = vec3(1.0, 0.3, 0.3);
    else if (normal.x < -0.5)  baseColor = vec3(0.3, 0.8, 0.9);
    else if (normal.y > 0.5)   baseColor = vec3(0.3, 0.9, 0.4);
    else if (normal.y < -0.5)  baseColor = vec3(0.3, 0.4, 1.0);
    else if (normal.z > 0.5)   baseColor = vec3(1.0, 0.9, 0.3);
    else                        baseColor = vec3(0.8, 0.3, 1.0);

    vec3 litColor = baseColor * (ambient + diff * 0.8);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// ---- 球体着色器（高光，弹跳球视觉标识） ----

public let SPHERE_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let SPHERE_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.3;

    // 高光（Phong 简化）
    vec3 viewDir = normalize(vec3(0.0, 0.0, 1.0));
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 16.0);

    // 暖色调橙红 + 高光
    vec3 baseColor = vec3(1.0, 0.5, 0.2);
    vec3 litColor = baseColor * (ambient + diff * 0.8) + vec3_splat(spec) * vec3(1.0, 1.0, 0.8);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// ---- 胶囊体着色器（金属质感） ----

public let CAPSULE_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let CAPSULE_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.2;

    // 金属质感：高对比度 + Fresnel 边缘光
    vec3 viewDir = normalize(vec3(0.0, 0.0, 1.0));
    float fresnel = pow(1.0 - max(dot(normal, viewDir), 0.0), 3.0);

    vec3 baseColor = vec3(0.6, 0.65, 0.7);  // 冷色调金属灰
    vec3 litColor = baseColor * (ambient + diff * 1.2);
    litColor += vec3_splat(fresnel) * vec3(0.8, 0.9, 1.0);

    gl_FragColor = vec4(litColor, 1.0);
}
"""

// ---- 圆柱体着色器（蓝绿渐变，用于约束演示/滚动体） ----

public let CYLINDER_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let CYLINDER_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 蓝绿渐变：顶部亮青、底部深蓝（沿局部 Y 用世界 Y 近似）
    float t = clamp((v_worldPos.y + 2.0) * 0.25, 0.0, 1.0);
    vec3 baseColor = mix(vec3(0.1, 0.3, 0.8), vec3(0.2, 0.9, 0.6), t);

    vec3 litColor = baseColor * (ambient + diff * 0.9);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// ---- 约束演示体着色器（铰链连接的钟摆杆，暖橙色调） ----

public let HINGE_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let HINGE_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 暖橙色调（与球体区分）
    vec3 baseColor = vec3(0.95, 0.55, 0.15);

    vec3 litColor = baseColor * (ambient + diff * 0.9);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// ---- Mesh 三角网格形状着色器（青绿色，静态坡道/地形） ----

public let MESH_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let MESH_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 青绿色（三角网格形状）
    vec3 baseColor = vec3(0.15, 0.85, 0.65);

    vec3 litColor = baseColor * (ambient + diff * 0.9);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// ---- ConvexHull 凸包形状着色器（亮紫色，下落翻滚） ----

public let CONVEX_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let CONVEX_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 亮紫色（凸包形状）
    vec3 baseColor = vec3(0.75, 0.35, 0.95);

    vec3 litColor = baseColor * (ambient + diff * 0.9);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// ---- Compound 复合形状着色器（亮黄色，哑铃形） ----

public let COMPOUND_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let COMPOUND_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 亮黄色（复合形状）
    vec3 baseColor = vec3(0.95, 0.85, 0.2);

    vec3 litColor = baseColor * (ambient + diff * 0.9);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// ===== 碰撞查询验证（raycastAll / collidePoint / collideShape / castShape）
// 迁移自 windows/physics main.cj：结果经 StringBuilder 汇总（不落盘/不打日志）

/// 断言工具：累计结果（仅统计，不落盘/不打日志）
private var _qPass: Int64 = 0
private var _qFail: Int64 = 0

private func _qcheck(name: String, cond: Bool, log: StringBuilder): Unit {
    if (cond) {
        _qPass += 1
        log.append("  [PASS] ${name}\n")
    } else {
        _qFail += 1
        log.append("  [FAIL] ${name}\n")
    }
}

/// 执行一轮碰撞查询验证：结果经 Logger 输出
public func verifyCollisionQueries(): Unit {
    let log = StringBuilder()
    log.append("=== 碰撞查询验证（raycastAll/collidePoint/collideShape/castShape） ===\n")
    let bodyID0: UInt32 = 0  // 地面 bodyID（第一个创建的刚体）

    // ---- [A] raycastAll：垂直向下射线，应命中地面及下落物体 ----
    log.append("[A] raycastAll 批量射线\n")
    let downHits = physicsWorld.raycastAll(Vector3(0.0, 30.0, 0.0), Vector3(0.0, -60.0, 0.0))
    _qcheck("向下射线至少 1 个命中（地面）", downHits.size >= 1, log)
    var hitGround = false
    for (h in downHits) {
        if (h.bodyID == bodyID0) { hitGround = true }
        log.append("    命中 body=${h.bodyID} frac=${_fmt3(Float64(h.fraction))} " + 
            "point=(${_fmt3(h.point.x)},${_fmt3(h.point.y)},${_fmt3(h.point.z)}) " + 
            "normal=(${_fmt3(h.normal.x)},${_fmt3(h.normal.y)},${_fmt3(h.normal.z)})\n")
    }
    _qcheck("命中列表按 fraction 升序", downHits.size < 2 || downHits[0].fraction <= downHits[1].fraction, log)
    _qcheck("命中点 Y 接近 0（地面）", if (downHits.size > 0) {
        let y = downHits[0].point.y
        y > -1.0 && y < 1.0
    } else { false }, log)
    _qcheck("命中法线已填充（非零）", if (downHits.size > 0) {
        let n = downHits[0].normal
        n.x * n.x + n.y * n.y + n.z * n.z > 0.01
    } else { false }, log)

    // ---- [B] collidePoint：点碰撞 ----
    log.append("[B] collidePoint 点碰撞\n")
    let inside = physicsWorld.collidePoint(Vector3(0.0, 0.2, 0.0))
    _qcheck("地面内部点命中", inside.size >= 1, log)
    let outside = physicsWorld.collidePoint(Vector3(0.0, 30.0, 0.0))
    _qcheck("空中点无命中", outside.size == 0, log)

    // ---- [C] collideShape：形状 vs 世界 ----
    log.append("[C] collideShape 形状碰撞\n")
    let probe = PhysicsShape.box(1.0, 1.0, 1.0)
    let overlap = physicsWorld.collideShape(probe,
        Vector3(0.0, 0.3, 0.0), Quaternion())
    _qcheck("盒子与地面重叠命中", overlap.size >= 1, log)
    if (overlap.size > 0) {
        let h0 = overlap[0]
        log.append("    命中 body=${h0.bodyID} depth=${_fmt3(Float64(h0.penetrationDepth))} " + 
            "point=(${_fmt3(h0.point.x)},${_fmt3(h0.point.y)},${_fmt3(h0.point.z)})\n")
    }
    let free = physicsWorld.collideShape(probe,
        Vector3(0.0, 30.0, 0.0), Quaternion())
    _qcheck("空中盒子无命中", free.size == 0, log)

    // ---- [D] castShape：形状投射 ----
    log.append("[D] castShape 形状投射\n")
    let castHits = physicsWorld.castShape(probe,
        Vector3(0.0, 10.0, 0.0), Quaternion(),
        Vector3(0.0, -20.0, 0.0))
    _qcheck("下落投射命中地面", castHits.size >= 1, log)
    if (castHits.size > 0) {
        let h0 = castHits[0]
        log.append("    命中 body=${h0.bodyID} frac=${_fmt3(Float64(h0.fraction))} " + 
            "point=(${_fmt3(h0.point.x)},${_fmt3(h0.point.y)},${_fmt3(h0.point.z)})\n")
        _qcheck("投射命中 fraction 在 (0,1]", h0.fraction > 0.0f32 && h0.fraction <= 1.0f32, log)
        _qcheck("投射命中点在地面附近", h0.point.y > -1.0 && h0.point.y < 1.5, log)
    }

    // 结果汇总（仅构建统计文本，不落盘/不打日志；碰撞查询执行本身已在此函数内完成）
    log.append("\n=== 碰撞查询结果 ===\n")
    log.append("  PASS: ${_qPass}\n")
    log.append("  FAIL: ${_qFail}\n")
    log.append(if (_qFail == 0) { "  == 查询全部通过 ==\n" } else { "  == 存在失败 ==\n" })
}

// =============================================================================
// 场景创建：地面 + 下落立方体 + 球体 + 胶囊 + 圆柱 + 约束钟摆 + 力/运动学演示
// 迁移自 windows/physics main.cj createPhysicsScene
// =============================================================================

/// 创建物理场景：返回 (Scene, Camera, RigidBody列表, Constraint列表)
public func createPhysicsScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<RigidBody>, ArrayList<PhysicsConstraint>) {
    // 创建场景
    let scene = Scene()
    scene.name = "PhysicsTestScene"

    // 创建相机
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 8.0, 20.0)
    camera.lookAt(Vector3(0.0, 2.0, 0.0))
    camera.name = "MainCamera"

    // ===== 初始化物理世界（默认 JoltBackend，可插拔） =====
    let ok = physicsWorld.start(maxBodies: 1024u32,
                               gravity: Vector3(0.0, -9.81, 0.0))
    if (!ok) {
        // 物理世界初始化失败，将无物理模拟
    }

    // ===== 创建地面（静态刚体） =====
    let groundGeom = PlaneGeometry(width: 40.0, height: 40.0)
    // 旋转地面让它平铺（PlaneGeometry 默认在 XY 平面，法线 +Z）
    groundGeom.rotateX(-PI / 2.0)
    let groundMat = ShaderMaterial(GROUND_VS, GROUND_FS)
    let ground = Mesh(geometry: groundGeom, material: groundMat)
    ground.name = "Ground"
    ground.position.set(0.0, 0.0, 0.0)
    scene.add(ground)

    // 地面物理：Static 刚体 + Plane 形状
    let groundBody = PhysicsBinding.ground(physicsWorld, ground, yPosition: 0.0)

    // ===== 注册碰撞事件监听器（接触回调 + 激活/休眠回调） =====
    physicsWorld.setContactListener(Some(sensorListener))

    // ===== 碰撞查询验证（此时世界仅有地面，断言确定性强） =====
    verifyCollisionQueries()

    // ===== 创建下落立方体（Dynamic 刚体） =====
    let bodies = ArrayList<RigidBody>()
    let boxSize = 1.0
    for (i in 0..6) {
        let boxGeom = BoxGeometry(width: boxSize, height: boxSize, depth: boxSize)
        let boxMat = ShaderMaterial(BOX_VS, BOX_FS)
        let box = Mesh(geometry: boxGeom, material: boxMat)
        box.name = "FallingBox_${i}"
        // 初始位置：空中，错开排列
        let x = (Float64(i) - 2.5) * 2.0
        let y = 8.0 + Float64(i) * 1.5
        let z = 0.0
        box.position.set(x, y, z)
        scene.add(box)

        // 物理绑定：Box 形状 + Dynamic 刚体
        let body = PhysicsBinding.meshBox(physicsWorld, box,
            motionType: PhysicsMotionType.Dynamic,
            friction: 0.3, restitution: 0.4)
        bodies.add(body)
    }

    // ===== 创建球体（Dynamic，高弹性） =====
    for (i in 0..3) {
        let sphereGeom = SphereGeometry(radius: 0.5, widthSegments: 16, heightSegments: 12)
        let sphereMat = ShaderMaterial(SPHERE_VS, SPHERE_FS)
        let sphere = Mesh(geometry: sphereGeom, material: sphereMat)
        sphere.name = "BouncingSphere_${i}"
        let x = (Float64(i) - 1.0) * 3.0
        let y = 6.0 + Float64(i) * 2.0
        let z = -2.0
        sphere.position.set(x, y, z)
        scene.add(sphere)

        // 物理绑定：Sphere 形状 + Dynamic，高弹性
        let body = PhysicsBinding.meshSphere(physicsWorld, sphere,
            motionType: PhysicsMotionType.Dynamic,
            friction: 0.2, restitution: 0.8)
        bodies.add(body)
    }

    // ===== 创建胶囊体（Dynamic） =====
    let capGeom = CapsuleGeometry(radius: 0.4, length: 1.2)
    let capMat = ShaderMaterial(CAPSULE_VS, CAPSULE_FS)
    let capsule = Mesh(geometry: capGeom, material: capMat)
    capsule.name = "FallingCapsule"
    capsule.position.set(0.0, 10.0, 3.0)
    scene.add(capsule)

    let capBody = PhysicsBinding.meshCapsule(physicsWorld, capsule,
        motionType: PhysicsMotionType.Dynamic,
        friction: 0.4, restitution: 0.3)
    bodies.add(capBody)

    // ===== 创建圆柱体（Dynamic，滚动演示） =====
    let cylGeom = CylinderGeometry(radiusTop: 0.5, radiusBottom: 0.5, height: 1.0)
    let cylMat = ShaderMaterial(CYLINDER_VS, CYLINDER_FS)
    let cylinder = Mesh(geometry: cylGeom, material: cylMat)
    cylinder.name = "RollingCylinder"
    cylinder.position.set(-4.0, 9.0, 2.0)
    scene.add(cylinder)

    let cylBody = PhysicsBinding.meshCylinder(physicsWorld, cylinder,
        motionType: PhysicsMotionType.Dynamic,
        friction: 0.5, restitution: 0.2)
    bodies.add(cylBody)

    // ===== 创建约束钟摆（铰链约束演示：静态支柱 + 动态摆杆） =====
    let constraints = ArrayList<PhysicsConstraint>()

    // 静态支柱（顶部锚点）
    let postGeom = BoxGeometry(width: 0.3, height: 4.0, depth: 0.3)
    let postMat = ShaderMaterial(BOX_VS, BOX_FS)
    let post = Mesh(geometry: postGeom, material: postMat)
    post.name = "HingePost"
    post.position.set(3.0, 2.0, -4.0)
    scene.add(post)
    let postBody = PhysicsBinding.meshBox(physicsWorld, post,
        motionType: PhysicsMotionType.Static, friction: 0.4, restitution: 0.2)
    bodies.add(postBody)

    // 动态摆杆（绕支柱顶端铰链旋转）
    // 视觉上摆杆保持竖直（质心在锚点正下方），靠创建后施加的质心水平线速度
    // 驱动往复摆动——竖直悬挂是稳定平衡，水平初速让摆杆绕锚点做单摆运动。
    // 注意：不能用 setAngularVelocity（绕质心自转会被铰链约束吸收），
    // 必须给质心水平线速度（等价于绕锚点的初始角速度 ω = v/L）。
    let armGeom = BoxGeometry(width: 0.4, height: 2.0, depth: 0.4)
    let armMat = ShaderMaterial(HINGE_VS, HINGE_FS)
    let arm = Mesh(geometry: armGeom, material: armMat)
    arm.name = "HingeArm"
    arm.position.set(3.0, 3.0, -4.0)
    scene.add(arm)
    let armBody = PhysicsBinding.meshBox(physicsWorld, arm,
        motionType: PhysicsMotionType.Dynamic, friction: 0.3, restitution: 0.1)
    // 初始水平线速度：质心沿 +X 1.5 m/s（摆长 1.0 → 初始角速度 1.5 rad/s），驱动单摆
    armBody.setLinearVelocity(1.5, 0.0, 0.0)
    bodies.add(armBody)

    // 铰链连接：锚点在支柱顶端，轴沿 Z（让摆杆在 XZ 平面摆动）
    let hinge = PhysicsConstraint.hinge(physicsWorld, postBody.handle, armBody.handle,
        Vector3(3.0, 4.0, -4.0), Vector3(0.0, 0.0, 1.0),
        limitMin: -1.2, limitMax: 1.2)
    constraints.add(hinge)

    // ===== 距离约束演示（两个小球用距离约束连接） =====
    let ballAGeom = SphereGeometry(radius: 0.35, widthSegments: 12, heightSegments: 10)
    let ballAMat = ShaderMaterial(SPHERE_VS, SPHERE_FS)
    let ballA = Mesh(geometry: ballAGeom, material: ballAMat)
    ballA.name = "ChainBallA"
    ballA.position.set(5.0, 5.0, -2.0)
    scene.add(ballA)
    let ballABody = PhysicsBinding.meshSphere(physicsWorld, ballA,
        motionType: PhysicsMotionType.Dynamic, friction: 0.3, restitution: 0.3)
    bodies.add(ballABody)

    let ballBGeom = SphereGeometry(radius: 0.35, widthSegments: 12, heightSegments: 10)
    let ballBMat = ShaderMaterial(SPHERE_VS, SPHERE_FS)
    let ballB = Mesh(geometry: ballBGeom, material: ballBMat)
    ballB.name = "ChainBallB"
    ballB.position.set(5.0, 4.0, -2.0)
    scene.add(ballB)
    let ballBBody = PhysicsBinding.meshSphere(physicsWorld, ballB,
        motionType: PhysicsMotionType.Dynamic, friction: 0.3, restitution: 0.3)
    bodies.add(ballBBody)

    // 距离约束：两球锚点距离保持 1.2 米（像弹簧链）
    let chain = PhysicsConstraint.distance(physicsWorld, ballABody.handle, ballBBody.handle,
        Vector3(5.0, 5.0, -2.0), Vector3(5.0, 4.0, -2.0),
        0.5, 1.2)
    constraints.add(chain)

    // ===== 扩展形状演示 1：Mesh 三角网格坡道（Static，青绿色） =====
    // 用顶点 + 索引三角形构造一个楔形三棱柱（坡道），Static 刚体；
    // 视觉用 BoxGeometry 近似渲染（物理形状为三角网格）。
    let meshGeom = BoxGeometry(width: 4.0, height: 1.0, depth: 2.0)
    let meshMat = ShaderMaterial(MESH_VS, MESH_FS)
    let meshRamp = Mesh(geometry: meshGeom, material: meshMat)
    meshRamp.name = "MeshRamp"
    meshRamp.position.set(7.0, 0.5, -1.0)
    meshRamp.quaternion.setFromEuler(Euler(0.0, 0.0, 0.0))
    scene.add(meshRamp)
    // 楔形三棱柱：6 顶点（底面矩形 + 顶边），8 三角形（2 端面 + 4 侧面 + 2 底面）
    let rampVerts = [
        Vector3(-2.0, 0.0, -1.0), Vector3(2.0, 0.0, -1.0),
        Vector3(2.0, 1.0, -1.0),  Vector3(-2.0, 1.0, -1.0),
        Vector3(-2.0, 0.0, 1.0),  Vector3(2.0, 0.0, 1.0),
        Vector3(2.0, 1.0, 1.0),   Vector3(-2.0, 1.0, 1.0),
    ]
    // 完整封闭盒的 12 三角形（两倍楔形 = 直接用完整盒子网格更稳）
    let rampTris = [
        0u32, 2u32, 1u32, 0u32, 3u32, 2u32,
        4u32, 5u32, 6u32, 4u32, 6u32, 7u32,
        0u32, 1u32, 5u32, 0u32, 5u32, 4u32,
        1u32, 2u32, 6u32, 1u32, 6u32, 5u32,
        2u32, 3u32, 7u32, 2u32, 7u32, 6u32,
        3u32, 0u32, 4u32, 3u32, 4u32, 7u32,
    ]
    let rampShape = PhysicsShape.mesh(rampVerts, rampTris)
    let rampBody = PhysicsBinding.bind(physicsWorld, meshRamp, rampShape,
        motionType: PhysicsMotionType.Static, friction: 0.6, restitution: 0.1)
    bodies.add(rampBody)

    // ===== 扩展形状演示 2：ConvexHull 凸包（Dynamic，亮紫色，下落翻滚） =====
    let hullGeom = BoxGeometry(width: 1.2, height: 1.2, depth: 1.2)
    let hullMat = ShaderMaterial(CONVEX_VS, CONVEX_FS)
    let hull = Mesh(geometry: hullGeom, material: hullMat)
    hull.name = "ConvexHull"
    hull.position.set(-7.0, 8.0, 1.0)
    scene.add(hull)
    // 不规则八面体顶点（凸包自动贴合）
    let hullPts = [
        Vector3(-0.6, -0.6, -0.6), Vector3(0.6, -0.6, -0.6),
        Vector3(0.6, 0.6, -0.6),   Vector3(-0.6, 0.6, -0.6),
        Vector3(-0.6, -0.6, 0.6),  Vector3(0.6, -0.6, 0.6),
        Vector3(0.6, 0.6, 0.6),    Vector3(-0.6, 0.6, 0.6),
        Vector3(0.0, 1.1, 0.0),
    ]
    let hullShape = PhysicsShape.convexHull(hullPts)
    let hullBody = PhysicsBinding.bind(physicsWorld, hull, hullShape,
        motionType: PhysicsMotionType.Dynamic, friction: 0.4, restitution: 0.3)
    bodies.add(hullBody)

    // ===== 扩展形状演示 3：Compound 复合形状（Dynamic，亮黄色，锤子形） =====
    let compGeom = BoxGeometry(width: 1.4, height: 1.4, depth: 1.4)
    let compMat = ShaderMaterial(COMPOUND_VS, COMPOUND_FS)
    let comp = Mesh(geometry: compGeom, material: compMat)
    comp.name = "Compound"
    comp.position.set(-3.0, 9.0, 4.0)
    scene.add(comp)
    // 复合形状：杆（Box）+ 两端锤头（Sphere）组成"哑铃"碰撞体
    let compShape = PhysicsShape.compound([
        PhysicsCompoundPart(shape: PhysicsShape.box(0.25, 1.2, 0.25), position: Vector3(0.0, 0.0, 0.0)),
        PhysicsCompoundPart(shape: PhysicsShape.sphere(0.45), position: Vector3(0.0, 1.0, 0.0)),
        PhysicsCompoundPart(shape: PhysicsShape.sphere(0.45), position: Vector3(0.0, -1.0, 0.0)),
    ])
    let compBody = PhysicsBinding.bind(physicsWorld, comp, compShape,
        motionType: PhysicsMotionType.Dynamic, friction: 0.4, restitution: 0.3)
    bodies.add(compBody)

    // ===== 优化 BroadPhase（批量插入后） =====
    physicsWorld.optimizeBroadPhase()

    return (scene, camera, bodies, constraints)
}

// =============================================================================
// ThreeWindow：对齐 base 的生命周期骨架（WindowEngine 泵线程驱动）
//   onInit  — 建窗成功后初始化 ThreeRenderer + 物理场景
//   onFrame — 步进物理世界 + 力/运动学演示 + 渲染
//   onClose — 先销毁约束再销毁刚体，关闭物理世界与渲染器
// =============================================================================

public class ThreeWindow <: WindowEngine {
    var renderer: ThreeRenderer
    var scene: Scene
    var camera: PerspectiveCamera
    var bodies: ArrayList<RigidBody>
    var constraints: ArrayList<PhysicsConstraint>
    var frame: Int64 = 0
    var appliedW: Int32 = 0
    var appliedH: Int32 = 0

    // 力演示目标：圆柱体（bodies[10]），每 120 帧施加侧向冲量
    var forceTarget: Option<RigidBody> = None
    // 运动学演示目标：第 6 个立方体（bodies[5]），沿 X 轴往返平移
    var kinematicTarget: Option<RigidBody> = None
    var kinematicDir: Float64 = 1.0

    public init() {
        this.renderer = ThreeRenderer()
        this.scene = Scene()
        this.scene.name = "PhysicsTestScene"
        this.camera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
        this.bodies = ArrayList<RigidBody>()
        this.constraints = ArrayList<PhysicsConstraint>()
    }

    // ===== 生命周期：建窗成功（初始化渲染器 + 物理场景） =====
    public override func onInit(): Unit {
        let hwnd = this.getNativeWindowHandle()

        // 优先读 ArkTS onAreaChange 原子尺寸；未同步时用建窗回填的真实尺寸
        var w = g_resizeW.load()
        var h = g_resizeH.load()
        if (w <= 0i32 || h <= 0i32) {
            w = this.getWidth()
            h = this.getHeight()
        }
        this.appliedW = w
        this.appliedH = h

        let dpr = this.getPixelRatio()
        this.renderer.setPixelRatio(Float64(dpr))
        let ok = this.renderer.initBgfx(hwnd, w, h)
        if (!ok) {
            // Bgfx 初始化失败（如原生窗口未就绪），关闭窗口
            this.requestClose()
            return
        }

        // 创建物理场景（含相机 / 刚体 / 约束；physicsWorld 在此内部 start）
        // 迁移自 windows/physics createPhysicsScene
        let (scene, camera, bodies, constraints) = createPhysicsScene(w, h)
        this.scene = scene
        this.camera = camera
        this.bodies = bodies
        this.constraints = constraints

        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x1a, 0x1a, 0x2e))

        // 力演示目标：圆柱体（bodies[10]，0-5 立方体，6-8 球体，9 胶囊，10 圆柱）
        if (this.bodies.size > 10) {
            this.forceTarget = Some(this.bodies[10])
        }

        // 运动学演示：第 6 个立方体（bodies[5]）改为运动学刚体做往返平移
        if (this.bodies.size > 5) {
            let kb = this.bodies[5]
            kb.setMotionTypeRuntime(PhysicsMotionType.Kinematic, activation: PhysicsActivation.Activate)
            this.kinematicTarget = Some(kb)
        }
    }

    // ===== 生命周期：每循环（步进物理 + 渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++

        // 应用 ArkTS onAreaChange 尺寸（XComponent 尺寸由 ArkTS 控制）
        let rw = g_resizeW.load()
        let rh = g_resizeH.load()
        if (rw > 0i32 && rh > 0i32 && (rw != this.appliedW || rh != this.appliedH)) {
            this.appliedW = rw
            this.appliedH = rh
            // 真实逻辑尺寸变化后重取窗口像素比（getPixelRatio 内部会用新的
            // _width/_height 重算缓存；updateSize 不在主线程重算以免阻塞），
            // 再应用到渲染器，避免沿用 onInit 占位尺寸算出的异常 pixelRatio。
            this.renderer.setPixelRatio(Float64(this.getPixelRatio()))
            this.renderer.setSize(rw, rh)
        }

        // 物理步长（参考 windows/physics：60Hz）
        let pdt: Float32 = 1.0f32 / 60.0f32

        // 力演示：每 120 帧给圆柱体一次侧向冲量（推动滚动）
        if (this.frame % 120 == 0) {
            match (this.forceTarget) {
                case Some(fb) => fb.addImpulse(0.0, 0.0, 2.0)
                case None => ()
            }
        }

        // 运动学演示：控制第 6 个立方体沿 X 轴往返平移
        match (this.kinematicTarget) {
            case Some(kb) =>
                let pos = kb.getPosition()
                let nx = pos.x + this.kinematicDir * 0.08
                let limit = 4.0
                if (nx > limit) { this.kinematicDir = -1.0 }
                if (nx < -limit) { this.kinematicDir = 1.0 }
                let targetPos = Vector3(nx, pos.y, pos.z)
                kb.moveKinematic(targetPos, kb.getRotation(), pdt)
            case None => ()
        }

        // 步进物理世界（独立物理线程执行，主线程等待完成）
        physicsWorld.update(pdt, collisionSteps: 1)

        // 更新相机宽高比并渲染场景（物理刚体的 transform 已同步到 Mesh）
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()
        this.renderer.render(this.scene, this.camera)
    }

    // ===== 生命周期：关闭前（先销毁约束，再销毁刚体，最后关闭物理世界与渲染器） =====
    public override func onClose(): Unit {
        for (c in this.constraints) {
            c.dispose()
        }
        for (b in this.bodies) {
            b.dispose()
        }
        physicsWorld.shutdown()
        this.renderer.shutdown()
    }
}

// ===== 启动 three 渲染（WindowEngine + 独立泵线程驱动） =====
// context：ArkTS 传入的 UIAbilityContext（physics 无音频，仅保留统一接口，未使用）

public func startThreeRender(context: Option<UIAbilityContext>): Bool {
    if (g_renderRunning.load()) {
        return true
    }
    let win = ThreeWindow()
    let cfg = WindowConfig()
    cfg.resizable = false
    // width/height 传占位值：OHOS 建窗回退路径会从注册的 XComponent 取真实
    // native window 并回填真实尺寸；真实尺寸随后由 ArkTS onAreaChange 同步。
    let ok = win.start(title: "ThreeRender", width: 1, height: 1, config: cfg)
    if (ok) {
        g_windowEngine = Some(win)
        g_renderRunning.store(true)
    }
    return ok
}

// ===== 事件驱动 resize：由 ArkTS 侧 XComponent onAreaChange 触发（旋转/窗口尺寸变化） =====
// 写入原子变量，渲染线程每帧只读内存原子（非 FFI、无锁、开销≈0），
// 与参考项目 xcomponent-vsync-master 的 OnSurfaceChanged 事件驱动等价。

public func resizeThreeRender(w: Int32, h: Int32): Unit {
    if (w > 0 && h > 0) {
        g_resizeW.store(w)
        g_resizeH.store(h)
        // 同步 three.cj WindowEngine 的窗口尺寸（跨平台接口；
        // OHOS 上 XComponent 由 ArkTS 控制，仅更新内部尺寸供渲染查询）
        match (g_windowEngine) {
            case Some(engine) => engine.updateSize(w, h)
            case None => ()
        }
    }
}

// ===== 停止 three 渲染 =====

public func stopThreeRender(): Unit {
    g_renderRunning.store(false)
    match (g_windowEngine) {
        case Some(engine) => engine.shutdown()
        case None => ()
    }
    g_windowEngine = None
}

// ===== 查询渲染状态 =====

public func isThreeRendering(): Bool {
    return g_renderRunning.load()
}
