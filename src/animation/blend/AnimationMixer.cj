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
 * @file[zh-cn] AnimationMixer 动画混合器
 * @brief[zh-cn] 管理动画混合与播放，是场景中特定对象的动画播放器
 * @explain[zh-cn] 当场景中的多个对象独立动画时，每个对象可以使用一个 AnimationMixer。
 * 它负责激活/停用动画动作、管理属性绑定与控制插值器的内存，
 * 并在每个渲染帧推进全局时间并更新所有动作。
 *
 * @file[en] AnimationMixer  Animation mixer
 * @brief[en] Manages animation mixing and playback; the animation player for a specific object in the scene
 * @explain[en] When multiple objects in a scene are animated independently, each object
 * can use its own AnimationMixer. It activates/deactivates animation actions,
 * manages memory for property bindings and control interpolants, and advances
 * the global time to update all actions each render frame.
 */
package three.animation.blend

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.scene.entity.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.core.math.soa.*
import three.core.math.interpolants.*
import three.utils.constants.*
import three.animation.interfaces.IAnimationClip
import three.animation.skeletal.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 动画混合器，管理一组动画动作的混合播放
 * @explain[zh-cn] 继承自 EventDispatcher，可派发动画事件。维护根对象、动作缓存、
 * 属性绑定缓存与控制插值器缓存，并提供 clipAction/existingAction、
 * update/setTime、stopAllAction 与各种 uncache 内存管理接口。
 *
 * @brief[en] Animation mixer that manages the blended playback of a set of animation actions
 * @explain[en] Extends EventDispatcher and can dispatch animation events. Maintains the
 * root object, action caches, property-binding caches and control-interpolant
 * caches, and exposes clipAction/existingAction, update/setTime, stopAllAction
 * and various uncache memory-management APIs.
 */
public class AnimationMixer <: EventDispatcher {
    /**
     * @brief[zh-cn] 根对象
     *
     * @brief[en] The root object
     */
    private var _root: Object3D

    /**
     * @brief[zh-cn] 活跃动作数量
     *
     * @brief[en] Number of active actions
     */
    private var _nActiveActions: Int64

    /**
     * @brief[zh-cn] 所有动作数组（前 nActiveActions 个为活跃，其余为非活跃）
     *
     * @brief[en] Array of all actions (the first nActiveActions are active, the rest inactive)
     */
    private var _actions: ArrayList<AnimationAction>

    /**
     * @brief[zh-cn] 按 clip UUID 分组的动作映射
     *
     * @brief[en] Action map grouped by clip UUID
     */
    private var _actionsByClip: HashMap<String, HashMap<String, Any>>

    /**
     * @brief[zh-cn] 活跃绑定数量
     *
     * @brief[en] Number of active bindings
     */
    private var _nActiveBindings: Int64

    /**
     * @brief[zh-cn] 所有绑定数组（前 nActiveBindings 个为活跃，其余为非活跃）
     *
     * @brief[en] Array of all bindings (the first nActiveBindings are active, the rest inactive)
     */
    private var _bindings: ArrayList<PropertyMixer>

    /**
     * @brief[zh-cn] 按根对象 UUID 和轨道名分组的绑定映射
     *
     * @brief[en] Binding map grouped by root object UUID and track name
     */
    private var _bindingsByRootAndName: HashMap<String, HashMap<String, PropertyMixer>>

    /**
     * @brief[zh-cn] 活跃控制插值器数量
     *
     * @brief[en] Number of active control interpolants
     */
    private var _nActiveControlInterpolants: Int64

    /**
     * @brief[zh-cn] 所有控制插值器数组
     *
     * @brief[en] Array of all control interpolants
     */
    private var _controlInterpolants: ArrayList<Interpolant>

    /**
     * @brief[zh-cn] 累积索引（0 或 1，帧交替）
     *
     * @brief[en] Accumulation index (0 or 1, alternating each frame)
     */
    private var _accuIndex: Int64

    /**
     * @brief[zh-cn] 骨骼动画数据映射（clip UUID → SkeletalAnimationData）
     * @explain[zh-cn] 由 registerSkeletalData 注册，updateSkeletal 时按 clip UUID 查找。
     *                  避免将骨骼数据挂在 AnimationClip 上造成循环依赖。
     *
     * @brief[en] Skeletal animation data map (clip UUID → SkeletalAnimationData)
     * @explain[en] Registered by registerSkeletalData and looked up by clip UUID in
     *                  updateSkeletal. Avoids attaching skeletal data to AnimationClip,
     *                  which would cause a circular dependency.
     */
    private var _skeletalDataMap: HashMap<String, SkeletalAnimationData>

    /**
     * @brief[zh-cn] 绑定的场景骨骼（可选）
     * @explain[zh-cn] updateSkeletal 计算出模型空间矩阵后，若已绑定场景骨骼，
     *                  则将矩阵分解为局部 TRS 写回对应 Bone 节点，驱动渲染蒙皮。
     *
     * @brief[en] The bound scene skeleton (optional)
     * @explain[en] After updateSkeletal computes model-space matrices, if a scene
     *                  skeleton is bound, the matrices are decomposed into local TRS
     *                  and written back to the corresponding Bone nodes to drive
     *                  render-side skinning.
     */
    private var _sceneSkeleton: ?Skeleton

    /**
     * @brief[zh-cn] 全局混合器时间（秒，从创建时为 0）
     *
     * @brief[en] Global mixer time in seconds, 0 at creation
     */
    public var time: Float64

    /**
     * @brief[zh-cn] 全局时间缩放因子
     *
     * @brief[en] Global time scale factor
     *
     * @note[zh-cn] 设置为 0 再恢复为 1 可暂停/恢复所有动作，默认值为 1
     * @note[en] Setting it to 0 and back to 1 pauses/resumes all actions; defaults to 1
     */
    public var timeScale: Float64

    /**
     * @brief[zh-cn] 统计信息
     *
     * @brief[en] Statistics
     */
    public var stats: HashMap<String, HashMap<String, ()->Int64>>

    /**
     * @brief[zh-cn] 构造一个新的动画混合器
     * @param[zh-cn] root 此混合器播放动画的根对象
     *
     * @brief[en] Constructs a new animation mixer
     * @param[en] root The root object on which this mixer plays animations
     */
    public init(root: Object3D) {
        super()
        this._root = root
        this._nActiveActions = 0
        this._actions = ArrayList<AnimationAction>()
        this._actionsByClip = HashMap<String, HashMap<String, Any>>()
        this._nActiveBindings = 0
        this._bindings = ArrayList<PropertyMixer>()
        this._bindingsByRootAndName = HashMap<String, HashMap<String, PropertyMixer>>()
        this._nActiveControlInterpolants = 0
        this._controlInterpolants = ArrayList<Interpolant>()
        this._accuIndex = 0
        this._skeletalDataMap = HashMap<String, SkeletalAnimationData>()
        this._sceneSkeleton = None
        this.time = 0.0
        this.timeScale = 1.0
        this.stats = HashMap<String, HashMap<String, ()->Int64>>()
    }

    /**
     * @param[zh-cn] action 要绑定的动作
     * @param[zh-cn] prototypeAction 原型动作（用于复用解析路径）
     *
     * 绑定动作到属性混合器
     *
     * @param[en] action The action to bind
     * @param[en] prototypeAction The prototype action (used to reuse parsed paths)
     *
     * Binds an action to the property mixers
     */
    internal func _bindAction(action: AnimationAction, prototypeAction: Option<AnimationAction>): Unit {
        let root = action.getRoot()
        let tracks = action.getClip().tracks
        let nTracks = tracks.size
        let bindings = action._propertyBindings
        let interpolants = action._interpolants
        let rootUuid = root.uuid
        let bindingsByRoot = this._bindingsByRootAndName

        var bindingsByName = bindingsByRoot.get(rootUuid)
        if (bindingsByName.isNone()) {
            bindingsByName = Some(HashMap<String, PropertyMixer>())
            bindingsByRoot.add(rootUuid, bindingsByName.getOrThrow())
        }
        let bindingsByNameVal = bindingsByName.getOrThrow()

        for (i in 0..nTracks) {
            let track = tracks[i]
            let trackName = track.name

            let bindingOpt = bindingsByNameVal.get(trackName)

            if (bindingOpt.isSome()) {
                let binding = bindingOpt.getOrThrow()
                binding.referenceCount += 1
                bindings[i] = binding
            } else {
                let existingBinding = bindings[i]

                if (existingBinding._cacheIndex.isSome()) {
                    // 已有绑定，确保缓存知道
                    existingBinding.referenceCount += 1
                    this._addInactiveBinding(existingBinding, rootUuid, trackName)
                } else {
                    // 创建新绑定
                    let path = match (prototypeAction) {
                        case Some(pa) => pa._propertyBindings[i].binding.parsedPath
                        case None => HashMap<String, Any>()
                    }

                    let createdBinding = PropertyBinding.create(root, trackName, path)
                    let propBinding = match (createdBinding) {
                        case pb: PropertyBinding => pb
                        case _ => PropertyBinding(root, trackName, path)
                    }

                    let binding = PropertyMixer(
                        propBinding,
                        track.ValueTypeName, track.getValueSize()
                    )

                    binding.referenceCount += 1
                    this._addInactiveBinding(binding, rootUuid, trackName)
                    bindings[i] = binding
                }
            }

            interpolants[i].resultBuffer = bindings[i].buffer
        }
    }

    /**
     * @param[zh-cn] action 要激活的动作
     *
     * 激活动作
     *
     * @param[en] action The action to activate
     *
     * Activates an action
     */
    internal func _activateAction(action: AnimationAction): Unit {
        if (!this._isActiveAction(action)) {
            if (action._cacheIndex.isNone()) {
                // 此动作已被缓存遗忘，但用户似乎仍在使用 -> 重新绑定
                let rootUuid = action.getRoot().uuid
                let clipUuid = action.getClip().uuid
                let actionsForClip = this._actionsByClip.get(clipUuid)

                var prototypeAction: Option<AnimationAction> = None
                if (actionsForClip.isSome()) {
                    let knownActionsOpt = actionsForClip.getOrThrow().get("knownActions")
                    match (knownActionsOpt) {
                        case Some(val) =>
                            match (val) {
                                case list: ArrayList<AnimationAction> =>
                                    if (list.size > 0) {
                                        prototypeAction = Some(list[0])
                                    }
                                case _ => ()
                            }
                        case None => ()
                    }
                }

                this._bindAction(action, prototypeAction)
                this._addInactiveAction(action, clipUuid, rootUuid)
            }

            let bindings = action._propertyBindings

            // 递增引用计数 / 排序状态
            for (i in 0..bindings.size) {
                let binding = bindings[i]

                if (binding.useCount == 0) {
                    this._lendBinding(binding)
                    binding.saveOriginalState()
                }

                binding.useCount += 1
            }

            this._lendAction(action)
        }
    }

    /**
     * @param[zh-cn] action 要停用的动作
     *
     * 停用动作
     *
     * @param[en] action The action to deactivate
     *
     * Deactivates an action
     */
    internal func _deactivateAction(action: AnimationAction): Unit {
        if (this._isActiveAction(action)) {
            let bindings = action._propertyBindings

            // 递减引用计数 / 排序状态
            for (i in 0..bindings.size) {
                let binding = bindings[i]

                binding.useCount -= 1

                if (binding.useCount == 0) {
                    binding.restoreOriginalState()
                    this._takeBackBinding(binding)
                }
            }

            this._takeBackAction(action)
        }
    }

    // === 内存管理 ===

    /**
     * 初始化内存管理器（在构造后调用以设置统计信息）
     */
    private func _initMemoryManager(): Unit {
        let scope = this

        let actionsStats = HashMap<String, ()->Int64>()
        actionsStats.add("total", { => scope._actions.size })
        actionsStats.add("inUse", { => scope._nActiveActions })
        this.stats.add("actions", actionsStats)

        let bindingsStats = HashMap<String, ()->Int64>()
        bindingsStats.add("total", { => scope._bindings.size })
        bindingsStats.add("inUse", { => scope._nActiveBindings })
        this.stats.add("bindings", bindingsStats)

        let controlStats = HashMap<String, ()->Int64>()
        controlStats.add("total", { => scope._controlInterpolants.size })
        controlStats.add("inUse", { => scope._nActiveControlInterpolants })
        this.stats.add("controlInterpolants", controlStats)
    }

    // === AnimationAction 内存管理 ===

    /**
     * 判断动作是否活跃
     */
    internal func _isActiveAction(action: AnimationAction): Bool {
        let index = action._cacheIndex
        match (index) {
            case Some(idx) => return idx < this._nActiveActions
            case None => return false
        }
    }

    /**
     * 添加非活跃动作到缓存
     */
    internal func _addInactiveAction(action: AnimationAction, clipUuid: String, rootUuid: String): Unit {
        let actions = this._actions
        let actionsByClip = this._actionsByClip

        let actionsForClipOpt = actionsByClip.get(clipUuid)

        if (actionsForClipOpt.isNone()) {
            let actionsForClip = HashMap<String, Any>()
            let knownActions = ArrayList<AnimationAction>()
            knownActions.add(action)
            action._byClipCacheIndex = Some(0)

            let actionByRoot = HashMap<String, AnimationAction>()
            actionByRoot.add(rootUuid, action)

            actionsForClip.add("knownActions", knownActions)
            actionsForClip.add("actionByRoot", actionByRoot)
            actionsByClip.add(clipUuid, actionsForClip)
        } else {
            let actionsForClip = actionsForClipOpt.getOrThrow()
            let knownActionsOpt = actionsForClip.get("knownActions")
            match (knownActionsOpt) {
                case Some(val) =>
                    match (val) {
                        case list: ArrayList<AnimationAction> =>
                            action._byClipCacheIndex = Some(list.size)
                            list.add(action)
                        case _ => ()
                    }
                case None => ()
            }

            let actionByRootOpt = actionsForClip.get("actionByRoot")
            match (actionByRootOpt) {
                case Some(val) =>
                    match (val) {
                        case map: HashMap<String, AnimationAction> =>
                            map.add(rootUuid, action)
                        case _ => ()
                    }
                case None => ()
            }
        }

        action._cacheIndex = Some(actions.size)
        actions.add(action)
    }

    /**
     * 从缓存中移除非活跃动作
     */
    internal func _removeInactiveAction(action: AnimationAction): Unit {
        let actions = this._actions
        let lastInactiveAction = actions[actions.size - 1]
        let cacheIndexOpt = action._cacheIndex

        match (cacheIndexOpt) {
            case Some(cacheIndex) =>
                lastInactiveAction._cacheIndex = Some(cacheIndex)
                actions[cacheIndex] = lastInactiveAction
                actions.remove(actions.size - 1..actions.size)
            case None => ()
        }

        action._cacheIndex = None

        let clipUuid = action.getClip().uuid
        let actionsByClip = this._actionsByClip
        let actionsForClipOpt = actionsByClip.get(clipUuid)

        match (actionsForClipOpt) {
            case Some(actionsForClip) =>
                let knownActionsOpt = actionsForClip.get("knownActions")
                match (knownActionsOpt) {
                    case Some(val) =>
                        match (val) {
                            case knownActionsForClip: ArrayList<AnimationAction> =>
                                if (knownActionsForClip.size > 0) {
                                    let lastKnownAction = knownActionsForClip[knownActionsForClip.size - 1]
                                    let byClipCacheIndexOpt = action._byClipCacheIndex

                                    match (byClipCacheIndexOpt) {
                                        case Some(byClipCacheIndex) =>
                                            lastKnownAction._byClipCacheIndex = Some(byClipCacheIndex)
                                            if (byClipCacheIndex < knownActionsForClip.size) {
                                                knownActionsForClip[byClipCacheIndex] = lastKnownAction
                                            }
                                        case None => ()
                                    }
                                    knownActionsForClip.remove(knownActionsForClip.size - 1..knownActionsForClip.size)
                                }
                            case _ => ()
                        }
                    case None => ()
                }

                action._byClipCacheIndex = None

                let actionByRootOpt = actionsForClip.get("actionByRoot")
                match (actionByRootOpt) {
                    case Some(val) =>
                        match (val) {
                            case actionByRoot: HashMap<String, AnimationAction> =>
                                let rootUuid = action.getRoot().uuid
                                actionByRoot.remove(rootUuid)

                                if (actionByRoot.size == 0) {
                                    actionsByClip.remove(clipUuid)
                                }
                            case _ => ()
                        }
                    case None => ()
                }
            case None => ()
        }

        this._removeInactiveBindingsForAction(action)
    }

    /**
     * 移除动作关联的非活跃绑定
     */
    internal func _removeInactiveBindingsForAction(action: AnimationAction): Unit {
        let bindings = action._propertyBindings

        for (i in 0..bindings.size) {
            let binding = bindings[i]

            binding.referenceCount -= 1

            if (binding.referenceCount == 0) {
                this._removeInactiveBinding(binding)
            }
        }
    }

    /**
     * 借出动作（从非活跃区移到活跃区）
     */
    internal func _lendAction(action: AnimationAction): Unit {
        // [ active actions |  inactive actions  ]
        // [  active actions >| inactive actions ]
        //                 s        a
        //                  <-swap->
        //                 a        s

        let actions = this._actions
        let prevIndexOpt = action._cacheIndex

        match (prevIndexOpt) {
            case Some(prevIndex) =>
                let lastActiveIndex = this._nActiveActions
                this._nActiveActions += 1

                if (lastActiveIndex < actions.size) {
                    let firstInactiveAction = actions[lastActiveIndex]
                    action._cacheIndex = Some(lastActiveIndex)
                    actions[lastActiveIndex] = action
                    firstInactiveAction._cacheIndex = Some(prevIndex)
                    actions[prevIndex] = firstInactiveAction
                } else {
                    action._cacheIndex = Some(lastActiveIndex)
                    actions.add(action)
                }
            case None => ()
        }
    }

    /**
     * 收回动作（从活跃区移到非活跃区）
     */
    internal func _takeBackAction(action: AnimationAction): Unit {
        // [  active actions  | inactive actions ]
        // [ active actions |< inactive actions  ]
        //        a        s
        //         <-swap->
        //        s        a

        let actions = this._actions
        let prevIndexOpt = action._cacheIndex

        match (prevIndexOpt) {
            case Some(prevIndex) =>
                this._nActiveActions -= 1
                let firstInactiveIndex = this._nActiveActions

                if (firstInactiveIndex < actions.size) {
                    let lastActiveAction = actions[firstInactiveIndex]
                    action._cacheIndex = Some(firstInactiveIndex)
                    actions[firstInactiveIndex] = action
                    lastActiveAction._cacheIndex = Some(prevIndex)
                    actions[prevIndex] = lastActiveAction
                }
            case None => ()
        }
    }

    // === PropertyMixer 内存管理 ===

    /**
     * 添加非活跃绑定到缓存
     */
    internal func _addInactiveBinding(binding: PropertyMixer, rootUuid: String, trackName: String): Unit {
        let bindingsByRoot = this._bindingsByRootAndName
        let bindings = this._bindings

        let bindingByNameOpt = bindingsByRoot.get(rootUuid)

        if (bindingByNameOpt.isNone()) {
            let bindingByName = HashMap<String, PropertyMixer>()
            bindingsByRoot.add(rootUuid, bindingByName)
            bindingByName.add(trackName, binding)
        } else {
            bindingByNameOpt.getOrThrow().add(trackName, binding)
        }

        binding._cacheIndex = Some(bindings.size)
        bindings.add(binding)
    }

    /**
     * 从缓存中移除非活跃绑定
     */
    internal func _removeInactiveBinding(binding: PropertyMixer): Unit {
        let bindings = this._bindings
        let propBinding = binding.binding
        var rootUuid = ""
        match (propBinding.rootNode) {
            case obj: Object3D => rootUuid = obj.uuid
            case _ => ()
        }
        let trackName = propBinding.path
        let bindingsByRoot = this._bindingsByRootAndName

        let bindingByNameOpt = bindingsByRoot.get(rootUuid)
        match (bindingByNameOpt) {
            case Some(bindingByName) =>
                let lastInactiveBinding = bindings[bindings.size - 1]
                let cacheIndexOpt = binding._cacheIndex

                match (cacheIndexOpt) {
                    case Some(cacheIndex) =>
                        lastInactiveBinding._cacheIndex = Some(cacheIndex)
                        bindings[cacheIndex] = lastInactiveBinding
                        bindings.remove(bindings.size - 1..bindings.size)
                    case None => ()
                }

                bindingByName.remove(trackName)

                if (bindingByName.size == 0) {
                    bindingsByRoot.remove(rootUuid)
                }
            case None => ()
        }
    }

    /**
     * 借出绑定（从非活跃区移到活跃区）
     */
    internal func _lendBinding(binding: PropertyMixer): Unit {
        let bindings = this._bindings
        let prevIndexOpt = binding._cacheIndex

        match (prevIndexOpt) {
            case Some(prevIndex) =>
                let lastActiveIndex = this._nActiveBindings
                this._nActiveBindings += 1

                if (lastActiveIndex < bindings.size) {
                    let firstInactiveBinding = bindings[lastActiveIndex]
                    binding._cacheIndex = Some(lastActiveIndex)
                    bindings[lastActiveIndex] = binding
                    firstInactiveBinding._cacheIndex = Some(prevIndex)
                    bindings[prevIndex] = firstInactiveBinding
                } else {
                    binding._cacheIndex = Some(lastActiveIndex)
                    bindings.add(binding)
                }
            case None => ()
        }
    }

    /**
     * 收回绑定（从活跃区移到非活跃区）
     */
    internal func _takeBackBinding(binding: PropertyMixer): Unit {
        let bindings = this._bindings
        let prevIndexOpt = binding._cacheIndex

        match (prevIndexOpt) {
            case Some(prevIndex) =>
                this._nActiveBindings -= 1
                let firstInactiveIndex = this._nActiveBindings

                if (firstInactiveIndex < bindings.size) {
                    let lastActiveBinding = bindings[firstInactiveIndex]
                    binding._cacheIndex = Some(firstInactiveIndex)
                    bindings[firstInactiveIndex] = binding
                    lastActiveBinding._cacheIndex = Some(prevIndex)
                    bindings[prevIndex] = lastActiveBinding
                }
            case None => ()
        }
    }

    // === 控制插值器内存管理 ===

    /**
     * 借出控制插值器
     */
    internal func _lendControlInterpolant(): Interpolant {
        let interpolants = this._controlInterpolants
        let lastActiveIndex = this._nActiveControlInterpolants
        this._nActiveControlInterpolants += 1

        if (lastActiveIndex < interpolants.size) {
            let interpolant = interpolants[lastActiveIndex]
            return interpolant
        }

        // 需要创建新的插值器
        let resultBuffer = Array<Float64>(1, { _ => 0.0 })
        let interpolant = LinearInterpolant(
            Array<Float64>(2, { _ => 0.0 }),
            Array<Float64>(2, { _ => 0.0 }),
            1, Some(resultBuffer)
        )
        interpolant.__cacheIndex = Some(lastActiveIndex)
        interpolants.add(interpolant)
        return interpolant
    }

    /**
     * 收回控制插值器
     */
    internal func _takeBackControlInterpolant(interpolant: Interpolant): Unit {
        let interpolants = this._controlInterpolants
        let prevIndexOpt = interpolant.__cacheIndex

        match (prevIndexOpt) {
            case Some(prevIndex) =>
                this._nActiveControlInterpolants -= 1
                let firstInactiveIndex = this._nActiveControlInterpolants

                if (firstInactiveIndex < interpolants.size) {
                    let lastActiveInterpolant = interpolants[firstInactiveIndex]
                    interpolant.__cacheIndex = Some(firstInactiveIndex)
                    interpolants[firstInactiveIndex] = interpolant
                    lastActiveInterpolant.__cacheIndex = Some(prevIndex)
                    interpolants[prevIndex] = lastActiveInterpolant
                }
            case None => ()
        }
    }

    // === 公共 API ===

    /**
     * @brief[zh-cn] 返回传入剪辑的 AnimationAction 实例
     * @param[zh-cn] clip 动画剪辑
     * optionalRoot 可选的替代根对象，默认为混合器根对象
     * blendMode 混合模式，默认使用剪辑的混合模式
     * @return[zh-cn] 动画动作
     *
     * @brief[en] Returns an AnimationAction for the given clip
     * @param[en] clip The animation clip
     * optionalRoot An optional alternate root object, defaults to the mixer's root
     * blendMode Blend mode, defaults to the clip's blend mode
     * @return[en] The animation action
     *
     * @note[zh-cn] 如果适合 clip 和 root 参数的动作尚不存在，此方法将创建它；
     * 使用相同的 clip 和 root 参数多次调用此方法始终返回相同的动作
     * @note[en] If an action matching the clip and root parameters does not yet exist,
     * it is created; calling repeatedly with the same clip and root always returns
     * the same action
     */
    public func clipAction(clip: IAnimationClip, optionalRoot!: Option<Object3D> = None, blendMode!: Int64 = -1): AnimationAction {
        let root = match (optionalRoot) { case Some(r) => r; case None => this._root }
        let rootUuid = root.uuid

        let clipObject = clip
        let clipUuid = clipObject.uuid

        let actionsForClipOpt = this._actionsByClip.get(clipUuid)
        var prototypeAction: Option<AnimationAction> = None

        var blendModeVal = blendMode
        if (blendModeVal == -1) {
            blendModeVal = clipObject.blendMode
        }

        match (actionsForClipOpt) {
            case Some(actionsForClip) =>
                let actionByRootOpt = actionsForClip.get("actionByRoot")
                match (actionByRootOpt) {
                    case Some(val) =>
                        match (val) {
                            case actionByRoot: HashMap<String, AnimationAction> =>
                                let existingActionOpt = actionByRoot.get(rootUuid)
                                match (existingActionOpt) {
                                    case Some(existingAction) =>
                                        if (existingAction.blendMode == blendModeVal) {
                                            return existingAction
                                        }
                                    case None => ()
                                }
                            case _ => ()
                        }
                    case None => ()
                }

                // 我们知道剪辑，所以不需要重新解析所有绑定，只需复制
                let knownActionsOpt = actionsForClip.get("knownActions")
                match (knownActionsOpt) {
                    case Some(val) =>
                        match (val) {
                            case list: ArrayList<AnimationAction> =>
                                if (list.size > 0) {
                                    prototypeAction = Some(list[0])
                                }
                            case _ => ()
                        }
                    case None => ()
                }
            case None => ()
        }

        // 分配运行所需的所有资源
        let newAction = AnimationAction(this, clipObject, root, blendMode: blendModeVal)

        this._bindAction(newAction, prototypeAction)

        // 使动作对内存管理器已知
        this._addInactiveAction(newAction, clipUuid, rootUuid)

        return newAction
    }

    /**
     * @brief[zh-cn] 返回传入剪辑的现有动画动作
     * @param[zh-cn] clip 动画剪辑
     * optionalRoot 可选的替代根对象，默认为混合器根对象
     * @return[zh-cn] 动画动作，未找到返回 None
     *
     * @brief[en] Returns an existing animation action for the given clip
     * @param[en] clip The animation clip
     * optionalRoot An optional alternate root object, defaults to the mixer's root
     * @return[en] The animation action, or None if not found
     */
    public func existingAction(clip: IAnimationClip, optionalRoot!: Option<Object3D> = None): Option<AnimationAction> {
        let root = match (optionalRoot) { case Some(r) => r; case None => this._root }
        let rootUuid = root.uuid
        let clipUuid = clip.uuid

        let actionsForClipOpt = this._actionsByClip.get(clipUuid)

        match (actionsForClipOpt) {
            case Some(actionsForClip) =>
                let actionByRootOpt = actionsForClip.get("actionByRoot")
                match (actionByRootOpt) {
                    case Some(val) =>
                        match (val) {
                            case actionByRoot: HashMap<String, AnimationAction> =>
                                return actionByRoot.get(rootUuid)
                            case _ => ()
                        }
                    case None => ()
                }
            case None => ()
        }

        return None
    }

    /**
     * @brief[zh-cn] 停用此混合器上所有先前调度的动作
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Deactivates all previously scheduled actions on this mixer
     * @return[en] Returns itself for chaining
     */
    public func stopAllAction(): AnimationMixer {
        let actions = this._actions
        let nActions = this._nActiveActions

        var i = nActions - 1
        while (i >= 0) {
            actions[i].stop()
            i -= 1
        }

        return this
    }

    /**
     * @brief[zh-cn] 推进全局混合器时间并更新动画
     * @param[zh-cn] deltaTime 增量时间（秒）
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Advances the global mixer time and updates the animations
     * @param[en] deltaTime The delta time in seconds
     * @return[en] Returns itself for chaining
     *
     * @note[zh-cn] 通常在渲染循环中通过传递 Clock 或 Timer 的增量时间来调用
     * @note[en] Usually called in the render loop with the delta time of a Clock or Timer
     */
    public func update(deltaTime: Float64): AnimationMixer {
        var dt = deltaTime * this.timeScale

        let actions = this._actions
        let nActions = this._nActiveActions

        let time = this.time + dt
        this.time = time

        let timeDirection = if (dt > 0.0) { 1.0 } else if (dt < 0.0) { -1.0 } else { 0.0 }

        // 帧交替累积索引
        this._accuIndex = this._accuIndex ^ 1

        // 运行活跃动作
        for (i in 0..nActions) {
            actions[i]._update(time, dt, timeDirection, this._accuIndex)
        }

        // 更新场景图
        let bindings = this._bindings
        let nBindings = this._nActiveBindings

        for (i in 0..nBindings) {
            bindings[i].apply(this._accuIndex)
        }

        return this
    }

    /**
     * @brief[zh-cn] 将全局混合器设置为特定时间并相应更新动画
     * @param[zh-cn] time 要设置的时间（秒）
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Sets the global mixer to a specific time and updates the animations accordingly
     * @param[en] time The time to set in seconds
     * @return[en] Returns itself for chaining
     *
     * @note[zh-cn] 当需要跳转到动画中的精确时间时很有用；输入参数将被 AnimationMixer#timeScale 缩放
     * @note[en] Useful when jumping to an exact time in the animation; the input is scaled by AnimationMixer#timeScale
     */
    public func setTime(time: Float64): AnimationMixer {
        this.time = 0.0 // 将 AnimationMixer 对象的时间属性归零

        for (i in 0..this._actions.size) {
            this._actions[i].time = 0.0 // 将所有关联 AnimationAction 对象的时间属性归零
        }

        return this.update(time) // 使用 update 设置精确时间
    }

    /**
     * @brief[zh-cn] 返回此混合器的根对象
     * @return[zh-cn] 根对象
     *
     * @brief[en] Returns the root object of this mixer
     * @return[en] The root object
     */
    public func getRoot(): Object3D {
        return this._root
    }

    /**
     * @brief[zh-cn] 释放剪辑的所有内存资源
     * @param[zh-cn] clip 要取消缓存的剪辑
     *
     * @brief[en] Releases all memory resources of a clip
     * @param[en] clip The clip to uncache
     *
     * @note[zh-cn] 使用此方法前，确保对所有相关动作调用了 AnimationAction#stop
     * @note[en] Make sure to call AnimationAction#stop on all related actions before using this method
     */
    public func uncacheClip(clip: IAnimationClip): Unit {
        let actions = this._actions
        let clipUuid = clip.uuid
        let actionsByClip = this._actionsByClip
        let actionsForClipOpt = actionsByClip.get(clipUuid)

        match (actionsForClipOpt) {
            case Some(actionsForClip) =>
                let knownActionsOpt = actionsForClip.get("knownActions")
                match (knownActionsOpt) {
                    case Some(val) =>
                        match (val) {
                            case actionsToRemove: ArrayList<AnimationAction> =>
                                for (i in 0..actionsToRemove.size) {
                                    let action = actionsToRemove[i]

                                    this._deactivateAction(action)

                                    let cacheIndexOpt = action._cacheIndex
                                    match (cacheIndexOpt) {
                                        case Some(cacheIndex) =>
                                            if (actions.size > 0) {
                                                let lastInactiveAction = actions[actions.size - 1]
                                                action._cacheIndex = None
                                                action._byClipCacheIndex = None

                                                lastInactiveAction._cacheIndex = Some(cacheIndex)
                                                actions[cacheIndex] = lastInactiveAction
                                                actions.remove(actions.size - 1..actions.size)
                                            }
                                        case None => ()
                                    }

                                    this._removeInactiveBindingsForAction(action)
                                }
                            case _ => ()
                        }
                    case None => ()
                }

                actionsByClip.remove(clipUuid)
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 释放根对象的所有内存资源
     * @param[zh-cn] root 要取消缓存的根对象
     *
     * @brief[en] Releases all memory resources of a root object
     * @param[en] root The root object to uncache
     *
     * @note[zh-cn] 使用此方法前，确保对所有相关动作调用了 AnimationAction#stop
     * @note[en] Make sure to call AnimationAction#stop on all related actions before using this method
     */
    public func uncacheRoot(root: Object3D): Unit {
        let rootUuid = root.uuid
        let actionsByClip = this._actionsByClip

        for (clipUuid in actionsByClip.keys()) {
            let actionsForClipOpt = actionsByClip.get(clipUuid)
            match (actionsForClipOpt) {
                case Some(actionsForClip) =>
                    let actionByRootOpt = actionsForClip.get("actionByRoot")
                    match (actionByRootOpt) {
                        case Some(val) =>
                            match (val) {
                                case actionByRoot: HashMap<String, AnimationAction> =>
                                    let actionOpt = actionByRoot.get(rootUuid)
                                    match (actionOpt) {
                                        case Some(action) =>
                                            this._deactivateAction(action)
                                            this._removeInactiveAction(action)
                                        case None => ()
                                    }
                                case _ => ()
                            }
                        case None => ()
                    }
                case None => ()
            }
        }

        let bindingsByRoot = this._bindingsByRootAndName
        let bindingByNameOpt = bindingsByRoot.get(rootUuid)

        match (bindingByNameOpt) {
            case Some(bindingByName) =>
                for (trackName in bindingByName.keys()) {
                    let bindingOpt = bindingByName.get(trackName)
                    match (bindingOpt) {
                        case Some(binding) =>
                            binding.restoreOriginalState()
                            this._removeInactiveBinding(binding)
                        case None => ()
                    }
                }
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 释放动作的所有内存资源
     * @param[zh-cn] clip 动画剪辑
     * optionalRoot 可选的替代根对象，默认为混合器根对象
     *
     * @brief[en] Releases all memory resources of an action
     * @param[en] clip The animation clip
     * optionalRoot An optional alternate root object, defaults to the mixer's root
     *
     * @note[zh-cn] 使用此方法前，确保调用了 AnimationAction#stop 停用动作
     * @note[en] Make sure to call AnimationAction#stop to deactivate the action before using this method
     */
    public func uncacheAction(clip: IAnimationClip, optionalRoot!: Option<Object3D> = None): Unit {
        let actionOpt = this.existingAction(clip, optionalRoot: optionalRoot)

        match (actionOpt) {
            case Some(action) =>
                this._deactivateAction(action)
                this._removeInactiveAction(action)
            case None => ()
        }
    }

    // =========================================================================
    // 骨骼动画 Job 集成（ozz 风格管线：Sampling → Blending → LocalToModel）
    // =========================================================================

    /**
     * @brief[zh-cn] 注册骨骼动画数据
     * @param[zh-cn] clipUUID 动画片段的 UUID
     * @param[zh-cn] data 骨骼动画压缩数据
     *
     * @brief[en] Register skeletal animation data
     * @param[en] clipUUID The UUID of the animation clip
     * @param[en] data Compressed skeletal animation data
     */
    public func registerSkeletalData(clipUUID: String, data: SkeletalAnimationData): Unit {
        if (this._skeletalDataMap.contains(clipUUID)) {
            this._skeletalDataMap.remove(clipUUID)
        }
        this._skeletalDataMap.add(clipUUID, data)
    }

    /**
     * @brief[zh-cn] 绑定场景骨骼
     * @explain[zh-cn] updateSkeletal 计算出模型空间矩阵后，若已绑定场景骨骼，
     *                  则将矩阵分解为相对父关节的局部 TRS 写回对应 Bone 节点，
     *                  驱动渲染侧蒙皮。Bone 数量须与 SkeletonData 关节数一致。
     * @param[zh-cn] skeleton 场景层骨骼对象
     *
     * @brief[en] Bind the scene skeleton
     * @explain[en] After updateSkeletal computes model-space matrices, if a scene
     *                  skeleton is bound, each matrix is decomposed into parent-relative
     *                  local TRS and written back to the corresponding Bone, driving
     *                  render-side skinning. Bone count must match the joint count.
     * @param[en] skeleton The scene-layer skeleton
     */
    public func bindSceneSkeleton(skeleton: Skeleton): Unit {
        this._sceneSkeleton = Some(skeleton)
    }

    /**
     * @brief[zh-cn] 使用骨骼采样/混合 Job 管线更新骨骼动画
     * @explain[zh-cn] 这是 ozz 风格 Job 管线的集成入口。动作时间由 update(deltaTime)
     *                  推进，本方法负责：
     *                  1. 对每个活跃且已注册骨骼数据的动作使用 SamplingJob 采样
     *                  2. 使用 BlendingJob 归一化混合多层动画（无活跃层时回退 rest pose）
     *                  3. 使用 LocalToModelJob 将局部姿态转换为模型空间矩阵
     *                  4. 若已绑定场景骨骼，将模型矩阵分解为局部 TRS 写回 Bone 节点
     *
     * @brief[en] Updates skeletal animation with the sampling/blending job pipeline
     * @explain[en] Ozz-style job pipeline entry. Action time is advanced by
     *                  update(deltaTime); this method samples each active action via
     *                  SamplingJob, blends layers via BlendingJob (falls back to the
     *                  rest pose when no layer is active), converts local poses to
     *                  model-space matrices via LocalToModelJob, and optionally writes
     *                  parent-relative local TRS back to the bound scene skeleton.
     *
     * @param[zh-cn] skeletonData 运行时骨骼数据
     * @param[zh-cn] deltaTime 帧间隔时间（秒），与 update 的入参保持一致
     *
     * @param[en] skeletonData Runtime skeleton data
     * @param[en] deltaTime Frame interval in seconds, same as the update argument
     */
    public func updateSkeletal(skeletonData: SkeletonData, deltaTime: Float32): Unit {
        let numJoints = skeletonData.numJoints()
        if (numJoints <= 0) { return }

        let numSoa = skeletonData.numSoaJoints()
        let restPoses = skeletonData.jointRestPoses()

        // 1. 采样：为每个活跃且已注册骨骼数据的动作构建混合层
        let layers = ArrayList<BlendLayer>()
        for (i in 0..this._nActiveActions) {
            let action = this._actions[i]
            if (!action.enabled) { continue }

            let weight = Float32(action.getEffectiveWeight())
            if (weight <= 0.0f32) { continue }

            let clip = action.getClip()
            let ratio = if (clip.duration > 0.0) {
                max(0.0f32, min(1.0f32, Float32(action.time / clip.duration)))
            } else {
                0.0f32
            }

            match (this._skeletalDataMap.get(clip.uuid)) {
                case Some(data) =>
                    let samplingOutput = Array<SoaTransform>(numSoa, { _ => SoaTransform() })
                    let samplingJob = SamplingJob()
                    samplingJob.ratio = ratio
                    samplingJob.animation = Some(data)
                    samplingJob.context = SamplingContext()
                    samplingJob.output = samplingOutput
                    if (samplingJob.validate() && samplingJob.run()) {
                        let layer = BlendLayer()
                        layer.weight = weight
                        layer.transforms = samplingOutput
                        layers.add(layer)
                    }
                case None => ()  // 未注册骨骼数据的动作跳过
            }
        }

        // 2. 混合：无活跃层时 BlendingJob 对所有关节回退 rest pose
        let blendOutput = Array<SoaTransform>(numSoa, { _ => SoaTransform() })
        let blendingJob = BlendingJob()
        blendingJob.threshold = 0.001f32
        blendingJob.layers = layers
        blendingJob.restPose = restPoses
        blendingJob.output = blendOutput
        if (!blendingJob.run()) { return }

        // 3. 局部空间 → 模型空间
        let modelMatrices = Array<Matrix4F>(numJoints, { _ => Matrix4F() })
        let localToModelJob = LocalToModelJob()
        localToModelJob.skeleton = Some(skeletonData)
        localToModelJob.input = blendOutput
        localToModelJob.output = modelMatrices
        localToModelJob.from = 0
        localToModelJob.to = 0  // <= 0 表示处理到最后一个关节
        if (!localToModelJob.run()) { return }

        // 4. 写回场景骨骼：模型矩阵 → 相对父关节的局部 TRS → Bone 节点
        match (this._sceneSkeleton) {
            case Some(sceneSkeleton) =>
                if (sceneSkeleton.bones.size != numJoints) { return }
                for (joint in 0..numJoints) {
                    let bone = sceneSkeleton.bones[joint]

                    // Float32 模型矩阵 → Float64 场景矩阵
                    let model = Matrix4()
                    model.fromArray(Array<Float64>(16, { e => Float64(modelMatrices[joint].elements[e]) }))

                    // 局部矩阵 = 父模型矩阵的逆 × 当前模型矩阵；根关节直接使用模型矩阵
                    let parentIdx = skeletonData.jointParent(joint)
                    let local = if (parentIdx >= 0) {
                        let parentModel = Matrix4()
                        parentModel.fromArray(
                            Array<Float64>(16, { e => Float64(modelMatrices[parentIdx].elements[e]) }))
                        parentModel.invert()
                        Matrix4().multiplyMatrices(parentModel, model)
                    } else {
                        model
                    }

                    local.decompose(bone.position, bone.quaternion, bone.scale)
                }
            case None => ()
        }
    }
}
