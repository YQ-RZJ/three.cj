/**
 * @file[zh-cn] ShaderChunks  着色器块系统
 * @brief[zh-cn] 管理 Three.js ShaderChunk 在 bgfx 下的加载和组合
 * @explain[zh-cn] Three.js 使用 #include 宏在运行时组合 GLSL chunk，
 * bgfx 使用 .sc 格式的着色器文件，需要在编译期完成组合。
 * 本模块在运行时模拟 chunk 组合，生成完整的 bgfx 着色器源码。
 *
 * @file[en] ShaderChunks  Shader chunk system
 * @brief[en] Manage Three.js ShaderChunk loading and composition under bgfx
 * @explain[en] Three.js uses #include macros to compose GLSL chunks at runtime,
 * bgfx uses .sc format shader files that require compile-time composition.
 * This module simulates chunk composition at runtime to generate complete bgfx shader source.
 */
package three.rendering.shaders

import std.collection.*
import three.rendering.shaders.ShaderChunk.*
import three.utils.log.Logger

/**
 * @brief[zh-cn] 管理所有着色器块的注册和组合
 *
 * @brief[en] Manage registration and composition of all shader chunks
 */
public class ShaderChunks {
    private static var chunks: HashMap<String, String> = HashMap<String, String>()

    /**
     * @param[zh-cn] name 着色器块名称
     * source 着色器块源码
     *
     * @brief[en] Register a shader chunk
     * @param[en] name Shader chunk name
     * source Shader chunk source code
     */
    public static func define(name: String, source: String): Unit {
        chunks.add(name, source)
        if (chunks.size <= 1) { Logger.debug(["chunks", "first define: '" + name + "' size=" + source.size.toString()]) }
    }

    /**
     * @param[zh-cn] name 着色器块名称
     * @return[zh-cn] 着色器块源码
     *
     * @brief[en] Get shader chunk source by name
     * @param[en] name Shader chunk name
     * @return[en] Shader chunk source code
     */
    public static func get(name: String): String {
        return chunks.get(name).getOrThrow()
    }

    /**
     * @brief[zh-cn] 解析着色器源码中的 #include <name> 指令，递归替换为对应的 chunk 内容
     * @param[zh-cn] source 着色器源码
     * @return[zh-cn] 替换后的完整着色器源码
     *
     * @brief[en] Resolve #include <name> directives in shader source, recursively replacing with corresponding chunk content
     * @param[en] source Shader source code
     * @return[en] Complete shader source code after resolution
     */
    public static func resolve(source: String): String {
        var result = source
        Logger.debug(["chunks", "resolve called, source length=" + source.size.toString() + ", chunks count=" + chunks.size.toString()])
        // Print first include directive found
        let inclIdx = source.indexOf("#include")
        if (inclIdx.isSome()) {
            Logger.debug(["chunks", "first include at " + inclIdx.getOrThrow().toString()])
        }
        var found = true
        while (found) {
            found = false
            let lines = result.split("\n")
            var newLines = ArrayList<String>()
            for (line in lines) {
                let trimmed = line.trimAsciiStart()
                if (trimmed.startsWith("#include <")) {
                    let endIdx = trimmed.indexOf(">")
                    match (endIdx) {
                        case Some(idx) =>
                            let chunkName = trimmed[10..idx]
                            let chunkSrc = chunks.get(chunkName)
                            match (chunkSrc) {
                                case Some(src) =>
                                    newLines.add(src)
                                    found = true
                                case None =>
                                    // 调试：检查 chunk 是否真的不存在
                                    let hasChunk = chunks.contains(chunkName)
                                    Logger.debug(["chunks", "MISSING: '" + chunkName + "' contains=" + hasChunk.toString()])
                                    newLines.add("// MISSING CHUNK: ${chunkName}")
                            }
                        case None =>
                            newLines.add(line)
                    }
                } else {
                    newLines.add(line)
                }
            }
            result = ""
            var first = true
            for (nl in newLines) {
                if (!first) { result += "\n" }
                result += nl
                first = false
            }
        }
        return result
    }

    /**
     * @brief[zh-cn] 注册所有基础着色器块
     *
     * @brief[en] Register all base shader chunks
     */
    public static func initialize(): Unit {
        // common
        ShaderChunks.define("common", common)
        // color_pars_vertex
        ShaderChunks.define("color_pars_vertex", color_pars_vertex)
        // color_vertex
        ShaderChunks.define("color_vertex", color_vertex)
        // uv_pars_vertex
        ShaderChunks.define("uv_pars_vertex", uv_pars_vertex)
        // uv_vertex
        ShaderChunks.define("uv_vertex", uv_vertex)
        // begin_vertex
        ShaderChunks.define("begin_vertex", begin_vertex)
        // beginnormal_vertex
        ShaderChunks.define("beginnormal_vertex", beginnormal_vertex)
        // defaultnormal_vertex
        ShaderChunks.define("defaultnormal_vertex", defaultnormal_vertex)
        // project_vertex
        ShaderChunks.define("project_vertex", project_vertex)
        // worldpos_vertex
        ShaderChunks.define("worldpos_vertex", worldpos_vertex)
        // fog_pars_vertex
        ShaderChunks.define("fog_pars_vertex", fog_pars_vertex)
        // fog_vertex
        ShaderChunks.define("fog_vertex", fog_vertex)
        // clipping_planes_pars_vertex
        ShaderChunks.define("clipping_planes_pars_vertex", clipping_planes_pars_vertex)
        // clipping_planes_vertex
        ShaderChunks.define("clipping_planes_vertex", clipping_planes_vertex)
        // logdepthbuf_pars_vertex
        ShaderChunks.define("logdepthbuf_pars_vertex", logdepthbuf_pars_vertex)
        // logdepthbuf_vertex
        ShaderChunks.define("logdepthbuf_vertex", logdepthbuf_vertex)
        // shadowmap_pars_vertex
        ShaderChunks.define("shadowmap_pars_vertex", shadowmap_pars_vertex)
        // shadowmap_vertex
        ShaderChunks.define("shadowmap_vertex", shadowmap_vertex)
        // envmap_pars_vertex
        ShaderChunks.define("envmap_pars_vertex", envmap_pars_vertex)
        // envmap_vertex
        ShaderChunks.define("envmap_vertex", envmap_vertex)
        // morphinstance_vertex
        ShaderChunks.define("morphinstance_vertex", morphinstance_vertex)
        // morphcolor_vertex
        ShaderChunks.define("morphcolor_vertex", morphcolor_vertex)
        // batching_pars_vertex
        ShaderChunks.define("batching_pars_vertex", batching_pars_vertex)
        // batching_vertex
        ShaderChunks.define("batching_vertex", batching_vertex)
        // skinning_pars_vertex
        ShaderChunks.define("skinning_pars_vertex", skinning_pars_vertex)
        // skinning_vertex
        ShaderChunks.define("skinning_vertex", skinning_vertex)
        // morphtarget_pars_vertex
        ShaderChunks.define("morphtarget_pars_vertex", morphtarget_pars_vertex)
        // morphtarget_vertex
        ShaderChunks.define("morphtarget_vertex", morphtarget_vertex)
        // color_pars_fragment
        ShaderChunks.define("color_pars_fragment", color_pars_fragment)
        // color_fragment
        ShaderChunks.define("color_fragment", color_fragment)
        // map_pars_fragment
        ShaderChunks.define("map_pars_fragment", map_pars_fragment)
        // map_fragment
        ShaderChunks.define("map_fragment", map_fragment)
        // alphamap_pars_fragment
        ShaderChunks.define("alphamap_pars_fragment", alphamap_pars_fragment)
        // alphamap_fragment
        ShaderChunks.define("alphamap_fragment", alphamap_fragment)
        // alphatest_fragment
        ShaderChunks.define("alphatest_fragment", alphatest_fragment)
        // fog_pars_fragment
        ShaderChunks.define("fog_pars_fragment", fog_pars_fragment)
        // fog_fragment
        ShaderChunks.define("fog_fragment", fog_fragment)
        // clipping_planes_pars_fragment
        ShaderChunks.define("clipping_planes_pars_fragment", clipping_planes_pars_fragment)
        // clipping_planes_fragment
        ShaderChunks.define("clipping_planes_fragment", clipping_planes_fragment)
        // logdepthbuf_pars_fragment
        ShaderChunks.define("logdepthbuf_pars_fragment", logdepthbuf_pars_fragment)
        // logdepthbuf_fragment
        ShaderChunks.define("logdepthbuf_fragment", logdepthbuf_fragment)
        // envmap_fragment
        ShaderChunks.define("envmap_fragment", envmap_fragment)
        // lights_pars
        ShaderChunks.define("lights_pars", lights_pars)
        // default_fragment
        ShaderChunks.define("default_fragment", default_fragment)
        // output_fragment
        ShaderChunks.define("output_fragment", output_fragment)
        // tonemapping_fragment
        ShaderChunks.define("tonemapping_fragment", tonemapping_fragment)
        // colorspace_fragment
        ShaderChunks.define("colorspace_fragment", colorspace_fragment)
        // premultiplied_alpha_fragment
        ShaderChunks.define("premultiplied_alpha_fragment", premultiplied_alpha_fragment)
        // encodings_pars_fragment
        ShaderChunks.define("encodings_pars_fragment", encodings_pars_fragment)
        // normal_pars_fragment
        ShaderChunks.define("normal_pars_fragment", normal_pars_fragment)
        // normal_fragment
        ShaderChunks.define("normal_fragment", normal_fragment)
        // lights_fragment
        ShaderChunks.define("lights_fragment", lights_fragment)
        // lights_pars_begin
        ShaderChunks.define("lights_pars_begin", lights_pars_begin)
        // shadowmap_pars_fragment
        ShaderChunks.define("shadowmap_pars_fragment", shadowmap_pars_fragment)
        // shadowmap_fragment
        ShaderChunks.define("shadowmap_fragment", shadowmap_fragment)
        // bsdfs
        ShaderChunks.define("bsdfs", bsdfs)
        // lights_physical_pars_fragment
        ShaderChunks.define("lights_physical_pars_fragment", lights_physical_pars_fragment)
        // lights_physical_fragment
        ShaderChunks.define("lights_physical_fragment", lights_physical_fragment)
        // iridescence_pars_fragment
        ShaderChunks.define("iridescence_pars_fragment", iridescence_pars_fragment)
        // iridescence_fragment
        ShaderChunks.define("iridescence_fragment", iridescence_fragment)
        // clearcoat_pars_fragment
        ShaderChunks.define("clearcoat_pars_fragment", clearcoat_pars_fragment)
        // clearcoat_normal_fragment_begin
        ShaderChunks.define("clearcoat_normal_fragment_begin", clearcoat_normal_fragment_begin)
        // transmission_pars_fragment
        ShaderChunks.define("transmission_pars_fragment", transmission_pars_fragment)
        // transmission_fragment
        ShaderChunks.define("transmission_fragment", transmission_fragment)
        // envmap_pars_fragment
        ShaderChunks.define("envmap_pars_fragment", envmap_pars_fragment)
        // envmap_fragment
        ShaderChunks.define("envmap_fragment", envmap_fragment)
        // envmap_physical_pars_fragment
        ShaderChunks.define("envmap_physical_pars_fragment", envmap_physical_pars_fragment)
        // shadowmap_pars_fragment
        ShaderChunks.define("shadowmap_pars_fragment", shadowmap_pars_fragment)
        // shadowmap_fragment
        ShaderChunks.define("shadowmap_fragment", shadowmap_fragment)
        // normalmap_pars_fragment
        ShaderChunks.define("normalmap_pars_fragment", normalmap_pars_fragment)
        // bumpmap_pars_fragment
        ShaderChunks.define("bumpmap_pars_fragment", bumpmap_pars_fragment)
        // displacementmap_pars_vertex
        ShaderChunks.define("displacementmap_pars_vertex", displacementmap_pars_vertex)
        // emissivemap_pars_fragment
        ShaderChunks.define("emissivemap_pars_fragment", emissivemap_pars_fragment)
        // emissivemap_fragment
        ShaderChunks.define("emissivemap_fragment", emissivemap_fragment)
        // roughnessmap_pars_fragment
        ShaderChunks.define("roughnessmap_pars_fragment", roughnessmap_pars_fragment)
        // metalnessmap_pars_fragment
        ShaderChunks.define("metalnessmap_pars_fragment", metalnessmap_pars_fragment)
        // aomap_pars_fragment
        ShaderChunks.define("aomap_pars_fragment", aomap_pars_fragment)
        // aomap_fragment
        ShaderChunks.define("aomap_fragment", aomap_fragment)
        // specularmap_pars_fragment
        ShaderChunks.define("specularmap_pars_fragment", specularmap_pars_fragment)
        // alphahash
        ShaderChunks.define("alphahash_pars_fragment", alphahash_pars_fragment)
        ShaderChunks.define("alphahash_fragment", alphahash_fragment)
        // alphatest_pars
        ShaderChunks.define("alphatest_pars_fragment", alphatest_pars_fragment)
        // clearcoat_normal_fragment_maps
        ShaderChunks.define("clearcoat_normal_fragment_maps", clearcoat_normal_fragment_maps)
        // colorspace_pars
        ShaderChunks.define("colorspace_pars_fragment", colorspace_pars_fragment)
        // cube_uv_reflection
        ShaderChunks.define("cube_uv_reflection_fragment", cube_uv_reflection_fragment)
        // default_vertex
        ShaderChunks.define("default_vertex", default_vertex)
        // displacementmap_vertex
        ShaderChunks.define("displacementmap_vertex", displacementmap_vertex)
        // dithering
        ShaderChunks.define("dithering_pars_fragment", dithering_pars_fragment)
        ShaderChunks.define("dithering_fragment", dithering_fragment)
        // envmap_common_pars
        ShaderChunks.define("envmap_common_pars_fragment", envmap_common_pars_fragment)
        // gradientmap
        ShaderChunks.define("gradientmap_pars_fragment", gradientmap_pars_fragment)
        // lightmap
        ShaderChunks.define("lightmap_pars_fragment", lightmap_pars_fragment)
        // lightprobes
        ShaderChunks.define("lightprobes_pars_fragment", lightprobes_pars_fragment)
        // lights_fragment
        ShaderChunks.define("lights_fragment_begin", lights_fragment_begin)
        ShaderChunks.define("lights_fragment_end", lights_fragment_end)
        ShaderChunks.define("lights_fragment_maps", lights_fragment_maps)
        // lights_lambert
        ShaderChunks.define("lights_lambert_pars_fragment", lights_lambert_pars_fragment)
        ShaderChunks.define("lights_lambert_fragment", lights_lambert_fragment)
        // lights_phong
        ShaderChunks.define("lights_phong_pars_fragment", lights_phong_pars_fragment)
        ShaderChunks.define("lights_phong_fragment", lights_phong_fragment)
        // lights_toon
        ShaderChunks.define("lights_toon_pars_fragment", lights_toon_pars_fragment)
        ShaderChunks.define("lights_toon_fragment", lights_toon_fragment)
        // map_particle
        ShaderChunks.define("map_particle_pars_fragment", map_particle_pars_fragment)
        ShaderChunks.define("map_particle_fragment", map_particle_fragment)
        // metalnessmap_fragment
        ShaderChunks.define("metalnessmap_fragment", metalnessmap_fragment)
        // morphnormal_vertex
        ShaderChunks.define("morphnormal_vertex", morphnormal_vertex)
        // normal_pars_vertex
        ShaderChunks.define("normal_pars_vertex", normal_pars_vertex)
        // normal_vertex
        ShaderChunks.define("normal_vertex", normal_vertex)
        // normal_fragment_begin
        ShaderChunks.define("normal_fragment_begin", normal_fragment_begin)
        // normal_fragment_maps
        ShaderChunks.define("normal_fragment_maps", normal_fragment_maps)
        // opaque_fragment
        ShaderChunks.define("opaque_fragment", opaque_fragment)
        // packing
        ShaderChunks.define("packing", packing)
        // roughnessmap_fragment
        ShaderChunks.define("roughnessmap_fragment", roughnessmap_fragment)
        // shadowmask_pars_fragment
        ShaderChunks.define("shadowmask_pars_fragment", shadowmask_pars_fragment)
        // skinbase_vertex
        ShaderChunks.define("skinbase_vertex", skinbase_vertex)
        // skinnormal_vertex
        ShaderChunks.define("skinnormal_vertex", skinnormal_vertex)
        // specularmap_fragment
        ShaderChunks.define("specularmap_fragment", specularmap_fragment)
        // uv_pars_fragment
        ShaderChunks.define("uv_pars_fragment", uv_pars_fragment)

        // bgfx 专用 PBR 辅助函数（standard/physical 材质共享）
        ShaderChunks.define("bgfx_pbr_pars", bgfx_pbr_pars)

        // ===== 16-shadowmaps 阴影 chunk 注册 =====
        // 对照 _参考内容/bgfx-知识/examples/16-shadowmaps/
        // shadow_common: PCF/PCSS/VSM/ESM/findBlocker/blur9 核心函数
        ShaderChunks.define("shadow_common", shadow_common)
        // shadow_packdepth_pars: PackDepth/UnpackDepth/HBlur/VBlur chunk
        ShaderChunks.define("shadow_packdepth_vertex", shadow_packdepth_vertex)
        ShaderChunks.define("shadow_packdepth_fragment", shadow_packdepth_fragment)
        ShaderChunks.define("shadow_unpackdepth_fragment", shadow_unpackdepth_fragment)
        ShaderChunks.define("shadow_hblur_fragment", shadow_hblur_fragment)
        ShaderChunks.define("shadow_vblur_fragment", shadow_vblur_fragment)
        ShaderChunks.define("shadow_blur_vertex", shadow_blur_vertex)
    }
}