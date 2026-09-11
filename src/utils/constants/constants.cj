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
 * @file[zh-cn] constants 常量定义
 * @brief[zh-cn] 定义 three.js 兼容的全局常量：交互、渲染状态、纹理、动画、模板等
 * @explain[zh-cn] 本文件集中存放渲染状态与配置相关的具名常量，供各模块以符号引用，
 * 避免魔法数字。常量按主题分组，数值与 three.js 保持一致。
 *
 * @file[en] constants  Constant definitions
 * @brief[en] Defines three.js-compatible global constants for interaction, render state,
 * textures, animation, stencil, etc.
 * @explain[en] This file holds named constants for render state and configuration,
 * referenced symbolically across modules to avoid magic numbers. Constants are
 * grouped by topic, and values match three.js.
 *
 * @package three.utils.constants
 */
package three.utils.constants


// ===== 版本号 =====
/**
 * @brief[zh-cn] 版本号
 *
 * @brief[en] Revision string
 */
public let REVISION: String = "1dev"

// ===== 鼠标交互 =====
/**
 * @brief[zh-cn] 鼠标左键
 *
 * @brief[en] Mouse left button
 */
public let MOUSE_LEFT: Int64 = 0
/**
 * @brief[zh-cn] 鼠标中键
 *
 * @brief[en] Mouse middle button
 */
public let MOUSE_MIDDLE: Int64 = 1
/**
 * @brief[zh-cn] 鼠标右键
 *
 * @brief[en] Mouse right button
 */
public let MOUSE_RIGHT: Int64 = 2
/**
 * @brief[zh-cn] 鼠标旋转动作
 *
 * @brief[en] Mouse rotate action
 */
public let MOUSE_ROTATE: Int64 = 0
/**
 * @brief[zh-cn] 鼠标拉近推远动作
 *
 * @brief[en] Mouse dolly action
 */
public let MOUSE_DOLLY: Int64 = 1
/**
 * @brief[zh-cn] 鼠标平移动作
 *
 * @brief[en] Mouse pan action
 */
public let MOUSE_PAN: Int64 = 2

// ===== 触摸交互 =====
/**
 * @brief[zh-cn] 触摸旋转
 *
 * @brief[en] Touch rotate
 */
public let TOUCH_ROTATE: Int64 = 0
/**
 * @brief[zh-cn] 触摸平移
 *
 * @brief[en] Touch pan
 */
public let TOUCH_PAN: Int64 = 1
/**
 * @brief[zh-cn] 触摸拉近推远+平移
 *
 * @brief[en] Touch dolly pan
 */
public let TOUCH_DOLLY_PAN: Int64 = 2
/**
 * @brief[zh-cn] 触摸拉近推远+旋转
 *
 * @brief[en] Touch dolly rotate
 */
public let TOUCH_DOLLY_ROTATE: Int64 = 3

// ===== 面剔除 =====
/**
 * @brief[zh-cn] 不剔除
 *
 * @brief[en] No face culling
 */
public let CullFaceNone: Int64 = 0
/**
 * @brief[zh-cn] 剔除背面
 *
 * @brief[en] Cull back faces
 */
public let CullFaceBack: Int64 = 1
/**
 * @brief[zh-cn] 剔除正面
 *
 * @brief[en] Cull front faces
 */
public let CullFaceFront: Int64 = 2
/**
 * @brief[zh-cn] 正反面均剔除
 *
 * @brief[en] Cull both front and back faces
 */
public let CullFaceFrontBack: Int64 = 3

// ===== 阴影映射 =====
/**
 * @brief[zh-cn] 基础阴影映射
 *
 * @brief[en] Basic shadow map
 */
public let BasicShadowMap: Int64 = 0
/**
 * @brief[zh-cn] PCF 阴影映射
 *
 * @brief[en] PCF shadow map
 */
public let PCFShadowMap: Int64 = 1
/**
 * @brief[zh-cn] PCF 软阴影映射
 *
 * @brief[en] PCF soft shadow map
 */
public let PCFSoftShadowMap: Int64 = 2
/**
 * @brief[zh-cn] VSM 阴影映射
 *
 * @brief[en] VSM shadow map
 */
public let VSMShadowMap: Int64 = 3

// ===== 面渲染 =====
/**
 * @brief[zh-cn] 渲染正面
 *
 * @brief[en] Render front side
 */
public let FrontSide: Int64 = 0
/**
 * @brief[zh-cn] 渲染背面
 *
 * @brief[en] Render back side
 */
public let BackSide: Int64 = 1
/**
 * @brief[zh-cn] 双面渲染
 *
 * @brief[en] Render both sides
 */
public let DoubleSide: Int64 = 2

// ===== 混合模式 =====
/**
 * @brief[zh-cn] 不混合
 *
 * @brief[en] No blending
 */
public let NoBlending: Int64 = 0
/**
 * @brief[zh-cn] 正常混合
 *
 * @brief[en] Normal blending
 */
public let NormalBlending: Int64 = 1
/**
 * @brief[zh-cn] 加法混合
 *
 * @brief[en] Additive blending
 */
public let AdditiveBlending: Int64 = 2
/**
 * @brief[zh-cn] 减法混合
 *
 * @brief[en] Subtractive blending
 */
public let SubtractiveBlending: Int64 = 3
/**
 * @brief[zh-cn] 乘法混合
 *
 * @brief[en] Multiply blending
 */
public let MultiplyBlending: Int64 = 4
/**
 * @brief[zh-cn] 自定义混合
 *
 * @brief[en] Custom blending
 */
public let CustomBlending: Int64 = 5
/**
 * @brief[zh-cn] 材质默认混合
 *
 * @brief[en] Material blending
 */
public let MaterialBlending: Int64 = 6

// ===== 混合方程 =====
/**
 * @brief[zh-cn] 加法混合方程
 *
 * @brief[en] Add equation
 */
public let AddEquation: Int64 = 100
/**
 * @brief[zh-cn] 减法混合方程
 *
 * @brief[en] Subtract equation
 */
public let SubtractEquation: Int64 = 101
/**
 * @brief[zh-cn] 反向减法混合方程
 *
 * @brief[en] Reverse-subtract equation
 */
public let ReverseSubtractEquation: Int64 = 102
/**
 * @brief[zh-cn] 取最小值混合方程
 *
 * @brief[en] Min equation
 */
public let MinEquation: Int64 = 103
/**
 * @brief[zh-cn] 取最大值混合方程
 *
 * @brief[en] Max equation
 */
public let MaxEquation: Int64 = 104

// ===== 混合因子 =====
/**
 * @brief[zh-cn] 因子：0
 *
 * @brief[en] Factor: zero
 */
public let ZeroFactor: Int64 = 200
/**
 * @brief[zh-cn] 因子：1
 *
 * @brief[en] Factor: one
 */
public let OneFactor: Int64 = 201
/**
 * @brief[zh-cn] 源颜色因子
 *
 * @brief[en] Source color factor
 */
public let SrcColorFactor: Int64 = 202
/**
 * @brief[zh-cn] 一减源颜色因子
 *
 * @brief[en] One minus source color factor
 */
public let OneMinusSrcColorFactor: Int64 = 203
/**
 * @brief[zh-cn] 源透明度因子
 *
 * @brief[en] Source alpha factor
 */
public let SrcAlphaFactor: Int64 = 204
/**
 * @brief[zh-cn] 一减源透明度因子
 *
 * @brief[en] One minus source alpha factor
 */
public let OneMinusSrcAlphaFactor: Int64 = 205
/**
 * @brief[zh-cn] 目标透明度因子
 *
 * @brief[en] Destination alpha factor
 */
public let DstAlphaFactor: Int64 = 206
/**
 * @brief[zh-cn] 一减目标透明度因子
 *
 * @brief[en] One minus destination alpha factor
 */
public let OneMinusDstAlphaFactor: Int64 = 207
/**
 * @brief[zh-cn] 目标颜色因子
 *
 * @brief[en] Destination color factor
 */
public let DstColorFactor: Int64 = 208
/**
 * @brief[zh-cn] 一减目标颜色因子
 *
 * @brief[en] One minus destination color factor
 */
public let OneMinusDstColorFactor: Int64 = 209
/**
 * @brief[zh-cn] 源透明度饱和因子
 *
 * @brief[en] Source alpha saturate factor
 */
public let SrcAlphaSaturateFactor: Int64 = 210
/**
 * @brief[zh-cn] 常量颜色因子
 *
 * @brief[en] Constant color factor
 */
public let ConstantColorFactor: Int64 = 211
/**
 * @brief[zh-cn] 一减常量颜色因子
 *
 * @brief[en] One minus constant color factor
 */
public let OneMinusConstantColorFactor: Int64 = 212
/**
 * @brief[zh-cn] 常量透明度因子
 *
 * @brief[en] Constant alpha factor
 */
public let ConstantAlphaFactor: Int64 = 213
/**
 * @brief[zh-cn] 一减常量透明度因子
 *
 * @brief[en] One minus constant alpha factor
 */
public let OneMinusConstantAlphaFactor: Int64 = 214

// ===== 深度测试函数 =====
/**
 * @brief[zh-cn] 深度测试：从不通过
 *
 * @brief[en] Depth test: never
 */
public let NeverDepth: Int64 = 0
/**
 * @brief[zh-cn] 深度测试：始终通过
 *
 * @brief[en] Depth test: always
 */
public let AlwaysDepth: Int64 = 1
/**
 * @brief[zh-cn] 深度测试：小于
 *
 * @brief[en] Depth test: less than
 */
public let LessDepth: Int64 = 2
/**
 * @brief[zh-cn] 深度测试：小于等于
 *
 * @brief[en] Depth test: less than or equal
 */
public let LessEqualDepth: Int64 = 3
/**
 * @brief[zh-cn] 深度测试：等于
 *
 * @brief[en] Depth test: equal
 */
public let EqualDepth: Int64 = 4
/**
 * @brief[zh-cn] 深度测试：大于等于
 *
 * @brief[en] Depth test: greater than or equal
 */
public let GreaterEqualDepth: Int64 = 5
/**
 * @brief[zh-cn] 深度测试：大于
 *
 * @brief[en] Depth test: greater than
 */
public let GreaterDepth: Int64 = 6
/**
 * @brief[zh-cn] 深度测试：不等于
 *
 * @brief[en] Depth test: not equal
 */
public let NotEqualDepth: Int64 = 7

// ===== 环境贴图混合操作 =====
/**
 * @brief[zh-cn] 环境贴图混合：乘法
 *
 * @brief[en] Env-map blend: multiply
 */
public let MultiplyOperation: Int64 = 0
/**
 * @brief[zh-cn] 环境贴图混合：混合
 *
 * @brief[en] Env-map blend: mix
 */
public let MixOperation: Int64 = 1
/**
 * @brief[zh-cn] 环境贴图混合：加法
 *
 * @brief[en] Env-map blend: add
 */
public let AddOperation: Int64 = 2

// ===== 色调映射 =====
/**
 * @brief[zh-cn] 不进行色调映射
 *
 * @brief[en] No tone mapping
 */
public let NoToneMapping: Int64 = 0
/**
 * @brief[zh-cn] 线性色调映射
 *
 * @brief[en] Linear tone mapping
 */
public let LinearToneMapping: Int64 = 1
/**
 * @brief[zh-cn] Reinhard 色调映射
 *
 * @brief[en] Reinhard tone mapping
 */
public let ReinhardToneMapping: Int64 = 2
/**
 * @brief[zh-cn] Cineon 色调映射
 *
 * @brief[en] Cineon tone mapping
 */
public let CineonToneMapping: Int64 = 3
/**
 * @brief[zh-cn] ACES Filmic 色调映射
 *
 * @brief[en] ACES Filmic tone mapping
 */
public let ACESFilmicToneMapping: Int64 = 4
/**
 * @brief[zh-cn] 自定义色调映射
 *
 * @brief[en] Custom tone mapping
 */
public let CustomToneMapping: Int64 = 5
/**
 * @brief[zh-cn] AgX 色调映射
 *
 * @brief[en] AgX tone mapping
 */
public let AgXToneMapping: Int64 = 6
/**
 * @brief[zh-cn] 中性色调映射
 *
 * @brief[en] Neutral tone mapping
 */
public let NeutralToneMapping: Int64 = 7

// ===== 绑定模式 =====
/**
 * @brief[zh-cn] 附着绑定模式
 *
 * @brief[en] Attached bind mode
 */
public let AttachedBindMode: String = "attached"
/**
 * @brief[zh-cn] 分离绑定模式
 *
 * @brief[en] Detached bind mode
 */
public let DetachedBindMode: String = "detached"

// ===== 纹理映射模式 =====
/**
 * @brief[zh-cn] UV 映射
 *
 * @brief[en] UV mapping
 */
public let UVMapping: Int64 = 300
/**
 * @brief[zh-cn] 立方体反射映射
 *
 * @brief[en] Cube reflection mapping
 */
public let CubeReflectionMapping: Int64 = 301
/**
 * @brief[zh-cn] 立方体折射映射
 *
 * @brief[en] Cube refraction mapping
 */
public let CubeRefractionMapping: Int64 = 302
/**
 * @brief[zh-cn] 等距圆柱反射映射
 *
 * @brief[en] Equirectangular reflection mapping
 */
public let EquirectangularReflectionMapping: Int64 = 303
/**
 * @brief[zh-cn] 等距圆柱折射映射
 *
 * @brief[en] Equirectangular refraction mapping
 */
public let EquirectangularRefractionMapping: Int64 = 304
/**
 * @brief[zh-cn] 立方体 UV 反射映射
 *
 * @brief[en] Cube UV reflection mapping
 */
public let CubeUVReflectionMapping: Int64 = 306

// ===== 纹理环绕模式 =====
/**
 * @brief[zh-cn] 重复环绕
 *
 * @brief[en] Repeat wrapping
 */
public let RepeatWrapping: Int64 = 1000
/**
 * @brief[zh-cn] 边缘钳制环绕
 *
 * @brief[en] Clamp-to-edge wrapping
 */
public let ClampToEdgeWrapping: Int64 = 1001
/**
 * @brief[zh-cn] 镜像重复环绕
 *
 * @brief[en] Mirrored repeat wrapping
 */
public let MirroredRepeatWrapping: Int64 = 1002

// ===== 纹理过滤模式 =====
/**
 * @brief[zh-cn] 最近邻过滤
 *
 * @brief[en] Nearest filter
 */
public let NearestFilter: Int64 = 1003
/**
 * @brief[zh-cn] 最近邻+最近 Mipmap
 *
 * @brief[en] Nearest mipmap nearest filter
 */
public let NearestMipmapNearestFilter: Int64 = 1004
/**
 * @brief[zh-cn] 最近邻+最近 Mipmap（别名）
 *
 * @brief[en] Nearest mipmap nearest filter (alias)
 */
public let NearestMipMapNearestFilter: Int64 = 1004
/**
 * @brief[zh-cn] 最近邻+线性 Mipmap
 *
 * @brief[en] Nearest mipmap linear filter
 */
public let NearestMipmapLinearFilter: Int64 = 1005
/**
 * @brief[zh-cn] 最近邻+线性 Mipmap（别名）
 *
 * @brief[en] Nearest mipmap linear filter (alias)
 */
public let NearestMipMapLinearFilter: Int64 = 1005
/**
 * @brief[zh-cn] 线性过滤
 *
 * @brief[en] Linear filter
 */
public let LinearFilter: Int64 = 1006
/**
 * @brief[zh-cn] 线性+最近 Mipmap
 *
 * @brief[en] Linear mipmap nearest filter
 */
public let LinearMipmapNearestFilter: Int64 = 1007
/**
 * @brief[zh-cn] 线性+最近 Mipmap（别名）
 *
 * @brief[en] Linear mipmap nearest filter (alias)
 */
public let LinearMipMapNearestFilter: Int64 = 1007
/**
 * @brief[zh-cn] 线性+线性 Mipmap
 *
 * @brief[en] Linear mipmap linear filter
 */
public let LinearMipmapLinearFilter: Int64 = 1008
/**
 * @brief[zh-cn] 线性+线性 Mipmap（别名）
 *
 * @brief[en] Linear mipmap linear filter (alias)
 */
public let LinearMipMapLinearFilter: Int64 = 1008

// ===== 纹理数据类型 =====
/**
 * @brief[zh-cn] 无符号字节
 *
 * @brief[en] Unsigned byte type
 */
public let UnsignedByteType: Int64 = 1009
/**
 * @brief[zh-cn] 有符号字节
 *
 * @brief[en] Byte type
 */
public let ByteType: Int64 = 1010
/**
 * @brief[zh-cn] 短整型
 *
 * @brief[en] Short type
 */
public let ShortType: Int64 = 1011
/**
 * @brief[zh-cn] 无符号短整型
 *
 * @brief[en] Unsigned short type
 */
public let UnsignedShortType: Int64 = 1012
/**
 * @brief[zh-cn] 整型
 *
 * @brief[en] Int type
 */
public let IntType: Int64 = 1013
/**
 * @brief[zh-cn] 无符号整型
 *
 * @brief[en] Unsigned int type
 */
public let UnsignedIntType: Int64 = 1014
/**
 * @brief[zh-cn] 浮点型
 *
 * @brief[en] Float type
 */
public let FloatType: Int64 = 1015
/**
 * @brief[zh-cn] 半浮点型
 *
 * @brief[en] Half-float type
 */
public let HalfFloatType: Int64 = 1016
/**
 * @brief[zh-cn] 无符号 4444 打包
 *
 * @brief[en] Unsigned short 4444 type
 */
public let UnsignedShort4444Type: Int64 = 1017
/**
 * @brief[zh-cn] 无符号 5551 打包
 *
 * @brief[en] Unsigned short 5551 type
 */
public let UnsignedShort5551Type: Int64 = 1018
/**
 * @brief[zh-cn] 无符号 24-8 打包
 *
 * @brief[en] Unsigned int 24-8 type
 */
public let UnsignedInt248Type: Int64 = 1020
/**
 * @brief[zh-cn] 无符号 5-9-9-9 打包
 *
 * @brief[en] Unsigned int 5999 type
 */
public let UnsignedInt5999Type: Int64 = 35902
/**
 * @brief[zh-cn] 无符号 10-10-10-2 打包
 *
 * @brief[en] Unsigned int 101111 type
 */
public let UnsignedInt101111Type: Int64 = 35899

// ===== 纹理格式 =====
/**
 * @brief[zh-cn] Alpha 格式
 *
 * @brief[en] Alpha format
 */
public let AlphaFormat: Int64 = 1021
/**
 * @brief[zh-cn] RGB 格式
 *
 * @brief[en] RGB format
 */
public let RGBFormat: Int64 = 1022
/**
 * @brief[zh-cn] RGBA 格式
 *
 * @brief[en] RGBA format
 */
public let RGBAFormat: Int64 = 1023
/**
 * @brief[zh-cn] 深度格式
 *
 * @brief[en] Depth format
 */
public let DepthFormat: Int64 = 1026
/**
 * @brief[zh-cn] 深度+模板格式
 *
 * @brief[en] Depth-stencil format
 */
public let DepthStencilFormat: Int64 = 1027
/**
 * @brief[zh-cn] 红色通道格式
 *
 * @brief[en] Red format
 */
public let RedFormat: Int64 = 1028
/**
 * @brief[zh-cn] 红色整型格式
 *
 * @brief[en] Red integer format
 */
public let RedIntegerFormat: Int64 = 1029
/**
 * @brief[zh-cn] RG 格式
 *
 * @brief[en] RG format
 */
public let RGFormat: Int64 = 1030
/**
 * @brief[zh-cn] RG 整型格式
 *
 * @brief[en] RG integer format
 */
public let RGIntegerFormat: Int64 = 1031
/**
 * @brief[zh-cn] RGB 整型格式
 *
 * @brief[en] RGB integer format
 */
public let RGBIntegerFormat: Int64 = 1032
/**
 * @brief[zh-cn] RGBA 整型格式
 *
 * @brief[en] RGBA integer format
 */
public let RGBAIntegerFormat: Int64 = 1033

// ===== 压缩纹理格式 (S3TC) =====
/**
 * @brief[zh-cn] S3TC DXT1 RGB 压缩格式
 *
 * @brief[en] S3TC DXT1 RGB compressed format
 */
public let RGB_S3TC_DXT1_Format: Int64 = 33776
/**
 * @brief[zh-cn] S3TC DXT1 RGBA 压缩格式
 *
 * @brief[en] S3TC DXT1 RGBA compressed format
 */
public let RGBA_S3TC_DXT1_Format: Int64 = 33777
/**
 * @brief[zh-cn] S3TC DXT3 RGBA 压缩格式
 *
 * @brief[en] S3TC DXT3 RGBA compressed format
 */
public let RGBA_S3TC_DXT3_Format: Int64 = 33778
/**
 * @brief[zh-cn] S3TC DXT5 RGBA 压缩格式
 *
 * @brief[en] S3TC DXT5 RGBA compressed format
 */
public let RGBA_S3TC_DXT5_Format: Int64 = 33779

// ===== 压缩纹理格式 (PVRTC) =====
/**
 * @brief[zh-cn] PVRTC 4bpp RGB 压缩格式
 *
 * @brief[en] PVRTC 4bpp RGB compressed format
 */
public let RGB_PVRTC_4BPPV1_Format: Int64 = 35840
/**
 * @brief[zh-cn] PVRTC 2bpp RGB 压缩格式
 *
 * @brief[en] PVRTC 2bpp RGB compressed format
 */
public let RGB_PVRTC_2BPPV1_Format: Int64 = 35841
/**
 * @brief[zh-cn] PVRTC 4bpp RGBA 压缩格式
 *
 * @brief[en] PVRTC 4bpp RGBA compressed format
 */
public let RGBA_PVRTC_4BPPV1_Format: Int64 = 35842
/**
 * @brief[zh-cn] PVRTC 2bpp RGBA 压缩格式
 *
 * @brief[en] PVRTC 2bpp RGBA compressed format
 */
public let RGBA_PVRTC_2BPPV1_Format: Int64 = 35843

// ===== 压缩纹理格式 (ETC) =====
/**
 * @brief[zh-cn] ETC1 RGB 压缩格式
 *
 * @brief[en] ETC1 RGB compressed format
 */
public let RGB_ETC1_Format: Int64 = 36196
/**
 * @brief[zh-cn] ETC2 RGB 压缩格式
 *
 * @brief[en] ETC2 RGB compressed format
 */
public let RGB_ETC2_Format: Int64 = 37492
/**
 * @brief[zh-cn] ETC2 EAC RGBA 压缩格式
 *
 * @brief[en] ETC2 EAC RGBA compressed format
 */
public let RGBA_ETC2_EAC_Format: Int64 = 37496

// ===== 压缩纹理格式 (EAC) =====
/**
 * @brief[zh-cn] EAC R11 压缩格式
 *
 * @brief[en] EAC R11 compressed format
 */
public let R11_EAC_Format: Int64 = 37488
/**
 * @brief[zh-cn] EAC 有符号 R11 压缩格式
 *
 * @brief[en] EAC signed R11 compressed format
 */
public let SIGNED_R11_EAC_Format: Int64 = 37489
/**
 * @brief[zh-cn] EAC RG11 压缩格式
 *
 * @brief[en] EAC RG11 compressed format
 */
public let RG11_EAC_Format: Int64 = 37490
/**
 * @brief[zh-cn] EAC 有符号 RG11 压缩格式
 *
 * @brief[en] EAC signed RG11 compressed format
 */
public let SIGNED_RG11_EAC_Format: Int64 = 37491

// ===== 压缩纹理格式 (ASTC) =====
/**
 * @brief[zh-cn] ASTC 4x4 RGBA 压缩格式
 *
 * @brief[en] ASTC 4x4 RGBA compressed format
 */
public let RGBA_ASTC_4x4_Format: Int64 = 37808
/**
 * @brief[zh-cn] ASTC 5x4 RGBA 压缩格式
 *
 * @brief[en] ASTC 5x4 RGBA compressed format
 */
public let RGBA_ASTC_5x4_Format: Int64 = 37809
/**
 * @brief[zh-cn] ASTC 5x5 RGBA 压缩格式
 *
 * @brief[en] ASTC 5x5 RGBA compressed format
 */
public let RGBA_ASTC_5x5_Format: Int64 = 37810
/**
 * @brief[zh-cn] ASTC 6x5 RGBA 压缩格式
 *
 * @brief[en] ASTC 6x5 RGBA compressed format
 */
public let RGBA_ASTC_6x5_Format: Int64 = 37811
/**
 * @brief[zh-cn] ASTC 6x6 RGBA 压缩格式
 *
 * @brief[en] ASTC 6x6 RGBA compressed format
 */
public let RGBA_ASTC_6x6_Format: Int64 = 37812
/**
 * @brief[zh-cn] ASTC 8x5 RGBA 压缩格式
 *
 * @brief[en] ASTC 8x5 RGBA compressed format
 */
public let RGBA_ASTC_8x5_Format: Int64 = 37813
/**
 * @brief[zh-cn] ASTC 8x6 RGBA 压缩格式
 *
 * @brief[en] ASTC 8x6 RGBA compressed format
 */
public let RGBA_ASTC_8x6_Format: Int64 = 37814
/**
 * @brief[zh-cn] ASTC 8x8 RGBA 压缩格式
 *
 * @brief[en] ASTC 8x8 RGBA compressed format
 */
public let RGBA_ASTC_8x8_Format: Int64 = 37815
/**
 * @brief[zh-cn] ASTC 10x5 RGBA 压缩格式
 *
 * @brief[en] ASTC 10x5 RGBA compressed format
 */
public let RGBA_ASTC_10x5_Format: Int64 = 37816
/**
 * @brief[zh-cn] ASTC 10x6 RGBA 压缩格式
 *
 * @brief[en] ASTC 10x6 RGBA compressed format
 */
public let RGBA_ASTC_10x6_Format: Int64 = 37817
/**
 * @brief[zh-cn] ASTC 10x8 RGBA 压缩格式
 *
 * @brief[en] ASTC 10x8 RGBA compressed format
 */
public let RGBA_ASTC_10x8_Format: Int64 = 37818
/**
 * @brief[zh-cn] ASTC 10x10 RGBA 压缩格式
 *
 * @brief[en] ASTC 10x10 RGBA compressed format
 */
public let RGBA_ASTC_10x10_Format: Int64 = 37819
/**
 * @brief[zh-cn] ASTC 12x10 RGBA 压缩格式
 *
 * @brief[en] ASTC 12x10 RGBA compressed format
 */
public let RGBA_ASTC_12x10_Format: Int64 = 37820
/**
 * @brief[zh-cn] ASTC 12x12 RGBA 压缩格式
 *
 * @brief[en] ASTC 12x12 RGBA compressed format
 */
public let RGBA_ASTC_12x12_Format: Int64 = 37821

// ===== 压缩纹理格式 (BPTC) =====
/**
 * @brief[zh-cn] BPTC RGBA 压缩格式
 *
 * @brief[en] BPTC RGBA compressed format
 */
public let RGBA_BPTC_Format: Int64 = 36492
/**
 * @brief[zh-cn] BPTC 有符号 RGB 压缩格式
 *
 * @brief[en] BPTC signed RGB compressed format
 */
public let RGB_BPTC_SIGNED_Format: Int64 = 36494
/**
 * @brief[zh-cn] BPTC 无符号 RGB 压缩格式
 *
 * @brief[en] BPTC unsigned RGB compressed format
 */
public let RGB_BPTC_UNSIGNED_Format: Int64 = 36495

// ===== 压缩纹理格式 (RGTC) =====
/**
 * @brief[zh-cn] RGTC RED 压缩格式
 *
 * @brief[en] RGTC RED compressed format
 */
public let RED_RGTC1_Format: Int64 = 36283
/**
 * @brief[zh-cn] RGTC 有符号 RED 压缩格式
 *
 * @brief[en] RGTC signed RED compressed format
 */
public let SIGNED_RED_RGTC1_Format: Int64 = 36284
/**
 * @brief[zh-cn] RGTC RG 压缩格式
 *
 * @brief[en] RGTC RG compressed format
 */
public let RED_GREEN_RGTC2_Format: Int64 = 36285
/**
 * @brief[zh-cn] RGTC 有符号 RG 压缩格式
 *
 * @brief[en] RGTC signed RG compressed format
 */
public let SIGNED_RED_GREEN_RGTC2_Format: Int64 = 36286

// ===== 动画循环模式 =====
/**
 * @brief[zh-cn] 动画循环：只播放一次
 *
 * @brief[en] Animation loop: play once
 */
public let LoopOnce: Int64 = 2200
/**
 * @brief[zh-cn] 动画循环：重复播放
 *
 * @brief[en] Animation loop: repeat
 */
public let LoopRepeat: Int64 = 2201
/**
 * @brief[zh-cn] 动画循环：往返播放
 *
 * @brief[en] Animation loop: ping-pong
 */
public let LoopPingPong: Int64 = 2202

// ===== 插值模式 =====
/**
 * @brief[zh-cn] 插值：离散（无插值）
 *
 * @brief[en] Interpolation: discrete (no interpolation)
 */
public let InterpolateDiscrete: Int64 = 2300
/**
 * @brief[zh-cn] 插值：线性
 *
 * @brief[en] Interpolation: linear
 */
public let InterpolateLinear: Int64 = 2301
/**
 * @brief[zh-cn] 插值：平滑
 *
 * @brief[en] Interpolation: smooth
 */
public let InterpolateSmooth: Int64 = 2302
/**
 * @brief[zh-cn] 插值：贝塞尔
 *
 * @brief[en] Interpolation: bezier
 */
public let InterpolateBezier: Int64 = 2303

// ===== 动画结束行为 =====
/**
 * @brief[zh-cn] 结束行为：零曲率
 *
 * @brief[en] Ending: zero curvature
 */
public let ZeroCurvatureEnding: Int64 = 2400
/**
 * @brief[zh-cn] 结束行为：零斜率
 *
 * @brief[en] Ending: zero slope
 */
public let ZeroSlopeEnding: Int64 = 2401
/**
 * @brief[zh-cn] 结束行为：环绕
 *
 * @brief[en] Ending: wrap around
 */
public let WrapAroundEnding: Int64 = 2402

// ===== 动画混合模式 =====
/**
 * @brief[zh-cn] 动画混合：常规
 *
 * @brief[en] Animation blend: normal
 */
public let NormalAnimationBlendMode: Int64 = 2500
/**
 * @brief[zh-cn] 动画混合：加法
 *
 * @brief[en] Animation blend: additive
 */
public let AdditiveAnimationBlendMode: Int64 = 2501

// ===== 绘制模式 =====
/**
 * @brief[zh-cn] 绘制模式：三角形列表
 *
 * @brief[en] Draw mode: triangles
 */
public let TrianglesDrawMode: Int64 = 0
/**
 * @brief[zh-cn] 绘制模式：三角形条带
 *
 * @brief[en] Draw mode: triangle strip
 */
public let TriangleStripDrawMode: Int64 = 1
/**
 * @brief[zh-cn] 绘制模式：三角形扇
 *
 * @brief[en] Draw mode: triangle fan
 */
public let TriangleFanDrawMode: Int64 = 2

// ===== 深度打包 =====
/**
 * @brief[zh-cn] 深度打包：基础
 *
 * @brief[en] Depth packing: basic
 */
public let BasicDepthPacking: Int64 = 3200
/**
 * @brief[zh-cn] 深度打包：RGBA
 *
 * @brief[en] Depth packing: RGBA
 */
public let RGBADepthPacking: Int64 = 3201
/**
 * @brief[zh-cn] 深度打包：RGB
 *
 * @brief[en] Depth packing: RGB
 */
public let RGBDepthPacking: Int64 = 3202
/**
 * @brief[zh-cn] 深度打包：RG
 *
 * @brief[en] Depth packing: RG
 */
public let RGDepthPacking: Int64 = 3203

// ===== 法线贴图空间 =====
/**
 * @brief[zh-cn] 法线贴图：切线空间
 *
 * @brief[en] Normal map: tangent space
 */
public let TangentSpaceNormalMap: Int64 = 0
/**
 * @brief[zh-cn] 法线贴图：对象空间
 *
 * @brief[en] Normal map: object space
 */
public let ObjectSpaceNormalMap: Int64 = 1

// ===== 色彩空间 =====
/**
 * @brief[zh-cn] 无色彩空间
 *
 * @brief[en] No color space
 */
public let NoColorSpace: String = ""
/**
 * @brief[zh-cn] sRGB 色彩空间
 *
 * @brief[en] sRGB color space
 */
public let SRGBColorSpace: String = "srgb"
/**
 * @brief[zh-cn] 线性 sRGB 色彩空间
 *
 * @brief[en] Linear sRGB color space
 */
public let LinearSRGBColorSpace: String = "srgb-linear"

// ===== 传输函数 =====
/**
 * @brief[zh-cn] 传输函数：线性
 *
 * @brief[en] Transfer: linear
 */
public let LinearTransfer: String = "linear"
/**
 * @brief[zh-cn] 传输函数：sRGB
 *
 * @brief[en] Transfer: sRGB
 */
public let SRGBTransfer: String = "srgb"

// ===== 法线贴图打包 =====
/**
 * @brief[zh-cn] 法线打包：无
 *
 * @brief[en] Normal packing: none
 */
public let NoNormalPacking: String = ""
/**
 * @brief[zh-cn] 法线打包：RG
 *
 * @brief[en] Normal packing: RG
 */
public let NormalRGPacking: String = "rg"
/**
 * @brief[zh-cn] 法线打包：GA
 *
 * @brief[en] Normal packing: GA
 */
public let NormalGAPacking: String = "ga"

// ===== 模板操作 =====
/**
 * @brief[zh-cn] 模板操作：置零
 *
 * @brief[en] Stencil op: zero
 */
public let ZeroStencilOp: Int64 = 0
/**
 * @brief[zh-cn] 模板操作：保持
 *
 * @brief[en] Stencil op: keep
 */
public let KeepStencilOp: Int64 = 7680
/**
 * @brief[zh-cn] 模板操作：替换
 *
 * @brief[en] Stencil op: replace
 */
public let ReplaceStencilOp: Int64 = 7681
/**
 * @brief[zh-cn] 模板操作：递增
 *
 * @brief[en] Stencil op: increment
 */
public let IncrementStencilOp: Int64 = 7682
/**
 * @brief[zh-cn] 模板操作：递减
 *
 * @brief[en] Stencil op: decrement
 */
public let DecrementStencilOp: Int64 = 7683
/**
 * @brief[zh-cn] 模板操作：环绕递增
 *
 * @brief[en] Stencil op: increment wrap
 */
public let IncrementWrapStencilOp: Int64 = 34055
/**
 * @brief[zh-cn] 模板操作：环绕递减
 *
 * @brief[en] Stencil op: decrement wrap
 */
public let DecrementWrapStencilOp: Int64 = 34056
/**
 * @brief[zh-cn] 模板操作：反转
 *
 * @brief[en] Stencil op: invert
 */
public let InvertStencilOp: Int64 = 5386

// ===== 模板测试函数 =====
/**
 * @brief[zh-cn] 模板测试：从不通过
 *
 * @brief[en] Stencil test: never
 */
public let NeverStencilFunc: Int64 = 512
/**
 * @brief[zh-cn] 模板测试：小于
 *
 * @brief[en] Stencil test: less
 */
public let LessStencilFunc: Int64 = 513
/**
 * @brief[zh-cn] 模板测试：等于
 *
 * @brief[en] Stencil test: equal
 */
public let EqualStencilFunc: Int64 = 514
/**
 * @brief[zh-cn] 模板测试：小于等于
 *
 * @brief[en] Stencil test: less than or equal
 */
public let LessEqualStencilFunc: Int64 = 515
/**
 * @brief[zh-cn] 模板测试：大于
 *
 * @brief[en] Stencil test: greater
 */
public let GreaterStencilFunc: Int64 = 516
/**
 * @brief[zh-cn] 模板测试：不等于
 *
 * @brief[en] Stencil test: not equal
 */
public let NotEqualStencilFunc: Int64 = 517
/**
 * @brief[zh-cn] 模板测试：大于等于
 *
 * @brief[en] Stencil test: greater than or equal
 */
public let GreaterEqualStencilFunc: Int64 = 518
/**
 * @brief[zh-cn] 模板测试：始终通过
 *
 * @brief[en] Stencil test: always
 */
public let AlwaysStencilFunc: Int64 = 519

// ===== 纹理比较函数 =====
/**
 * @brief[zh-cn] 纹理比较：从不
 *
 * @brief[en] Texture compare: never
 */
public let NeverCompare: Int64 = 512
/**
 * @brief[zh-cn] 纹理比较：小于
 *
 * @brief[en] Texture compare: less
 */
public let LessCompare: Int64 = 513
/**
 * @brief[zh-cn] 纹理比较：等于
 *
 * @brief[en] Texture compare: equal
 */
public let EqualCompare: Int64 = 514
/**
 * @brief[zh-cn] 纹理比较：小于等于
 *
 * @brief[en] Texture compare: less than or equal
 */
public let LessEqualCompare: Int64 = 515
/**
 * @brief[zh-cn] 纹理比较：大于
 *
 * @brief[en] Texture compare: greater
 */
public let GreaterCompare: Int64 = 516
/**
 * @brief[zh-cn] 纹理比较：不等于
 *
 * @brief[en] Texture compare: not equal
 */
public let NotEqualCompare: Int64 = 517
/**
 * @brief[zh-cn] 纹理比较：大于等于
 *
 * @brief[en] Texture compare: greater than or equal
 */
public let GreaterEqualCompare: Int64 = 518
/**
 * @brief[zh-cn] 纹理比较：始终
 *
 * @brief[en] Texture compare: always
 */
public let AlwaysCompare: Int64 = 519

// ===== 缓冲区使用模式 =====
/**
 * @brief[zh-cn] 缓冲用途：静态绘制
 *
 * @brief[en] Buffer usage: static draw
 */
public let StaticDrawUsage: Int64 = 35044
/**
 * @brief[zh-cn] 缓冲用途：动态绘制
 *
 * @brief[en] Buffer usage: dynamic draw
 */
public let DynamicDrawUsage: Int64 = 35048
/**
 * @brief[zh-cn] 缓冲用途：流式绘制
 *
 * @brief[en] Buffer usage: stream draw
 */
public let StreamDrawUsage: Int64 = 35040
/**
 * @brief[zh-cn] 缓冲用途：静态读取
 *
 * @brief[en] Buffer usage: static read
 */
public let StaticReadUsage: Int64 = 35045
/**
 * @brief[zh-cn] 缓冲用途：动态读取
 *
 * @brief[en] Buffer usage: dynamic read
 */
public let DynamicReadUsage: Int64 = 35049
/**
 * @brief[zh-cn] 缓冲用途：流式读取
 *
 * @brief[en] Buffer usage: stream read
 */
public let StreamReadUsage: Int64 = 35041
/**
 * @brief[zh-cn] 缓冲用途：静态复制
 *
 * @brief[en] Buffer usage: static copy
 */
public let StaticCopyUsage: Int64 = 35046
/**
 * @brief[zh-cn] 缓冲用途：动态复制
 *
 * @brief[en] Buffer usage: dynamic copy
 */
public let DynamicCopyUsage: Int64 = 35050
/**
 * @brief[zh-cn] 缓冲用途：流式复制
 *
 * @brief[en] Buffer usage: stream copy
 */
public let StreamCopyUsage: Int64 = 35042

// ===== 着色器语言 =====
/**
 * @brief[zh-cn] GLSL ES 1.0（WebGL1）
 *
 * @brief[en] GLSL ES 1.0 (WebGL1)
 */
public let GLSL1: String = "100"
/**
 * @brief[zh-cn] GLSL ES 3.0（WebGL2）
 *
 * @brief[en] GLSL ES 3.0 (WebGL2)
 */
public let GLSL3: String = "300 es"

// ===== 坐标系 =====
/**
 * @brief[zh-cn] WebGL 坐标系
 *
 * @brief[en] WebGL coordinate system
 */
public let WebGLCoordinateSystem: Int64 = 2000
/**
 * @brief[zh-cn] WebGPU 坐标系
 *
 * @brief[en] WebGPU coordinate system
 */
public let WebGPUCoordinateSystem: Int64 = 2001

// ===== 时间戳查询 =====
/**
 * @brief[zh-cn] 时间戳查询：计算管线
 *
 * @brief[en] Timestamp query: compute
 */
public let TimestampQuery_COMPUTE: String = "compute"
/**
 * @brief[zh-cn] 时间戳查询：渲染管线
 *
 * @brief[en] Timestamp query: render
 */
public let TimestampQuery_RENDER: String = "render"

// ===== 插值采样类型 =====
/**
 * @brief[zh-cn] 插值采样类型：透视
 *
 * @brief[en] Interpolation sampling type: perspective
 */
public let InterpolationSamplingType_PERSPECTIVE: String = "perspective"
/**
 * @brief[zh-cn] 插值采样类型：线性
 *
 * @brief[en] Interpolation sampling type: linear
 */
public let InterpolationSamplingType_LINEAR: String = "linear"
/**
 * @brief[zh-cn] 插值采样类型：平坦
 *
 * @brief[en] Interpolation sampling type: flat
 */
public let InterpolationSamplingType_FLAT: String = "flat"

// ===== 插值采样模式 =====
/**
 * @brief[zh-cn] 插值采样模式：常规
 *
 * @brief[en] Interpolation sampling mode: normal
 */
public let InterpolationSamplingMode_NORMAL: String = "normal"
/**
 * @brief[zh-cn] 插值采样模式：质心
 *
 * @brief[en] Interpolation sampling mode: centroid
 */
public let InterpolationSamplingMode_CENTROID: String = "centroid"
/**
 * @brief[zh-cn] 插值采样模式：样本
 *
 * @brief[en] Interpolation sampling mode: sample
 */
public let InterpolationSamplingMode_SAMPLE: String = "sample"
/**
 * @brief[zh-cn] 插值采样模式：首个
 *
 * @brief[en] Interpolation sampling mode: first
 */
public let InterpolationSamplingMode_FIRST: String = "first"
/**
 * @brief[zh-cn] 插值采样模式：任一
 *
 * @brief[en] Interpolation sampling mode: either
 */
public let InterpolationSamplingMode_EITHER: String = "either"

// ===== 兼容性 =====
/**
 * @brief[zh-cn] 深度纹理比较兼容常量
 *
 * @brief[en] Depth-texture compare compatibility constant
 */
public let COMPATIBILITY_TEXTURE_COMPARE: String = "depthTextureCompare"