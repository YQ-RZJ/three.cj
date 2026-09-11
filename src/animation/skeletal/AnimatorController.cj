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
 * @file[zh-cn] AnimatorController
 * @brief[zh-cn] 动画状态机（Animator Controller）
 * @explain[zh-cn] 管理动画状态和状态间过渡。每个状态对应一个动画片段，
 *                  过渡可配置条件（参数触发）和混合时间。
 *                  类似 Unity Animator Controller 的核心功能。
 *
 * @file[en] AnimatorController
 * @brief[en] Animation state machine (Animator Controller)
 * @explain[en] Manages animation states and transitions between them.
 *              Each state maps to an animation clip, transitions support
 *              conditions (parameter triggers) and blend duration.
 */
package three.animation.skeletal

import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 参数类型
 *
 * @brief[en] Parameter type
 */
public enum AnimatorParamType {
    | Boolean
    | Float
    | Int
    | Trigger
}

/**
 * @brief[zh-cn] 动画参数
 *
 * @brief[en] Animation parameter
 */
public class AnimatorParam {
    public var name: String
    public var paramType: AnimatorParamType
    public var boolValue: Bool
    public var floatValue: Float32
    public var intValue: Int

    public init() {
        this.name = ""
        this.paramType = AnimatorParamType.Boolean
        this.boolValue = false
        this.floatValue = 0.0f32
        this.intValue = 0
    }

    public init(name: String, paramType: AnimatorParamType) {
        this.name = name
        this.paramType = paramType
        this.boolValue = false
        this.floatValue = 0.0f32
        this.intValue = 0
    }
}

/**
 * @brief[zh-cn] 过渡条件比较方式
 *
 * @brief[en] Transition condition comparison mode
 */
public enum ConditionMode {
    | If            // bool == true
    | IfNot         // bool == false
    | Greater       // float > threshold
    | Less          // float < threshold
    | Equals        // int == value
    | NotEquals     // int != value
}

/**
 * @brief[zh-cn] 过渡条件
 *
 * @brief[en] Transition condition
 */
public class TransitionCondition {
    public var paramName: String
    public var mode: ConditionMode
    public var threshold: Float32

    public init() {
        this.paramName = ""
        this.mode = ConditionMode.If
        this.threshold = 0.0f32
    }

    public init(paramName: String, mode: ConditionMode, threshold!: Float32 = 0.0f32) {
        this.paramName = paramName
        this.mode = mode
        this.threshold = threshold
    }
}

/**
 * @brief[zh-cn] 动画状态
 *
 * @brief[en] Animation state
 */
public class AnimatorState {
    public var name: String
    public var clipName: String
    public var looping: Bool
    public var speed: Float32
    public var ratio: Float32

    public init() {
        this.name = ""
        this.clipName = ""
        this.looping = true
        this.speed = 1.0f32
        this.ratio = 0.0f32
    }

    public init(name: String, clipName: String, looping!: Bool = true, speed!: Float32 = 1.0f32) {
        this.name = name
        this.clipName = clipName
        this.looping = looping
        this.speed = speed
        this.ratio = 0.0f32
    }
}

/**
 * @brief[zh-cn] 状态过渡定义
 *
 * @brief[en] State transition definition
 */
public class AnimatorTransition {
    public var fromState: String
    public var toState: String
    public var conditions: ArrayList<TransitionCondition>
    public var blendDuration: Float32
    public var exitTime: Float32

    public init() {
        this.fromState = ""
        this.toState = ""
        this.conditions = ArrayList<TransitionCondition>()
        this.blendDuration = 0.25f32
        this.exitTime = 0.0f32
    }

    public init(fromState: String, toState: String, blendDuration!: Float32 = 0.25f32, exitTime!: Float32 = 0.0f32) {
        this.fromState = fromState
        this.toState = toState
        this.conditions = ArrayList<TransitionCondition>()
        this.blendDuration = blendDuration
        this.exitTime = exitTime
    }

    /**
     * @brief[zh-cn] 添加过渡条件
     *
     * @brief[en] Adds a transition condition
     */
    public func addCondition(paramName: String, mode: ConditionMode, threshold!: Float32 = 0.0f32): Unit {
        this.conditions.add(TransitionCondition(paramName, mode, threshold: threshold))
    }
}

/**
 * @brief[zh-cn] 动画状态机控制器
 *
 * @brief[en] Animator state machine controller
 */
public class AnimatorController {
    /**
     * @brief[zh-cn] 状态列表（序列化用）
     *
     * @brief[en] State list (for serialization)
     */
    public var states: HashMap<String, AnimatorState>

    /**
     * @brief[zh-cn] 过渡列表（序列化用）
     *
     * @brief[en] Transition list (for serialization)
     */
    public var transitions: ArrayList<AnimatorTransition>

    /**
     * @brief[zh-cn] 参数列表（序列化用）
     *
     * @brief[en] Parameter list (for serialization)
     */
    public var params: HashMap<String, AnimatorParam>

    /**
     * @brief[zh-cn] 当前状态名称（序列化用）
     *
     * @brief[en] Current state name (for serialization)
     */
    public var currentStateName: String

    /**
     * @brief[zh-cn] 运行时：当前状态引用（不序列化）
     *
     * @brief[en] Runtime: current state reference (not serialized)
     */
    private var _currentState: String

    /**
     * @brief[zh-cn] 是否正在过渡中
     *
     * @brief[en] Whether a transition is in progress
     */
    private var _isTransitioning: Bool

    /**
     * @brief[zh-cn] 过渡进度 [0, 1]
     *
     * @brief[en] Transition progress [0, 1]
     */
    private var _transitionProgress: Float32

    /**
     * @brief[zh-cn] 过渡目标状态名称
     *
     * @brief[en] Transition target state name
     */
    private var _transitionTarget: String

    /**
     * @brief[zh-cn] 当前过渡的混合时间
     *
     * @brief[en] Blend duration of the current transition
     */
    private var _transitionBlendDuration: Float32

    public init() {
        this.states = HashMap<String, AnimatorState>()
        this.transitions = ArrayList<AnimatorTransition>()
        this.params = HashMap<String, AnimatorParam>()
        this.currentStateName = ""
        this._currentState = ""
        this._isTransitioning = false
        this._transitionProgress = 0.0f32
        this._transitionTarget = ""
        this._transitionBlendDuration = 0.0f32
    }

    // ===== 状态管理 =====

    /**
     * @brief[zh-cn] 添加动画状态
     *
     * @brief[en] Adds an animation state
     */
    public func addState(state: AnimatorState): Unit {
        this.states.add(state.name, state)
        if (this._currentState == "") {
            this._currentState = state.name
            this.currentStateName = state.name
        }
    }

    /**
     * @brief[zh-cn] 设置初始状态
     *
     * @brief[en] Sets the default state
     */
    public func setDefaultState(stateName: String): Unit {
        this._currentState = stateName
    }

    /**
     * @brief[zh-cn] 获取当前状态
     *
     * @brief[en] Gets the current state
     */
    public func getCurrentState(): Option<AnimatorState> {
        this.states.get(this._currentState)
    }

    /**
     * @brief[zh-cn] 获取当前状态名称
     *
     * @brief[en] Gets the current state name
     */
    public func getCurrentStateName(): String {
        this._currentState
    }

    // ===== 参数管理 =====

    /**
     * @brief[zh-cn] 添加参数
     *
     * @brief[en] Adds a parameter
     */
    public func addParam(param: AnimatorParam): Unit {
        this.params.add(param.name, param)
    }

    /**
     * @brief[zh-cn] 设置 bool 参数
     *
     * @brief[en] Sets a bool parameter
     */
    public func setBool(name: String, value: Bool): Unit {
        match (this.params.get(name)) {
            case Some(p) => p.boolValue = value
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 设置 float 参数
     *
     * @brief[en] Sets a float parameter
     */
    public func setFloat(name: String, value: Float32): Unit {
        match (this.params.get(name)) {
            case Some(p) => p.floatValue = value
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 设置 int 参数
     *
     * @brief[en] Sets an int parameter
     */
    public func setInt(name: String, value: Int): Unit {
        match (this.params.get(name)) {
            case Some(p) => p.intValue = value
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 触发 trigger 参数（设置后自动在下一帧消费后重置）
     *
     * @brief[en] Triggers a trigger parameter (consumed and auto-reset on the next frame)
     */
    public func setTrigger(name: String): Unit {
        match (this.params.get(name)) {
            case Some(p) => p.boolValue = true
            case None => ()
        }
    }

    // ===== 过渡管理 =====

    /**
     * @brief[zh-cn] 添加状态过渡
     *
     * @brief[en] Adds a state transition
     */
    public func addTransition(transition: AnimatorTransition): Unit {
        this.transitions.add(transition)
    }

    /**
     * @brief[zh-cn] 是否正在过渡中
     *
     * @brief[en] Whether a transition is in progress
     */
    public func isTransitioning(): Bool {
        this._isTransitioning
    }

    /**
     * @brief[zh-cn] 获取过渡混合权重（过渡中时 [0,1]，非过渡时返回 1.0）
     *
     * @brief[en] Gets the transition blend weight ([0,1] while transitioning, 1.0 otherwise)
     */
    public func getTransitionWeight(): Float32 {
        if (this._isTransitioning) {
            this._transitionProgress
        } else {
            1.0f32
        }
    }

    /**
     * @brief[zh-cn] 获取过渡源状态（过渡中时有效）
     *
     * @brief[en] Gets the transition source state (valid while transitioning)
     */
    public func getTransitionSource(): String {
        this._currentState
    }

    /**
     * @brief[zh-cn] 获取过渡目标状态（过渡中时有效）
     *
     * @brief[en] Gets the transition target state (valid while transitioning)
     */
    public func getTransitionTarget(): String {
        this._transitionTarget
    }

    // ===== 更新 =====

    /**
     * @brief[zh-cn] 更新状态机
     * @param[zh-cn] deltaTime 帧间隔时间（秒）
     * @explain[zh-cn] 1. 推进当前状态时间比
     *                  2. 检查过渡条件
     *                  3. 执行过渡（推进混合进度）
     *                  4. 消费 trigger 参数
     *
     * @brief[en] Updates the state machine
     * @param[en] deltaTime Frame interval in seconds
     * @explain[en] 1. Advances the current state's time ratio
     *              2. Checks transition conditions
     *              3. Performs transitions (advances blend progress)
     *              4. Consumes trigger parameters
     */
    public func update(deltaTime: Float32): Unit {
        // 推进当前状态
        match (this.states.get(this._currentState)) {
            case Some(state) =>
                state.ratio += deltaTime * state.speed
                if (state.looping) {
                    // 循环：取模
                    while (state.ratio >= 1.0f32) {
                        state.ratio -= 1.0f32
                    }
                } else {
                    // 钳制
                    state.ratio = min(state.ratio, 1.0f32)
                }
            case None => ()
        }

        // 处理过渡中的状态
        if (this._isTransitioning) {
            this._transitionProgress += deltaTime / this._transitionBlendDuration
            if (this._transitionProgress >= 1.0f32) {
                // 过渡完成
                this._currentState = this._transitionTarget
                this._isTransitioning = false
                this._transitionProgress = 0.0f32
                // 重置目标状态的时间比
                match (this.states.get(this._currentState)) {
                    case Some(state) => state.ratio = 0.0f32
                    case None => ()
                }
            }
            return  // 过渡中不检查新过渡
        }

        // 检查过渡条件
        for (transition in this.transitions) {
            if (transition.fromState != this._currentState) { continue }

            // 检查 exitTime
            match (this.states.get(this._currentState)) {
                case Some(state) =>
                    if (state.ratio < transition.exitTime) { continue }
                case None => continue
            }

            // 检查所有条件
            var allConditionsMet = true
            for (condition in transition.conditions) {
                match (this.params.get(condition.paramName)) {
                    case Some(param) =>
                        var met = false
                        match (condition.mode) {
                            case ConditionMode.If => met = param.boolValue
                            case ConditionMode.IfNot => met = !param.boolValue
                            case ConditionMode.Greater => met = param.floatValue > condition.threshold
                            case ConditionMode.Less => met = param.floatValue < condition.threshold
                            case ConditionMode.Equals => met = Float32(param.intValue) == condition.threshold
                            case ConditionMode.NotEquals => met = Float32(param.intValue) != condition.threshold
                        }
                        if (!met) { allConditionsMet = false }
                    case None => allConditionsMet = false
                }
                if (!allConditionsMet) { break }
            }

            if (allConditionsMet) {
                // 触发过渡
                this._isTransitioning = true
                this._transitionTarget = transition.toState
                this._transitionBlendDuration = transition.blendDuration
                this._transitionProgress = 0.0f32

                // 消费 trigger 参数
                for (condition in transition.conditions) {
                    match (this.params.get(condition.paramName)) {
                        case Some(param) =>
                            match (param.paramType) {
                                case AnimatorParamType.Trigger => param.boolValue = false
                                case _ => ()
                            }
                        case None => ()
                    }
                }
                break
            }
        }
    }
}
