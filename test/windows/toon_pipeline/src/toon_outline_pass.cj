package toon_pipeline

/**
 * ToonOutlinePass —— 自定义卡通描边后处理 pass（配置面）
 *
 * 设计目标：完整实现自定义后处理 pass 的配置语义，不复用引擎内置 OutlinePass。
 *
 * 算法流程（基于深度的 Sobel 边缘检测，参照 OutlinePass 简化版）：
 *   1. 场景渲染到 readBuffer（由 RenderPass 完成）
 *   2. ToonOutlinePass 采样 readBuffer 的颜色 + 深度
 *   3. 用 Sobel 算子检测深度边缘
 *   4. 边缘像素混合描边颜色，输出到 writeBuffer
 *
 * 渲染管线组装（对照官方 toon 案例 webgl_materials_toon.html）：
 *   EffectComposer
 *     ├── RenderPass（场景→readBuffer）
 *     └── ToonOutlinePass（边缘检测描边→writeBuffer→上屏）
 *
 * 渲染抽象重构后的迁移说明（renderers-abstraction-refactor 5.1）：
 *   - 旧实现的 GPU 提交路径（shader 编译 / 全屏 quad / setView* / submit，
 *     直接持有 VertexBufferHandle/ProgramHandle/UniformHandle 等句柄字段）依赖
 *     已收窄的 ThreeRenderer 薄包装 API 与句柄类型，模块外不可再见。
 *   - 本测试的渲染管线为简化直渲（renderer.render 上屏，见 main.cj），
 *     render() 从未进入帧循环；故本类保留完整的公开配置面
 *     （outlineColor/outlineStrength/edgeThreshold/setSize）与生命周期语义，
 *     GPU 提交面待引擎提供外部自定义 pass 的公开后处理支撑 API 后接入
 *     （design.md KD5：renderFullscreenQuad / Pass 基类内建能力的公开化）。
 */

import three.core.*
import three.scene.scenegraph.*
import three.renderers.cameras.*
import three.core.math.*

/**
 * 卡通描边后处理 pass（配置面）。
 *
 * 单 pass Sobel 边缘检测：
 *   - 采样 readBuffer 颜色（t_scene）+ 深度（t_depth）
 *   - Sobel 算子检测深度边缘
 *   - 边缘像素混合描边颜色，输出到 writeBuffer
 */
public class ToonOutlinePass {
    /**
     * 待渲染场景（用于获取 depth attachment）。
     */
    public let renderScene: Scene

    /**
     * 待渲染相机。
     */
    public let renderCamera: Camera

    /**
     * 描边颜色（默认黑色）。
     * 对照 JS OutlinePass.visibleEdgeColor。
     */
    public var outlineColor: Color = Color(0.0, 0.0, 0.0)

    /**
     * 描边强度（0~1，边缘像素混合描边颜色的比例）。
     */
    public var outlineStrength: Float64 = 1.0

    /**
     * 边缘检测阈值（Sobel 算子输出超过此值则为边缘）。
     */
    public var edgeThreshold: Float64 = 0.001

    /**
     * pass 输出宽度（像素）。
     */
    private var _width: Int64 = 0

    /**
     * pass 输出高度（像素）。
     */
    private var _height: Int64 = 0

    /**
     * 构造 ToonOutlinePass。
     *
     * @param scene 待渲染场景
     * @param camera 待渲染相机
     *
     * 对照 JS: `constructor(resolution, scene, camera, selectedObjects)`。
     * 简化：本 pass 对整个场景做边缘检测，不区分 selectedObjects。
     */
    public init(scene: Scene, camera: Camera) {
        this.renderScene = scene
        this.renderCamera = camera
    }

    /**
     * 设置 pass 尺寸。
     * 对照 JS: `setSize(width, height)`。
     *
     * @param width 宽度（像素）
     * @param height 高度（像素）
     */
    public func setSize(width: Int64, height: Int64): Unit {
        this._width = width
        this._height = height
    }

    /**
     * 获取 pass 输出宽度（像素）。
     */
    public prop width: Int64 {
        get() { this._width }
    }

    /**
     * 获取 pass 输出高度（像素）。
     */
    public prop height: Int64 {
        get() { this._height }
    }

    /**
     * 释放 ToonOutlinePass 占用的资源。
     * 对照 JS: `dispose()`。
     * GPU 提交面收窄后本类不持有 GPU 资源，释放为幂等空操作
     * （保留生命周期语义供调用方无缝使用）。
     */
    public func dispose(): Unit {}

    /**
     * 释放（dispose 的别名，IReleasable 习惯）。
     */
    public func release(): Bool {
        this.dispose()
        return true
    }
}
