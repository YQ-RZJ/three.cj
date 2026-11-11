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
 * @file[zh-cn] System 系统装饰宏
 * @brief[zh-cn] 以属性传入系统所需组件类列表，自动注入组件掩码收集逻辑
 * @explain[zh-cn] 用法：@System[PositionCpt, VelocityCpt] public class MoveSystem <: System { ... }
 * 展开后注入 collectCptMask override：逐个 mask.set(XxxCpt.typeId(), value: true) + super.collectCptMask(mask)
 * 说明：注入的 override 只触碰各组件类的静态成员，init 期虚分派安全
 * 末尾调用 super.collectCptMask，使系统继承链上各层宏注入的掩码可叠加
 * 属性列表可为空（@System[]），此时不注入任何成员
 * 约束：类必须继承 three.scene.ecs.System 且非泛型；不要自行实现 collectCptMask；
 * 使用处需 import three.scene.ecs.* 与 three.core.dsa.*
 *
 * @file[en] System  System decorator macro
 * @brief[en] Accepts component class list as attributes and auto-injects component mask collection logic
 * @explain[en] Usage: @System[PositionCpt, VelocityCpt] public class MoveSystem <: System { ... }
 * Injects collectCptMask override: mask.set(XxxCpt.typeId(), value: true) for each + super.collectCptMask(mask)
 * Note: injected override only touches static members of component classes, safe for init-time virtual dispatch
 * Calls super.collectCptMask at the end, allowing mask stacking across inheritance chain
 * Attribute list can be empty (@System[]), in which case no members are injected
 * Constraints: class must extend three.scene.ecs.System and be non-generic; do not implement collectCptMask manually;
 * requires import three.scene.ecs.* and three.core.dsa.*
 */
macro package three.scene.ecs.macros

import std.ast.*

/**
 * @brief[zh-cn] 系统装饰宏：登记系统所需组件列表并注入掩码收集
 * @param[zh-cn] attr 属性中的组件类列表（逗号分隔）
 * input 宏输入（类声明 Tokens）
 * @return[zh-cn] 转换后的 Tokens
 *
 * @brief[en] System decorator macro: registers component list and injects mask collection
 * @param[en] attr Component class list in attributes (comma-separated)
 * input Macro input (class declaration tokens)
 * @return[en] Transformed tokens
 */
public macro System(attr: Tokens, input: Tokens): Tokens {
    let cdOpt = requireClass(input, "System")
    if (cdOpt.isNone()) {
        return input
    }
    let cd = cdOpt.getOrThrow()
    if (!checkDecoratable(cd, input, "System", "System")) {
        return input
    }
    // 解析属性中的组件类列表（逗号分隔）
    let cpts = ArrayList<Tokens>()
    var index: Int64 = 0
    while (index < attr.size) {
        let (expr, next) = parseExprFragment(attr, startFrom: index)
        cpts.add(expr.toTokens())
        if (next >= attr.size) {
            break
        }
        if (attr[next].kind != TokenKind.COMMA) {
            diagReport(DiagReportLevel.ERROR, attr[next..next + 1],
                "@System 属性应为逗号分隔的组件类名列表", "Expected comma")
            return input
        }
        index = next + 1 // 跳过逗号
    }
    // 无组件需求：无需注入（基类空实现即可）
    if (cpts.size == 0) {
        return input
    }
    let conflict = findMember(cd, ["collectCptMask"])
    if (let Some(n) <- conflict) {
        diagReport(DiagReportLevel.ERROR, input, "@System 与类内已有成员 ${n} 冲突，请移除该成员",
            "conflicting member ${n}")
        return input
    }
    // 逐语句构造 AST 节点列表（ArrayList<Node> 插值时逐项换行）
    let stmts = ArrayList<Node>()
    for (c in cpts) {
        stmts.add(parseExpr(quote(mask.set($(c).typeId(), value: true))))
    }
    stmts.add(parseExpr(quote(super.collectCptMask(mask))))
    // open：允许继承链上的子类再次用 @System 装饰并叠加掩码
    cd.body.decls.add(parseDecl(quote(
        protected open override func collectCptMask(mask: BitArray): Unit {
            $(stmts)
        }
    )))
    cd.toTokens()
}
