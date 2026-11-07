/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] BgfxShadowPass
 * @brief[zh-cn] 阴影深度预 pass — 三类光源（方向/聚光/点）的阴影贴图渲染 + 主 pass 阴影 uniform 绑定
 * @explain[zh-cn] 组合注入 BgfxBackend，覆盖三类阴影光源：方向光（2D 阴影）、聚光灯（2D 阴影）、点光源（cube 阴影 6 face）。
 *
 * @file[en] BgfxShadowPass
 * @brief[en] Shadow depth pre-pass — shadow map rendering for three light types (directional/spot/point) + main pass shadow uniform binding
 * @explain[en] Composed into BgfxBackend, covers three shadow light types: directional (2D shadow), spot (2D shadow), point (cube shadow 6 faces).
 */
package three.rendering.bgfx

import three.rendering.common.*
import three.rendering.shaders.ShaderLibs
import three.rendering.shaders.ShaderProgram
import three.rendering.shaders.SamplerStages
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.scene.scenegraph.*
import three.rendering.lights.*
import three.rendering.cameras.*
import three.scene.entity.Mesh
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.*
import three.utils.log.macros.*
import three.profiler.*
import three.profiler.macros.*
import bgfx4cj.bgfx.*
import std.collection.*
import std.math.*
import three.utils.safe.IReleasable

// ===== 点光源 cube shadow 的 6 个 face 方向常量 =====
// 原实现把这三张表定义在 _renderPointShadowDepth 函数体内，每次调用都新建
// 3 个 Array<Vector3>（共 18 个 Vector3 对象 + 3 个数组）。boxshow 场景 4 个
// 点光源每帧调用 4 次，即每帧 72 个 Vector3 + 12 个数组的堆分配。
// 方向表是编译期常量，提升为模块级后只在包加载时分配一次。
/** face 0..5 的朝向（+X/-X/+Y/-Y/+Z/-Z）。 */
private let POINT_SHADOW_FACE_DIRS: Array<Vector3> = [
    Vector3(1.0, 0.0, 0.0),
    Vector3(-1.0, 0.0, 0.0),
    Vector3(0.0, 1.0, 0.0),
    Vector3(0.0, -1.0, 0.0),
    Vector3(0.0, 0.0, 1.0),
    Vector3(0.0, 0.0, -1.0)
]

// D3D11 cube face 约定（MSDN）：每个 face 的 s（right）与 t（up）方向
//   face 0 (+X): s=-z, t=-y   face 1 (-X): s=+z, t=-y
//   face 2 (+Y): s=+x, t=+z   face 3 (-Y): s=+x, t=-z
//   face 4 (+Z): s=+x, t=-y   face 5 (-Z): s=-x, t=-y
// 手动构造 view 矩阵（right/up/dir 列向量），绕开 lookAt 的左手系手性差异：
// Three.cj 左手系 lookAt 的 x = cross(up, z) 与 D3D11 的 s 方向相反 →
// 渲染内容左右镜像（左上↔右下）。用 D3D11 约定直接构建即可严格对齐 bgfx cube 采样方向。
/** face 0..5 的 right（s）方向。 */
private let POINT_SHADOW_FACE_RIGHTS: Array<Vector3> = [
    Vector3(0.0, 0.0, -1.0),
    Vector3(0.0, 0.0, 1.0),
    Vector3(1.0, 0.0, 0.0),
    Vector3(1.0, 0.0, 0.0),
    Vector3(1.0, 0.0, 0.0),
    Vector3(-1.0, 0.0, 0.0)
]

/** face 0..5 的 up（t）方向。 */
private let POINT_SHADOW_FACE_UPS: Array<Vector3> = [
    Vector3(0.0, 1.0, 0.0),
    Vector3(0.0, 1.0, 0.0),
    Vector3(0.0, 0.0, -1.0),
    Vector3(0.0, 0.0, 1.0),
    Vector3(0.0, 1.0, 0.0),
    Vector3(0.0, 1.0, 0.0)
]

/**
 * @brief[zh-cn] 阴影深度预 pass
 * @explain[zh-cn] 组合注入 BgfxBackend，持有阴影状态字段（_shadowSlots/_shadowResources/...）。BgfxBackend 在 prepareShadowMap/bindShadowUniforms 时委托给本类
 *
 * @brief[en] Shadow depth pre-pass
 * @explain[en] Composed into BgfxBackend, holds shadow state fields (_shadowSlots/_shadowResources/...). BgfxBackend delegates to this class for prepareShadowMap/bindShadowUniforms
 */
public class BgfxShadowPass {
    /**
     * @brief[zh-cn] 宿主 BgfxBackend（bindBackend 后可用，internal 访问共享资源）
     *
     * @brief[en] Host BgfxBackend (available after bindBackend, internal access to shared resources)
     */
    private var _backend: Option<BgfxBackend> = None

    /**
     * @brief[zh-cn] 阴影深度预 pass 用的 view ID 段约定：主渲染 view 0，阴影 view 从 64 开始
     *
     * @brief[en] Shadow depth pre-pass view ID segment convention: main render view 0, shadow views start from 64
     */
    public static let SHADOW_VIEW_ID_BASE: UInt16 = 64u16

    /**
     * @brief[zh-cn] 当前帧各阴影光源的 ShadowSlot，按光源 ID 索引（每帧 prepareShadowMap 时清空重建）
     *
     * @brief[en] Current frame ShadowSlots per shadow light, indexed by light ID (cleared and rebuilt each frame during prepareShadowMap)
     */
    internal var _shadowSlots: HashMap<Int64, ShadowSlot> = HashMap<Int64, ShadowSlot>()
    /**
     * @brief[zh-cn] 持久化的阴影 framebuffer/纹理资源池（按光源 ID 索引），跨帧复用，光源销毁时释放
     *
     * @brief[en] Persistent shadow framebuffer/texture resource pool (indexed by light ID), reused across frames, released when light is destroyed
     */
    private var _shadowResources: HashMap<Int64, ShadowSlot> = HashMap<Int64, ShadowSlot>()
    /**
     * @brief[zh-cn] view ID 分配游标：每个阴影光源占用若干连续 view ID，从 SHADOW_VIEW_ID_BASE 开始
     *
     * @brief[en] View ID allocation cursor: each shadow light occupies several consecutive view IDs, starting from SHADOW_VIEW_ID_BASE
     */
    private var _nextShadowViewId: UInt16 = BgfxShadowPass.SHADOW_VIEW_ID_BASE
    /**
     * @brief[zh-cn] 当前帧各阴影光源的类型标记（"dir"/"spot"/"point"），供 _bindShadowUniforms 区分 2D 阴影的类型
     *
     * @brief[en] Current frame shadow light type markers ("dir"/"spot"/"point"), used by _bindShadowUniforms to distinguish 2D shadow types
     */
    internal var _shadowSlotKind: HashMap<Int64, String> = HashMap<Int64, String>()

    /**
     * @brief[zh-cn] 帧级阴影绑定缓存（bindShadowUniforms 每 draw 调用，帧内数据恒定）
     * @explain[zh-cn]
     * bindShadowUniforms 在绘制循环中逐 draw 调用（submit 用 BGFX_DISCARD_ALL，
     * 纹理绑定提交即消费，故必须每 draw 重绑），但 slot 列表、bias 矩阵乘结果与
     * uniform 句柄在帧内完全不变。缓存这些数据后，每 draw 仅剩 set_texture /
     * set_uniform 的必需调用。beginFrame 时失效重建。
     */
    private var _shadowBindCache: ShadowBindCache = ShadowBindCache()

    /**
     * @brief[zh-cn] 帧级阴影 caster 列表（所有阴影光源共享）
     * @explain[zh-cn] caster 集合与光源无关：同一帧内 N 个阴影光源需要的是同一份
     *               caster 列表。此前每个光源（点光源更是每个 cube 面）都重新
     *               遍历整棵场景树并为每个 Mesh 新建一个 RenderObject，
     *               10 万对象 × 1 个点光源 = 60 万次全树遍历 + 60 万次
     *               RenderObject 分配。现改为帧内只收集一次，多光源复用。
     *
     * @brief[en] Frame-level shadow caster list (shared by all shadow lights)
     * @explain[en] The caster set is light-independent: all N shadow lights of a frame
     *               need the same list. Previously every light (and every cube face
     *               of a point light) re-walked the whole scene tree and allocated a
     *               fresh RenderObject per Mesh — 100k objects x 1 point light =
     *               600k full-tree walks + 600k RenderObject allocations per frame.
     *               Now it is collected once per frame and shared by all lights.
     */
    private var _shadowCasters: ArrayList<RenderObject> = ArrayList<RenderObject>(256)
    /**
     * @brief[zh-cn] 帧级阴影 caster 缓存是否有效（beginFrame 时失效）
     *
     * @brief[en] Whether the frame-level shadow caster cache is valid (invalidated in beginFrame)
     */
    private var _shadowCastersValid: Bool = false
    /**
     * @brief[zh-cn] caster 对象池（复用 RenderObject，避免每帧每 Mesh 一次堆分配）
     * @explain[zh-cn] RenderObject 的构造器会连带分配 RenderContext / Camera / Scene /
     *               Matrix4 ×2 / Matrix3 / Vector3 / ArrayList ×2（≈10 次堆分配），
     *               池化后每帧只做字段重置。
     *
     * @brief[en] Caster object pool (reuses RenderObject to avoid one heap allocation per Mesh per frame)
     */
    private var _casterPool: ArrayList<RenderObject> = ArrayList<RenderObject>(256)
    /**
     * @brief[zh-cn] caster 对象池游标（下一待复用位置）
     *
     * @brief[en] Caster pool cursor (next slot to reuse)
     */
    private var _casterPoolCursor: Int64 = 0

    public init() {}

    /**
     * @brief[zh-cn] 带宿主引用的构造
     * @explain[zh-cn] 供 BgfxBackend.init 末尾重新构造注入（此时 BgfxBackend 所有成员已初始化，访问 this 合法——声明处默认构造已保证 shadowPass 字段有值，此处用真实宿主替换）
     * @param[zh-cn] backend 宿主 BgfxBackend 实例
     *
     * @brief[en] Constructor with host reference
     * @explain[en] Used at end of BgfxBackend.init for re-construction injection (all BgfxBackend members are initialized at this point, accessing this is legal — the default constructor at declaration ensures shadowPass field has a value, replaced here with the real host)
     * @param[en] backend Host BgfxBackend instance
     */
    public init(backend!: BgfxBackend) {
        this._backend = Some(backend)
    }

    /**
     * @brief[zh-cn] 宿主 BgfxBackend 只读属性（bindBackend 后可用）
     *
     * @brief[en] Host BgfxBackend read-only property (available after bindBackend)
     */
    private prop backend: BgfxBackend {
        get() {
            if (let Some(b) <- this._backend) {
                return b
            } else {
                throw Exception("BgfxShadowPass.backend not bound — call bindBackend first")
            }
        }
    }

    // ===== 阴影深度 pass 的复用缓冲 =====
    // 原实现把 Matrix4 / 16 元素数组 / BgfxMemory 分配在阴影循环体内：
    //   - 方向光：每光源每帧 1 份（bgfx_alloc ×1 + 矩阵暂存 ×1）；
    //   - 点光源：每 cube face 1 份（boxshow 4 点光源 × 6 face = 每帧 24 份），
    //     另有每 face 一个 PerspectiveCamera + 两个 16 元素 view/proj 数组。
    // 复用安全性：bgfx_set_transform / bgfx_set_view_transform 在调用时即把数据
    // memcpy 进引擎内部缓冲（bgfx.cpp EncoderImpl::setTransform / View::setTransform），
    // bgfx_alloc 的缓冲只作数据源，因此同一块内存在两次写入之间必然已被消费。
    /** 阴影 pass 复用的矩阵暂存（worldMatrix → 上传缓冲的中间数组）。 */
    private let _shadowMtxScratch: Array<Float64> = Array<Float64>(16, { _ => 0.0 })
    /** 点光源 face 复用的 view 矩阵。 */
    private let _shadowViewMtx: Matrix4 = Matrix4()
    private var _shadowMtxMemStore: Option<BgfxMemory> = None

    /**
     * @brief[zh-cn] VSM 水平 blur 变体缓存（HORIZONTAL_PASS=1）
     * @explain[zh-cn] 原实现每帧 `createVariant + compileBgfx`，逐帧新建 2 个 shader +
     *               1 个 program 且从不销毁，造成 bgfx 句柄持续泄漏；改为只编译一次、
     *               跨帧复用。dispose 时清空引用（bgfx_shutdown 后句柄失效）。
     *
     * @brief[en] Cached VSM horizontal blur variant (HORIZONTAL_PASS=1)
     * @explain[en] The previous implementation created and compiled a variant every frame,
     *               leaking two shaders and one program per frame; compile once and reuse.
     *               Cleared on dispose (handles become invalid after bgfx_shutdown).
     */
    private var _vsmHorizontalProg: Option<ShaderProgram> = None

    /**
     * @brief[zh-cn] 水平变体所依据的垂直基础程序
     * @explain[zh-cn] ShaderLibs.shutdown() 会清空程序注册表，重新初始化后 get("vsm")
     *               返回新实例；用引用比较识别这种情况并重建水平变体，避免复用失效句柄。
     *
     * @brief[en] Vertical base program the horizontal variant was built from
     * @explain[en] ShaderLibs.shutdown() clears the program registry, so get("vsm") returns a
     *               new instance after re-initialization; a reference comparison detects this
     *               and rebuilds the horizontal variant instead of reusing stale handles.
     */
    private var _vsmHorizontalBase: Option<ShaderProgram> = None

    /** 阴影 pass 复用的模型矩阵上传缓冲（惰性分配：bgfx 初始化后才可分配）。 */
    private prop _shadowMtxMem: BgfxMemory {
        get() {
            if (let Some(m) <- this._shadowMtxMemStore) {
                m
            } else {
                let m = BgfxMemory(64u32)
                this._shadowMtxMemStore = Some(m)
                m
            }
        }
    }

    /**
     * @brief[zh-cn] 每帧开始时清空当前帧阴影槽（持久资源 _shadowResources 不清，跨帧复用）
     *
     * @brief[en] Clear current frame shadow slots at frame start (persistent resources _shadowResources are not cleared, reused across frames)
     */
    public func beginFrame(): Unit {
        this._shadowSlots.clear()
        this._shadowSlotKind.clear()
        // 帧级阴影绑定缓存在每帧开始时失效，下一帧首个 draw 重建（见 _shadowBindCache 注释）
        this._shadowBindCache.valid = false
        // 帧级 caster 缓存同样按帧失效：场景内容可能变化（增删 Mesh / 变换）
        this._shadowCastersValid = false
        this._nextShadowViewId = BgfxShadowPass.SHADOW_VIEW_ID_BASE
    }

    /**
     * @brief[zh-cn] 获取本帧的阴影 caster 列表（帧内首次调用时收集，后续光源复用）
     * @explain[zh-cn] caster 集合与光源无关，因此整帧只收集一次。返回值是内部列表
     *               引用（不做拷贝），调用方只读遍历即可。
     * @param[zh-cn] scene 场景
     * @return[zh-cn] 本帧阴影 caster 列表
     *
     * @brief[en] Get this frame's shadow caster list (collected on first use, shared by all lights)
     * @explain[en] The caster set is light-independent, so it is collected only once per
     *               frame. The returned value is the internal list reference (no copy);
     *               callers only need to traverse it read-only.
     * @param[en] scene Scene
     * @return[en] This frame's shadow caster list
     */
    public func _getShadowCasters(scene: Scene): ArrayList<RenderObject> {
        if (!this._shadowCastersValid) {
            this._shadowCasters.clear()
            this._casterPoolCursor = 0
            this._collectShadowCasters(scene, this._shadowCasters)
            this._shadowCastersValid = true
        }
        return this._shadowCasters
    }

    /**
     * @brief[zh-cn] 当前帧是否存在需要绑定的阴影槽（无阴影光源时为 false）
     * @explain[zh-cn] 供 BgfxBackend.bindShadowUniforms 提前返回：无 castShadow 光源时逐 draw
     * 调用完全是空转（submit 用 BGFX_DISCARD_ALL 消费绑定的前提是确有绑定需要重做）。
     * 槽表在 beginFrame 清空、由 prepareShadowMap 阶段的 renderXxxShadowMap 填充，
     * 主 pass draw 时读取即为当帧有效槽。
     * @param[zh-cn] 当前帧是否有阴影槽
     *
     * @brief[en] Whether the current frame has any shadow slots to bind (false when no shadow-casting light)
     * @param[en] True if the current frame has shadow slots
     */
    public func hasShadowSlots(): Bool {
        return !this._shadowSlots.isEmpty()
    }

    // ===== 方向光阴影 =====

    /**
     * @brief[zh-cn] 渲染方向光阴影贴图（预 pass）
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.renderShadowMap：用 lightView/lightProj 设 view transform，把所有 caster 几何体用 depth shader submit 到 shadowViewId 对应的 shadow framebuffer，内部计算 _shadowMatrix = lightProj × lightView
     * @param[zh-cn] light 方向光（含 shadow.camera 正交相机 + shadow.mapSize）
     * scene 场景（收集 caster 几何体）
     *
     * @brief[en] Render directional light shadow map (pre-pass)
     * @explain[en] Corresponds to bgfx4cj-last ThreeRenderer.renderShadowMap: sets view transform with lightView/lightProj, submits all caster geometry using depth shader to shadow framebuffer at shadowViewId, internally computes _shadowMatrix = lightProj × lightView
     * @param[en] light Directional light (with shadow.camera orthographic camera + shadow.mapSize)
     * scene Scene (collects caster geometry)
     */
    @Zone[three.rendering.bgfx.BgfxShadowPass.renderShadowMap]
    public func renderShadowMap(light: DirectionalLight, scene: Scene): Unit {
        let shadowSize = Int64(light.shadow.mapSize.x)
        @LogTrace(["shadow", "renderShadowMap ENTER shadowSize=${shadowSize} lightId=${light.id}"])
        let lightId = Int64(light.id)
        // VSM 类型：需要 RG16F mean/variance 纹理链（D32 深度 → blur → RG16F final），
        // 与 PCF/BASIC 的 D24 深度纹理不同（对照参考版 ThreeRenderer.renderShadowMap + BgfxShadowMap.createShadowMap VSM 分支）
        let isVsm = backend.shadowMap.getShadowType() == VSM_SHADOW_MAP

        // 持久资源：尺寸不变则跨帧复用；变更则销毁重建
        var slot = if (let Some(s) <- this._shadowResources.get(lightId)) {
            if (s.size != shadowSize) {
                this._destroySlot(s)
                let fresh = ShadowSlot()
                fresh.size = shadowSize
                this._shadowResources.add(lightId, fresh)
                fresh
            } else {
                s
            }
        } else {
            let fresh = ShadowSlot()
            fresh.size = shadowSize
            this._shadowResources.add(lightId, fresh)
            fresh
        }

        if (slot.texture.idx == 65535u16) {
            if (isVsm) {
                // VSM 模式：三步纹理链（对照 BgfxShadowMap.createShadowMap VSM 分支）：
                //   ① D32 深度纹理 → frameBuffer（深度 pass 写入）
                //   ② RG16F pass 纹理 → passFrameBuffer（垂直 blur 输出）
                //   ③ RG16F final 纹理 → finalFrameBuffer（水平 blur 输出，主 pass 采样 slot.texture）
                // 全部用 from_handles 把外部句柄包进 FB，确保 blur 读到的就是同一份 GPU 资源
                let depthTex = bgfx_create_texture_2d_cj(
                    UInt16(shadowSize), UInt16(shadowSize), false, 1u16,
                    TextureFormat.D32.value(), TEXTURE_RT, CPointer<Memory>())
                slot.vsmDepthTexture = depthTex
                let depthHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
                unsafe { depthHolder.get().write(0, depthTex) }
                slot.frameBuffer = bgfx_create_frame_buffer_from_handles_cj(1u8, depthHolder.get(), false)
                depthHolder.dispose()

                let passTex = bgfx_create_texture_2d_cj(
                    UInt16(shadowSize), UInt16(shadowSize), false, 1u16,
                    TextureFormat.RG16F.value(), TEXTURE_RT, CPointer<Memory>())
                slot.vsmPassTexture = passTex
                let passHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
                unsafe { passHolder.get().write(0, passTex) }
                slot.vsmPassFrameBuffer = bgfx_create_frame_buffer_from_handles_cj(1u8, passHolder.get(), false)
                passHolder.dispose()

                let finalTex = bgfx_create_texture_2d_cj(
                    UInt16(shadowSize), UInt16(shadowSize), false, 1u16,
                    TextureFormat.RG16F.value(), TEXTURE_RT, CPointer<Memory>())
                slot.texture = finalTex
                let finalHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
                unsafe { finalHolder.get().write(0, finalTex) }
                slot.vsmFinalFrameBuffer = bgfx_create_frame_buffer_from_handles_cj(1u8, finalHolder.get(), false)
                finalHolder.dispose()
                @LogTrace(["shadow", "dir created VSM chain D32=${depthTex.idx} RG16F pass=${passTex.idx} final=${finalTex.idx} size=${shadowSize}"])
            } else {
                // PCF/BASIC 模式：D24S8 深度纹理（比较采样器；D3D11 下 D24 无 DSV 不能作深度附件）
                let depthTex = bgfx_create_texture_2d_cj(
                    UInt16(shadowSize), UInt16(shadowSize), false, 1u16,
                    TextureFormat.D24S8.value(),
                    TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_COMPARE_LEQUAL) |
                        UInt64(SAMPLER_U_CLAMP) | UInt64(SAMPLER_V_CLAMP),
                    CPointer<Memory>())
                slot.texture = depthTex
                let handlesHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
                unsafe { handlesHolder.get().write(0, depthTex) }
                slot.frameBuffer = bgfx_create_frame_buffer_from_handles_cj(1u8, handlesHolder.get(), true)
                handlesHolder.dispose()
                @LogTrace(["shadow", "dir created shadowFB(D24S8) idx=${slot.frameBuffer.idx} tex=${depthTex.idx} size=${shadowSize}"])
            }
        }

        // 分配 view ID（每光源独占一段）并登记到当前帧 _shadowSlots
        // VSM 需 2 个连续 view：baseViewId=深度 pass，baseViewId+1=blur pass
        slot.baseViewId = this._allocShadowViewId(count: if (isVsm) { 2 } else { 1 })
        this._shadowSlots.add(lightId, slot)
        this._shadowSlotKind.add(lightId, "dir")
        // per-light bias/normalBias（来自 light.shadow，主 pass 绑 u_dirShadowParams[i]）
        slot.bias = light.shadow.bias
        slot.normalBias = light.shadow.normalBias

        if (slot.frameBuffer.idx == 65535u16) { return }

        // 渲染深度 pass（内部计算 slot.shadowMatrix = bias × lightViewProj）
        this._renderShadowDepth(light, scene, slot)
        // VSM：深度 pass 后执行 blur（D32 → RG16F pass → RG16F final）
        if (isVsm) {
            this._vsmBlurPass(slot)
        }
    }

    /**
     * @brief[zh-cn] 渲染方向光阴影深度到指定 framebuffer
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.renderShadowDepth：从光源视角设置 view/proj，遍历场景几何体用 depth shader submit 到 shadowViewId
     * @param[zh-cn] light 方向光
     * scene 场景
     * slot 阴影槽
     *
     * @brief[en] Render directional light shadow depth to specified framebuffer
     * @explain[en] Corresponds to bgfx4cj-last ThreeRenderer.renderShadowDepth: sets view/proj from light perspective, iterates scene geometry using depth shader to submit to shadowViewId
     * @param[en] light Directional light
     * scene Scene
     * slot Shadow slot
     */
    private func _renderShadowDepth(light: DirectionalLight, scene: Scene, slot: ShadowSlot): Unit {
        let shadowSize = slot.size
        let shadowViewId = slot.baseViewId
        let fb = slot.frameBuffer
        let shadowCamera = light.shadow.camera
        @LogTrace(["shadow", "_renderShadowDepth ENTER shadowViewId=${shadowViewId} fb.idx=${fb.idx} shadowSize=${shadowSize}"])

        bgfx_set_view_rect_cj(shadowViewId, 0u16, 0u16, UInt16(shadowSize), UInt16(shadowSize))
        bgfx_set_view_frame_buffer_cj(shadowViewId, fb)

        // 关键修复：显式 update shadowCamera 的 position/lookAt/matrixWorld。
        // DirectionalLightShadow/DirectionalLight 基类不会自动 update shadowCamera，
        // 故 shadowCamera.matrixWorld 默认是单位矩阵（位置 0,0,0 朝向 -Z），
        // 用它的 matrixWorldInverse 会把所有 caster 顶点映到 [-5,5] 外 → 全灰。
        // 必须把 shadowCamera 定位到光源位置朝向光源 target，再 updateMatrixWorld。
        shadowCamera.position.copy(light.position)
        shadowCamera.lookAt(light.target.position)
        shadowCamera.updateMatrixWorld(true)
        // 正交相机 bounds 已含 [-5,5]×[-5,5]×[0.5,500]，updateProjectionMatrix 确保 projectionMatrix 已算
        // updateProjectionMatrix 是 OrthographicCamera 子类独有方法（Camera 基类无），需 cast 调
        if (let Some(ortho) <- (shadowCamera as OrthographicCamera)) { ortho.updateProjectionMatrix() }

        // 从光源视角设置 view/proj 矩阵：用 shadowCamera 自己的 matrixWorldInverse + projectionMatrix
        // （不再手算 lookAt —— shadowCamera.matrixWorldInverse 已含位置/朝向，projectionMatrix 已含正交 bounds）
        let lightView = shadowCamera.matrixWorldInverse
        let lightProj = shadowCamera.projectionMatrix
        // 直接传 elements（_setViewTransform 调用时即 memcpy），省去每光源两个 16 元素数组
        backend._setViewTransform(shadowViewId, lightView.elements, lightProj.elements)

        // 计算阴影矩阵（lightViewProj → 用于主 pass 的阴影坐标变换）
        let lightViewProj = lightProj.clone().multiply(lightView)
        slot.shadowMatrix = lightViewProj

        // 渲染深度 pass：遍历场景几何体用 depth shader submit
        bgfx_set_view_clear_cj(shadowViewId, CLEAR_COLOR | CLEAR_DEPTH, 0x00000000u32, 1.0f32, 0)
        let depthState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.WRITE_Z |
                         BgfxConstants.DEPTH_TEST_LESS | BgfxConstants.FRONT_CCW

        // 确保 depth shader 已编译
        let depthProgOpt = ShaderLibs.get("depth")
        @LogTrace(["shadow", "_renderShadowDepth depthProgOpt=${if (let Some(_) <- depthProgOpt) { "Some" } else { "None" }}"])
        if (let Some(depthSp) <- depthProgOpt) {
            if (depthSp.programHandle.idx == 65535u16) {
                depthSp.compileBgfx()
            }
            let depthProg = depthSp.programHandle
            @LogTrace(["shadow", "_renderShadowDepth depthProg.idx=${depthProg.idx}"])
            if (depthProg.idx == 65535u16) { @LogTrace(["shadow", "_renderShadowDepth SKIP: depthProg compile failed"]); return }

            // 帧内共享的 caster 列表（所有阴影光源复用，避免每光源/每 cube 面全树遍历）
            let renderObjects = this._getShadowCasters(scene)
            @LogTrace(["shadow", "_renderShadowDepth casters.size=${renderObjects.size}"])
            let layout = backend._getOrCreateLayout()
            // 复用的矩阵暂存与 bgfx 上传缓冲：原实现每次调用都新建
            // Array<Float64>(16) + BgfxMemory(64)（后者走 bgfx_alloc，
            // 内存交给 bgfx 后不会被归还，逐帧新建等于持续泄漏）。
            let mtxScratch = this._shadowMtxScratch
            let mtxMem = this._shadowMtxMem
            var submitCnt: Int64 = 0
            for (ro in renderObjects) {
                let vb = backend._createVB(ro.geometry)
                if (vb.idx == 65535u16) { @LogTrace(["shadow", "_renderShadowDepth caster SKIP: vb invalid geom=${ro.mesh.name}"]); continue }
                let posAttrOpt = ro.geometry.getAttribute("position")
                if (let Some(posAttr) <- posAttrOpt) {
                    ro.worldMatrix.toArray(mtxScratch)
                    mtxMem.writeFloats(mtxScratch, 16)
                    bgfx_set_transform_cj(unsafe { CPointer<Unit>(mtxMem.data()) }, 1u16)
                    bgfx_set_vertex_buffer_with_layout_cj(0u8, vb, 0u32, UInt32(posAttr.count), layout)
                    let ib = backend._createIB(ro.geometry)
                    if (ib.idx != 65535u16) {
                        bgfx_set_index_buffer_cj(ib, 0u32, 0xFFFFFFFFu32)
                    }
                    bgfx_set_state_cj(depthState, 0x00000000u32)
                    bgfx_submit_cj(shadowViewId, depthProg, 0u32, 0xFFu8)
                    submitCnt += 1
                }
            }
            @LogTrace(["shadow", "_renderShadowDepth done submitCnt=${submitCnt}"])
        } else {
            @LogTrace(["shadow", "_renderShadowDepth SKIP: depth shader not registered"])
        }
    }

    /**
     * @brief[zh-cn] VSM blur pass：对阴影深度图执行垂直+水平两个方向的 Gaussian-like blur
     * @explain[zh-cn] 对照参考版 ThreeRenderer.vsmBlurPass（2081-2128）：① 垂直 blur：输入 slot.vsmDepthTexture (D32) → 输出 slot.vsmPassFrameBuffer (RG16F pass)；② 水平 blur：输入 slot.vsmPassTexture (RG16F) → 输出 slot.vsmFinalFrameBuffer (RG16F final = slot.texture)。blur view ID = slot.baseViewId + 1
     * @param[zh-cn] slot 阴影槽
     *
     * @brief[en] VSM blur pass: execute vertical + horizontal Gaussian-like blur on shadow depth map
     * @explain[en] Corresponds to ThreeRenderer.vsmBlurPass (2081-2128): ① vertical blur: input slot.vsmDepthTexture (D32) → output slot.vsmPassFrameBuffer (RG16F pass); ② horizontal blur: input slot.vsmPassTexture (RG16F) → output slot.vsmFinalFrameBuffer (RG16F final = slot.texture). blur view ID = slot.baseViewId + 1
     * @param[en] slot Shadow slot
     */
    private func _vsmBlurPass(slot: ShadowSlot): Unit {
        let blurViewId = UInt16(UInt16(slot.baseViewId) + 1u16)
        let w = UInt16(slot.size)
        let h = UInt16(slot.size)
        @LogTrace(["shadow", "_vsmBlurPass ENTER blurViewId=${blurViewId} size=${slot.size}"])

        let vsmOpt = ShaderLibs.get("vsm")
        if (let Some(vsmSp) <- vsmOpt) {
            // 垂直变体（无 HORIZONTAL_PASS）
            if (vsmSp.programHandle.idx == 65535u16) {
                vsmSp.compileBgfx()
            }
            let vProg = vsmSp.programHandle
            if (vProg.idx == 65535u16) { @LogTrace(["shadow", "_vsmBlurPass SKIP: vsm vertical compile failed"]); return }
            // 水平变体（HORIZONTAL_PASS=1）：只编译一次并跨帧复用。
            // 原实现每帧 createVariant + compileBgfx，逐帧泄漏 2 个 shader + 1 个 program。
            var hProg = ProgramHandle(65535u16)
            var cacheHit = false
            if (let Some(hv) <- this._vsmHorizontalProg) {
                if (let Some(base) <- this._vsmHorizontalBase) {
                    if (refEq(base, vsmSp)) {
                        hProg = hv.programHandle
                        cacheHit = true
                    }
                }
            }
            if (!cacheHit) {
                let hVariant = ShaderProgram.createVariant("vsm_h", vsmSp)
                let defStrings = ArrayList<String>()
                defStrings.add("HORIZONTAL_PASS=1")
                hVariant.compileBgfx(extraDefines: defStrings.toArray())
                if (hVariant.programHandle.idx != 65535u16) {
                    this._vsmHorizontalProg = Some(hVariant)
                    this._vsmHorizontalBase = Some(vsmSp)
                }
                hProg = hVariant.programHandle
            }
            if (hProg.idx == 65535u16) { @LogTrace(["shadow", "_vsmBlurPass SKIP: vsm horizontal compile failed"]); return }

            // 全屏四边形 VB（与 vsmVaryingDef 对齐：position + texcoord0）
            backend.blitQuad.ensureBlitVB()
            let uniforms = backend.uniforms
            let shadowSampler = uniforms.createUniform("s_shadowPass", UniformType.Sampler.value())
            let uResolution = uniforms.createUniform("u_resolution", UniformType.Vec4.value())
            let uRadius = uniforms.createUniform("u_radius", UniformType.Vec4.value())
            let blurState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.FRONT_CCW

            // ── ① 垂直 blur：vsmDepthTexture → vsmPassFrameBuffer ──
            bgfx_set_view_rect_cj(blurViewId, 0u16, 0u16, w, h)
            bgfx_set_view_frame_buffer_cj(blurViewId, slot.vsmPassFrameBuffer)
            bgfx_set_view_clear_cj(blurViewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, 1.0f32, 0)
            bgfx_set_texture_cj(0u8, shadowSampler.value, slot.vsmDepthTexture, 0u32)
            let resMem = BgfxMemory(16u32)
            resMem.writeFloats([Float64(w), Float64(h), 0.0, 0.0], 4)
            bgfx_set_uniform_cj(uResolution.value, unsafe { CPointer<Unit>(resMem.data()) }, 1u16)
            let radMem = BgfxMemory(16u32)
            radMem.writeFloats([4.0, 0.0, 0.0, 0.0], 4)
            bgfx_set_uniform_cj(uRadius.value, unsafe { CPointer<Unit>(radMem.data()) }, 1u16)
            if (let Some(vb) <- backend.blitQuad._blitVB) {
                if (let Some(ib) <- backend.blitQuad._blitIB) {
                    if (let Some(layout) <- backend.blitQuad._blitLayout) {
                        bgfx_set_vertex_buffer_with_layout_cj(0u8, vb, 0u32, 0xFFFFFFFFu32, layout)
                        bgfx_set_index_buffer_cj(ib, 0u32, 0xFFFFFFFFu32)
                        bgfx_set_state_cj(blurState, 0x00000000u32)
                        bgfx_submit_cj(blurViewId, vProg, 0u32, 0xFFu8)
                        @LogTrace(["shadow", "_vsmBlurPass vertical submit done"])

                        // ── ② 水平 blur：vsmPassTexture → vsmFinalFrameBuffer ──
                        bgfx_set_view_frame_buffer_cj(blurViewId, slot.vsmFinalFrameBuffer)
                        bgfx_set_view_clear_cj(blurViewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, 1.0f32, 0)
                        bgfx_set_texture_cj(0u8, shadowSampler.value, slot.vsmPassTexture, 0u32)
                        // resolution/radius 不变（同一帧 blur 参数固定）
                        bgfx_set_state_cj(blurState, 0x00000000u32)
                        bgfx_submit_cj(blurViewId, hProg, 0u32, 0xFFu8)
                        @LogTrace(["shadow", "_vsmBlurPass horizontal submit done"])
                    } else {
                        @LogTrace(["shadow", "_vsmBlurPass SKIP: blitLayout None"])
                    }
                } else {
                    @LogTrace(["shadow", "_vsmBlurPass SKIP: blitIB None"])
                }
            } else {
                @LogTrace(["shadow", "_vsmBlurPass SKIP: blitVB None"])
            }
        } else {
            @LogTrace(["shadow", "_vsmBlurPass SKIP: vsm shader not registered"]); return
        }
    }

    // ===== 聚光灯阴影 =====

    /**
     * @brief[zh-cn] 渲染聚光灯阴影贴图（预 pass）
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.renderSpotShadowMap：用 SpotLightShadow.camera（PerspectiveCamera）从光源视角渲染深度到阴影 framebuffer，按 SpotLight.id 分配独立 FB。与方向光阴影的区别：shadowCamera 是 PerspectiveCamera，需调 SpotLightShadow.updateMatrices(light)
     * @param[zh-cn] light 聚光灯（含 shadow.camera 透视相机 + shadow.mapSize）
     * scene 场景（收集 caster 几何体）
     *
     * @brief[en] Render spot light shadow map (pre-pass)
     * @explain[en] Corresponds to bgfx4cj-last ThreeRenderer.renderSpotShadowMap: renders depth from light perspective using SpotLightShadow.camera (PerspectiveCamera) to shadow framebuffer, allocates independent FB per SpotLight.id. Difference from directional light: shadowCamera is PerspectiveCamera, needs SpotLightShadow.updateMatrices(light)
     * @param[en] light Spot light (with shadow.camera perspective camera + shadow.mapSize)
     * scene Scene (collects caster geometry)
     */
    @Zone[three.rendering.bgfx.BgfxShadowPass.renderSpotShadowMap]
    public func renderSpotShadowMap(light: SpotLight, scene: Scene): Unit {
        let shadowSize = Int64(light.shadow.mapSize.x)
        @LogTrace(["shadow", "renderSpotShadowMap ENTER shadowSize=${shadowSize} lightId=${light.id}"])
        let lightId = Int64(light.id)

        var slot = if (let Some(s) <- this._shadowResources.get(lightId)) {
            if (s.size != shadowSize) {
                this._destroySlot(s)
                let fresh = ShadowSlot()
                fresh.size = shadowSize
                this._shadowResources.add(lightId, fresh)
                fresh
            } else {
                s
            }
        } else {
            let fresh = ShadowSlot()
            fresh.size = shadowSize
            this._shadowResources.add(lightId, fresh)
            fresh
        }

        if (slot.texture.idx == 65535u16) {
            let depthTex = bgfx_create_texture_2d_cj(
                UInt16(shadowSize), UInt16(shadowSize), false, 1u16,
                TextureFormat.D24S8.value(),
                TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_COMPARE_LEQUAL) |
                    UInt64(SAMPLER_U_CLAMP) | UInt64(SAMPLER_V_CLAMP),
                CPointer<Memory>())
            slot.texture = depthTex
            let handlesHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
            unsafe { handlesHolder.get().write(0, depthTex) }
            slot.frameBuffer = bgfx_create_frame_buffer_from_handles_cj(1u8, handlesHolder.get(), true)
            handlesHolder.dispose()
            @LogTrace(["shadow", "spot created shadowFB(D24S8) idx=${slot.frameBuffer.idx} size=${shadowSize}"])
        }

        slot.baseViewId = this._allocShadowViewId()
        this._shadowSlots.add(lightId, slot)
        this._shadowSlotKind.add(lightId, "spot")
        // per-light bias/normalBias（来自 light.shadow，主 pass 绑 u_spotShadowParams[i]）
        slot.bias = light.shadow.bias
        slot.normalBias = light.shadow.normalBias

        if (slot.frameBuffer.idx == 65535u16) { return }

        // 渲染聚光灯深度 pass（内部计算 slot.shadowMatrix = bias × lightViewProj）
        this._renderSpotShadowDepth(light, scene, slot)

        // 缓存聚光灯主 pass 绑定所需的 bias 矩阵（即 shader 期望的 spotLightMatrix[i]）
        let biasMtx = Matrix4().set(
            0.5, 0.0, 0.0, 0.5,
            0.0, -0.5, 0.0, 0.5,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        )
        slot.shadowMatrix = biasMtx.multiply(slot.shadowMatrix)
    }

    /**
     * @brief[zh-cn] 渲染聚光灯阴影深度到指定 framebuffer
     * @explain[zh-cn] 对照 _renderShadowDepth 但用 SpotLightShadow.camera（PerspectiveCamera），并调 SpotLightShadow.updateMatrices(light) 确保 camera 位置/朝向/projectionMatrix 已 update
     * @param[zh-cn] light 聚光灯
     * scene 场景
     * slot 阴影槽
     *
     * @brief[en] Render spot light shadow depth to specified framebuffer
     * @explain[en] Corresponds to _renderShadowDepth but uses SpotLightShadow.camera (PerspectiveCamera), and calls SpotLightShadow.updateMatrices(light) to ensure camera position/orientation/projectionMatrix are updated
     * @param[en] light Spot light
     * scene Scene
     * slot Shadow slot
     */
    private func _renderSpotShadowDepth(light: SpotLight, scene: Scene, slot: ShadowSlot): Unit {
        let shadowSize = slot.size
        let shadowViewId = slot.baseViewId
        let fb = slot.frameBuffer
        let shadowCamera = light.shadow.camera
        @LogTrace(["shadow", "_renderSpotShadowDepth ENTER shadowViewId=${shadowViewId} fb.idx=${fb.idx} shadowSize=${shadowSize}"])

        bgfx_set_view_rect_cj(shadowViewId, 0u16, 0u16, UInt16(shadowSize), UInt16(shadowSize))
        bgfx_set_view_frame_buffer_cj(shadowViewId, fb)

        // 关键：调 SpotLightShadow.updateMatrices(light) 确保 camera 位置/朝向/projectionMatrix 已 update
        // （SpotLightShadow 的 updateMatrices 会按 light.position/target/angle/focus 自动调整 PerspectiveCamera）
        light.shadow.updateMatrices(light)

        // 从光源视角设置 view/proj 矩阵：用 shadowCamera 自己的 matrixWorldInverse + projectionMatrix
        let lightView = shadowCamera.matrixWorldInverse
        let lightProj = shadowCamera.projectionMatrix
        // 直接传 elements（_setViewTransform 调用时即 memcpy），省去每光源两个 16 元素数组
        backend._setViewTransform(shadowViewId, lightView.elements, lightProj.elements)

        // 计算阴影矩阵（lightViewProj → 用于主 pass 的阴影坐标变换）
        let lightViewProj = lightProj.clone().multiply(lightView)
        slot.shadowMatrix = lightViewProj

        // 渲染深度 pass：遍历场景几何体用 depth shader submit
        bgfx_set_view_clear_cj(shadowViewId, CLEAR_COLOR | CLEAR_DEPTH, 0x00000000u32, 1.0f32, 0)
        let depthState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.WRITE_Z |
                         BgfxConstants.DEPTH_TEST_LESS | BgfxConstants.FRONT_CCW

        let depthProgOpt = ShaderLibs.get("depth")
        if (let Some(depthSp) <- depthProgOpt) {
            if (depthSp.programHandle.idx == 65535u16) {
                depthSp.compileBgfx()
            }
            let depthProg = depthSp.programHandle
            if (depthProg.idx == 65535u16) { return }

            let renderObjects = this._getShadowCasters(scene)
            let layout = backend._getOrCreateLayout()
            // 复用的矩阵暂存与 bgfx 上传缓冲（原实现每次调用新建，含一次 bgfx_alloc 泄漏）
            let mtxScratch = this._shadowMtxScratch
            let mtxMem = this._shadowMtxMem
            var submitCnt: Int64 = 0
            for (ro in renderObjects) {
                let vb = backend._createVB(ro.geometry)
                if (vb.idx == 65535u16) { continue }
                let posAttrOpt = ro.geometry.getAttribute("position")
                if (let Some(posAttr) <- posAttrOpt) {
                    ro.worldMatrix.toArray(mtxScratch)
                    mtxMem.writeFloats(mtxScratch, 16)
                    bgfx_set_transform_cj(unsafe { CPointer<Unit>(mtxMem.data()) }, 1u16)
                    bgfx_set_vertex_buffer_with_layout_cj(0u8, vb, 0u32, UInt32(posAttr.count), layout)
                    let ib = backend._createIB(ro.geometry)
                    if (ib.idx != 65535u16) {
                        bgfx_set_index_buffer_cj(ib, 0u32, 0xFFFFFFFFu32)
                    }
                    bgfx_set_state_cj(depthState, 0x00000000u32)
                    bgfx_submit_cj(shadowViewId, depthProg, 0u32, 0xFFu8)
                    submitCnt += 1
                }
            }
            @LogTrace(["shadow", "_renderSpotShadowDepth done submitCnt=${submitCnt}"])
        }
    }

    // ===== 点光源阴影（cube） =====

    /**
     * @brief[zh-cn] 渲染点光源阴影贴图（预 pass）
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.renderPointShadowMap：点光源阴影是立方体贴图（6 个面），每面独立 view ID，主 pass 采样 cube shadow map（pointShadowMap sampler，cube 采样方向 = normalize(worldPos - lightPos)）
     * @param[zh-cn] light 点光源（含 shadow.camera PerspectiveCamera fov=90 + shadow.mapSize）
     * scene 场景（收集 caster 几何体）
     *
     * @brief[en] Render point light shadow map (pre-pass)
     * @explain[en] Corresponds to bgfx4cj-last ThreeRenderer.renderPointShadowMap: point light shadow is a cube map (6 faces), each face has independent view ID, main pass samples cube shadow map (pointShadowMap sampler, cube sample direction = normalize(worldPos - lightPos))
     * @param[en] light Point light (with shadow.camera PerspectiveCamera fov=90 + shadow.mapSize)
     * scene Scene (collects caster geometry)
     */
    @Zone[three.rendering.bgfx.BgfxShadowPass.renderPointShadowMap]
    public func renderPointShadowMap(light: PointLight, scene: Scene): Unit {
        let shadowSize = Int64(light.shadow.mapSize.x)
        @LogTrace(["shadow", "renderPointShadowMap ENTER shadowSize=${shadowSize} lightId=${light.id}"])
        let lightId = Int64(light.id)

        var slot = if (let Some(s) <- this._shadowResources.get(lightId)) {
            if (s.size != shadowSize) {
                this._destroySlot(s)
                let fresh = ShadowSlot()
                fresh.size = shadowSize
                fresh.isCube = true
                this._shadowResources.add(lightId, fresh)
                fresh
            } else {
                s
            }
        } else {
            let fresh = ShadowSlot()
            fresh.size = shadowSize
            fresh.isCube = true
            this._shadowResources.add(lightId, fresh)
            fresh
        }

        // 创建 cube 阴影纹理（6 face cube）+ 6 个 face framebuffer
        if (slot.texture.idx == 65535u16) {
            // cube 纹理用 TextureFormat.D24S8（D24 在某些后端 cube 路径不稳，参考项目用 D24S8）
            // + TEXTURE_RT（render target）+ SAMPLER_COMPARE_LEQUAL（硬件深度比较）
            // 注意：cube 纹理不能加 SAMPLER_U_CLAMP|SAMPLER_V_CLAMP（cube 无 UV wrap 概念）
            let cubeFlags = TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_COMPARE_LEQUAL)
            let cubeTex = bgfx_create_texture_cube_cj(
                UInt16(shadowSize), false, 1u16,
                TextureFormat.D24S8.value(), cubeFlags, CPointer<Memory>())
            slot.texture = cubeTex
            // 为每个 face（0-5）创建独立 framebuffer：Attachment(cubeTex, Write, layer=faceIdx)
            for (faceIdx in 0..6) {
                let atHolder = AutoFreePtr<Attachment>(unsafe { LibC.malloc<Attachment>(count: 1i64) })
                let at = atHolder.get()
                bgfx_attachment_init_cj(at, cubeTex, 0u32, UInt16(faceIdx), 1u16, 0u16, flags: ATTACHMENT_NONE)
                let faceFb = bgfx_create_frame_buffer_from_attachment_cj(1u8, at, false)
                atHolder.dispose()
                slot.faceFrameBuffers.add(faceFb)
                @LogTrace(["shadow", "point cube face ${faceIdx} fb.idx=${faceFb.idx}"])
            }
            // frameBuffer 保留为第 0 个 face 的 fb（兼容性占位；实际按 faceFrameBuffers 索引）
            slot.frameBuffer = slot.faceFrameBuffers[0]
            @LogTrace(["shadow", "point created cube shadowFB(D24S8) tex.idx=${cubeTex.idx} size=${shadowSize}"])
        }

        // cube 阴影占 6 个连续 view ID
        slot.baseViewId = this._allocShadowViewId(count: 6)
        this._shadowSlots.add(lightId, slot)
        this._shadowSlotKind.add(lightId, "point")
        // per-light bias（来自 light.shadow，主 pass 绑 u_pointShadowParams[i]）
        slot.bias = light.shadow.bias

        // 缓存点光源世界坐标（主 pass 绑定 u_pointShadowLightPos[i] 用）+ near/far（u_pointShadowNearFar[i]）
        slot.lightPos = light.position.clone()
        if (let Some(persp) <- (light.shadow.camera as PerspectiveCamera)) {
            slot.near = persp.near
            slot.far = persp.far
        }

        if (slot.frameBuffer.idx == 65535u16) { return }

        // 渲染 6 个 face 的深度 pass
        this._renderPointShadowDepth(light, scene, slot)
    }

    /**
     * @brief[zh-cn] 渲染点光源阴影深度到 cube 纹理的 6 个 face
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.renderPointShadowMap。关键：cube 阴影采样方向 = normalize(worldPos - lightPos)，故每个 face 用 PerspectiveCamera(fov=90) 从光源位置朝 6 个轴向渲染
     * @param[zh-cn] light 点光源
     * scene 场景
     * slot 阴影槽
     *
     * @brief[en] Render point light shadow depth to 6 faces of cube texture
     * @explain[en] Corresponds to bgfx4cj-last ThreeRenderer.renderPointShadowMap. Key: cube shadow sample direction = normalize(worldPos - lightPos), so each face uses PerspectiveCamera(fov=90) to render from light position towards 6 axis directions
     * @param[en] light Point light
     * scene Scene
     * slot Shadow slot
     */
    private func _renderPointShadowDepth(light: PointLight, scene: Scene, slot: ShadowSlot): Unit {
        let shadowSize = slot.size
        let baseViewId = slot.baseViewId
        let lightPos = slot.lightPos
        @LogTrace(["shadow", "_renderPointShadowDepth ENTER baseViewId=${baseViewId} lightPos=${lightPos.x},${lightPos.y},${lightPos.z}"])

        // 三张方向表是模块级常量（见文件头），此处只做引用，不再每次调用新建 18 个 Vector3。
        let faceDirs = POINT_SHADOW_FACE_DIRS
        let faceRights = POINT_SHADOW_FACE_RIGHTS
        let faceUps = POINT_SHADOW_FACE_UPS

        // 投影：fov=90 透视（左手系，与 view 匹配）。
        // 6 个 face 的 fov/aspect/near/far 完全相同，原实现每 face 新建一个
        // PerspectiveCamera 并 updateProjectionMatrix（boxshow 每帧 24 次矩阵重算）；
        // 现每次调用只建一个，6 个 face 共用同一份投影矩阵。
        let shadowCamera = PerspectiveCamera(fov: 90.0, aspect: 1.0, near: slot.near, far: slot.far)
        shadowCamera.updateProjectionMatrix()
        // 直接取投影矩阵的 elements（与 toArray 的结果逐元素一致，省去每 face 一个 16 元素数组）
        let projArr = shadowCamera.projectionMatrix.elements

        // 复用的 view 矩阵与上传缓冲：下方 _setViewTransform / set_transform 在调用时即
        // 把数据 memcpy 进 bgfx 内部缓冲，因此同一块内存在两次写入之间必然已被消费，
        // 可安全地逐 face 复用（原实现每 face 新建 Matrix4 + 两个 16 元素数组 + BgfxMemory）。
        let viewMtx = this._shadowViewMtx
        let mtxScratch = this._shadowMtxScratch
        let mtxMem = this._shadowMtxMem
        let renderObjects = this._getShadowCasters(scene)
        let layout = backend._getOrCreateLayout()

        for (faceIdx in 0..6) {
            let faceViewId = UInt16(UInt16(baseViewId) + UInt16(faceIdx))
            let fb = slot.faceFrameBuffers[faceIdx]
            @LogTrace(["shadow", "_renderPointShadowDepth face ${faceIdx} viewId=${faceViewId} fb.idx=${fb.idx}"])

            bgfx_set_view_rect_cj(faceViewId, 0u16, 0u16, UInt16(shadowSize), UInt16(shadowSize))
            bgfx_set_view_frame_buffer_cj(faceViewId, fb)

            // 关键修复①：near/far 必须与主 pass 绑定的 u_pointShadowNearFar 一致
            // （slot.near/slot.far 已在 renderPointShadowMap 中从 light.shadow.camera 读取）。
            // 旧实现硬编码 near=0.5, far=30，而 PointLightShadow 默认 far=500 →
            // getPointShadow 用 far=500 重构 dp，与 far=30 渲染的深度贴图不匹配 → 阴影形状错乱。
            // 关键修复②：手动构造 view 矩阵（D3D11 cube face 约定），不用 lookAt——
            // Three.cj 左手系 lookAt 的 x = cross(up, z) 使渲染内容左右镜像。
            let dir = faceDirs[faceIdx]
            let right = faceRights[faceIdx]
            let up = faceUps[faceIdx]
            // 就地写复用的 Matrix4（原实现每 face 新建一个 Matrix4）
            viewMtx.set(
                right.x, right.y, right.z, -right.dot(lightPos),
                up.x,    up.y,    up.z,    -up.dot(lightPos),
                dir.x,   dir.y,   dir.z,   -dir.dot(lightPos),
                0.0, 0.0, 0.0, 1.0
            )
            @LogTrace(["shadow", "_renderPointShadowDepth face ${faceIdx} camPos=${lightPos.x},${lightPos.y},${lightPos.z} dir=${dir.x},${dir.y},${dir.z}"])
            // 直接传 elements：_setViewTransform 调用时即 memcpy 进 bgfx，
            // 无需每 face 复制成新数组（原实现每 face 两个 16 元素数组）
            backend._setViewTransform(faceViewId, viewMtx.elements, projArr)

            bgfx_set_view_clear_cj(faceViewId, CLEAR_COLOR | CLEAR_DEPTH, 0x00000000u32, 1.0f32, 0)
            let depthState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.WRITE_Z |
                             BgfxConstants.DEPTH_TEST_LESS | BgfxConstants.FRONT_CCW

            let depthProgOpt = ShaderLibs.get("depth")
            if (let Some(depthSp) <- depthProgOpt) {
                if (depthSp.programHandle.idx == 65535u16) {
                    depthSp.compileBgfx()
                }
                let depthProg = depthSp.programHandle
                if (depthProg.idx == 65535u16) { continue }

                // caster 列表与 layout 已在 face 循环外取好（原实现每 face 重复查询 + 重复分配）
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = backend._createVB(ro.geometry)
                    if (vb.idx == 65535u16) { continue }
                    let posAttrOpt = ro.geometry.getAttribute("position")
                    if (let Some(posAttr) <- posAttrOpt) {
                        ro.worldMatrix.toArray(mtxScratch)
                        mtxMem.writeFloats(mtxScratch, 16)
                        bgfx_set_transform_cj(unsafe { CPointer<Unit>(mtxMem.data()) }, 1u16)
                        bgfx_set_vertex_buffer_with_layout_cj(0u8, vb, 0u32, UInt32(posAttr.count), layout)
                        let ib = backend._createIB(ro.geometry)
                        if (ib.idx != 65535u16) {
                            bgfx_set_index_buffer_cj(ib, 0u32, 0xFFFFFFFFu32)
                        }
                        bgfx_set_state_cj(depthState, 0x00000000u32)
                        bgfx_submit_cj(faceViewId, depthProg, 0u32, 0xFFu8)
                        submitCnt += 1
                    }
                }
                @LogTrace(["shadow", "_renderPointShadowDepth face ${faceIdx} done submitCnt=${submitCnt}"])
            }
        }
        @LogTrace(["shadow", "_renderPointShadowDepth ALL 6 faces done"])
    }

    // ===== 阴影辅助方法 =====

    /**
     * @brief[zh-cn] 销毁一个 ShadowSlot 持有的所有 GPU 资源（framebuffer + 纹理 + cube face framebuffer + VSM 链）
     * @param[zh-cn] slot 阴影槽
     *
     * @brief[en] Destroy all GPU resources held by a ShadowSlot (framebuffer + texture + cube face framebuffers + VSM chain)
     * @param[en] slot Shadow slot
     */
    public func _destroySlot(slot: ShadowSlot): Unit {
        if (slot.isCube) {
            // cube：frameBuffer 与 faceFrameBuffers[0] 同句柄，避免重复销毁
            slot.frameBuffer.idx = 0xFFFFu16
        }
        for (faceFb in slot.faceFrameBuffers) {
            if (faceFb.idx != 0xFFFFu16) {
                bgfx_destroy_frame_buffer_cj(faceFb)
            }
        }
        slot.faceFrameBuffers.clear()
        // VSM 链：vsmDepthTexture / vsmPassTexture / vsmPassFrameBuffer / vsmFinalFrameBuffer
        // 注意 slot.frameBuffer（D32 深度 FB）与 slot.texture（RG16F final）由下方统一销毁，
        // vsm 链的额外 FB（pass/final）与 vsmDepthTexture/vsmPassTexture 是独立句柄需单独释放
        if (slot.vsmPassFrameBuffer.idx != 0xFFFFu16) {
            bgfx_destroy_frame_buffer_cj(slot.vsmPassFrameBuffer)
            slot.vsmPassFrameBuffer.idx = 0xFFFFu16
        }
        if (slot.vsmFinalFrameBuffer.idx != 0xFFFFu16) {
            bgfx_destroy_frame_buffer_cj(slot.vsmFinalFrameBuffer)
            slot.vsmFinalFrameBuffer.idx = 0xFFFFu16
        }
        if (slot.vsmDepthTexture.idx != 0xFFFFu16) {
            bgfx_destroy_texture_cj(slot.vsmDepthTexture)
            slot.vsmDepthTexture.idx = 0xFFFFu16
        }
        if (slot.vsmPassTexture.idx != 0xFFFFu16) {
            bgfx_destroy_texture_cj(slot.vsmPassTexture)
            slot.vsmPassTexture.idx = 0xFFFFu16
        }
        if (slot.frameBuffer.idx != 0xFFFFu16) {
            bgfx_destroy_frame_buffer_cj(slot.frameBuffer)
            slot.frameBuffer.idx = 0xFFFFu16
        }
        if (slot.texture.idx != 0xFFFFu16) {
            bgfx_destroy_texture_cj(slot.texture)
            slot.texture.idx = 0xFFFFu16
        }
    }

    /**
     * @brief[zh-cn] 为新的阴影光源分配 view ID 段
     * @param[zh-cn] count 该光源占用的 view ID 数（2D 阴影=1，cube 阴影=6）
     * @return[zh-cn] 起始 view ID
     *
     * @brief[en] Allocate view ID segment for a new shadow light
     * @param[en] count Number of view IDs this light occupies (2D shadow=1, cube shadow=6)
     * @return[en] Starting view ID
     */
    public func _allocShadowViewId(count!: Int64 = 1): UInt16 {
        let base = this._nextShadowViewId
        this._nextShadowViewId = UInt16(UInt16(this._nextShadowViewId) + UInt16(count))
        return base
    }

    /**
     * @brief[zh-cn] 递归收集场景中所有 castShadow 的 Mesh 几何体作为阴影 caster
     * @explain[zh-cn] 对照 bgfx4cj-last collectRenderObjects：当前简化为收集所有 Mesh（不区分 castShadow 标志，因 Light 基类无 castShadow 字段，默认所有几何体都参与阴影深度 pass）
     * @param[zh-cn] obj 场景对象
     * renderObjects 渲染对象列表
     *
     * @brief[en] Recursively collect all castShadow Mesh geometry in the scene as shadow casters
     * @explain[en] Corresponds to bgfx4cj-last collectRenderObjects: currently simplified to collect all Meshes (no castShadow flag distinction, as Light base class has no castShadow field, all geometry participates in shadow depth pass by default)
     * @param[en] obj Scene object
     * renderObjects Render object list
     */
    @Zone[three.rendering.bgfx.BgfxShadowPass._collectShadowCasters]
    public func _collectShadowCasters(obj: Object3D, renderObjects: ArrayList<RenderObject>): Unit {
        for (child in obj.children) {
            if (child.children.size > 0) {
                this._collectShadowCasters(child, renderObjects)
            }
            // 关键：仓颉 `match (child as Mesh)` 的运行时 cast 检查对 Mesh 子类不生效
            // （GroundPlane/FloatingCube 的 kind=Mesh 但 cast 不匹配 → casters.size=0 → blit 空 = 黑）
            // 改用 kind 字段判断（对照 Renderer._collectRenderObjects 既有风格），
            // 然后用 match (child as Mesh) 解构 Option<Mesh> 拿 Mesh 实例（child.kind=Mesh 已保证安全）。
            if (child.kind == "Mesh") {
                if (let Some(mesh) <- (child as Mesh)) {
                    // Mesh.material 字段类型是 Material（非 Option<Material>），直接用
                    // 池化复用 RenderObject：避免每个 caster 每帧新建一个
                    // RenderObject（连带分配 RenderContext/Camera/Scene/Matrix 等）
                    let ro = if (this._casterPoolCursor < this._casterPool.size) {
                        let pooled = this._casterPool[this._casterPoolCursor]
                        this._casterPoolCursor += 1
                        pooled.resetFor(mesh, mesh.geometry, mesh.material)
                        pooled
                    } else {
                        let created = RenderObject(mesh.id, mesh, mesh.geometry, mesh.material, mesh.matrixWorld)
                        this._casterPool.add(created)
                        this._casterPoolCursor += 1
                        created
                    }
                    renderObjects.add(ro)
                    @LogTrace(["shadow", "_collectShadowCasters ADD caster name=${mesh.name}"])
                } else {
                    @LogTrace(["shadow", "_collectShadowCasters cast FAILED kind=${child.kind}"])
                }
            }
        }
    }

    // ===== 主 pass 阴影 uniform 绑定 =====

    /**
     * @brief[zh-cn] 绑定阴影 uniform 到主 pass draw（在 _drawRenderObject 中调用）
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.draw 行 788-819 + bindMultiSpotShadows/bindMultiPointShadows：directionalShadowMap 纹理绑定到 sampler stage 0..numDir-1，spotShadowMap 纹理绑定到 sampler stage numDir..，pointShadowMap 纹理绑定到 sampler stage numDir+numSpot..，各 ShadowMatrix = bias × lightViewProj。关键修复：原实现仅绑定方向光阴影，聚光灯/点光源阴影贴图从未被采样 → 无阴影
     *
     * @brief[en] Bind shadow uniforms to main pass draw (called in _drawRenderObject)
     * @explain[en] Corresponds to bgfx4cj-last ThreeRenderer.draw lines 788-819 + bindMultiSpotShadows/bindMultiPointShadows: directionalShadowMap texture bound to sampler stage 0..numDir-1, spotShadowMap to stage numDir.., pointShadowMap to stage numDir+numSpot.., each ShadowMatrix = bias × lightViewProj. Key fix: original implementation only bound directional light shadows, spot/point light shadow maps were never sampled → no shadows
     */
    @Zone[three.rendering.bgfx.BgfxShadowPass.bindShadowUniforms]
    public func bindShadowUniforms(): Unit {
        // 多光源阴影支持：按当前帧 _shadowSlots 逐光源绑定数组化 uniform。
        // shader 端已数组化（uniform sampler2DShadow directionalShadowMap[NUM_DIR_LIGHT_SHADOWS] 等），
        // bgfx 数组 uniform 绑定方式（对照 u_pointPosition[4] 先例）：
        //   - 数组 uniform（mat4/vec4）：createUniform(name, type, num) 一次创建 + setUniform 一次传整个数组
        //   - 数组 sampler：createUniform(name, Sampler, num) 一次创建 + setTexture(stage, uniform, tex) 按 stage 逐个绑定
        // 注意：数组 sampler 的 stage 从 0 起连续分配（bgfx 按声明顺序分配寄存器），
        // 故 directional/spot/point 三类阴影 sampler 的 stage 段必须互不重叠：
        //   directional: stage 0..numDir-1
        //   spot:        stage 4..4+numSpot-1（预留 4 个）
        //   point(cube): stage 8..8+numPoint-1（预留 8 个）
        // 对应 uniform 数组：directionalShadowMatrix[i] / spotLightMatrix[i] / pointShadowMatrix[i]
        //   + u_pointShadowLightPos[i] / u_pointShadowNearFar[i]
        //
        // 旧实现仅绑定方向光阴影，聚光灯/点光源阴影贴图从未被采样 → 无阴影。
        // 现按三类光源独立 framebuffer（_shadowFB/_spotShadowFB/_pointShadowFB）分别绑定。
        //
        // 性能：本方法在绘制循环中逐 draw 调用（submit 用 BGFX_DISCARD_ALL，纹理
        // 绑定提交即消费，故必须每 draw 重绑）。其中 slot 分类、bias 矩阵乘与
        // uniform 句柄在帧内恒定，已缓存到 _shadowBindCache（beginFrame 失效）；
        // 每 draw 仅执行必需的 set_texture / set_uniform。
        if (!this._shadowBindCache.valid) {
            this._buildShadowBindCache()
        }
        this._submitShadowBindings()
    }

    /**
     * @brief[zh-cn] 构建帧级阴影绑定缓存（slot 分类 + 矩阵乘 + uniform 句柄）
     * @explain[zh-cn]
     * 每帧仅执行一次（首次 bindShadowUniforms 时），结果存入 _shadowBindCache。
     *
     * @brief[en] Build the frame-level shadow binding cache (slot categorization +
     *            matrix premultiply + uniform handles)
     * @explain[en]
     * Runs once per frame (on the first bindShadowUniforms call); the result is
     * stored in _shadowBindCache.
     */
    private func _buildShadowBindCache(): Unit {
        let cache = this._shadowBindCache
        let backend = this._backend.getOrThrow()
        let uniforms = backend.uniforms

        // bias 矩阵：NDC [-1,1] → 纹理 UV [0,1]，D3D11 Y-flip 风格（-0.5）。
        let biasMtx = Matrix4().set(
            0.5, 0.0, 0.0, 0.5,
            0.0, -0.5, 0.0, 0.5,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        )
        let cmpFlags = BgfxConstants.SAMPLER_COMPARE_LEQUAL | BgfxConstants.SAMPLER_MIN_ANISOTROPIC | BgfxConstants.SAMPLER_MAG_ANISOTROPIC

        // 收集三类阴影光源的 slot（按 lightId 排序保证帧间一致）
        cache.dirSlots.clear()
        cache.spotSlots.clear()
        cache.pointSlots.clear()
        let lightIds = ArrayList<Int64>()
        for ((lid, _) in this._shadowSlots) {
            lightIds.add(lid)
        }
        // 排序（升序）
        for (i in 0..lightIds.size) {
            for (j in i + 1..lightIds.size) {
                if (lightIds[j] < lightIds[i]) {
                    let tmp = lightIds[i]
                    lightIds[i] = lightIds[j]
                    lightIds[j] = tmp
                }
            }
        }
        for (lid in lightIds) {
            if (let Some(slot) <- this._shadowSlots.get(lid)) {
                // 区分类型：cube → point；2D 中按 texture 是否带 cube 标记再次区分
                if (slot.isCube) {
                    cache.pointSlots.add(slot)
                } else {
                    // 这里无法直接区分 directional/spot，需通过 _shadowSlotKind 查询
                    if (let Some(kind) <- this._shadowSlotKind.get(lid)) {
                        if (kind == "dir") {
                            cache.dirSlots.add(slot)
                        } else if (kind == "spot") {
                            cache.spotSlots.add(slot)
                        } else {
                            cache.dirSlots.add(slot)
                        }
                    } else {
                        cache.dirSlots.add(slot)
                    }
                }
            }
        }

        let dirSlots = cache.dirSlots
        let spotSlots = cache.spotSlots
        let pointSlots = cache.pointSlots

        // ===== 1. 方向光阴影 =====
        if (dirSlots.size > 0) {
            let numDir = UInt16(dirSlots.size)
            // VSM：RG16F mean/variance 纹理用普通采样（texture2D 读 .rg，无比较），
            // 与 PCF/BASIC 的 D24 比较采样器（shadow2D 硬件比较）区分。
            let isVsm = backend.shadowMap.getShadowType() == VSM_SHADOW_MAP
            cache.dirSamplerFlags = if (isVsm) {
                UInt32(SAMPLER_U_CLAMP) | UInt32(SAMPLER_V_CLAMP)
            } else {
                UInt32(cmpFlags)
            }
            cache.dirSampler = uniforms.createUniform("directionalShadowMap", UniformType.Sampler.value(), numDir).value
            cache.dirMatUniform = uniforms.createUniform("directionalShadowMatrix", UniformType.Mat4.value(), numDir).value
            cache.dirParamUniform = uniforms.createUniform("u_dirShadowParams", UniformType.Vec4.value(), numDir).value

            cache.dirMats = Array<Float32>(dirSlots.size * 16, { _ => 0.0f32 })
            cache.dirParams = Array<Float32>(dirSlots.size * 4, { _ => 0.0f32 })
            for (i in 0..dirSlots.size) {
                let shadowMtx = biasMtx.multiply(dirSlots[i].shadowMatrix)
                let smArr = shadowMtx.toArray(Array<Float64>(16, { _ => 0.0 }))
                for (k in 0..16) { cache.dirMats[i * 16 + k] = Float32(smArr[k]) }
                cache.dirParams[i * 4 + 0] = Float32(dirSlots[i].bias)
                cache.dirParams[i * 4 + 1] = Float32(dirSlots[i].normalBias)
            }
        }

        // ===== 2. 聚光灯阴影（spotLightMatrix 已在生成侧预乘 bias）=====
        if (spotSlots.size > 0) {
            let numSpot = UInt16(spotSlots.size)
            cache.spotSampler = uniforms.createUniform("spotShadowMap", UniformType.Sampler.value(), numSpot).value
            cache.spotMatUniform = uniforms.createUniform("spotLightMatrix", UniformType.Mat4.value(), numSpot).value
            cache.spotParamUniform = uniforms.createUniform("u_spotShadowParams", UniformType.Vec4.value(), numSpot).value

            cache.spotMats = Array<Float32>(spotSlots.size * 16, { _ => 0.0f32 })
            cache.spotParams = Array<Float32>(spotSlots.size * 4, { _ => 0.0f32 })
            for (i in 0..spotSlots.size) {
                let smArr = spotSlots[i].shadowMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                for (k in 0..16) { cache.spotMats[i * 16 + k] = Float32(smArr[k]) }
                cache.spotParams[i * 4 + 0] = Float32(spotSlots[i].bias)
                cache.spotParams[i * 4 + 1] = Float32(spotSlots[i].normalBias)
            }
        }

        // ===== 3. 点光源阴影（cube sampler + 位置/近远平面数组）=====
        if (pointSlots.size > 0) {
            let numPoint = UInt16(pointSlots.size)
            cache.pointSampler = uniforms.createUniform("pointShadowMap", UniformType.Sampler.value(), numPoint).value
            cache.pointPosUniform = uniforms.createUniform("u_pointShadowLightPos", UniformType.Vec4.value(), numPoint).value
            cache.pointRangeUniform = uniforms.createUniform("u_pointShadowNearFar", UniformType.Vec4.value(), numPoint).value
            cache.pointParamUniform = uniforms.createUniform("u_pointShadowParams", UniformType.Vec4.value(), numPoint).value

            cache.pointLightPos = Array<Float32>(pointSlots.size * 4, { _ => 0.0f32 })
            cache.pointNearFar = Array<Float32>(pointSlots.size * 4, { _ => 0.0f32 })
            cache.pointParams = Array<Float32>(pointSlots.size * 4, { _ => 0.0f32 })
            for (i in 0..pointSlots.size) {
                cache.pointLightPos[i * 4 + 0] = Float32(pointSlots[i].lightPos.x)
                cache.pointLightPos[i * 4 + 1] = Float32(pointSlots[i].lightPos.y)
                cache.pointLightPos[i * 4 + 2] = Float32(pointSlots[i].lightPos.z)
                cache.pointNearFar[i * 4 + 0] = Float32(pointSlots[i].near)
                cache.pointNearFar[i * 4 + 1] = Float32(pointSlots[i].far)
                cache.pointParams[i * 4 + 0] = Float32(pointSlots[i].bias)
            }
        }

        // ===== 4. 全局阴影参数（三类光源共用）=====
        // shadowParams: x=intensity, y=bias, z=normalBias, w=radius
        // PcfVizMaterial 的 "pcf" 调试 shader 仍读 shadowParams.y/z 作为
        // bias/threshold，故从第一个方向光 slot 填入实际 bias/normalBias。
        let spBias = if (dirSlots.size > 0) { dirSlots[0].bias } else { 0.0 }
        let spNormalBias = if (dirSlots.size > 0) { dirSlots[0].normalBias } else { 0.0 }
        cache.shadowParams = Array<Float32>(4, { _ => 0.0f32 })
        cache.shadowParams[0] = 1.0f32
        cache.shadowParams[1] = Float32(spBias)
        cache.shadowParams[2] = Float32(spNormalBias)
        cache.shadowParams[3] = 1.0f32
        cache.shadowParamsUniform = uniforms.createUniform("shadowParams", UniformType.Vec4.value()).value

        // shadowMapSize（xyz=size, w=0），取三类 framebuffer 尺寸中非零者
        let activeSize = if (dirSlots.size > 0) {
            dirSlots[0].size
        } else if (spotSlots.size > 0) {
            spotSlots[0].size
        } else if (pointSlots.size > 0) {
            pointSlots[0].size
        } else {
            0
        }
        let smSizeVal = Float32(activeSize)
        cache.mapSize = Array<Float32>(4, { _ => 0.0f32 })
        cache.mapSize[0] = smSizeVal
        cache.mapSize[1] = smSizeVal
        cache.mapSize[2] = smSizeVal
        cache.mapSizeUniform = uniforms.createUniform("shadowMapSize", UniformType.Vec4.value()).value

        cache.valid = true
    }

    private var _bindMemStore: Option<BgfxMemory> = None
    private var _bindMemSize: UInt32 = 0

    /**
     * @brief[zh-cn] 取一块至少 need 字节的复用上传缓冲（容量不足时才重新分配）
     * @explain[zh-cn] _submitShadowBindings 逐 draw 调用，原实现每次新建 7 个
     *                BgfxMemory（boxshow 25s 采集 3995 draw ≈ 2.8 万次 bgfx_alloc）。
     *                bgfx_alloc 的缓冲只作 set_uniform 的数据源：调用时即 memcpy 进
     *                引擎内部 uniform buffer，且该内存不会被归还 → 逐 draw 新建等于
     *                持续泄漏原生内存（实测工作集每秒增长约 1MB）。
     *                所有 uniform 都是"写入 → 立刻 set_uniform"的顺序消费，
     *                故单块缓冲即可安全复用。
     *
     * @brief[en] Returns a reusable upload buffer of at least `need` bytes (reallocates only when it must grow)
     * @param[en] need Required capacity in bytes
     * @return[en] The reusable buffer
     */
    private func _bindMem(need: UInt32): BgfxMemory {
        if (let Some(m) <- this._bindMemStore) {
            if (this._bindMemSize >= need) { return m }
        }
        let m = BgfxMemory(need)
        this._bindMemStore = Some(m)
        this._bindMemSize = need
        return m
    }

    /**
     * @brief[zh-cn] 逐 draw 提交帧级缓存的阴影绑定（set_texture / set_uniform）
     * @explain[zh-cn]
     * 提交使用 BGFX_DISCARD_ALL，纹理与 uniform 绑定在 submit 时被消费，因此这一步
     * 必须每个 draw 重复执行；数据来源为帧级缓存，不再重算矩阵与查表。
     *
     * @brief[en] Submit the frame-level cached shadow bindings per draw
     * @explain[en]
     * Submit uses BGFX_DISCARD_ALL, so texture and uniform bindings are consumed at
     * submit time and this step must repeat for every draw; the data now comes from
     * the frame-level cache instead of being recomputed.
     */
    private func _submitShadowBindings(): Unit {
        let cache = this._shadowBindCache
        let dirSlots = cache.dirSlots
        let spotSlots = cache.spotSlots
        let pointSlots = cache.pointSlots
        let cmpFlags = BgfxConstants.SAMPLER_COMPARE_LEQUAL | BgfxConstants.SAMPLER_MIN_ANISOTROPIC | BgfxConstants.SAMPLER_MAG_ANISOTROPIC

        // ===== 1. 方向光阴影（stage 0..numDir-1）=====
        if (dirSlots.size > 0) {
            let numDir = UInt16(dirSlots.size)
            for (i in 0..dirSlots.size) {
                bgfx_set_texture_cj(UInt8(UInt32(i)), cache.dirSampler, dirSlots[i].texture, cache.dirSamplerFlags)
            }
            let smMem = this._bindMem(UInt32(dirSlots.size * 64))
            for (i in 0..cache.dirMats.size) {
                smMem.writeFloat(Int64(i), cache.dirMats[i])
            }
            bgfx_set_uniform_cj(cache.dirMatUniform, unsafe { CPointer<Unit>(smMem.data()) }, numDir)
            let dirPMem = this._bindMem(UInt32(dirSlots.size * 16))
            for (i in 0..cache.dirParams.size) {
                dirPMem.writeFloat(Int64(i), cache.dirParams[i])
            }
            bgfx_set_uniform_cj(cache.dirParamUniform, unsafe { CPointer<Unit>(dirPMem.data()) }, numDir)
        }

        // ===== 2. 聚光灯阴影（stage 顺延：dir 占 0..numDir-1）=====
        if (spotSlots.size > 0) {
            let numSpot = UInt16(spotSlots.size)
            let spotStageBase = dirSlots.size
            for (i in 0..spotSlots.size) {
                bgfx_set_texture_cj(UInt8(UInt32(spotStageBase) + UInt32(i)), cache.spotSampler, spotSlots[i].texture, UInt32(cmpFlags))
            }
            let smMem = this._bindMem(UInt32(spotSlots.size * 64))
            for (i in 0..cache.spotMats.size) {
                smMem.writeFloat(Int64(i), cache.spotMats[i])
            }
            bgfx_set_uniform_cj(cache.spotMatUniform, unsafe { CPointer<Unit>(smMem.data()) }, numSpot)
            let spotPMem = this._bindMem(UInt32(spotSlots.size * 16))
            for (i in 0..cache.spotParams.size) {
                spotPMem.writeFloat(Int64(i), cache.spotParams[i])
            }
            bgfx_set_uniform_cj(cache.spotParamUniform, unsafe { CPointer<Unit>(spotPMem.data()) }, numSpot)
        }

        // ===== 3. 点光源阴影（stage 顺延：dir+spot 之后）=====
        if (pointSlots.size > 0) {
            let numPoint = UInt16(pointSlots.size)
            let pointStageBase = dirSlots.size + spotSlots.size
            for (i in 0..pointSlots.size) {
                bgfx_set_texture_cj(UInt8(UInt32(pointStageBase) + UInt32(i)), cache.pointSampler, pointSlots[i].texture, UInt32(cmpFlags))
            }
            let plpMem = this._bindMem(UInt32(pointSlots.size * 16))
            for (i in 0..cache.pointLightPos.size) {
                plpMem.writeFloat(Int64(i), cache.pointLightPos[i])
            }
            bgfx_set_uniform_cj(cache.pointPosUniform, unsafe { CPointer<Unit>(plpMem.data()) }, numPoint)

            let pnfMem = this._bindMem(UInt32(pointSlots.size * 16))
            for (i in 0..cache.pointNearFar.size) {
                pnfMem.writeFloat(Int64(i), cache.pointNearFar[i])
            }
            bgfx_set_uniform_cj(cache.pointRangeUniform, unsafe { CPointer<Unit>(pnfMem.data()) }, numPoint)

            let pointPMem = this._bindMem(UInt32(pointSlots.size * 16))
            for (i in 0..cache.pointParams.size) {
                pointPMem.writeFloat(Int64(i), cache.pointParams[i])
            }
            bgfx_set_uniform_cj(cache.pointParamUniform, unsafe { CPointer<Unit>(pointPMem.data()) }, numPoint)
        }

        // ===== 4. 全局阴影参数 =====
        let spMem = this._bindMem(16u32)
        for (i in 0..4) { spMem.writeFloat(Int64(i), cache.shadowParams[i]) }
        bgfx_set_uniform_cj(cache.shadowParamsUniform, unsafe { CPointer<Unit>(spMem.data()) }, 1u16)

        let smSizeMem = this._bindMem(16u32)
        for (i in 0..4) { smSizeMem.writeFloat(Int64(i), cache.mapSize[i]) }
        bgfx_set_uniform_cj(cache.mapSizeUniform, unsafe { CPointer<Unit>(smSizeMem.data()) }, 1u16)
    }

    /**
     * @brief[zh-cn] 销毁所有持久阴影资源（_shadowResources），供 BgfxBackend.dispose 调用
     *
     * @brief[en] Destroy all persistent shadow resources (_shadowResources), called by BgfxBackend.dispose
     */
    public func dispose(): Unit {
        for ((_, slot) in this._shadowResources) {
            this._destroySlot(slot)
        }
        this._shadowResources.clear()
        this._shadowSlots.clear()
        this._shadowSlotKind.clear()
        // bgfx_shutdown 后缓存的 VSM 变体句柄失效，清空引用以便下次重建
        this._vsmHorizontalProg = None
        this._vsmHorizontalBase = None
    }
}

/**
 * @brief[zh-cn] 帧级阴影绑定缓存
 * @explain[zh-cn]
 * 缓存 bindShadowUniforms 中"帧内恒定"的部分：分类后的 slot 列表、预乘 bias 的
 * 矩阵数据、逐光源参数数据、以及 createUniform 得到的 uniform 句柄。
 * 由于绘制循环中每个 draw 都要重新调用 bindShadowUniforms（submit 使用
 * BGFX_DISCARD_ALL，纹理绑定提交即被消费），这部分重复计算占用了可观的每 draw 开销。
 *
 * @brief[en] Frame-level shadow binding cache
 * @explain[en]
 * Holds the parts of bindShadowUniforms that are constant within a frame: the
 * categorized slot lists, the bias-premultiplied matrix data, the per-light
 * parameter data, and the uniform handles returned by createUniform. Every draw
 * calls bindShadowUniforms again (submit uses BGFX_DISCARD_ALL, so texture
 * bindings are consumed per submit), which made this recomputation a notable
 * per-draw cost.
 */
public class ShadowBindCache {
    /** 缓存是否有效（beginFrame 时置 false） */
    public var valid: Bool = false

    /** 分类后的方向光 slot（按 lightId 升序，帧间稳定） */
    public var dirSlots: ArrayList<ShadowSlot> = ArrayList<ShadowSlot>()
    /** 分类后的聚光灯 slot */
    public var spotSlots: ArrayList<ShadowSlot> = ArrayList<ShadowSlot>()
    /** 分类后的点光源 slot */
    public var pointSlots: ArrayList<ShadowSlot> = ArrayList<ShadowSlot>()

    /** 方向光阴影矩阵（bias 已预乘），长度 = dirSlots.size * 16 */
    public var dirMats: Array<Float32> = Array<Float32>()
    /** 聚光灯阴影矩阵（bias 已在生成侧预乘），长度 = spotSlots.size * 16 */
    public var spotMats: Array<Float32> = Array<Float32>()
    /** 方向光逐光源参数 [bias, normalBias, 0, 0]，长度 = dirSlots.size * 4 */
    public var dirParams: Array<Float32> = Array<Float32>()
    /** 聚光灯逐光源参数，长度 = spotSlots.size * 4 */
    public var spotParams: Array<Float32> = Array<Float32>()
    /** 点光源位置 [x, y, z, 0]，长度 = pointSlots.size * 4 */
    public var pointLightPos: Array<Float32> = Array<Float32>()
    /** 点光源近远平面 [near, far, 0, 0]，长度 = pointSlots.size * 4 */
    public var pointNearFar: Array<Float32> = Array<Float32>()
    /** 点光源逐光源参数 [bias, 0, 0, 0]，长度 = pointSlots.size * 4 */
    public var pointParams: Array<Float32> = Array<Float32>()
    /** 全局阴影参数 [intensity, bias, normalBias, radius] */
    public var shadowParams: Array<Float32> = Array<Float32>(4, { _ => 0.0f32 })
    /** 阴影贴图尺寸 [size, size, size, 0] */
    public var mapSize: Array<Float32> = Array<Float32>(4, { _ => 0.0f32 })

    /** 方向光阴影贴图 sampler 句柄 */
    public var dirSampler: UniformHandle = UniformHandle()
    /** 方向光阴影矩阵 uniform 句柄 */
    public var dirMatUniform: UniformHandle = UniformHandle()
    /** 方向光逐光源参数 uniform 句柄 */
    public var dirParamUniform: UniformHandle = UniformHandle()
    /** 聚光灯阴影贴图 sampler 句柄 */
    public var spotSampler: UniformHandle = UniformHandle()
    /** 聚光灯阴影矩阵 uniform 句柄 */
    public var spotMatUniform: UniformHandle = UniformHandle()
    /** 聚光灯逐光源参数 uniform 句柄 */
    public var spotParamUniform: UniformHandle = UniformHandle()
    /** 点光源阴影贴图 sampler 句柄 */
    public var pointSampler: UniformHandle = UniformHandle()
    /** 点光源位置 uniform 句柄 */
    public var pointPosUniform: UniformHandle = UniformHandle()
    /** 点光源近远平面 uniform 句柄 */
    public var pointRangeUniform: UniformHandle = UniformHandle()
    /** 点光源逐光源参数 uniform 句柄 */
    public var pointParamUniform: UniformHandle = UniformHandle()
    /** 全局阴影参数 uniform 句柄 */
    public var shadowParamsUniform: UniformHandle = UniformHandle()
    /** 阴影贴图尺寸 uniform 句柄 */
    public var mapSizeUniform: UniformHandle = UniformHandle()

    /** 方向光 sampler 的比较/各向异性标志（VSM 时为普通采样标志） */
    public var dirSamplerFlags: UInt32 = 0

    public init() {}
}
