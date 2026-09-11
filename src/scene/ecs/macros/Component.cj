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
 * @file[zh-cn] Component 组件装饰宏
 * @brief[zh-cn] 一个装饰器完成组件类级唯一 ID 的自动登记
 * @explain[zh-cn] 用法：
 *
 * @file[en] Component  Component decorator macro
 * @brief[en] A decorator that auto-registers a class-level unique ID for components
 * @explain[en] Usage:
 *
 * @Component
 * public class PositionCpt <: Component { public var x: Float64 = 0.0 }
 * 展开后注入：
 * private static var _cptId_PositionCpt_<哈希>: Int64 = ComponentRegistry.registerAlloc(...)
 * public static func typeId(): Int64 { _cptId_PositionCpt_<哈希> }
 * public open override prop cptId: Int64 { get() { _cptId_PositionCpt_<哈希> } }
 * 说明：静态访问器命名为 typeId 而非 cptId（仓颉禁止同类中静态成员与实例成员同名）
 * 约束：类必须继承 Component 且非泛型；类必须提供无参构造；使用处需 import three.scene.ecs.*
 * @Component
 * public class PositionCpt <: Component { public var x: Float64 = 0.0 }
 * Injected after expansion:
 * private static var _cptId_PositionCpt_<hash>: Int64 = ComponentRegistry.registerAlloc(...)
 * public static func typeId(): Int64 { _cptId_PositionCpt_<hash> }
 * public open override prop cptId: Int64 { get() { _cptId_PositionCpt_<hash> } }
 * Note: static accessor named typeId instead of cptId (Cangjie forbids same-name static and instance members)
 * Constraints: class must extend Component and be non-generic; must provide no-arg constructor; requires import three.scene.ecs.*
 */
macro package three.scene.ecs.macros

import std.ast.*

/**
 * @brief[zh-cn] 组件装饰宏：自动登记组件类级唯一 ID
 * @param[zh-cn] input 宏输入（类声明 Tokens）
 * @return[zh-cn] 转换后的 Tokens
 *
 * @brief[en] Component decorator macro: auto-registers class-level unique ID for components
 * @param[en] input Macro input (class declaration tokens)
 * @return[en] Transformed tokens
 */
public macro Component(input: Tokens): Tokens {
    let cdOpt = requireClass(input, "Component")
    if (cdOpt.isNone()) {
        return input
    }
    let cd = cdOpt.getOrThrow()
    if (!checkDecoratable(cd, input, "Component", "Component")) {
        return input
    }
    let conflict = findMember(cd, ["cptId", "typeId"])
    if (let Some(n) <- conflict) {
        diagReport(DiagReportLevel.ERROR, input, "@Component 与类内已有成员 ${n} 冲突，请移除该成员",
            "conflicting member ${n}")
        return input
    }
    let field = Token(TokenKind.IDENTIFIER, uniqMemberName(cd, "cptId"))
    let key = uniqKey(cd)
    let ctor = Token(TokenKind.IDENTIFIER, cd.identifier.value)
    // 每类唯一的静态字段：登记类 ID 与无参工厂（静态成员惰性初始化，首次访问即登记）
    cd.body.decls.add(parseDecl(quote(
        private static var $(field): Int64 = ComponentRegistry.registerAlloc($(key), { => $(ctor)() })
    )))
    // 类级静态访问（类型上下文，如 XxxCpt.typeId()）
    cd.body.decls.add(parseDecl(quote(
        public static func typeId(): Int64 {
            $(field)
        }
    )))
    // 实例级多态访问（框架上下文，如 addComponent 内读取）
    // open：允许继承链上的子类再次用 @Component 装饰并重载为自身类 ID
    cd.body.decls.add(parseDecl(quote(
        public open override prop cptId: Int64 {
            get() { $(field) }
        }
    )))
    cd.toTokens()
}
