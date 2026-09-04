/**
 * @file[zh-cn] bgfx 渲染状态管理
 * @brief[zh-cn] 替代 WebGLState，管理混合、深度测试、模板测试、剔除等渲染状态
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLState.js。在 WebGL 中通过 gl.enable/disable/gl.blendFunc 等调用管理状态，在 bgfx 中通过状态标志位（BGFX_STATE_xxx）组合设置，并跟踪当前状态避免冗余设置。
 *
 * @file[en] bgfx Render State Management
 * @brief[en] Replaces WebGLState, manages blending, depth test, stencil test, culling and other render states
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLState.js. In WebGL, states are managed via gl.enable/disable/gl.blendFunc calls; in bgfx, states are managed via combined state flags (BGFX_STATE_xxx) and tracked to avoid redundant settings.
 */
package three.rendering.bgfx

import three.utils.constants.*
import three.core.math.*
import bgfx4cj.bgfx.*
import three.rendering.materials.Material
import std.collection.*

/**
 * @brief[zh-cn] 颜色缓冲状态
 * @explain[zh-cn] 对照 WebGLState.ColorBuffer
 *
 * @brief[en] Color buffer state
 * @explain[en] Corresponds to WebGLState.ColorBuffer
 */
public class ColorBuffer {
    /**
     * @brief[zh-cn] 是否锁定
     *
     * @brief[en] Whether locked
     */
    private var locked: Bool = false
    /**
     * @brief[zh-cn] 当前颜色掩码
     *
     * @brief[en] Current color mask
     */
    private var currentColorMask: Option<Bool> = None
    /**
     * @brief[zh-cn] 当前清除颜色
     *
     * @brief[en] Current clear color
     */
    private let currentColorClear: Color = Color(0.0, 0.0, 0.0)

    /**
     * @brief[zh-cn] 设置颜色掩码
     * @param[zh-cn] colorMask 颜色掩码
     *
     * @brief[en] Set color mask
     * @param[en] colorMask Color mask
     */
    public func setMask(colorMask: Bool): Unit {
        if (currentColorMask.getOrThrow() != colorMask && !locked) {
            currentColorMask = Some(colorMask)
        }
    }

    /**
     * @brief[zh-cn] 设置锁定状态
     * @param[zh-cn] lock 是否锁定
     *
     * @brief[en] Set locked state
     * @param[en] lock Whether to lock
     */
    public func setLocked(lock: Bool): Unit {
        locked = lock
    }

    /**
     * @brief[zh-cn] 设置清除颜色
     * @param[zh-cn] r 红色分量
     * g 绿色分量
     * b 蓝色分量
     * a 透明度分量
     * premultipliedAlpha 是否预乘 Alpha
     *
     * @brief[en] Set clear color
     * @param[en] r Red component
     * g Green component
     * b Blue component
     * a Alpha component
     * premultipliedAlpha Whether premultiplied alpha
     */
    public func setClear(r: Float64, g: Float64, b: Float64, a: Float64, premultipliedAlpha: Bool): Unit {
        var rr = r
        var gg = g
        var bb = b
        if (premultipliedAlpha) {
            rr = r * a
            gg = g * a
            bb = b * a
        }
        currentColorClear.setRGB(rr, gg, bb)
    }

    /**
     * @brief[zh-cn] 重置颜色缓冲状态
     *
     * @brief[en] Reset color buffer state
     */
    public func reset(): Unit {
        locked = false
        currentColorMask = None
    }
}

/**
 * @brief[zh-cn] 深度缓冲状态
 * @explain[zh-cn] 对照 WebGLState.DepthBuffer
 *
 * @brief[en] Depth buffer state
 * @explain[en] Corresponds to WebGLState.DepthBuffer
 */
public class DepthBuffer {
    /**
     * @brief[zh-cn] 是否锁定
     *
     * @brief[en] Whether locked
     */
    private var locked: Bool = false
    /**
     * @brief[zh-cn] 当前是否反转深度
     *
     * @brief[en] Whether depth is currently reversed
     */
    private var currentReversed: Bool = false
    /**
     * @brief[zh-cn] 当前深度掩码
     *
     * @brief[en] Current depth mask
     */
    private var currentDepthMask: Option<Bool> = None
    /**
     * @brief[zh-cn] 当前深度测试函数
     *
     * @brief[en] Current depth test function
     */
    private var currentDepthFunc: Option<Int64> = None
    /**
     * @brief[zh-cn] 当前深度清除值
     *
     * @brief[en] Current depth clear value
     */
    private var currentDepthClear: Option<Float64> = None

    /**
     * @brief[zh-cn] 设置深度是否反转
     * @param[zh-cn] reversed 是否反转
     *
     * @brief[en] Set whether depth is reversed
     * @param[en] reversed Whether reversed
     */
    public func setReversed(reversed: Bool): Unit {
        currentReversed = reversed
    }

    /**
     * @brief[zh-cn] 获取深度是否反转
     * @return[zh-cn] 是否反转
     *
     * @brief[en] Get whether depth is reversed
     * @return[en] Whether reversed
     */
    public func getReversed(): Bool {
        return currentReversed
    }

    /**
     * @brief[zh-cn] 设置深度测试
     * @explain[zh-cn] bgfx 通过状态标志位控制，此处仅记录状态
     * @param[zh-cn] depthTest 是否启用深度测试
     *
     * @brief[en] Set depth test
     * @explain[en] bgfx controls via state flags, this only records the state
     * @param[en] depthTest Whether to enable depth test
     */
    public func setTest(depthTest: Bool): Unit {
        // bgfx 通过状态标志位控制，此处仅记录状态
    }

    /**
     * @brief[zh-cn] 设置深度掩码
     * @param[zh-cn] depthMask 深度掩码
     *
     * @brief[en] Set depth mask
     * @param[en] depthMask Depth mask
     */
    public func setMask(depthMask: Bool): Unit {
        if (currentDepthMask.getOrThrow() != depthMask && !locked) {
            currentDepthMask = Some(depthMask)
        }
    }

    /**
     * @brief[zh-cn] 设置深度测试函数
     * @param[zh-cn] depthFunc 深度测试函数
     *
     * @brief[en] Set depth test function
     * @param[en] depthFunc Depth test function
     */
    public func setFunc(depthFunc: Int64): Unit {
        if (currentDepthFunc.getOrThrow() != depthFunc) {
            currentDepthFunc = Some(depthFunc)
        }
    }

    /**
     * @brief[zh-cn] 设置锁定状态
     * @param[zh-cn] lock 是否锁定
     *
     * @brief[en] Set locked state
     * @param[en] lock Whether to lock
     */
    public func setLocked(lock: Bool): Unit {
        locked = lock
    }

    /**
     * @brief[zh-cn] 设置深度清除值
     * @param[zh-cn] depth 深度清除值
     *
     * @brief[en] Set depth clear value
     * @param[en] depth Depth clear value
     */
    public func setClear(depth: Float64): Unit {
        if (currentDepthClear.getOrThrow() != depth) {
            currentDepthClear = Some(depth)
        }
    }

    /**
     * @brief[zh-cn] 重置深度缓冲状态
     *
     * @brief[en] Reset depth buffer state
     */
    public func reset(): Unit {
        locked = false
        currentDepthMask = None
        currentDepthFunc = None
        currentDepthClear = None
        currentReversed = false
    }
}

/**
 * @brief[zh-cn] 模板缓冲状态
 * @explain[zh-cn] 对照 WebGLState.StencilBuffer
 *
 * @brief[en] Stencil buffer state
 * @explain[en] Corresponds to WebGLState.StencilBuffer
 */
public class StencilBuffer {
    /**
     * @brief[zh-cn] 是否锁定
     *
     * @brief[en] Whether locked
     */
    private var locked: Bool = false
    /**
     * @brief[zh-cn] 当前模板掩码
     *
     * @brief[en] Current stencil mask
     */
    private var currentStencilMask: Option<Int64> = None
    /**
     * @brief[zh-cn] 当前模板测试函数
     *
     * @brief[en] Current stencil test function
     */
    private var currentStencilFunc: Option<Int64> = None
    /**
     * @brief[zh-cn] 当前模板参考值
     *
     * @brief[en] Current stencil reference value
     */
    private var currentStencilRef: Option<Int64> = None
    /**
     * @brief[zh-cn] 当前模板函数掩码
     *
     * @brief[en] Current stencil function mask
     */
    private var currentStencilFuncMask: Option<Int64> = None
    /**
     * @brief[zh-cn] 当前模板测试失败操作
     *
     * @brief[en] Current stencil fail operation
     */
    private var currentStencilFail: Option<Int64> = None
    /**
     * @brief[zh-cn] 当前模板深度测试失败操作
     *
     * @brief[en] Current stencil depth fail operation
     */
    private var currentStencilZFail: Option<Int64> = None
    /**
     * @brief[zh-cn] 当前模板深度测试通过操作
     *
     * @brief[en] Current stencil depth pass operation
     */
    private var currentStencilZPass: Option<Int64> = None
    /**
     * @brief[zh-cn] 当前模板清除值
     *
     * @brief[en] Current stencil clear value
     */
    private var currentStencilClear: Option<Int64> = None

    /**
     * @brief[zh-cn] 设置模板测试
     * @explain[zh-cn] bgfx 通过状态标志位控制
     * @param[zh-cn] stencilTest 是否启用模板测试
     *
     * @brief[en] Set stencil test
     * @explain[en] bgfx controls via state flags
     * @param[en] stencilTest Whether to enable stencil test
     */
    public func setTest(stencilTest: Bool): Unit {
        // bgfx 通过状态标志位控制，此处仅记录状态
    }

    /**
     * @brief[zh-cn] 设置模板掩码
     * @param[zh-cn] stencilMask 模板掩码
     *
     * @brief[en] Set stencil mask
     * @param[en] stencilMask Stencil mask
     */
    public func setMask(stencilMask: Int64): Unit {
        if (currentStencilMask.getOrThrow() != stencilMask && !locked) {
            currentStencilMask = Some(stencilMask)
        }
    }

    /**
     * @brief[zh-cn] 设置模板测试函数
     * @param[zh-cn] stencilFunc 模板测试函数
     * stencilRef 模板参考值
     * stencilMask 模板函数掩码
     *
     * @brief[en] Set stencil test function
     * @param[en] stencilFunc Stencil test function
     * stencilRef Stencil reference value
     * stencilMask Stencil function mask
     */
    public func setFunc(stencilFunc: Int64, stencilRef: Int64, stencilMask: Int64): Unit {
        if (currentStencilFunc.getOrThrow() != stencilFunc ||
            currentStencilRef.getOrThrow() != stencilRef ||
            currentStencilFuncMask.getOrThrow() != stencilMask) {
            currentStencilFunc = Some(stencilFunc)
            currentStencilRef = Some(stencilRef)
            currentStencilFuncMask = Some(stencilMask)
        }
    }

    /**
     * @brief[zh-cn] 设置模板操作
     * @param[zh-cn] stencilFail 模板测试失败操作
     * stencilZFail 深度测试失败操作
     * stencilZPass 深度测试通过操作
     *
     * @brief[en] Set stencil operation
     * @param[en] stencilFail Stencil fail operation
     * stencilZFail Depth fail operation
     * stencilZPass Depth pass operation
     */
    public func setOp(stencilFail: Int64, stencilZFail: Int64, stencilZPass: Int64): Unit {
        if (currentStencilFail.getOrThrow() != stencilFail ||
            currentStencilZFail.getOrThrow() != stencilZFail ||
            currentStencilZPass.getOrThrow() != stencilZPass) {
            currentStencilFail = Some(stencilFail)
            currentStencilZFail = Some(stencilZFail)
            currentStencilZPass = Some(stencilZPass)
        }
    }

    /**
     * @brief[zh-cn] 设置锁定状态
     * @param[zh-cn] lock 是否锁定
     *
     * @brief[en] Set locked state
     * @param[en] lock Whether to lock
     */
    public func setLocked(lock: Bool): Unit {
        locked = lock
    }

    /**
     * @brief[zh-cn] 设置模板清除值
     * @param[zh-cn] stencil 模板清除值
     *
     * @brief[en] Set stencil clear value
     * @param[en] stencil Stencil clear value
     */
    public func setClear(stencil: Int64): Unit {
        if (currentStencilClear.getOrThrow() != stencil) {
            currentStencilClear = Some(stencil)
        }
    }

    /**
     * @brief[zh-cn] 重置模板缓冲状态
     *
     * @brief[en] Reset stencil buffer state
     */
    public func reset(): Unit {
        locked = false
        currentStencilMask = None
        currentStencilFunc = None
        currentStencilRef = None
        currentStencilFuncMask = None
        currentStencilFail = None
        currentStencilZFail = None
        currentStencilZPass = None
        currentStencilClear = None
    }
}

/**
 * @brief[zh-cn] bgfx 渲染状态管理
 * @explain[zh-cn] 对照 WebGLState，管理混合、深度测试、模板测试、剔除等渲染状态。bgfx 使用状态标志位组合，而非 WebGL 的独立状态调用。此类跟踪当前状态，生成 bgfx 状态标志位
 *
 * @brief[en] bgfx render state management
 * @explain[en] Corresponds to WebGLState, manages blending, depth test, stencil test, culling and other render states. bgfx uses combined state flags instead of WebGL's independent state calls. This class tracks current state and generates bgfx state flags
 */
public class BgfxState {
    /**
     * @brief[zh-cn] 颜色缓冲状态
     *
     * @brief[en] Color buffer state
     */
    public let colorBuffer: ColorBuffer
    /**
     * @brief[zh-cn] 深度缓冲状态
     *
     * @brief[en] Depth buffer state
     */
    public let depthBuffer: DepthBuffer
    /**
     * @brief[zh-cn] 模板缓冲状态
     *
     * @brief[en] Stencil buffer state
     */
    public let stencilBuffer: StencilBuffer

    // 当前状态跟踪
    private var currentBlendingEnabled: Bool = false
    private var currentBlending: Option<Int64> = None
    private var currentBlendEquation: Option<Int64> = None
    private var currentBlendSrc: Option<Int64> = None
    private var currentBlendDst: Option<Int64> = None
    private var currentBlendEquationAlpha: Option<Int64> = None
    private var currentBlendSrcAlpha: Option<Int64> = None
    private var currentBlendDstAlpha: Option<Int64> = None
    private var currentPremultipledAlpha: Bool = false
    private var currentFlipSided: Option<Bool> = None
    private var currentCullFace: Option<Int64> = None
    private var currentLineWidth: Option<Float64> = None
    private var currentPolygonOffsetFactor: Option<Float64> = None
    private var currentPolygonOffsetUnits: Option<Float64> = None
    private var currentProgram: Option<UInt16> = None  // bgfx ProgramHandle

    // 当前视口和裁剪
    private let currentViewport: Vector4 = Vector4()
    private let currentScissor: Vector4 = Vector4()

    // 当前 bgfx 状态标志位
    private var currentState: UInt64 = 0u64

    // 已启用的 GL 能力状态(对照 WebGLState.enabledCapabilities)
    private var enabledCapabilities: HashMap<Int64, Bool> = HashMap<Int64, Bool>()

    public init() {
        this.colorBuffer = ColorBuffer()
        this.depthBuffer = DepthBuffer()
        this.stencilBuffer = StencilBuffer()
        // 初始化默认状态
        this.currentState = BgfxConstants.DEFAULT_STATE
    }

    /**
     * @brief[zh-cn] 启用 GL 状态
     * @explain[zh-cn] 对照 WebGLState.enable()。在 bgfx 中通过状态标志位组合控制，记录已启用的能力
     * @param[zh-cn] id 状态 ID
     *
     * @brief[en] Enable GL state
     * @explain[en] Corresponds to WebGLState.enable(). In bgfx, states are controlled via combined state flags, records enabled capabilities
     * @param[en] id State ID
     */
    public func enable(id: Int64): Unit {
        let enabled = enabledCapabilities.get(id) ?? false
        if (!enabled) {
            enabledCapabilities.add(id, true)
            // 更新状态标志位
            let depthTestLequal = Int64(BgfxConstants.DEPTH_TEST_LEQUAL)
            let cullCw = Int64(BgfxConstants.CULL_CW)
            let blendOne = Int64(BgfxConstants.BLEND_ONE)
            if (id == depthTestLequal) {
                currentState = currentState | BgfxConstants.DEPTH_TEST_LEQUAL
            } else if (id == cullCw) {
                currentState = currentState | BgfxConstants.CULL_CW
            } else if (id == blendOne) {
                if (!currentBlendingEnabled) {
                    currentBlendingEnabled = true
                    currentState = currentState | BgfxConstants.BLEND_ONE
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 禁用 GL 状态
     * @explain[zh-cn] 对照 WebGLState.disable()
     * @param[zh-cn] id 状态 ID
     *
     * @brief[en] Disable GL state
     * @explain[en] Corresponds to WebGLState.disable()
     * @param[en] id State ID
     */
    public func disable(id: Int64): Unit {
        let enabled = enabledCapabilities.get(id) ?? false
        if (enabled) {
            enabledCapabilities.add(id, false)
            // 更新状态标志位
            let depthTestLequal = Int64(BgfxConstants.DEPTH_TEST_LEQUAL)
            let cullCw = Int64(BgfxConstants.CULL_CW)
            let blendOne = Int64(BgfxConstants.BLEND_ONE)
            if (id == depthTestLequal) {
                currentState = currentState & !BgfxConstants.DEPTH_TEST_LEQUAL
            } else if (id == cullCw) {
                currentState = currentState & !BgfxConstants.CULL_CW
            } else if (id == blendOne) {
                if (currentBlendingEnabled) {
                    currentBlendingEnabled = false
                    currentState = currentState & !BgfxConstants.BLEND_ONE
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 获取当前 bgfx 状态标志位
     * @explain[zh-cn] 将所有跟踪的状态组合为一个 UInt64 标志位
     * @return[zh-cn] bgfx 状态标志位
     *
     * @brief[en] Get current bgfx state flags
     * @explain[en] Combines all tracked states into a single UInt64 flag
     * @return[en] bgfx state flags
     */
    public func getState(): UInt64 {
        return currentState
    }

    /**
     * @brief[zh-cn] 设置混合模式
     * @explain[zh-cn] 对照 WebGLState.setBlending()
     * @param[zh-cn] blending 混合模式
     * blendEquation 混合方程
     * blendSrc 源混合因子
     * blendDst 目标混合因子
     * blendEquationAlpha Alpha 混合方程
     * blendSrcAlpha Alpha 源混合因子
     * blendDstAlpha Alpha 目标混合因子
     * premultipliedAlpha 是否预乘 Alpha
     *
     * @brief[en] Set blending mode
     * @explain[en] Corresponds to WebGLState.setBlending()
     * @param[en] blending Blending mode
     * blendEquation Blend equation
     * blendSrc Source blend factor
     * blendDst Destination blend factor
     * blendEquationAlpha Alpha blend equation
     * blendSrcAlpha Alpha source blend factor
     * blendDstAlpha Alpha destination blend factor
     * premultipliedAlpha Whether premultiplied alpha
     */
    public func setBlending(blending: Int64, blendEquation: Int64, blendSrc: Int64, blendDst: Int64,
        blendEquationAlpha: Int64, blendSrcAlpha: Int64, blendDstAlpha: Int64,
        premultipliedAlpha: Bool): Unit {

        if (blending == NoBlending) {
            if (currentBlendingEnabled) {
                currentBlendingEnabled = false
                // 清除混合状态位（保留高32位，清除低32位混合标志）
                currentState = currentState & 0xFFFFFFFF00000000u64
            }
            return
        }

        if (!currentBlendingEnabled) {
            currentBlendingEnabled = true
        }

        if (blending != CustomBlending) {
            if (currentBlending.getOrThrow() != blending || currentPremultipledAlpha != premultipliedAlpha) {
                // 预设混合模式
                var blendState: UInt64 = 0u64
                if (premultipliedAlpha) {
                    if (blending == NormalBlending) {
                        blendState = BgfxConstants.BLEND_ONE | (BgfxConstants.BLEND_ONE_MINUS_SRC_ALPHA << 4u64)
                    } else if (blending == AdditiveBlending) {
                        blendState = BgfxConstants.BLEND_ONE | (BgfxConstants.BLEND_ONE << 4u64)
                    } else if (blending == SubtractiveBlending) {
                        blendState = BgfxConstants.BLEND_ZERO | (BgfxConstants.BLEND_ONE_MINUS_SRC_COLOR << 4u64)
                    } else if (blending == MultiplyBlending) {
                        blendState = BgfxConstants.BLEND_DST_COLOR | (BgfxConstants.BLEND_ONE_MINUS_SRC_ALPHA << 4u64)
                    }
                } else {
                    if (blending == NormalBlending) {
                        blendState = BgfxConstants.BLEND_SRC_ALPHA | (BgfxConstants.BLEND_ONE_MINUS_SRC_ALPHA << 4u64)
                    } else if (blending == AdditiveBlending) {
                        blendState = BgfxConstants.BLEND_SRC_ALPHA | (BgfxConstants.BLEND_ONE << 4u64)
                    } else if (blending == SubtractiveBlending) {
                        blendState = BgfxConstants.BLEND_SRC_ALPHA | (BgfxConstants.BLEND_ONE << 4u64)
                    } else if (blending == MultiplyBlending) {
                        blendState = BgfxConstants.BLEND_DST_COLOR | (BgfxConstants.BLEND_ONE_MINUS_SRC_ALPHA << 4u64)
                    }
                }
                // 设置混合状态
                currentState = (currentState & 0xFFFFFFFF00000000u64) | blendState
                currentBlendSrc = None
                currentBlendDst = None
                currentBlendSrcAlpha = None
                currentBlendDstAlpha = None
                currentBlending = Some(blending)
                currentPremultipledAlpha = premultipliedAlpha
            }
            return
        }

        // 自定义混合
        var bea = blendEquationAlpha
        if (bea == 0) { bea = blendEquation }
        var bsa = blendSrcAlpha
        if (bsa == 0) { bsa = blendSrc }
        var bda = blendDstAlpha
        if (bda == 0) { bda = blendDst }

        if (currentBlendEquation.getOrThrow() != blendEquation || currentBlendEquationAlpha.getOrThrow() != bea) {
            currentBlendEquation = Some(blendEquation)
            currentBlendEquationAlpha = Some(bea)
        }

        if (currentBlendSrc.getOrThrow() != blendSrc || currentBlendDst.getOrThrow() != blendDst ||
            currentBlendSrcAlpha.getOrThrow() != bsa || currentBlendDstAlpha.getOrThrow() != bda) {
            currentBlendSrc = Some(blendSrc)
            currentBlendDst = Some(blendDst)
            currentBlendSrcAlpha = Some(bsa)
            currentBlendDstAlpha = Some(bda)
            // 更新混合状态
            let blendState = BgfxConstants.convertBlendFunc(blendSrc, blendDst, bsa, bda)
            currentState = (currentState & 0xFFFFFFFF00000000u64) | blendState
        }

        currentBlending = Some(blending)
        currentPremultipledAlpha = false
    }

    /**
     * @brief[zh-cn] 设置材质渲染状态
     * @explain[zh-cn] 对照 WebGLState.setMaterial()
     * @param[zh-cn] material 材质对象
     * frontFaceCW 是否正面顺时针
     *
     * @brief[en] Set material render state
     * @explain[en] Corresponds to WebGLState.setMaterial()
     * @param[en] material Material object
     * frontFaceCW Whether front face is clockwise
     */
    public func setMaterial(material: Material, frontFaceCW: Bool): Unit {
        // bgfx 中通过状态标志位组合设置
        // 材质参数需要从 material 对象中读取
        // 此处提供状态设置接口，具体材质参数由 BgfxRenderer 调用时传入
    }

    /**
     * @brief[zh-cn] 设置翻转面
     * @explain[zh-cn] 对照 WebGLState.setFlipSided()
     * @param[zh-cn] flipSided 是否翻转
     *
     * @brief[en] Set flip sided
     * @explain[en] Corresponds to WebGLState.setFlipSided()
     * @param[en] flipSided Whether to flip
     */
    public func setFlipSided(flipSided: Bool): Unit {
        if (currentFlipSided.getOrThrow() != flipSided) {
            if (flipSided) {
                currentState = currentState | BgfxConstants.FRONT_CCW
            } else {
                currentState = currentState & !BgfxConstants.FRONT_CCW
            }
            currentFlipSided = Some(flipSided)
        }
    }

    /**
     * @brief[zh-cn] 设置剔除面
     * @explain[zh-cn] 对照 WebGLState.setCullFace()
     * @param[zh-cn] cullFace 剔除面模式
     *
     * @brief[en] Set cull face
     * @explain[en] Corresponds to WebGLState.setCullFace()
     * @param[en] cullFace Cull face mode
     */
    public func setCullFace(cullFace: Int64): Unit {
        if (cullFace != CullFaceNone) {
            if (currentCullFace.getOrThrow() != cullFace) {
                if (cullFace == CullFaceBack) {
                    currentState = (currentState & !BgfxConstants.CULL_CW & !BgfxConstants.CULL_CCW) | BgfxConstants.CULL_CW
                } else if (cullFace == CullFaceFront) {
                    currentState = (currentState & !BgfxConstants.CULL_CW & !BgfxConstants.CULL_CCW) | BgfxConstants.CULL_CCW
                }
            }
        } else {
            currentState = currentState & !BgfxConstants.CULL_CW & !BgfxConstants.CULL_CCW
        }
        currentCullFace = Some(cullFace)
    }

    /**
     * @brief[zh-cn] 设置线宽
     * @explain[zh-cn] 对照 WebGLState.setLineWidth()
     * @param[zh-cn] width 线宽
     *
     * @brief[en] Set line width
     * @explain[en] Corresponds to WebGLState.setLineWidth()
     * @param[en] width Line width
     */
    public func setLineWidth(width: Float64): Unit {
        currentLineWidth = Some(width)
    }

    /**
     * @brief[zh-cn] 设置多边形偏移
     * @explain[zh-cn] 对照 WebGLState.setPolygonOffset()
     * @param[zh-cn] polygonOffset 是否启用多边形偏移
     * factor 偏移因子
     * units 偏移单位
     *
     * @brief[en] Set polygon offset
     * @explain[en] Corresponds to WebGLState.setPolygonOffset()
     * @param[en] polygonOffset Whether to enable polygon offset
     * factor Offset factor
     * units Offset units
     */
    public func setPolygonOffset(polygonOffset: Bool, factor: Float64, units: Float64): Unit {
        if (polygonOffset) {
            if (currentPolygonOffsetFactor.getOrThrow() != factor || currentPolygonOffsetUnits.getOrThrow() != units) {
                currentPolygonOffsetFactor = Some(factor)
                currentPolygonOffsetUnits = Some(units)
            }
        }
    }

    /**
     * @brief[zh-cn] 设置视口
     * @explain[zh-cn] 对照 WebGLState.viewport()
     * @param[zh-cn] x X 坐标
     * y Y 坐标
     * width 宽度
     * height 高度
     *
     * @brief[en] Set viewport
     * @explain[en] Corresponds to WebGLState.viewport()
     * @param[en] x X coordinate
     * y Y coordinate
     * width Width
     * height Height
     */
    public func setViewport(x: Float64, y: Float64, width: Float64, height: Float64): Unit {
        currentViewport.set(x, y, width, height)
    }

    /**
     * @brief[zh-cn] 设置裁剪测试区域
     * @explain[zh-cn] bgfx 通过 bgfx_set_view_scissor_cj 设置
     * @param[zh-cn] scissorTest 是否启用裁剪测试
     *
     * @brief[en] Set scissor test
     * @explain[en] bgfx sets via bgfx_set_view_scissor_cj
     * @param[en] scissorTest Whether to enable scissor test
     */
    public func setScissorTest(scissorTest: Bool): Unit {
        // bgfx 通过 bgfx_set_view_scissor_cj 设置
    }

    /**
     * @brief[zh-cn] 使用着色器程序
     * @explain[zh-cn] 对照 WebGLState.useProgram()
     * @param[zh-cn] program 着色器程序句柄
     * @return[zh-cn] 是否切换了程序
     *
     * @brief[en] Use shader program
     * @explain[en] Corresponds to WebGLState.useProgram()
     * @param[en] program Shader program handle
     * @return[en] Whether program was switched
     */
    public func useProgram(program: UInt16): Bool {
        if (currentProgram.getOrThrow() != program) {
            currentProgram = Some(program)
            return true
        }
        return false
    }

    /**
     * @brief[zh-cn] 重置所有状态
     * @explain[zh-cn] 对照 WebGLState.reset()
     *
     * @brief[en] Reset all states
     * @explain[en] Corresponds to WebGLState.reset()
     */
    public func reset(): Unit {
        colorBuffer.reset()
        depthBuffer.reset()
        stencilBuffer.reset()
        currentBlendingEnabled = false
        currentBlending = None
        currentBlendEquation = None
        currentBlendSrc = None
        currentBlendDst = None
        currentBlendEquationAlpha = None
        currentBlendSrcAlpha = None
        currentBlendDstAlpha = None
        currentPremultipledAlpha = false
        currentFlipSided = None
        currentCullFace = None
        currentLineWidth = None
        currentPolygonOffsetFactor = None
        currentPolygonOffsetUnits = None
        currentProgram = None
        currentState = BgfxConstants.DEFAULT_STATE
    }
}
