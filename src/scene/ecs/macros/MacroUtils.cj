/**
 * @file[zh-cn] MacroUtils ECS 宏公共工具
 * @brief[zh-cn] 类声明校验、类内唯一成员名生成、成员冲突检测
 * @explain[zh-cn] 提供 ECS 宏共用的 AST 工具函数：requireClass、checkDecoratable、uniqMemberName、uniqKey、findMember
 *
 * @file[en] MacroUtils  ECS macro utilities
 * @brief[en] Class declaration validation, unique member name generation within class, member conflict detection
 * @explain[en] Provides shared AST utility functions for ECS macros: requireClass, checkDecoratable, uniqMemberName, uniqKey, findMember
 */
macro package three.scene.ecs.macros

import std.ast.*

/**
 * @brief[zh-cn] 校验宏输入为类声明
 * @param[zh-cn] input 宏输入
 * macroName 宏名（用于报错信息）
 * @return[zh-cn] 解析成功返回 ClassDecl，否则报错并返回 None
 *
 * @brief[en] Validate macro input as a class declaration
 * @param[en] input Macro input
 * macroName Macro name (used in error messages)
 * @return[en] ClassDecl on success; reports error and returns None on failure
 */
func requireClass(input: Tokens, macroName: String): ?ClassDecl {
    let decl = try {
        parseDecl(input)
    } catch (e: ASTException) {
        diagReport(DiagReportLevel.ERROR, input, "@${macroName} 只能用于 class 声明", "expected a class declaration here")
        return None
    }
    match (decl) {
        case cd: ClassDecl => cd
        case _ =>
            diagReport(DiagReportLevel.ERROR, input, "@${macroName} 只能用于 class 声明", "expected a class declaration here")
            None
    }
}

/**
 * @brief[zh-cn] 校验类声明可装饰（非泛型、有父类型）
 * @param[zh-cn] cd 类声明
 * input 宏输入（用于报错）
 * macroName 宏名
 * @return[zh-cn] 合法返回 true
 *
 * @brief[en] Validate class declaration is decoratable (non-generic, has supertype)
 * @param[en] cd Class declaration
 * input Macro input (used in error messages)
 * macroName Macro name
 * @return[en] true if valid
 */
func checkDecoratable(cd: ClassDecl, input: Tokens, macroName: String, superName: String): Bool {
    if (cd.isGenericDecl) {
        diagReport(DiagReportLevel.ERROR, input, "@${macroName} 不支持泛型类", "generic class is not supported")
        return false
    }
    if (cd.superTypes.size == 0) {
        diagReport(DiagReportLevel.ERROR, input, "@${macroName} 类必须继承 three.scene.ecs.${superName}",
            "missing supertype ${superName}")
        return false
    }
    true
}

/**
 * @brief[zh-cn] 生成类内唯一静态成员名：`_<前缀>_<类名>_<哈希>`
 * @explain[zh-cn] 以"类名 + 定义位置（文件/行/列）"为种子取哈希：
 * - 同一继承链上各宏注入的静态成员名互不相同（类名不同）
 * - 不同文件中同名类注入的成员名也不同（位置不同）
 * 从而规避仓颉"子类不允许声明与父类同名静态成员"的限制
 * @param[zh-cn] cd 类声明
 * prefix 前缀
 * @return[zh-cn] 唯一成员名
 *
 * @brief[en] Generate unique static member name within class: `_<prefix>_<ClassName>_<hash>`
 * @explain[en] Hash seeded by "class name + definition location (file/line/column)":
 * - Macro-injected static member names are unique across the inheritance chain (different class names)
 * - Same-named classes in different files also get different member names (different locations)
 * This avoids Cangjie's restriction "subclasses cannot declare static members with the same name as the parent class"
 * @param[en] cd Class declaration
 * prefix Prefix
 * @return[en] Unique member name
 */
func uniqMemberName(cd: ClassDecl, prefix: String): String {
    let pos = cd.identifier.pos
    let seed = "${prefix}:${cd.identifier.value}:${pos.fileID}:${pos.line}:${pos.column}"
    let h = seed.hashCode() & 0x7FFFFFFFFFFFFFFF
    "_${prefix}_${cd.identifier.value}_${h}"
}

/**
 * @brief[zh-cn] 生成定义点唯一键（用于 ComponentRegistry 幂等登记）
 * @param[zh-cn] cd 类声明
 * @return[zh-cn] 唯一键字符串
 *
 * @brief[en] Generate definition-point unique key (for ComponentRegistry idempotent registration)
 * @param[en] cd Class declaration
 * @return[en] Unique key string
 */
func uniqKey(cd: ClassDecl): String {
    let pos = cd.identifier.pos
    "${cd.identifier.value}#f${pos.fileID}L${pos.line}C${pos.column}"
}

/**
 * @brief[zh-cn] 检查类体是否已存在同名成员（函数/属性/变量）
 * @param[zh-cn] cd 类声明
 * names 待检查的成员名数组
 * @return[zh-cn] 冲突成员名，无冲突返回 None
 *
 * @brief[en] Check if class body already has a member with the same name (function/property/variable)
 * @param[en] cd Class declaration
 * names Array of member names to check
 * @return[en] Conflicting member name, or None if no conflict
 */
func findMember(cd: ClassDecl, names: Array<String>): ?String {
    for (d in cd.body.decls) {
        let n = match (d) {
            case fd: FuncDecl => fd.identifier.value
            case pd: PropDecl => pd.identifier.value
            case vd: VarDecl => vd.identifier.value
            case _ => ""
        }
        if (n != "" && names.contains(n)) {
            return n
        }
    }
    None
}
