/**
 * @file[zh-cn] ShaderVariant  Shader 变体管理
 * @brief[zh-cn] Shader 变体管理：根据材质纹理组合生成编译时 #define 标志
 * @explain[zh-cn] 解决运行时 u_use* 判定的性能开销问题。
 * 思路：按材质实际带有的纹理贴图组合，生成不同的 shader 变体，
 * 在编译时通过 #ifdef USE_XXX 消除分支，实现零运行时开销。
 * 变体数量仅限实际出现的组合，不会 2ⁿ 爆炸。
 *
 * @file[en] ShaderVariant  Shader variant management
 * @brief[en] Shader variant management: generate compile-time #define flags based on material texture combinations
 * @explain[en] Solves the performance overhead of runtime u_use* conditionals.
 * Approach: generate different shader variants based on the material's actual texture combination,
 * using #ifdef USE_XXX at compile time to eliminate branches for zero runtime overhead.
 * Variant count is limited to actually occurring combinations, avoiding 2ⁿ explosion.
 */
package three.rendering.shaders

import std.collection.*
import three.rendering.materials.*

/**
 * @brief[zh-cn] Shader 变体管理器
 *
 * @brief[en] Shader variant manager
 */
public class ShaderVariant {

    /**
     * @brief[zh-cn] 从材质生成变体键（用于缓存）
     * @param[zh-cn] mat 材质
     * @return[zh-cn] 变体键字符串
     *
     * @brief[en] Generate variant key from material (for caching)
     * @param[en] mat Material
     * @return[en] Variant key string
     */
    public static func getVariantKey(mat: Material): String {
        let flags = getActiveTextureFlags(mat)
        if (flags.size == 0) {
            return mat.kind
        }
        let sb = ArrayList<String>()
        sb.add(mat.kind)
        for (flag in flags) {
            sb.add(flag)
        }
        let arr = Array<String>(sb.size, { i => sb[i] })
        return String.join(arr, delimiter: "_")
    }

    /**
     * @brief[zh-cn] 生成 #define 标志字符串数组（如 "USE_MAP=1"）
     * @explain[zh-cn] 安全化说明（对照任务 3 调整建议）：返回仓颉原生 Array<String>，
     * 对外不暴露任何指针 / @C 结构体。调用方把返回的字符串数组直接传给
     * ShaderProgram.compileBgfx(extraDefines: ...)（该接口同样只收 Array<String>），
     * String → CString → CPointer<UInt8> 的指针转换在 compileBgfx 内部完成。
     * @param[zh-cn] mat 材质
     * @return[zh-cn] define 字符串数组（空数组表示无变体标志）
     *
     * @brief[en] Generate #define flag string array (e.g. "USE_MAP=1")
     * @explain[en] Safety note (per task 3 adjustment): returns Cangjie native Array<String>,
     * exposing no pointers / @C structs externally. Callers pass the returned string array
     * directly to ShaderProgram.compileBgfx(extraDefines: ...) (which also accepts Array<String>).
     * String → CString → CPointer<UInt8> pointer conversion is done internally in compileBgfx.
     * @param[en] mat Material
     * @return[en] Define string array (empty array means no variant flags)
     */
    public static func getDefines(mat: Material): Array<String> {
        let flags = getActiveTextureFlags(mat)
        if (flags.size == 0) {
            return Array<String>()
        }
        let defs = ArrayList<String>()
        for (flag in flags) {
            defs.add("USE_" + flag + "=1")
        }
        return defs.toArray()
    }

    /**
     * @brief[zh-cn] 获取激活的纹理标记列表
     * @explain[zh-cn] 注意：返回大写名称，与 ShaderChunk 中的 #ifdef USE_XXX 一致
     * @param[zh-cn] mat 材质
     * @return[zh-cn] 激活的纹理标记数组
     *
     * @brief[en] Get the list of active texture flags
     * @explain[en] Note: returns uppercase names, consistent with #ifdef USE_XXX in ShaderChunks
     * @param[en] mat Material
     * @return[en] Array of active texture flags
     */
    public static func getActiveTextureFlags(mat: Material): Array<String> {
        let flags = ArrayList<String>()
        match (mat) {
            case sm: MeshStandardMaterial =>
                match (sm.map) { case Some(_) => flags.add("MAP"); case None => () }
                match (sm.roughnessMap) { case Some(_) => flags.add("ROUGHNESSMAP"); case None => () }
                match (sm.metalnessMap) { case Some(_) => flags.add("METALNESSMAP"); case None => () }
                match (sm.normalMap) { case Some(_) => flags.add("NORMALMAP"); case None => () }
                match (sm.emissiveMap) { case Some(_) => flags.add("EMISSIVEMAP"); case None => () }
                match (sm.aoMap) { case Some(_) => flags.add("AOMAP"); case None => () }
                match (sm.lightMap) { case Some(_) => flags.add("LIGHTMAP"); case None => () }
            case bm: MeshBasicMaterial =>
                match (bm.map) { case Some(_) => flags.add("MAP"); case None => () }
            case _ => ()
        }
        return flags.toArray()
    }
}
