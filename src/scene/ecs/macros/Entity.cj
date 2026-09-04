/**
 * @file[zh-cn] Entity 实体装饰宏
 * @brief[zh-cn] 实体侧的对称标记：校验继承合法性；ID 分配/回收由 Entity 基类自动完成
 * @explain[zh-cn] 实体/系统的实例 ID 由基类 Entity/System 在 init 中分配、destruct 中回收，
 * 无需宏注入任何成员；本宏保留与 @Component/@System 对称的装饰入口，
 * 并对被装饰类做合法性校验（必须继承 three.scene.ecs.Entity、非泛型）
 * 用法：@Entity public class Player <: Entity {}
 *
 * @file[en] Entity  Entity decorator macro
 * @brief[en] Symmetric entity-side marker: validates inheritance legality; ID allocation/release is auto-handled by Entity base class
 * @explain[en] Entity/system instance IDs are allocated in init and released in destruct by the Entity/System base class,
 * no macro-injected members needed; this macro provides a symmetric decorator entry alongside @Component/@System,
 * and validates the decorated class (must extend three.scene.ecs.Entity, non-generic)
 * Usage: @Entity public class Player <: Entity {}
 */
macro package three.scene.ecs.macros

import std.ast.*

/**
 * @brief[zh-cn] 实体装饰宏（标记 + 校验）
 * @param[zh-cn] input 宏输入（类声明 Tokens）
 * @return[zh-cn] 转换后的 Tokens
 *
 * @brief[en] Entity decorator macro (marker + validation)
 * @param[en] input Macro input (class declaration tokens)
 * @return[en] Transformed tokens
 */
public macro Entity(input: Tokens): Tokens {
    if (let Some(cd) <- requireClass(input, "Entity")) {
        checkDecoratable(cd, input, "Entity", "Entity")
    }
    input
}
