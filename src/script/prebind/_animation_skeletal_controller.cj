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
 * @file[zh-cn] animation_skeletal_controller 动画状态机（AnimatorParam /
 * TransitionCondition / AnimatorState / AnimatorTransition / AnimatorController）的
 * Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.animation.skeletal 下状态机相关类绑定为 Lua 类型
 * @explain[zh-cn] 各数据类型提供双构造（无参 / 全参）与全部 public 属性；AnimatorController
 * 暴露 addState / setDefaultState / getCurrentState / getCurrentStateName / addParam /
 * setBool / setFloat / setInt / setTrigger / addTransition / isTransitioning /
 * getTransitionWeight / getTransitionSource / getTransitionTarget / update。
 * 三个枚举（AnimatorParamType / ConditionMode）无 Lua 通道，统一以整数读写：
 * 属性 paramType / mode 改经 getXxx / setXxx 方法暴露。
 * 跳过：states / transitions / params（HashMap / ArrayList 容器属性）。
 *
 * @file[en] animation_skeletal_controller  Lua bindings of the animation state machine
 * (AnimatorParam / TransitionCondition / AnimatorState / AnimatorTransition /
 * AnimatorController) (three.script.prebind)
 * @brief[en] Binds the state-machine classes under three.animation.skeletal as Lua types
 * @explain[en] Each data type provides both constructors (parameterless / full) and all public
 * properties; AnimatorController exposes addState / setDefaultState / getCurrentState /
 * getCurrentStateName / addParam / setBool / setFloat / setInt / setTrigger / addTransition /
 * isTransitioning / getTransitionWeight / getTransitionSource / getTransitionTarget / update.
 * The two enums (AnimatorParamType / ConditionMode) have no Lua channel and are read/written as
 * integers: the paramType / mode properties are exposed as getXxx / setXxx methods instead.
 * Skipped: states / transitions / params (HashMap / ArrayList container properties).
 */
package three.script.prebind

import three.animation.skeletal.*
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 由整数值取参数类型枚举（0=Boolean / 1=Float / 2=Int / 3=Trigger；越界回退 Boolean）
 * @param[zh-cn] i 整数值
 * @return[zh-cn] 对应枚举值
 *
 * @brief[en] Maps an integer to the parameter-type enum (0=Boolean / 1=Float / 2=Int / 3=Trigger;
 * falls back to Boolean)
 * @param[en] i The integer value
 * @return[en] The corresponding enum value
 */
private func _prebindParamTypeFrom(i: Int64): AnimatorParamType {
    match (i) {
        case 1 => AnimatorParamType.Float
        case 2 => AnimatorParamType.Int
        case 3 => AnimatorParamType.Trigger
        case _ => AnimatorParamType.Boolean
    }
}

/**
 * @brief[zh-cn] 取参数类型枚举的整数值
 * @param[zh-cn] t 参数类型
 * @return[zh-cn] 整数值（Boolean=0 / Float=1 / Int=2 / Trigger=3）
 *
 * @brief[en] Returns the integer value of a parameter-type enum
 * @param[en] t The parameter type
 * @return[en] The integer value (Boolean=0 / Float=1 / Int=2 / Trigger=3)
 */
private func _prebindParamTypeTo(t: AnimatorParamType): Int64 {
    match (t) {
        case AnimatorParamType.Boolean => 0
        case AnimatorParamType.Float => 1
        case AnimatorParamType.Int => 2
        case AnimatorParamType.Trigger => 3
    }
}

/**
 * @brief[zh-cn] 由整数值取条件比较方式枚举（0=If / 1=IfNot / 2=Greater / 3=Less /
 * 4=Equals / 5=NotEquals；越界回退 If）
 * @param[zh-cn] i 整数值
 * @return[zh-cn] 对应枚举值
 *
 * @brief[en] Maps an integer to the condition-mode enum (0=If / 1=IfNot / 2=Greater / 3=Less /
 * 4=Equals / 5=NotEquals; falls back to If)
 * @param[en] i The integer value
 * @return[en] The corresponding enum value
 */
private func _prebindCondModeFrom(i: Int64): ConditionMode {
    match (i) {
        case 1 => ConditionMode.IfNot
        case 2 => ConditionMode.Greater
        case 3 => ConditionMode.Less
        case 4 => ConditionMode.Equals
        case 5 => ConditionMode.NotEquals
        case _ => ConditionMode.If
    }
}

/**
 * @brief[zh-cn] 取条件比较方式枚举的整数值
 * @param[zh-cn] m 条件比较方式
 * @return[zh-cn] 整数值（If=0 / IfNot=1 / Greater=2 / Less=3 / Equals=4 / NotEquals=5）
 *
 * @brief[en] Returns the integer value of a condition-mode enum
 * @param[en] m The condition mode
 * @return[en] The integer value (If=0 / IfNot=1 / Greater=2 / Less=3 / Equals=4 / NotEquals=5)
 */
private func _prebindCondModeTo(m: ConditionMode): Int64 {
    match (m) {
        case ConditionMode.If => 0
        case ConditionMode.IfNot => 1
        case ConditionMode.Greater => 2
        case ConditionMode.Less => 3
        case ConditionMode.Equals => 4
        case ConditionMode.NotEquals => 5
    }
}

/**
 * @brief[zh-cn] 安装 AnimatorParam 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.skeletal.AnimatorParam）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AnimatorParam
 * @param[en] vm The target virtual machine (class table installed at three.animation.skeletal.AnimatorParam)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAnimatorParam(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.skeletal.AnimatorParam")
    b.constructor {
        args => if (args.size >= 2) {
            AnimatorParam(prebindStr(args, 0), _prebindParamTypeFrom(prebindInt(args, 1)))
        } else {
            AnimatorParam()
        }
    }
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<AnimatorParam>().name)}),
        setter: Some({ref, v => ref.cast<AnimatorParam>().name = v.stringValue()}))
    b.property("boolValue", getter: Some({ref => LuaValue.of(ref.cast<AnimatorParam>().boolValue)}),
        setter: Some({ref, v => ref.cast<AnimatorParam>().boolValue = v.boolValue()}))
    b.property("floatValue", getter: Some({ref => LuaValue.of(Float64(ref.cast<AnimatorParam>().floatValue))}),
        setter: Some({ref, v => ref.cast<AnimatorParam>().floatValue = Float32(v.numberValue())}))
    b.property("intValue", getter: Some({ref => LuaValue.of(Int64(ref.cast<AnimatorParam>().intValue))}),
        setter: Some({ref, v => ref.cast<AnimatorParam>().intValue = Int64(v.intValue())}))
    b.method("getParamType") {
        ref, _ => [LuaValue.of(_prebindParamTypeTo(ref.cast<AnimatorParam>().paramType))]
    }
    b.method("setParamType") {
        ref, args =>
            ref.cast<AnimatorParam>().paramType = _prebindParamTypeFrom(prebindInt(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 TransitionCondition 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.skeletal.TransitionCondition）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of TransitionCondition
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.skeletal.TransitionCondition)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTransitionCondition(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.skeletal.TransitionCondition")
    b.constructor {
        args => if (args.size >= 2) {
            TransitionCondition(prebindStr(args, 0), _prebindCondModeFrom(prebindInt(args, 1)),
                threshold: Float32(prebindNum(args, 2)))
        } else {
            TransitionCondition()
        }
    }
    b.property("paramName", getter: Some({ref => LuaValue.of(ref.cast<TransitionCondition>().paramName)}),
        setter: Some({ref, v => ref.cast<TransitionCondition>().paramName = v.stringValue()}))
    b.property("threshold", getter: Some({ref => LuaValue.of(Float64(ref.cast<TransitionCondition>().threshold))}),
        setter: Some({ref, v => ref.cast<TransitionCondition>().threshold = Float32(v.numberValue())}))
    b.method("getMode") {
        ref, _ => [LuaValue.of(_prebindCondModeTo(ref.cast<TransitionCondition>().mode))]
    }
    b.method("setMode") {
        ref, args =>
            ref.cast<TransitionCondition>().mode = _prebindCondModeFrom(prebindInt(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 AnimatorState 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.skeletal.AnimatorState）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AnimatorState
 * @param[en] vm The target virtual machine (class table installed at three.animation.skeletal.AnimatorState)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAnimatorState(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.skeletal.AnimatorState")
    b.constructor {
        args => if (args.size >= 2) {
            AnimatorState(prebindStr(args, 0), prebindStr(args, 1), looping: prebindBool(args, 2, default: true),
                speed: Float32(prebindNum(args, 3, default: 1.0)))
        } else {
            AnimatorState()
        }
    }
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<AnimatorState>().name)}),
        setter: Some({ref, v => ref.cast<AnimatorState>().name = v.stringValue()}))
    b.property("clipName", getter: Some({ref => LuaValue.of(ref.cast<AnimatorState>().clipName)}),
        setter: Some({ref, v => ref.cast<AnimatorState>().clipName = v.stringValue()}))
    b.property("looping", getter: Some({ref => LuaValue.of(ref.cast<AnimatorState>().looping)}),
        setter: Some({ref, v => ref.cast<AnimatorState>().looping = v.boolValue()}))
    b.property("speed", getter: Some({ref => LuaValue.of(Float64(ref.cast<AnimatorState>().speed))}),
        setter: Some({ref, v => ref.cast<AnimatorState>().speed = Float32(v.numberValue())}))
    b.property("ratio", getter: Some({ref => LuaValue.of(Float64(ref.cast<AnimatorState>().ratio))}),
        setter: Some({ref, v => ref.cast<AnimatorState>().ratio = Float32(v.numberValue())}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 AnimatorTransition 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.skeletal.AnimatorTransition）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AnimatorTransition
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.skeletal.AnimatorTransition)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAnimatorTransition(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.skeletal.AnimatorTransition")
    b.constructor {
        args => if (args.size >= 2) {
            AnimatorTransition(prebindStr(args, 0), prebindStr(args, 1),
                blendDuration: Float32(prebindNum(args, 2, default: 0.25)),
                exitTime: Float32(prebindNum(args, 3, default: 0.0)))
        } else {
            AnimatorTransition()
        }
    }
    b.property("fromState", getter: Some({ref => LuaValue.of(ref.cast<AnimatorTransition>().fromState)}),
        setter: Some({ref, v => ref.cast<AnimatorTransition>().fromState = v.stringValue()}))
    b.property("toState", getter: Some({ref => LuaValue.of(ref.cast<AnimatorTransition>().toState)}),
        setter: Some({ref, v => ref.cast<AnimatorTransition>().toState = v.stringValue()}))
    b.property("blendDuration",
        getter: Some({ref => LuaValue.of(Float64(ref.cast<AnimatorTransition>().blendDuration))}),
        setter: Some({ref, v => ref.cast<AnimatorTransition>().blendDuration = Float32(v.numberValue())}))
    b.property("exitTime", getter: Some({ref => LuaValue.of(Float64(ref.cast<AnimatorTransition>().exitTime))}),
        setter: Some({ref, v => ref.cast<AnimatorTransition>().exitTime = Float32(v.numberValue())}))
    b.method("addCondition") {
        ref, args =>
            ref
                .cast<AnimatorTransition>()
                .addCondition(prebindStr(args, 0), _prebindCondModeFrom(prebindInt(args, 1)),
                    threshold: Float32(prebindNum(args, 2)))
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 AnimatorController 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.skeletal.AnimatorController）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AnimatorController
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.skeletal.AnimatorController)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAnimatorController(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.skeletal.AnimatorController")
    b.constructor {_ => AnimatorController()}
    b.property("currentStateName", getter: Some({ref => LuaValue.of(ref.cast<AnimatorController>().currentStateName)}),
        setter: Some({ref, v => ref.cast<AnimatorController>().currentStateName = v.stringValue()}))
    // ===== 状态与参数注册 =====
    b.method("addState") {
        ref, args =>
            ref.cast<AnimatorController>().addState(prebindAs<AnimatorState>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setDefaultState") {
        ref, args =>
            ref.cast<AnimatorController>().setDefaultState(prebindStr(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("addParam") {
        ref, args =>
            ref.cast<AnimatorController>().addParam(prebindAs<AnimatorParam>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("addTransition") {
        ref, args =>
            ref.cast<AnimatorController>().addTransition(prebindAs<AnimatorTransition>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 参数写入 =====
    b.method("setBool") {
        ref, args =>
            ref.cast<AnimatorController>().setBool(prebindStr(args, 0), prebindBool(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFloat") {
        ref, args =>
            ref.cast<AnimatorController>().setFloat(prebindStr(args, 0), Float32(prebindNum(args, 1)))
            [LuaValue.Object(ref.id)]
    }
    b.method("setInt") {
        ref, args =>
            ref.cast<AnimatorController>().setInt(prebindStr(args, 0), Int64(prebindInt(args, 1)))
            [LuaValue.Object(ref.id)]
    }
    b.method("setTrigger") {
        ref, args =>
            ref.cast<AnimatorController>().setTrigger(prebindStr(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 状态查询 =====
    b.method("getCurrentState") {
        ref, _ => match (ref.cast<AnimatorController>().getCurrentState()) {
            case Some(s) => [prebindRegister(s, "three.animation.skeletal.AnimatorState")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getCurrentStateName") {
        ref, _ => [LuaValue.of(ref.cast<AnimatorController>().getCurrentStateName())]
    }
    b.method("isTransitioning") {
        ref, _ => [LuaValue.of(ref.cast<AnimatorController>().isTransitioning())]
    }
    b.method("getTransitionWeight") {
        ref, _ => [LuaValue.of(Float64(ref.cast<AnimatorController>().getTransitionWeight()))]
    }
    b.method("getTransitionSource") {
        ref, _ => [LuaValue.of(ref.cast<AnimatorController>().getTransitionSource())]
    }
    b.method("getTransitionTarget") {
        ref, _ => [LuaValue.of(ref.cast<AnimatorController>().getTransitionTarget())]
    }
    // ===== 每帧推进 =====
    b.method("update") {
        ref, args =>
            ref.cast<AnimatorController>().update(Float32(prebindNum(args, 0)))
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
