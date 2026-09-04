/**
 * @file[zh-cn] Animation 动画模块父包声明
 * @brief[zh-cn] 本文件仅用于声明 three.animation 包，便于 cjpm 识别 clip/blend 子包
 * @explain[zh-cn] 本包为动画模块的父包锚点，具体实现分布于子包：clip（AnimationClip 与工具函数）、blend（AnimationMixer/AnimationAction/KeyframeTrack/PropertyBinding 等）、tracks（各类关键帧轨道）与 interfaces（跨包解耦契约）。
 *
 * @file[en] Animation  Declaration of the animation module parent package
 * @brief[en] This file only declares the three.animation package so cjpm can recognize the clip/blend subpackages
 * @explain[en] This package is the anchor of the animation module; the actual implementations live in the subpackages: clip (AnimationClip & utilities), blend (AnimationMixer/AnimationAction/KeyframeTrack/PropertyBinding etc.), tracks (various keyframe tracks) and interfaces (cross-package decoupling contracts).
 *
 * @intro[zh-cn] three.animation 提供完整的动画系统，对应 Three.js 的 animation 模块，涵盖动画剪辑（clip）、混合与动作调度（blend）、关键帧轨道（tracks）以及用于解耦循环依赖的接口（interfaces）。
 * @intro[en] three.animation provides a complete animation system mirroring the Three.js animation module, covering animation clips (clip), blending and action scheduling (blend), keyframe tracks (tracks), and the interfaces (interfaces) used to break circular dependencies.
 */
package three.animation
