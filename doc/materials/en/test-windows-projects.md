# Three.cj Test Project Documentation

This document provides a brief overview of all test projects located under `three/test/windows/`, along with preview screenshots.

> **Note** <br/>
> - Some projects demonstrate capabilities that cannot be perceived through rendered screenshots alone; readers are encouraged to run them directly.
> - Before running any test project, please download the required library files into the `three/libs` directory first.

---

## Table of Contents

- [I. Core Feature Verification](#i-core-feature-verification)
  - [base](#base)
  - [geometries](#geometries)
  - [materials](#materials)
  - [objects](#objects)
  - [textures](#textures)
  - [cubetexture](#cubetexture)
  - [helpers](#helpers)
  - [scenes](#scenes)
  - [rendercommon](#rendercommon)
- [II. Scene & Rendering](#ii-scene--rendering)
  - [boxshow](#boxshow)
  - [depthtest](#depthtest)
  - [particles](#particles)
  - [window](#window)
- [III. Lighting & Shadows](#iii-lighting--shadows)
  - [sp_ambientlight](#sp_ambientlight)
  - [sp_hemispherelight](#sp_hemispherelight)
  - [sp_lightprobe](#sp_lightprobe)
  - [sp_pointshadow](#sp_pointshadow)
  - [sp_spotshadow](#sp_spotshadow)
  - [sp_vsm](#sp_vsm)
- [IV. Shadow Pipeline Debug](#iv-shadow-pipeline-debug)
  - [sp_depth](#sp_depth)
  - [sp_normal](#sp_normal)
  - [sp_wireframe](#sp_wireframe)
  - [sp_lightdir](#sp_lightdir)
  - [sp_shadowfrustum](#sp_shadowfrustum)
  - [sp_shadowmap](#sp_shadowmap)
  - [sp_shadowproj](#sp_shadowproj)
  - [sp_pcf](#sp_pcf)
  - [sp_fullphong](#sp_fullphong)
- [V. Post-Processing Effects](#v-post-processing-effects)
  - [afterimage](#afterimage)
  - [bloom_basic](#bloom_basic)
  - [unreal_bloom](#unreal_bloom)
  - [bokeh_pass](#bokeh_pass)
  - [clearpass](#clearpass)
  - [dotscreen](#dotscreen)
  - [film](#film)
  - [glitch](#glitch)
  - [halftone](#halftone)
  - [lut_pass](#lut_pass)
  - [mask](#mask)
  - [outline](#outline)
  - [outputpass](#outputpass)
  - [pixelated](#pixelated)
  - [savepass](#savepass)
  - [shaderpass](#shaderpass)
  - [sp_texturepass](#sp_texturepass)
  - [transition](#transition)
  - [volumecloud](#volumecloud)
- [VI. Anti-Aliasing](#vi-anti-aliasing)
  - [fxaa](#fxaa)
  - [smaa](#smaa)
  - [ssaa](#ssaa)
  - [taa](#taa)
- [VII. Ambient Occlusion & Reflection](#vii-ambient-occlusion--reflection)
  - [gtao](#gtao)
  - [sao](#sao)
  - [ssao](#ssao)
  - [ssr](#ssr)
- [VIII. Model Loading & Render Pipeline](#viii-model-loading--render-pipeline)
  - [glTFLoader](#gltfloader)
  - [toon_pipeline](#toon_pipeline)
  - [animation](#animation)
- [IX. Engine & Extensions](#ix-engine--extensions)
  - [audio](#audio)
  - [physics](#physics)
  - [gui](#gui)
  - [xrmanager](#xrmanager)

---

## I. Core Feature Verification

### base

> Basic scene setup test that verifies the core rendering pipeline of the three engine.

![base](../../asstes/base.gif)

[Jump to Project Directory](../../../test/windows/base/)

---

### geometries

> Renders all geometry types orbiting around the camera, verifying geometry generation and transformation.

![geometries](../../asstes/geometries.gif)

[Jump to Project Directory](../../../test/windows/geometries/)

---

### materials

> Material rendering test with layered sphere rings and raycasting debug.

![materials](../../asstes/materials.gif)

[Jump to Project Directory](../../../test/windows/materials/)

---

### objects

> Objects package feature verification covering intersectsFrustum / LOD / Mesh / Points / Line / Sprite.

![objects](../../asstes/objects.gif)

[Jump to Project Directory](../../../test/windows/objects/)

---

### textures

> Textures package feature verification testing TextureLoader (PNG) and DataTexture.

![textures](../../asstes/textures.gif)

[Jump to Project Directory](../../../test/windows/textures/)

---

### cubetexture

> CubeTexturePass cubemap background rendering test.

![cubetexture](../../asstes/cubetexture.gif)

[Jump to Project Directory](../../../test/windows/cubetexture/)

---

### helpers

> Helpers module verification with data validation and visual rendering.

![helpers](../../asstes/helpers.gif)

[Jump to Project Directory](../../../test/windows/helpers/)

---

### scenes

> Scenes package feature verification testing Scene / Fog / FogExp2 / background / overrideMaterial.

![scenes](../../asstes/scenes.gif)

[Jump to Project Directory](../../../test/windows/scenes/)

---

### rendercommon

> renderers/common package feature verification.

![rendercommon](../../asstes/rendercommon.gif)

[Jump to Project Directory](../../../test/windows/rendercommon/)

---

## II. Scene & Rendering

### boxshow

> Open-box scene with moving spheres and colored point lights.

![boxshow](../../asstes/boxshow.gif)

[Jump to Project Directory](../../../test/windows/boxshow/)

---

### depthtest

> Depth rendering visualization test based on boxshow.

![depthtest](../../asstes/depthtest.gif)

[Jump to Project Directory](../../../test/windows/depthtest/)

---

### particles

> Points point cloud + Sprite rendering test.

![particles](../../asstes/particles.gif)

[Jump to Project Directory](../../../test/windows/particles/)

---

### window

> WindowEngine + InputEngine + BgfxRenderer window and input integration test.

![window](../../asstes/window.gif)

[Jump to Project Directory](../../../test/windows/window/)

---

## III. Lighting & Shadows

### sp_ambientlight

> AmbientLight test with directional shadow casting.

![sp_ambientlight](../../asstes/sp_ambientlight.gif)

[Jump to Project Directory](../../../test/windows/sp_ambientlight/)

---

### sp_hemispherelight

> HemisphereLight sky-ground gradient lighting test with directional shadow casting.

![sp_hemispherelight](../../asstes/sp_hemispherelight.gif)

[Jump to Project Directory](../../../test/windows/sp_hemispherelight/)

---

### sp_lightprobe

> LightProbe SH3 spherical harmonics test with directional shadow casting.

![sp_lightprobe](../../asstes/sp_lightprobe.gif)

[Jump to Project Directory](../../../test/windows/sp_lightprobe/)

---

### sp_pointshadow

> PointLight cubemap shadow map verification.

![sp_pointshadow](../../asstes/sp_pointshadow.gif)

[Jump to Project Directory](../../../test/windows/sp_pointshadow/)

---

### sp_spotshadow

> SpotLight shadow casting verification.

![sp_spotshadow](../../asstes/sp_spotshadow.gif)

[Jump to Project Directory](../../../test/windows/sp_spotshadow/)

---

### sp_vsm

> VSM (Variance Shadow Mapping) blur pipeline verification.

![sp_vsm](../../asstes/sp_vsm.gif)

[Jump to Project Directory](../../../test/windows/sp_vsm/)

---

## IV. Shadow Pipeline Debug

The shadow pipeline debug projects cover debug modes 1 through 9, used to verify each stage of shadow rendering step by step.

### sp_depth

> Debug Mode 1 — Depth visualization.

![sp_depth](../../asstes/sp_depth.gif)

[Jump to Project Directory](../../../test/windows/sp_depth/)

---

### sp_normal

> Debug Mode 2 — World-space normal visualization.

![sp_normal](../../asstes/sp_normal.gif)

[Jump to Project Directory](../../../test/windows/sp_normal/)

---

### sp_wireframe

> Debug Mode 3 — Wireframe rendering.

![sp_wireframe](../../asstes/sp_wireframe.gif)

[Jump to Project Directory](../../../test/windows/sp_wireframe/)

---

### sp_lightdir

> Debug Mode 4 — N dot L lighting direction (no ambient).

![sp_lightdir](../../asstes/sp_lightdir.gif)

[Jump to Project Directory](../../../test/windows/sp_lightdir/)

---

### sp_shadowfrustum

> Debug Mode 5 — Shadow camera frustum visualization.

![sp_shadowfrustum](../../asstes/sp_shadowfrustum.gif)

[Jump to Project Directory](../../../test/windows/sp_shadowfrustum/)

---

### sp_shadowmap

> Debug Mode 6 — Shadow map blit to screen.

![sp_shadowmap](../../asstes/sp_shadowmap.gif)

[Jump to Project Directory](../../../test/windows/sp_shadowmap/)

---

### sp_shadowproj

> Debug Mode 7 — ShadowMatrix projection UV visualization.

![sp_shadowproj](../../asstes/sp_shadowproj.gif)

[Jump to Project Directory](../../../test/windows/sp_shadowproj/)

---

### sp_pcf

> Debug Mode 8 — PCF shadow sampling result.

![sp_pcf](../../asstes/sp_pcf.gif)

[Jump to Project Directory](../../../test/windows/sp_pcf/)

---

### sp_fullphong

> Debug Mode 9 — Baseline full Phong lighting.

![sp_fullphong](../../asstes/sp_fullphong.gif)

[Jump to Project Directory](../../../test/windows/sp_fullphong/)

---

## V. Post-Processing Effects

### afterimage

> AfterimagePass trailing image post-processing effect.

![afterimage](../../asstes/afterimage.gif)

[Jump to Project Directory](../../../test/windows/afterimage/)

---

### bloom_basic

> Basic Bloom post-processing (migrated from three.js BloomPass).

![bloom_basic](../../asstes/bloom_basic.gif)

[Jump to Project Directory](../../../test/windows/bloom_basic/)

---

### unreal_bloom

> UnrealBloom glowing spheres post-processing effect.

![unreal_bloom](../../asstes/unreal_bloom.gif)

[Jump to Project Directory](../../../test/windows/unreal_bloom/)

---

### bokeh_pass

> BokehPass depth-of-field bokeh post-processing.

![bokeh_pass](../../asstes/bokeh_pass.gif)

[Jump to Project Directory](../../../test/windows/bokeh_pass/)

---

### clearpass

> ClearPass infrastructure post-processing test.

![clearpass](../../asstes/clearpass.gif)

[Jump to Project Directory](../../../test/windows/clearpass/)

---

### dotscreen

> DotScreenPass dot-screen post-processing effect.

![dotscreen](../../asstes/dotscreen.gif)

[Jump to Project Directory](../../../test/windows/dotscreen/)

---

### film

> FilmPass film grain post-processing effect.

![film](../../asstes/film.gif)

[Jump to Project Directory](../../../test/windows/film/)

---

### glitch

> GlitchPass digital glitch post-processing effect.

![glitch](../../asstes/glitch.gif)

[Jump to Project Directory](../../../test/windows/glitch/)

---

### halftone

> HalftonePass RGB halftone post-processing effect.

![halftone](../../asstes/halftone.gif)

[Jump to Project Directory](../../../test/windows/halftone/)

---

### lut_pass

> LUTPass 3D lookup table color grading test.

![lut_pass](../../asstes/lut_pass.gif)

[Jump to Project Directory](../../../test/windows/lut_pass/)

---

### mask

> MaskPass + ClearMaskPass stencil mask control test.

![mask](../../asstes/mask.gif)

[Jump to Project Directory](../../../test/windows/mask/)

---

### outline

> OutlinePass outline post-processing effect.

![outline](../../asstes/outline.gif)

[Jump to Project Directory](../../../test/windows/outline/)

---

### outputpass

> OutputPass tone mapping + sRGB post-processing test.

![outputpass](../../asstes/outputpass.gif)

[Jump to Project Directory](../../../test/windows/outputpass/)

---

### pixelated

> RenderPixelatedPass pixelated rendering effect.

![pixelated](../../asstes/pixelated.gif)

[Jump to Project Directory](../../../test/windows/pixelated/)

---

### savepass

> SavePass buffer snapshot post-processing test.

![savepass](../../asstes/savepass.gif)

[Jump to Project Directory](../../../test/windows/savepass/)

---

### shaderpass

> ShaderPass generic shader post-processing test.

![shaderpass](../../asstes/shaderpass.gif)

[Jump to Project Directory](../../../test/windows/shaderpass/)

---

### sp_texturepass

> TexturePass fullscreen texture post-processing test.

![sp_texturepass](../../asstes/sp_texturepass.gif)

[Jump to Project Directory](../../../test/windows/sp_texturepass/)

---

### transition

> RenderTransitionPass scene transition rendering test.

![transition](../../asstes/transition.gif)

[Jump to Project Directory](../../../test/windows/transition/)

---

### volumecloud

> VolumeCloudPass volumetric cloud post-processing effect.

![volumecloud](../../asstes/volumecloud.gif)

[Jump to Project Directory](../../../test/windows/volumecloud/)

---

## VI. Anti-Aliasing

### fxaa

> FXAA fast approximate anti-aliasing.

![fxaa](../../asstes/fxaa.gif)

[Jump to Project Directory](../../../test/windows/fxaa/)

---

### smaa

> SMAA subpixel morphological anti-aliasing.

![smaa](../../asstes/smaa.gif)

[Jump to Project Directory](../../../test/windows/smaa/)

---

### ssaa

> SSAA supersample anti-aliasing.

![ssaa](../../asstes/ssaa.gif)

[Jump to Project Directory](../../../test/windows/ssaa/)

---

### taa

> TAA temporal anti-aliasing.

![taa](../../asstes/taa.gif)

[Jump to Project Directory](../../../test/windows/taa/)

---

## VII. Ambient Occlusion & Reflection

### gtao

> GTAO ground truth ambient occlusion test.

![gtao](../../asstes/gtao.gif)

[Jump to Project Directory](../../../test/windows/gtao/)

---

### sao

> SAO scale-aware ambient occlusion test.

![sao](../../asstes/sao.gif)

[Jump to Project Directory](../../../test/windows/sao/)

---

### ssao

> SSAO screen-space ambient occlusion test.

![ssao](../../asstes/ssao.gif)

[Jump to Project Directory](../../../test/windows/ssao/)

---

### ssr

> SSR screen-space reflection test.

![ssr](../../asstes/ssr.gif)

[Jump to Project Directory](../../../test/windows/ssr/)

---

## VIII. Model Loading & Render Pipeline

### glTFLoader

> glTF/GLB model loader test.

![glTFLoader](../../asstes/glTFLoader.gif)

[Jump to Project Directory](../../../test/windows/glTFLoader/)

---

### toon_pipeline

> Custom toon shading render pipeline test.

![toon_pipeline](../../asstes/toon_pipeline.gif)

[Jump to Project Directory](../../../test/windows/toon_pipeline/)

---

### animation

> glTF skeletal skinning animation test: loads a glb model with skin and animation clips, drives CPU skinning through the ozz animation pipeline (SkeletonData → SamplingJob → BlendingJob → LocalToModelJob), with mouse-drag orbit and wheel zoom support.

![animation](../../asstes/animation.gif)

[Jump to Project Directory](../../../test/windows/animation/)

---

## IX. Engine & Extensions

### audio

> Audio functionality test.<br/>
> **Note** This project demonstrates audio capabilities which cannot be perceived through rendered screenshots alone.

![audio](../../asstes/audio.gif)

[Jump to Project Directory](../../../test/windows/audio/)

---

### physics

> Physics engine test.

![physics](../../asstes/physics.gif)

[Jump to Project Directory](../../../test/windows/physics/)

---

### gui

> Immediate-mode GUI test based on imgui4cj: side-by-side comparison of a window without ImGui and one with ImGui; the ImGui window contains UiText / UiSliderFloat / UiButton widgets with an interactive counter.

![gui](../../asstes/gui.gif)

[Jump to Project Directory](../../../test/windows/gui/)

---

### xrmanager

> bgfxxr XR extension package feature verification.

![xrmanager](../../asstes/xrmanager.gif)

[Jump to Project Directory](../../../test/windows/xrmanager/)

---
