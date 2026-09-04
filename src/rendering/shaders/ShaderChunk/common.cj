/**
 * @file[zh-cn] common  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: common
 *
 * @file[en] common  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: common
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * common GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const common: String = #"
#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI_HALF 1.5707963267948966
#define RECIPROCAL_PI 0.3183098861837907
#define RECIPROCAL_PI2 0.15915494309189535
#define EPSILON 1e-6

#ifndef saturate
// <tonemapping_pars_fragment> may have defined saturate() already
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
#define whiteComplement( a ) ( 1.0 - saturate( a ) )

// three.js chunk 用 normal/position/uv 等属性名，但 bgfx $input 用 a_normal/a_position/a_texcoord0
#define normal a_normal
#define position a_position
#define uv a_texcoord0
#define normalMatrix u_normalMatrix

// three.js chunk 引用 modelViewMatrix/projectionMatrix/viewMatrix/modelMatrix 等标准 uniform 变量名
// 映射到 bgfx scene 标准 uniform（由 BgfxRenderer 绑定到 u_view/u_proj/u_model[0] 等）
// 注意：modelViewMatrix = viewMatrix * modelMatrix，无对应 bgfx 单独 uniform，用 u_viewProj 近似
#define viewMatrix u_view
#define projectionMatrix u_proj
#define modelMatrix u_model[0]
// three.js chunk body 用 camelCase vNormal/vTangent/vBitangent，但 $output 声明用 snake_case v_normal
#define vNormal v_normal
#define vTangent v_tangent
#define vBitangent v_bitangent
// three.js chunk body 用 camelCase vUv/vMapUv/vMetalnessMapUv 等，但 $output 声明用 snake_case v_uv/v_mapUv/...
#define vUv v_uv
#define vMapUv v_mapUv
#define vAlphaMapUv v_alphaMapUv
#define vLightMapUv v_lightMapUv
#define vAoMapUv v_aoMapUv
#define vBumpMapUv v_bumpMapUv
#define vNormalMapUv v_normalMapUv
#define vDisplacementMapUv v_displacementMapUv
#define vEmissiveMapUv v_emissiveMapUv
#define vMetalnessMapUv v_metalnessMapUv
#define vRoughnessMapUv v_roughnessMapUv
#define vAnisotropyMapUv v_anisotropyMapUv
#define vClearcoatMapUv v_clearcoatMapUv
#define vClearcoatNormalMapUv v_clearcoatNormalMapUv
#define vClearcoatRoughnessMapUv v_clearcoatRoughnessMapUv
#define vIridescenceMapUv v_iridescenceMapUv
#define vIridescenceThicknessMapUv v_iridescenceThicknessMapUv
#define vSheenColorMapUv v_sheenColorMapUv
#define vSheenRoughnessMapUv v_sheenRoughnessMapUv
#define vSpecularMapUv v_specularMapUv
#define vSpecularColorMapUv v_specularColorMapUv
#define vSpecularIntensityMapUv v_specularIntensityMapUv
#define vTransmissionMapUv v_transmissionMapUv
#define vThicknessMapUv v_thicknessMapUv
// three.js uv_vertex 用 MAP_UV/METALNESSMAP_UV 等宏取基 UV；Three.js 由 WebGLProgram
// 按参数注入 #define MAP_UV vUv，此处统一映射到 vUv（vUv 已映射到 v_uv）
#define MAP_UV vUv
#define ALPHAMAP_UV vUv
#define LIGHTMAP_UV vUv
#define AOMAP_UV vUv
#define BUMPMAP_UV vUv
#define NORMALMAP_UV vUv
#define DISPLACEMENTMAP_UV vUv
#define EMISSIVEMAP_UV vUv
#define METALNESSMAP_UV vUv
#define ROUGHNESSMAP_UV vUv
#define ANISOTROPYMAP_UV vUv
#define CLEARCOATMAP_UV vUv
#define CLEARCOAT_NORMALMAP_UV vUv
#define CLEARCOAT_ROUGHNESSMAP_UV vUv
#define IRIDESCENCEMAP_UV vUv
#define IRIDESCENCE_THICKNESSMAP_UV vUv
#define SHEEN_COLORMAP_UV vUv
#define SHEEN_ROUGHNESSMAP_UV vUv
#define SPECULARMAP_UV vUv
#define SPECULAR_COLORMAP_UV vUv
#define SPECULAR_INTENSITYMAP_UV vUv
#define TRANSMISSIONMAP_UV vUv
#define THICKNESSMAP_UV vUv
// FS chunk 引用 specular（vec3），shell 声明 u_specular（vec4）
#define specular u_specular
#define shininess u_shininess
#define vViewPosition v_viewPos
#define isOrthographic false

// three.js envmap_fragment/light 等 chunk 引用 cameraPosition，shell 对应 u_cameraPos
#define cameraPosition u_cameraPos

float pow2( const in float x ) { return x*x; }
vec3 pow2( const in vec3 x ) { return x*x; }
float pow3( const in float x ) { return x*x*x; }
float pow4( const in float x ) { float x2 = x*x; return x2*x2; }
float max3( const in vec3 v ) { return max( max( v.x, v.y ), v.z ); }
float average( const in vec3 v ) { return dot( v, vec3( 0.3333333, 0.3333333, 0.3333333 ) ); }

// expects values in the range of [0,1]x[0,1], returns values in the [0,1] range.
// do not collapse into a single function per: http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
highp float rand( const in vec2 uv ) {

	const highp float a = 12.9898, b = 78.233, c = 43758.5453;
	highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );

	return fract( sin( sn ) * c );

}

#ifdef HIGH_PRECISION
	float precisionSafeLength( vec3 v ) { return length( v ); }
#else
	float precisionSafeLength( vec3 v ) {
		float maxComponent = max3( abs( v ) );
		return length( v / maxComponent ) * maxComponent;
	}
#endif

struct IncidentLight {
	vec3 color;
	vec3 direction;
	bool visible;
};

struct ReflectedLight {
	vec3 directDiffuse;
	vec3 directSpecular;
	vec3 indirectDiffuse;
	vec3 indirectSpecular;
};

#define inverseTransformDirection transformDirectionByInverseViewMatrix // @deprecated r185

vec3 transformNormalByInverseViewMatrix( in vec3 normal, in mat4 vMtx ) {

	// upper-left 3x3 of view matrix is assumed to be orthogonal
	// 显式 dot 乘积绕过 HLSL * 运算符的 mat4/float4 类型解析问题
	vec4 t = vec4( normal, 0.0 );
	return normalize( vec3( dot( vMtx[0], t ), dot( vMtx[1], t ), dot( vMtx[2], t ) ) );

}

vec3 transformDirectionByInverseViewMatrix( in vec3 dir, in mat4 vMtx ) {

	// upper-left 3x3 of view matrix is assumed to be orthogonal
	vec4 t = vec4( dir, 0.0 );
	return normalize( vec3( dot( vMtx[0], t ), dot( vMtx[1], t ), dot( vMtx[2], t ) ) );

}

bool isPerspectiveMatrix( mat4 m ) {

	return m[ 2 ][ 3 ] == - 1.0;

}

vec2 equirectUv( in vec3 dir ) {

	// dir is assumed to be unit length

	float u = atan2( dir.z, dir.x ) * RECIPROCAL_PI2 + 0.5;

	float v = asin( clamp( dir.y, - 1.0, 1.0 ) ) * RECIPROCAL_PI + 0.5;

	return vec2( u, v );

}

vec3 BRDF_Lambert( const in vec3 diffuseColor ) {

	return RECIPROCAL_PI * diffuseColor;

} // validated

vec3 F_Schlick( const in vec3 f0, const in float f90, const in float dotVH ) {

	// Original approximation by Christophe Schlick '94
	// float fresnel = pow( 1.0 - dotVH, 5.0 );

	// Optimized variant (presented by Epic at SIGGRAPH '13)
	// https://cdn2.unrealengine.com/Resources/files/2013SiggraphPresentationsNotes-26915738.pdf
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );

	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );

} // validated

float F_Schlick( const in float f0, const in float f90, const in float dotVH ) {

	// Original approximation by Christophe Schlick '94
	// float fresnel = pow( 1.0 - dotVH, 5.0 );

	// Optimized variant (presented by Epic at SIGGRAPH '13)
	// https://cdn2.unrealengine.com/Resources/files/2013SiggraphPresentationsNotes-26915738.pdf
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );

	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );

} // validated
"#
