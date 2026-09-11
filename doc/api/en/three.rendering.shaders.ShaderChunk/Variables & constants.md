# Variables & constants
## const alphahash\_fragment
```cj
public const alphahash_fragment: String = #"
#ifdef USE_ALPHAHASH

	if ( diffuseColor.a < getAlphaHashThreshold( vPosition ) ) discard;

#endif
"#
```
alphahash_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const alphahash\_pars\_fragment
```cj
public const alphahash_pars_fragment: String = #"
#ifdef USE_ALPHAHASH

	/**
	 * See: https://casual-effects.com/research/Wyman2017Hashed/index.html
	 */

	const float ALPHA_HASH_SCALE = 0.05; // Derived from trials only, and may be changed.

	float hash2D( vec2 value ) {

		return fract( 1.0e4 * sin( 17.0 * value.x + 0.1 * value.y ) * ( 0.1 + abs( sin( 13.0 * value.y + value.x ) ) ) );

	}

	float hash3D( vec3 value ) {

		return hash2D( vec2( hash2D( value.xy ), value.z ) );

	}

	float getAlphaHashThreshold( vec3 position ) {

		// Find the discretized derivatives of our coordinates
		float maxDeriv = max(
			length( dFdx( position.xyz ) ),
			length( dFdy( position.xyz ) )
		);
		float pixScale = 1.0 / ( ALPHA_HASH_SCALE * maxDeriv );

		// Find two nearest log-discretized noise scales
		vec2 pixScales = vec2(
			exp2( floor( log2( pixScale ) ) ),
			exp2( ceil( log2( pixScale ) ) )
		);

		// Compute alpha thresholds at our two noise scales
		vec2 alpha = vec2(
			hash3D( floor( pixScales.x * position.xyz ) ),
			hash3D( floor( pixScales.y * position.xyz ) )
		);

		// Factor to interpolate lerp with
		float lerpFactor = fract( log2( pixScale ) );

		// Interpolate alpha threshold from noise at two scales
		float x = ( 1.0 - lerpFactor ) * alpha.x + lerpFactor * alpha.y;

		// Pass into CDF to compute uniformly distrib threshold
		float a = min( lerpFactor, 1.0 - lerpFactor );
		vec3 cases = vec3(
			x * x / ( 2.0 * a * ( 1.0 - a ) ),
			( x - 0.5 * a ) / ( 1.0 - a ),
			1.0 - ( ( 1.0 - x ) * ( 1.0 - x ) / ( 2.0 * a * ( 1.0 - a ) ) )
		);

		// Find our final, uniformly distributed alpha threshold (ατ)
		float threshold = ( x < ( 1.0 - a ) )
			? ( ( x < a ) ? cases.x : cases.y )
			: cases.z;

		// Avoids ατ == 0. Could also do ατ =1-ατ
		return clamp( threshold , 1.0e-6, 1.0 );

	}

#endif
"#
```
alphahash_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const alphamap\_fragment
```cj
public const alphamap_fragment: String = #"
#ifdef USE_ALPHAMAP

	diffuseColor.a *= texture2D( alphaMap, vAlphaMapUv ).g;

#endif
"#
```
alphamap_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const alphamap\_pars\_fragment
```cj
public const alphamap_pars_fragment: String = #"
#ifdef USE_ALPHAMAP

	uniform sampler2D alphaMap;

#endif
"#
```
alphamap_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const alphatest\_fragment
```cj
public const alphatest_fragment: String = #"
#ifdef USE_ALPHATEST

	#ifdef ALPHA_TO_COVERAGE

	diffuseColor.a = smoothstep( alphaTest, alphaTest + fwidth( diffuseColor.a ), diffuseColor.a );
	if ( diffuseColor.a == 0.0 ) discard;

	#else

	if ( diffuseColor.a < alphaTest ) discard;

	#endif

#endif
"#
```
alphatest_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const alphatest\_pars\_fragment
```cj
public const alphatest_pars_fragment: String = #"
#ifdef USE_ALPHATEST
	uniform float alphaTest;
#endif
"#
```
alphatest_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const aomap\_fragment
```cj
public const aomap_fragment: String = #"
#ifdef USE_AOMAP

	// reads channel R, compatible with a combined OcclusionRoughnessMetallic (RGB) texture
	float ambientOcclusion = ( texture2D( aoMap, vAoMapUv ).r - 1.0 ) * aoMapIntensity + 1.0;

	reflectedLight.indirectDiffuse *= ambientOcclusion;

	#if defined( USE_CLEARCOAT ) 
		clearcoatSpecularIndirect *= ambientOcclusion;
	#endif

	#if defined( USE_SHEEN ) 
		sheenSpecularIndirect *= ambientOcclusion;
	#endif

	#if defined( USE_ENVMAP ) && defined( STANDARD )

		float dotNV = saturate( dot( geometryNormal, geometryViewDir ) );

		reflectedLight.indirectSpecular *= computeSpecularOcclusion( dotNV, ambientOcclusion, material.roughness );

	#endif

#endif
"#
```
aomap_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const aomap\_pars\_fragment
```cj
public const aomap_pars_fragment: String = #"
#ifdef USE_AOMAP

	uniform sampler2D u_aoMap;
	uniform float u_aoMapIntensity;

#endif
"#
```
aomap_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const batching\_pars\_vertex
```cj
public const batching_pars_vertex: String = #"
#ifdef USE_BATCHING
	#if ! defined( GL_ANGLE_multi_draw )
	#define gl_DrawID _gl_DrawID
	uniform int _gl_DrawID;
	#endif

	uniform highp sampler2D batchingTexture;
	uniform highp usampler2D batchingIdTexture;
	mat4 getBatchingMatrix( const in float i ) {

		int size = textureSize( batchingTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( batchingTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( batchingTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( batchingTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( batchingTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );

	}

	float getIndirectIndex( const in int i ) {

		int size = textureSize( batchingIdTexture, 0 ).x;
		int x = i % size;
		int y = i / size;
		return float( texelFetch( batchingIdTexture, ivec2( x, y ), 0 ).r );

	}

#endif

#ifdef USE_BATCHING_COLOR

	uniform sampler2D batchingColorTexture;
	vec4 getBatchingColor( const in float i ) {

		int size = textureSize( batchingColorTexture, 0 ).x;
		int j = int( i );
		int x = j % size;
		int y = j / size;
		return texelFetch( batchingColorTexture, ivec2( x, y ), 0 );

	}

#endif
"#
```
batching_pars_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const batching\_vertex
```cj
public const batching_vertex: String = #"
#ifdef USE_BATCHING
	mat4 batchingMatrix = getBatchingMatrix( getIndirectIndex( gl_DrawID ) );
#endif
"#
```
batching_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const begin\_vertex
```cj
public const begin_vertex: String = #"
vec3 transformed = vec3( position );

#ifdef USE_ALPHAHASH

	vPosition = vec3( position );

#endif
"#
```
begin_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const beginnormal\_vertex
```cj
public const beginnormal_vertex: String = #"
vec3 objectNormal = vec3( normal );

#ifdef USE_TANGENT

	vec3 objectTangent = vec3( tangent.xyz );

#endif
"#
```
beginnormal_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const bgfx\_pbr\_pars
```cj
public const bgfx_pbr_pars: String = #"

// Schlick 菲涅尔近似
vec3 F_Schlick(vec3 f0, float f90, float dotVH)
{
    float x = clamp(1.0 - dotVH, 0.0, 1.0);
    float x2 = x * x;
    float x5 = x * x2 * x2;
    return f0 + (vec3_splat(f90) - f0) * x5;
}

// GGX 法线分布函数 (Trowbridge-Reitz)
float D_GGX(float alpha, float dotNH)
{
    float a2 = alpha * alpha;
    float denom = dotNH * dotNH * (a2 - 1.0) + 1.0;
    return a2 / (3.14159 * denom * denom);
}

// Smith 可见性函数 (GGX 关联形式)
float V_SmithGGXCorrelated(float alpha, float dotNL, float dotNV)
{
    float a2 = alpha * alpha;
    float gv = dotNL * sqrt(a2 + (1.0 - a2) * dotNV * dotNV);
    float gl = dotNV * sqrt(a2 + (1.0 - a2) * dotNL * dotNL);
    return 0.5 / max(gv + gl, 0.0001);
}

// Lambert 漫反射 BRDF
vec3 BRDF_Lambert(vec3 diffuseColor)
{
    return diffuseColor * (1.0 / 3.14159);
}

// 环境 BRDF（对照 Three.js EnvironmentBRDF + DFGLUT）
vec3 EnvironmentBRDF(vec3 specularColor, float roughness, float dotNV)
{
    vec2 uv = vec2(roughness, dotNV);
    vec2 fab = texture2D(dfgLUT, uv).rg;
    return specularColor * fab.x + vec3_splat(1.0) * fab.y;
}

// SH3 球谐辐照度（对照 Three.js getShIrradianceAt）
vec3 getShIrradianceAt(vec3 normal)
{
    float x = normal.x, y = normal.y, z = normal.z;

    // band 0
    vec3 result = shCoefficients[0].xyz * 0.886227;

    // band 1
    result += shCoefficients[1].xyz * (2.0 * 0.511664) * y;
    result += shCoefficients[2].xyz * (2.0 * 0.511664) * z;
    result += shCoefficients[3].xyz * (2.0 * 0.511664) * x;

    // band 2
    result += shCoefficients[4].xyz * (2.0 * 0.429043) * x * y;
    result += shCoefficients[5].xyz * (2.0 * 0.429043) * y * z;
    result += shCoefficients[6].xyz * (z * z * 0.743125 - 0.247708);
    result += shCoefficients[7].xyz * (2.0 * 0.429043) * x * z;
    result += shCoefficients[8].xyz * 0.429043 * (x * x - y * y);

    return result;
}

// 多散射补偿（参照 Three.js computeMultiscattering）
void computeMultiscattering(vec3 normal, vec3 viewDir, vec3 specularColor, float specularF90, float roughness, inout vec3 singleScatter, inout vec3 multiScatter)
{
    float dotNV = saturate(dot(normal, viewDir));
    float x = 1.0 - dotNV;
    float x5 = x * x * x * x * x;
    vec3 Fr = specularColor;
    vec3 FssEss = Fr * (1.0 - x5) + vec3_splat(specularF90) * x5;
    float Ess = (1.0 - x5) * 0.6 + x5 * 0.4;
    float Ems = 1.0 - Ess;
    vec3 Favg = Fr + (vec3_splat(1.0) - Fr) * 0.047619;
    vec3 Fms = FssEss * Favg / max(vec3_splat(1.0) - Ems * Favg, vec3_splat(0.001));
    singleScatter += FssEss;
    multiScatter += Fms * Ems;
}

// 法线贴图切线空间构建（参照 Three.js getTangentFrame）
mat3 getTangentFrame(vec3 viewDir, vec3 surfNorm, vec2 uv)
{
    vec3 q0 = dFdx(viewDir);
    vec3 q1 = dFdy(viewDir);
    vec2 st0 = dFdx(uv);
    vec2 st1 = dFdy(uv);
    vec3 N = surfNorm;
    vec3 q1perp = cross(q1, N);
    vec3 q0perp = cross(N, q0);
    vec3 T = q1perp * st0.x + q0perp * st1.x;
    vec3 B = q1perp * st0.y + q0perp * st1.y;
    float det = max(dot(T, T), dot(B, B));
    float scale = (det == 0.0) ? 0.0 : inversesqrt(det);
    return mat3(T.x * scale, T.y * scale, T.z * scale, B.x * scale, B.y * scale, B.z * scale, N.x, N.y, N.z);
}
"#
```
bgfx PBR helper functions GLSL fragment string

## const bsdfs
```cj
public const bsdfs: String = #"

float G_BlinnPhong_Implicit( /* const in float dotNL, const in float dotNV */ ) {

	// geometry term is (n dot l)(n dot v) / 4(n dot l)(n dot v)
	return 0.25;

}

float D_BlinnPhong( const in float shininess, const in float dotNH ) {

	return RECIPROCAL_PI * ( shininess * 0.5 + 1.0 ) * pow( dotNH, shininess );

}

vec3 BRDF_BlinnPhong( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in vec3 specularColor, const in float shininess ) {

	vec3 halfDir = normalize( lightDir + viewDir );

	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );

	vec3 F = F_Schlick( specularColor, 1.0, dotVH );

	float G = G_BlinnPhong_Implicit( /* dotNL, dotNV */ );

	float D = D_BlinnPhong( shininess, dotNH );

	return F * ( G * D );

} // validated
"#
```
bsdfs GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const bumpmap\_pars\_fragment
```cj
public const bumpmap_pars_fragment: String = #"
#ifdef USE_BUMPMAP

	uniform sampler2D bumpMap;
	uniform float bumpScale;

	// Bump Mapping Unparametrized Surfaces on the GPU by Morten S. Mikkelsen
	// https://mmikk.github.io/papers3d/mm_sfgrad_bump.pdf

	// Evaluate the derivative of the height w.r.t. screen-space using forward differencing (listing 2)

	vec2 dHdxy_fwd() {

		vec2 dSTdx = dFdx( vBumpMapUv );
		vec2 dSTdy = dFdy( vBumpMapUv );

		float Hll = bumpScale * texture2D( bumpMap, vBumpMapUv ).x;
		float dBx = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdx ).x - Hll;
		float dBy = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdy ).x - Hll;

		return vec2( dBx, dBy );

	}

	vec3 perturbNormalArb( vec3 surf_pos, vec3 surf_norm, vec2 dHdxy, float faceDirection ) {

		// normalize is done to ensure that the bump map looks the same regardless of the texture's scale
		vec3 vSigmaX = normalize( dFdx( surf_pos.xyz ) );
		vec3 vSigmaY = normalize( dFdy( surf_pos.xyz ) );
		vec3 vN = surf_norm; // normalized

		vec3 R1 = cross( vSigmaY, vN );
		vec3 R2 = cross( vN, vSigmaX );

		float fDet = dot( vSigmaX, R1 ) * faceDirection;

		vec3 vGrad = sign( fDet ) * ( dHdxy.x * R1 + dHdxy.y * R2 );
		return normalize( abs( fDet ) * surf_norm - vGrad );

	}

#endif
"#
```
bumpmap_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const clearcoat\_normal\_fragment\_begin
```cj
public const clearcoat_normal_fragment_begin: String = #"
#ifdef USE_CLEARCOAT

	vec3 clearcoatNormal = nonPerturbedNormal;

#endif
"#
```
clearcoat_normal_fragment_begin GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const clearcoat\_normal\_fragment\_maps
```cj
public const clearcoat_normal_fragment_maps: String = #"
#ifdef USE_CLEARCOAT_NORMALMAP

	vec3 clearcoatMapN = texture2D( clearcoatNormalMap, vClearcoatNormalMapUv ).xyz * 2.0 - 1.0;
	clearcoatMapN.xy *= clearcoatNormalScale;

	clearcoatNormal = normalize( tbn2 * clearcoatMapN );

#endif
"#
```
clearcoat_normal_fragment_maps GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const clearcoat\_pars\_fragment
```cj
public const clearcoat_pars_fragment: String = #"

#ifdef USE_CLEARCOATMAP

	uniform sampler2D clearcoatMap;

#endif

#ifdef USE_CLEARCOAT_NORMALMAP

	uniform sampler2D clearcoatNormalMap;
	uniform vec2 clearcoatNormalScale;

#endif

#ifdef USE_CLEARCOAT_ROUGHNESSMAP

	uniform sampler2D clearcoatRoughnessMap;

#endif
"#
```
clearcoat_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const clipping\_planes\_fragment
```cj
public const clipping_planes_fragment: String = #"
#if NUM_CLIPPING_PLANES > 0

	vec4 plane;

	#ifdef ALPHA_TO_COVERAGE

		float distanceToPlane, distanceGradient;
		float clipOpacity = 1.0;

		UNROLL
		for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {

			plane = clippingPlanes[ i ];
			distanceToPlane = - dot( vClipPosition, plane.xyz ) + plane.w;
			distanceGradient = fwidth( distanceToPlane ) / 2.0;
			clipOpacity *= smoothstep( - distanceGradient, distanceGradient, distanceToPlane );

			if ( clipOpacity == 0.0 ) discard;

		}
		

		#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES

			float unionClipOpacity = 1.0;

			UNROLL
			for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {

				plane = clippingPlanes[ i ];
				distanceToPlane = - dot( vClipPosition, plane.xyz ) + plane.w;
				distanceGradient = fwidth( distanceToPlane ) / 2.0;
				unionClipOpacity *= 1.0 - smoothstep( - distanceGradient, distanceGradient, distanceToPlane );

			}
			

			clipOpacity *= 1.0 - unionClipOpacity;

		#endif

		diffuseColor.a *= clipOpacity;

		if ( diffuseColor.a == 0.0 ) discard;

	#else

		UNROLL
		for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {

			plane = clippingPlanes[ i ];
			if ( dot( vClipPosition, plane.xyz ) > plane.w ) discard;

		}
		

		#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES

			bool clipped = true;

			UNROLL
			for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {

				plane = clippingPlanes[ i ];
				clipped = ( dot( vClipPosition, plane.xyz ) > plane.w ) && clipped;

			}
			

			if ( clipped ) discard;

		#endif

	#endif

#endif
"#
```
clipping_planes_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const clipping\_planes\_pars\_fragment
```cj
public const clipping_planes_pars_fragment: String = #"
#if NUM_CLIPPING_PLANES > 0

	uniform vec4 clippingPlanes[ NUM_CLIPPING_PLANES ];

#endif
"#
```
clipping_planes_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const clipping\_planes\_pars\_vertex
```cj
public const clipping_planes_pars_vertex: String = #""#
```
clipping_planes_pars_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const clipping\_planes\_vertex
```cj
public const clipping_planes_vertex: String = #"
#if NUM_CLIPPING_PLANES > 0

	vClipPosition = - mvPosition.xyz;

#endif
"#
```
clipping_planes_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const color\_fragment
```cj
public const color_fragment: String = #"
#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA )

	diffuseColor *= vColor;

#endif
"#
```
color_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const color\_pars\_fragment
```cj
public const color_pars_fragment: String = #""#
```
color_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const color\_pars\_vertex
```cj
public const color_pars_vertex: String = #""#
```
color_pars_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const color\_vertex
```cj
public const color_vertex: String = #"
#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA ) || defined( USE_INSTANCING_COLOR ) || defined( USE_BATCHING_COLOR )

	vColor = vec4( 1.0 );

#endif

#ifdef USE_COLOR_ALPHA

	vColor *= color;

#elif defined( USE_COLOR )

	vColor.rgb *= color;

#endif

#ifdef USE_INSTANCING_COLOR

	vColor.rgb *= instanceColor.rgb;

#endif

#ifdef USE_BATCHING_COLOR

	vColor *= getBatchingColor( getIndirectIndex( gl_DrawID ) );

#endif
"#
```
color_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const colorspace\_fragment
```cj
public const colorspace_fragment: String = #"
gl_FragColor = gl_FragColor;
"#
```
colorspace_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const colorspace\_pars\_fragment
```cj
public const colorspace_pars_fragment: String = #"

vec4 LinearTransferOETF( in vec4 value ) {
	return value;
}

// sRGBTransferEOTF/OETF 未在基础渲染管线中使用（linearToOutputTexel 为空定义），
// 注释掉以避免 HLSL 编译器中 mix/pow 嵌套调用导致的 X3014 参数数量错误。
// 后续需要 srgb 编解码时再恢复，并确认 bgfx GLSL→HLSL 翻译器兼容性。

#define linearToOutputTexel
"#
```
colorspace_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const common
```cj
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
// 映射到 bgfx scene 标准 uniform（由 ThreeRenderer 绑定到 u_view/u_proj/u_model[0] 等）
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
```
common GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const cube\_uv\_reflection\_fragment
```cj
public const cube_uv_reflection_fragment: String = #"
#ifdef ENVMAP_TYPE_CUBE_UV

	#define cubeUV_minMipLevel 4.0
	#define cubeUV_minTileSize 16.0

	// These shader functions convert between the UV coordinates of a single face of
	// a cubemap, the 0-5 integer index of a cube face, and the direction vector for
	// sampling a textureCube (not generally normalized ).

	float getFace( vec3 direction ) {

		vec3 absDirection = abs( direction );

		float face = - 1.0;

		if ( absDirection.x > absDirection.z ) {

			if ( absDirection.x > absDirection.y )

				face = direction.x > 0.0 ? 0.0 : 3.0;

			else

				face = direction.y > 0.0 ? 1.0 : 4.0;

		} else {

			if ( absDirection.z > absDirection.y )

				face = direction.z > 0.0 ? 2.0 : 5.0;

			else

				face = direction.y > 0.0 ? 1.0 : 4.0;

		}

		return face;

	}

	// RH coordinate system; PMREM face-indexing convention
	vec2 getUV( vec3 direction, float face ) {

		vec2 uv;

		if ( face == 0.0 ) {

			uv = vec2( direction.z, direction.y ) / abs( direction.x ); // pos x

		} else if ( face == 1.0 ) {

			uv = vec2( - direction.x, - direction.z ) / abs( direction.y ); // pos y

		} else if ( face == 2.0 ) {

			uv = vec2( - direction.x, direction.y ) / abs( direction.z ); // pos z

		} else if ( face == 3.0 ) {

			uv = vec2( - direction.z, direction.y ) / abs( direction.x ); // neg x

		} else if ( face == 4.0 ) {

			uv = vec2( - direction.x, direction.z ) / abs( direction.y ); // neg y

		} else {

			uv = vec2( direction.x, direction.y ) / abs( direction.z ); // neg z

		}

		return 0.5 * ( uv + 1.0 );

	}

	vec3 bilinearCubeUV( sampler2D envMap, vec3 direction, float mipInt ) {

		float face = getFace( direction );

		float filterInt = max( cubeUV_minMipLevel - mipInt, 0.0 );

		mipInt = max( mipInt, cubeUV_minMipLevel );

		float faceSize = exp2( mipInt );

		highp vec2 uv = getUV( direction, face ) * ( faceSize - 2.0 ) + 1.0; // #25071

		if ( face > 2.0 ) {

			uv.y += faceSize;

			face -= 3.0;

		}

		uv.x += face * faceSize;

		uv.x += filterInt * 3.0 * cubeUV_minTileSize;

		uv.y += 4.0 * ( exp2( CUBEUV_MAX_MIP ) - faceSize );

		uv.x *= CUBEUV_TEXEL_WIDTH;
		uv.y *= CUBEUV_TEXEL_HEIGHT;

		#ifdef texture2DGradEXT

			return texture2DGradEXT( envMap, uv, vec2( 0.0 ), vec2( 0.0 ) ).rgb; // disable anisotropic filtering

		#else

			return texture2D( envMap, uv ).rgb;

		#endif

	}

	// These defines must match with PMREMGenerator

	#define cubeUV_r0 1.0
	#define cubeUV_m0 - 2.0
	#define cubeUV_r1 0.8
	#define cubeUV_m1 - 1.0
	#define cubeUV_r4 0.4
	#define cubeUV_m4 2.0
	#define cubeUV_r5 0.305
	#define cubeUV_m5 3.0
	#define cubeUV_r6 0.21
	#define cubeUV_m6 4.0

	float roughnessToMip( float roughness ) {

		float mip = 0.0;

		if ( roughness >= cubeUV_r1 ) {

			mip = ( cubeUV_r0 - roughness ) * ( cubeUV_m1 - cubeUV_m0 ) / ( cubeUV_r0 - cubeUV_r1 ) + cubeUV_m0;

		} else if ( roughness >= cubeUV_r4 ) {

			mip = ( cubeUV_r1 - roughness ) * ( cubeUV_m4 - cubeUV_m1 ) / ( cubeUV_r1 - cubeUV_r4 ) + cubeUV_m1;

		} else if ( roughness >= cubeUV_r5 ) {

			mip = ( cubeUV_r4 - roughness ) * ( cubeUV_m5 - cubeUV_m4 ) / ( cubeUV_r4 - cubeUV_r5 ) + cubeUV_m4;

		} else if ( roughness >= cubeUV_r6 ) {

			mip = ( cubeUV_r5 - roughness ) * ( cubeUV_m6 - cubeUV_m5 ) / ( cubeUV_r5 - cubeUV_r6 ) + cubeUV_m5;

		} else {

			mip = - 2.0 * log2( 1.16 * roughness ); // 1.16 = 1.79^0.25
		}

		return mip;

	}

	vec4 textureCubeUV( sampler2D envMap, vec3 sampleDir, float roughness ) {

		float mip = clamp( roughnessToMip( roughness ), cubeUV_m0, CUBEUV_MAX_MIP );

		float mipF = fract( mip );

		float mipInt = floor( mip );

		vec3 color0 = bilinearCubeUV( envMap, sampleDir, mipInt );

		if ( mipF == 0.0 ) {

			return vec4( color0, 1.0 );

		} else {

			vec3 color1 = bilinearCubeUV( envMap, sampleDir, mipInt + 1.0 );

			return vec4( mix( color0, color1, mipF ), 1.0 );

		}

	}

#endif
"#
```
cube_uv_reflection_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const default\_fragment
```cj
public const default_fragment: String = #"
void main() {
	gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}
"#
```
default_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const default\_vertex
```cj
public const default_vertex: String = #"
void main() {
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}
"#
```
default_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const defaultnormal\_vertex
```cj
public const defaultnormal_vertex: String = #"

vec3 transformedNormal = objectNormal;
#ifdef USE_TANGENT

	vec3 transformedTangent = objectTangent;

#endif

#ifdef USE_BATCHING

	// this is in lieu of a per-instance normal-matrix
	// non-uniform scaling in the instance matrix is supported
	// shear transforms are not supported

	mat3 bm = mat3( batchingMatrix );
	transformedNormal /= vec3( dot( bm[ 0 ], bm[ 0 ] ), dot( bm[ 1 ], bm[ 1 ] ), dot( bm[ 2 ], bm[ 2 ] ) );
	transformedNormal = bm * transformedNormal;

	#ifdef USE_TANGENT

		transformedTangent = bm * transformedTangent;

	#endif

#endif

#ifdef USE_INSTANCING

	// this is in lieu of a per-instance normal-matrix
	// non-uniform scaling in the instance matrix is supported
	// shear transforms are not supported

	mat3 im = mat3( instanceMatrix );
	transformedNormal /= vec3( dot( im[ 0 ], im[ 0 ] ), dot( im[ 1 ], im[ 1 ] ), dot( im[ 2 ], im[ 2 ] ) );
	transformedNormal = im * transformedNormal;

	#ifdef USE_TANGENT

		transformedTangent = im * transformedTangent;

	#endif

#endif

transformedNormal = mul( normalMatrix, transformedNormal );

#ifdef FLIP_SIDED

	transformedNormal = - transformedNormal;

#endif

#ifdef USE_TANGENT

	transformedTangent = ( modelViewMatrix * vec4( transformedTangent, 0.0 ) ).xyz;

#endif
"#
```
defaultnormal_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const displacementmap\_pars\_vertex
```cj
public const displacementmap_pars_vertex: String = #"
#ifdef USE_DISPLACEMENTMAP

	uniform sampler2D displacementMap;
	uniform float displacementScale;
	uniform float displacementBias;

#endif
"#
```
displacementmap_pars_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const displacementmap\_vertex
```cj
public const displacementmap_vertex: String = #"
#ifdef USE_DISPLACEMENTMAP

	transformed += normalize( objectNormal ) * ( texture2D( displacementMap, vDisplacementMapUv ).x * displacementScale + displacementBias );

#endif
"#
```
displacementmap_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const dithering\_fragment
```cj
public const dithering_fragment: String = #"
#ifdef DITHERING

	gl_FragColor.rgb = dithering( gl_FragColor.rgb );

#endif
"#
```
dithering_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const dithering\_pars\_fragment
```cj
public const dithering_pars_fragment: String = #"
#ifdef DITHERING

	// based on https://www.shadertoy.com/view/MslGR8
	vec3 dithering( vec3 color ) {
		//Calculate grid position
		float grid_position = rand( gl_FragCoord.xy );

		//Shift the individual colors differently, thus making it even harder to see the dithering pattern
		vec3 dither_shift_RGB = vec3( 0.25 / 255.0, -0.25 / 255.0, 0.25 / 255.0 );

		//modify shift according to grid position.
		dither_shift_RGB = mix( 2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position );

		//shift the color by dither_shift
		return color + dither_shift_RGB;
	}

#endif
"#
```
dithering_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const emissivemap\_fragment
```cj
public const emissivemap_fragment: String = #"
#ifdef USE_EMISSIVEMAP

	vec4 emissiveColor = texture2D( emissiveMap, vEmissiveMapUv );

	#ifdef DECODE_VIDEO_TEXTURE_EMISSIVE

		// use inline sRGB decode until browsers properly support SRGB8_ALPHA8 with video textures (#26516)

		emissiveColor = sRGBTransferEOTF( emissiveColor );

	#endif

	totalEmissiveRadiance *= emissiveColor.rgb;

#endif
"#
```
emissivemap_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const emissivemap\_pars\_fragment
```cj
public const emissivemap_pars_fragment: String = #"
#ifdef USE_EMISSIVEMAP

	uniform sampler2D u_emissiveMap;

#endif
"#
```
emissivemap_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const encodings\_pars\_fragment
```cj
public const encodings_pars_fragment: String = #"
// encodings not implemented
"#
```
encodings_pars_fragment GLSL 片段字符串

## const envmap\_common\_pars\_fragment
```cj
public const envmap_common_pars_fragment: String = #"
#ifdef USE_ENVMAP

	uniform float envMapIntensity;
	uniform mat3 envMapRotation;

	#ifdef ENVMAP_TYPE_CUBE
		uniform samplerCube envMap;
	#else
		uniform sampler2D envMap;
	#endif

#endif
"#
```
envmap_common_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const envmap\_fragment
```cj
public const envmap_fragment: String = #"
#ifdef USE_ENVMAP

	#ifdef ENV_WORLDPOS

		vec3 cameraToFrag;

		if ( isOrthographic ) {

		 cameraToFrag = normalize( vec3( viewMatrix[ 0 ][ 2 ], viewMatrix[ 1 ][ 2 ], viewMatrix[ 2 ][ 2 ] ) );

		} else {

			cameraToFrag = normalize( vWorldPosition - cameraPosition );

		}

		// Transforming Normal Vectors with the Inverse Transformation
		vec3 worldNormal = transformNormalByInverseViewMatrix( normal, viewMatrix );

		#ifdef ENVMAP_MODE_REFLECTION

			vec3 reflectVec = reflect( cameraToFrag, worldNormal );

		#else

			vec3 reflectVec = refract( cameraToFrag, worldNormal, refractionRatio );

		#endif

	#else

		vec3 reflectVec = vReflect;

	#endif

	#ifdef ENVMAP_TYPE_CUBE

		vec4 envColor = textureCube( envMap, envMapRotation * reflectVec );

		#ifdef ENVMAP_BLENDING_MULTIPLY

			outgoingLight = mix( outgoingLight, outgoingLight * envColor.xyz, specularStrength * reflectivity );

		#elif defined( ENVMAP_BLENDING_MIX )

			outgoingLight = mix( outgoingLight, envColor.xyz, specularStrength * reflectivity );

		#elif defined( ENVMAP_BLENDING_ADD )

			outgoingLight += envColor.xyz * specularStrength * reflectivity;

		#endif

	#endif

#endif
"#
```
envmap_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const envmap\_pars\_fragment
```cj
public const envmap_pars_fragment: String = #"
#ifdef USE_ENVMAP

	uniform float reflectivity;

	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )

		#define ENV_WORLDPOS

	#endif

	#ifdef ENV_WORLDPOS

		uniform float refractionRatio;
	#else
	#endif

#endif
"#
```
envmap_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const envmap\_pars\_vertex
```cj
public const envmap_pars_vertex: String = #"
#ifdef USE_ENVMAP

	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )

		#define ENV_WORLDPOS

	#endif

	#ifdef ENV_WORLDPOS

	#else

		uniform float refractionRatio;

	#endif

#endif
"#
```
envmap_pars_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const envmap\_physical\_pars\_fragment
```cj
public const envmap_physical_pars_fragment: String = #"
#ifdef USE_ENVMAP

	vec3 getIBLIrradiance( const in vec3 normal ) {

		#ifdef ENVMAP_TYPE_CUBE_UV

			vec3 worldNormal = transformNormalByInverseViewMatrix( normal, viewMatrix );

			vec4 envMapColor = textureCubeUV( envMap, envMapRotation * worldNormal, 1.0 );

			return PI * envMapColor.rgb * envMapIntensity;

		#else

			return vec3(0.0, 0.0, 0.0);

		#endif

	}

	vec3 getIBLRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness ) {

		#ifdef ENVMAP_TYPE_CUBE_UV

			vec3 reflectVec = reflect( - viewDir, normal );

			// Mixing the reflection with the normal is more accurate and keeps rough objects from gathering light from behind their tangent plane.
			reflectVec = normalize( mix( reflectVec, normal, pow4( roughness ) ) );

			reflectVec = transformDirectionByInverseViewMatrix( reflectVec, viewMatrix );

			vec4 envMapColor = textureCubeUV( envMap, envMapRotation * reflectVec, roughness );

			return envMapColor.rgb * envMapIntensity;

		#else

			return vec3(0.0, 0.0, 0.0);

		#endif

	}

	#ifdef USE_ANISOTROPY

		vec3 getIBLAnisotropyRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness, const in vec3 bitangent, const in float anisotropy ) {

			#ifdef ENVMAP_TYPE_CUBE_UV

			  // https://google.github.io/filament/Filament.md.html#lighting/imagebasedlights/anisotropy
				vec3 bentNormal = cross( bitangent, viewDir );
				bentNormal = normalize( cross( bentNormal, bitangent ) );
				bentNormal = normalize( mix( bentNormal, normal, pow2( pow2( 1.0 - anisotropy * ( 1.0 - roughness ) ) ) ) );

				return getIBLRadiance( viewDir, bentNormal, roughness );

			#else

				return vec3(0.0, 0.0, 0.0);

			#endif

		}

	#endif

#endif
"#
```
envmap_physical_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const envmap\_vertex
```cj
public const envmap_vertex: String = #"
#ifdef USE_ENVMAP

	#ifdef ENV_WORLDPOS

		vWorldPosition = worldPosition.xyz;

	#else

		vec3 cameraToVertex;

		if ( isOrthographic ) {

		 cameraToVertex = normalize( vec3( viewMatrix[ 0 ][ 2 ], viewMatrix[ 1 ][ 2 ], viewMatrix[ 2 ][ 2 ] ) );

		} else {

			cameraToVertex = normalize( worldPosition.xyz - cameraPosition );

		}

		vec3 worldNormal = transformNormalByInverseViewMatrix( transformedNormal, viewMatrix );

		#ifdef ENVMAP_MODE_REFLECTION

			vReflect = reflect( cameraToVertex, worldNormal );

		#else

			vReflect = refract( cameraToVertex, worldNormal, refractionRatio );

		#endif

	#endif

#endif
"#
```
envmap_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const fog\_fragment
```cj
public const fog_fragment: String = #"
#ifdef USE_FOG

	#ifdef FOG_EXP2

		float fogFactor = 1.0 - exp( - fogDensity * fogDensity * vFogDepth * vFogDepth );

	#else

		float fogFactor = smoothstep( fogNear, fogFar, vFogDepth );

	#endif

	gl_FragColor.rgb = mix( gl_FragColor.rgb, fogColor, fogFactor );

#endif
"#
```
fog_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const fog\_pars\_fragment
```cj
public const fog_pars_fragment: String = #"
#ifdef USE_FOG

	uniform vec3 fogColor;

	#ifdef FOG_EXP2

		uniform float fogDensity;

	#else

		uniform float fogNear;
		uniform float fogFar;

	#endif

#endif
"#
```
fog_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const fog\_pars\_vertex
```cj
public const fog_pars_vertex: String = #""#
```
fog_pars_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const fog\_vertex
```cj
public const fog_vertex: String = #"
#ifdef USE_FOG

	vFogDepth = - mvPosition.z;

#endif
"#
```
fog_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const gradientmap\_pars\_fragment
```cj
public const gradientmap_pars_fragment: String = #"

#ifdef USE_GRADIENTMAP

	uniform sampler2D gradientMap;

#endif

vec3 getGradientIrradiance( vec3 normal, vec3 lightDirection ) {

	// dotNL will be from -1.0 to 1.0
	float dotNL = dot( normal, lightDirection );
	vec2 coord = vec2( dotNL * 0.5 + 0.5, 0.0 );

	#ifdef USE_GRADIENTMAP

		return vec3( texture2D( gradientMap, coord ).r );

	#else

		vec2 fw = fwidth( coord ) * 0.5;
		return mix( vec3( 0.7 ), vec3( 1.0 ), smoothstep( 0.7 - fw.x, 0.7 + fw.x, coord.x ) );

	#endif

}
"#
```
gradientmap_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const iridescence\_fragment
```cj
public const iridescence_fragment: String = #"

#ifdef USE_IRIDESCENCE

	// XYZ to linear-sRGB color space
	const mat3 XYZ_TO_REC709 = mat3(
		 3.2404542, -0.9692660,  0.0556434,
		-1.5371385,  1.8760108, -0.2040259,
		-0.4985314,  0.0415560,  1.0572252
	);

	// Assume air interface for top
	// Note: We don't handle the case fresnel0 == 1
	vec3 Fresnel0ToIor( vec3 fresnel0 ) {

		vec3 sqrtF0 = sqrt( fresnel0 );
		return ( vec3( 1.0 ) + sqrtF0 ) / ( vec3( 1.0 ) - sqrtF0 );

	}

	// Conversion FO/IOR
	vec3 IorToFresnel0( vec3 transmittedIor, float incidentIor ) {

		return pow2( ( transmittedIor - vec3( incidentIor, incidentIor, incidentIor ) ) / ( transmittedIor + vec3( incidentIor, incidentIor, incidentIor ) ) );

	}

	// ior is a value between 1.0 and 3.0. 1.0 is air interface
	float IorToFresnel0( float transmittedIor, float incidentIor ) {

		return pow2( ( transmittedIor - incidentIor ) / ( transmittedIor + incidentIor ));

	}

	// Fresnel equations for dielectric/dielectric interfaces.
	// Ref: https://belcour.github.io/blog/research/2017/05/01/brdf-thin-film.html
	// Evaluation XYZ sensitivity curves in Fourier space
	vec3 evalSensitivity( float OPD, vec3 shift ) {

		float phase = 2.0 * PI * OPD * 1.0e-9;
		vec3 val = vec3( 5.4856e-13, 4.4201e-13, 5.2481e-13 );
		vec3 pos = vec3( 1.6810e+06, 1.7953e+06, 2.2084e+06 );
		vec3 var = vec3( 4.3278e+09, 9.3046e+09, 6.6121e+09 );

		vec3 xyz = val * sqrt( 2.0 * PI * var ) * cos( pos * phase + shift ) * exp( - pow2( phase ) * var );
		xyz.x += 9.7470e-14 * sqrt( 2.0 * PI * 4.5282e+09 ) * cos( 2.2399e+06 * phase + shift[ 0 ] ) * exp( - 4.5282e+09 * pow2( phase ) );
		xyz /= 1.0685e-7;

		vec3 rgb = XYZ_TO_REC709 * xyz;
		return rgb;

	}

	vec3 evalIridescence( float outsideIOR, float eta2, float cosTheta1, float thinFilmThickness, vec3 baseF0 ) {

		vec3 I;

		// Force iridescenceIOR -> outsideIOR when thinFilmThickness -> 0.0
		float iridescenceIOR = mix( outsideIOR, eta2, smoothstep( 0.0, 0.03, thinFilmThickness ) );
		// Evaluate the cosTheta on the base layer (Snell law)
		float sinTheta2Sq = pow2( outsideIOR / iridescenceIOR ) * ( 1.0 - pow2( cosTheta1 ) );

		// Handle TIR:
		float cosTheta2Sq = 1.0 - sinTheta2Sq;
		if ( cosTheta2Sq < 0.0 ) {

			return vec3( 1.0 );

		}

		float cosTheta2 = sqrt( cosTheta2Sq );

		// First interface
		float R0 = IorToFresnel0( iridescenceIOR, outsideIOR );
		float R12 = F_Schlick( R0, 1.0, cosTheta1 );
		float T121 = 1.0 - R12;
		float phi12 = 0.0;
		if ( iridescenceIOR < outsideIOR ) phi12 = PI;
		float phi21 = PI - phi12;

		// Second interface
		vec3 baseIOR = Fresnel0ToIor( clamp( baseF0, 0.0, 0.9999 ) ); // guard against 1.0
		vec3 R1 = IorToFresnel0( baseIOR, iridescenceIOR );
		vec3 R23 = F_Schlick( R1, 1.0, cosTheta2 );
		vec3 phi23 = vec3(0.0, 0.0, 0.0);
		if ( baseIOR[ 0 ] < iridescenceIOR ) phi23[ 0 ] = PI;
		if ( baseIOR[ 1 ] < iridescenceIOR ) phi23[ 1 ] = PI;
		if ( baseIOR[ 2 ] < iridescenceIOR ) phi23[ 2 ] = PI;

		// Phase shift
		float OPD = 2.0 * iridescenceIOR * thinFilmThickness * cosTheta2;
		vec3 phi = vec3( phi21, phi21, phi21 ) + phi23;

		// Compound terms
		vec3 R123 = clamp( R12 * R23, 1e-5, 0.9999 );
		vec3 r123 = sqrt( R123 );
		vec3 Rs = pow2( T121 ) * R23 / ( vec3( 1.0 ) - R123 );

		// Reflectance term for m = 0 (DC term amplitude)
		vec3 C0 = R12 + Rs;
		I = C0;

		// Reflectance term for m > 0 (pairs of diracs)
		vec3 Cm = Rs - T121;
		for ( int m = 1; m <= 2; ++ m ) {

			Cm *= r123;
			vec3 Sm = 2.0 * evalSensitivity( float( m ) * OPD, float( m ) * phi );
			I += Cm * Sm;

		}

		// Since out of gamut colors might be produced, negative color values are clamped to 0.
		return max( I, vec3(0.0, 0.0, 0.0) );

	}

#endif
"#
```
iridescence_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const iridescence\_pars\_fragment
```cj
public const iridescence_pars_fragment: String = #"

#ifdef USE_IRIDESCENCEMAP

	uniform sampler2D iridescenceMap;

#endif

#ifdef USE_IRIDESCENCE_THICKNESSMAP

	uniform sampler2D iridescenceThicknessMap;

#endif
"#
```
iridescence_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lightmap\_pars\_fragment
```cj
public const lightmap_pars_fragment: String = #"
#ifdef USE_LIGHTMAP

	uniform sampler2D u_lightMap;
	uniform float u_lightMapIntensity;

#endif
"#
```
lightmap_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lightprobes\_pars\_fragment
```cj
public const lightprobes_pars_fragment: String = #"
#ifdef USE_LIGHT_PROBES_GRID

// Single atlas 3D texture that stores all 7 SH sub-volumes stacked along Z.
// Atlas depth = 7 * ( nz + 2 ) where nz = probesResolution.z.
// Each sub-volume occupies ( nz + 2 ) slices: 1 padding + nz data + 1 padding.
// Padding is a copy of the first / last data slice and prevents color bleeding
// when the hardware linear filter reads across a sub-volume boundary.
uniform highp sampler3D probesSH;

uniform vec3 probesMin;
uniform vec3 probesMax;
uniform vec3 probesResolution;

vec3 getLightProbeGridIrradiance( vec3 worldPos, vec3 worldNormal ) {

	vec3 res = probesResolution;
	vec3 gridRange = probesMax - probesMin;
	vec3 resMinusOne = res - 1.0;
	vec3 probeSpacing = gridRange / resMinusOne;

	// Offset sample position along normal by half a probe spacing
	vec3 samplePos = worldPos + worldNormal * probeSpacing * 0.5;
	vec3 uvw = clamp( ( samplePos - probesMin ) / gridRange, 0.0, 1.0 );

	// Remap to texel centers of the probe grid (XY and Z)
	uvw = uvw * resMinusOne / res + 0.5 / res;

	// Atlas UV mapping along Z:
	//   paddedSlices = nz + 2  (1 padding texel at each end of every sub-volume)
	//   atlasDepth   = 7 * paddedSlices
	//   For sub-volume t the first DATA texel sits at atlas slice t*paddedSlices + 1.
	//   Given probe-grid texel-centre UVZ = ( iz + 0.5 ) / nz the atlas UV is:
	//     atlasUvZ = ( uvw.z * nz + t * paddedSlices + 1 ) / atlasDepth
	//
	// uvZBase encodes the nz-scaled Z plus the intra-volume offset (+ 1 for padding),
	// so adding t*paddedSlices steps to each successive sub-volume.
	float nz          = res.z;
	float paddedSlices = nz + 2.0;
	float atlasDepth  = 7.0 * paddedSlices;
	float uvZBase     = uvw.z * nz + 1.0;

	vec4 s0 = shadow2D( probesSH, vec3( uvw.xy, ( uvZBase                       ) / atlasDepth ) );
	vec4 s1 = shadow2D( probesSH, vec3( uvw.xy, ( uvZBase +       paddedSlices   ) / atlasDepth ) );
	vec4 s2 = shadow2D( probesSH, vec3( uvw.xy, ( uvZBase + 2.0 * paddedSlices   ) / atlasDepth ) );
	vec4 s3 = shadow2D( probesSH, vec3( uvw.xy, ( uvZBase + 3.0 * paddedSlices   ) / atlasDepth ) );
	vec4 s4 = shadow2D( probesSH, vec3( uvw.xy, ( uvZBase + 4.0 * paddedSlices   ) / atlasDepth ) );
	vec4 s5 = shadow2D( probesSH, vec3( uvw.xy, ( uvZBase + 5.0 * paddedSlices   ) / atlasDepth ) );
	vec4 s6 = shadow2D( probesSH, vec3( uvw.xy, ( uvZBase + 6.0 * paddedSlices   ) / atlasDepth ) );

	// Unpack 9 vec3 SH L2 coefficients
	vec3 c0 = s0.xyz;
	vec3 c1 = vec3( s0.w, s1.xy );
	vec3 c2 = vec3( s1.zw, s2.x );
	vec3 c3 = s2.yzw;
	vec3 c4 = s3.xyz;
	vec3 c5 = vec3( s3.w, s4.xy );
	vec3 c6 = vec3( s4.zw, s5.x );
	vec3 c7 = s5.yzw;
	vec3 c8 = s6.xyz;

	// Evaluate L2 irradiance
	float x = worldNormal.x, y = worldNormal.y, z = worldNormal.z;

	vec3 result = c0 * 0.886227;
	result += c1 * 2.0 * 0.511664 * y;
	result += c2 * 2.0 * 0.511664 * z;
	result += c3 * 2.0 * 0.511664 * x;
	result += c4 * 2.0 * 0.429043 * x * y;
	result += c5 * 2.0 * 0.429043 * y * z;
	result += c6 * ( 0.743125 * z * z - 0.247708 );
	result += c7 * 2.0 * 0.429043 * x * z;
	result += c8 * 0.429043 * ( x * x - y * y );

	return max( result, vec3(0.0, 0.0, 0.0) );

}

#endif
"#
```
lightprobes_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lights\_fragment
```cj
public const lights_fragment: String = #"
// lights not implemented
"#
```
lights_fragment GLSL 片段字符串

## const lights\_fragment\_begin
```cj
public const lights_fragment_begin: String = #"
/**
 * This is a template that can be used to light a material, it uses pluggable
 * RenderEquations (RE)for specific lighting scenarios.
 *
 * Instructions for use:
 * - Ensure that both RE_Direct, RE_IndirectDiffuse and RE_IndirectSpecular are defined
 * - Create a material parameter that is to be passed as the third parameter to your lighting functions.
 *
 * TODO:
 * Ignore: JS 原文 TODO（area light / sphere light / diffuse light probe 支持），属 three.js 上游未实现项。
 * - Add area light support.
 * - Add sphere light support.
 * - Add diffuse light probe (irradiance cubemap) support.
 */

// bgfx4cj: 使用世界空间坐标（v_worldPos）替代 Three.js 的视图空间（-vViewPosition）
// 因为渲染器传递的光源数据是世界空间坐标，而非视图空间
vec3 geometryPosition = v_worldPos;
vec3 geometryNormal = v_normal;
vec3 geometryViewDir = ( isOrthographic ) ? vec3( 0, 0, 1 ) : normalize( u_cameraPos.xyz - v_worldPos );

vec3 geometryClearcoatNormal = vec3(0.0, 0.0, 0.0);

#ifdef USE_CLEARCOAT

	geometryClearcoatNormal = clearcoatNormal;

#endif

#ifdef USE_IRIDESCENCE

	float dotNVi = saturate( dot( v_normal, geometryViewDir ) );

	if ( material.iridescenceThickness == 0.0 ) {

		material.iridescence = 0.0;

	} else {

		material.iridescence = saturate( material.iridescence );

	}

	if ( material.iridescence > 0.0 ) {

		vec3 iridescenceFresnelDielectric = evalIridescence( 1.0, material.iridescenceIOR, dotNVi, material.iridescenceThickness, material.specularColor );
		vec3 iridescenceFresnelMetallic = evalIridescence( 1.0, material.iridescenceIOR, dotNVi, material.iridescenceThickness, material.diffuseColor );

		material.iridescenceFresnel = mix( iridescenceFresnelDielectric, iridescenceFresnelMetallic, material.metalness );

		// Iridescence F0 approximation
		material.iridescenceF0Dielectric = Schlick_to_F0( iridescenceFresnelDielectric, 1.0, dotNVi );
		material.iridescenceF0Metallic = Schlick_to_F0( iridescenceFresnelMetallic, 1.0, dotNVi );

	}

#endif

#if defined( STANDARD ) && ( NUM_DIR_LIGHTS > 0 || NUM_POINT_LIGHTS > 0 || NUM_SPOT_LIGHTS > 0 )

	// Multi-scattering energy compensation for direct lighting
	// Based on "Practical Multiple Scattering Compensation for Microfacet Models"
	// https://blog.selfshadow.com/publications/turquin/ms_comp_final.pdf
	float dotNVms = saturate( dot( geometryNormal, geometryViewDir ) );

	vec2 fabMs = texture2D( dfgLUT, vec2( material.roughness, dotNVms ) ).rg;

	// Energy of the single-scattering lobe in a white furnace ( F0 = F90 = 1 )
	float EssMs = fabMs.x + fabMs.y;

	// bgfx4cj: dfgLUT 采样可能因格式/平台差异返回 0，导致 1.0/0 无穷 → 高光爆炸（向光面全白）。
	// 保护最小值：若 EssMs 接近 0 则用 1.0（无补偿），避免除零。
	if (EssMs < 0.001) { EssMs = 1.0; }

	// Compensate for the energy lost to multiple scattering, tinting the added term by F0 ( equation 16 )
	// 注意：此处依赖 dfgLUT 采样（1.0/EssMs），dfgLUT 必须用 RG16F 格式正确绑定
	// （BgfxBackend._bindSceneTextures），否则 EssMs=0 → 1/0 无穷 → 高光爆炸。
	material.multiScatteringCompensation = 1.0 + material.specularColorBlended * ( 1.0 / EssMs - 1.0 );

#endif

IncidentLight directLight;

#if ( NUM_POINT_LIGHTS > 0 ) && defined( RE_Direct )

	PointLight pointLight;

	// bgfx4cj: 点光源循环用 for + 动态下标（对照官方 13-stencil fs_stencil_color_lighting.sc：
	// for(int ii = 0; ii < MAX_NUM_LIGHTS; ++ii) { ... u_lightPosRadius[ii] ... }）。
	// 循环上界 = NUM_POINT_LIGHTS_MAX（配置上限宏），动态下标访问数组 uniform
	// u_pointPosition/u_pointColor/u_pointParams（渲染器侧通过数组 uniform 传递）。
	// 实际数量由 NUM_POINT_LIGHTS 宏裁剪（渲染器已将多余槽位填 0，颜色×0 无贡献）。
	for ( int i = 0; i < NUM_POINT_LIGHTS_MAX; i ++ ) {

		pointLight.position = u_pointPosition[ i ].xyz;
		pointLight.color = u_pointColor[ i ].rgb * u_pointColor[ i ].a;
		pointLight.distance = u_pointPosition[ i ].w;
		pointLight.decay = u_pointParams[ i ].x;

		getPointLightInfo( pointLight, geometryPosition, directLight );

		#if defined( USE_SHADOWMAP ) && NUM_POINT_LIGHT_SHADOWS > 0
		if ( i < NUM_POINT_LIGHT_SHADOWS )
		{
			directLight.color *= ( directLight.visible && receiveShadow.x > 0.5 ) ? getPointShadow( pointShadowMap[i], shadowMapSize.xy, shadowParams.x, u_pointShadowParams[i].x, shadowParams.w, vec4( geometryPosition - u_pointShadowLightPos[i].xyz, 1.0 ), u_pointShadowNearFar[i].x, u_pointShadowNearFar[i].y ) : 1.0;
		}
		#endif

		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );

	}
	

#endif

#if ( NUM_SPOT_LIGHTS > 0 ) && defined( RE_Direct )

	SpotLight spotLight;
	vec4 spotColor;
	vec3 spotLightCoord;
	bool inSpotLightMap;

	// bgfx4cj: 聚光灯循环用 for + 动态下标（对照官方 13-stencil fs_stencil_color_lighting.sc）。
	// 循环上界 = NUM_SPOT_LIGHTS_MAX（配置上限宏），动态下标访问数组 uniform
	// u_spotPosition/u_spotColor/u_spotDirection/u_spotParams（渲染器侧通过数组 uniform 传递）。
	// 实际数量由 NUM_SPOT_LIGHTS 宏裁剪（渲染器已将多余槽位填 0，颜色×0 无贡献）。
	for ( int i = 0; i < NUM_SPOT_LIGHTS_MAX; i ++ ) {

		spotLight.position = u_spotPosition[ i ].xyz;
		spotLight.direction = u_spotDirection[ i ].xyz;
		spotLight.color = u_spotColor[ i ].rgb * u_spotColor[ i ].a;
		spotLight.distance = u_spotPosition[ i ].w;
		spotLight.decay = u_spotParams[ i ].z;
		spotLight.coneCos = u_spotDirection[ i ].w;
		spotLight.penumbraCos = u_spotParams[ i ].w;

		getSpotLightInfo( spotLight, geometryPosition, directLight );

		#if ( NUM_SPOT_LIGHT_MAPS > 0 )
		// bgfx4cj: spotLightMap 数组按光源顺序，动态下标访问（当前 NUM_SPOT_LIGHT_MAPS=0 时整段裁剪）
		if ( i < NUM_SPOT_LIGHT_MAPS )
		{
			spotLightCoord = vSpotLightCoord.xyz / vSpotLightCoord.w;
			inSpotLightMap = all( lessThan( abs( spotLightCoord * 2. - 1. ), vec3_splat(1.0) ) );
			spotColor = texture2D( spotLightMap[ i ], spotLightCoord.xy );
			directLight.color = inSpotLightMap ? directLight.color * spotColor.rgb : directLight.color;
		}
		#endif

		#if defined( USE_SHADOWMAP ) && NUM_SPOT_LIGHT_SHADOWS > 0
		if ( i < NUM_SPOT_LIGHT_SHADOWS )
		{
			directLight.color *= ( directLight.visible && receiveShadow.x > 0.5 ) ? getShadow( spotShadowMap[i], shadowMapSize.xy, shadowParams.x, u_spotShadowParams[i].x, shadowParams.w, vSpotLightCoord ) : 1.0;
		}
		#endif

		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );

	}
	

#endif

#if ( NUM_DIR_LIGHTS > 0 ) && defined( RE_Direct )

	DirectionalLight directionalLight;

	// bgfx4cj: 方向光循环用 for + 动态下标（对照官方 13-stencil fs_stencil_color_lighting.sc）。
	// 循环上界 = NUM_DIR_LIGHTS_MAX（配置上限宏），动态下标访问数组 uniform
	// u_lightDir/u_lightColor（渲染器侧通过数组 uniform 传递）。
	// 实际数量由 NUM_DIR_LIGHTS 宏裁剪（渲染器已将多余槽位填 0，颜色×0 无贡献）。
	for ( int i = 0; i < NUM_DIR_LIGHTS_MAX; i ++ ) {

		directionalLight.direction = u_lightDir[ i ].xyz;
		directionalLight.color = u_lightColor[ i ].rgb * u_lightColor[ i ].a;

		getDirectionalLightInfo( directionalLight, directLight );

		#if defined( USE_SHADOWMAP ) && NUM_DIR_LIGHT_SHADOWS > 0
		if ( i < NUM_DIR_LIGHT_SHADOWS )
		{
			directLight.color *= ( directLight.visible && receiveShadow.x > 0.5 ) ? getShadow( directionalShadowMap[i], shadowMapSize.xy, shadowParams.x, u_dirShadowParams[i].x, shadowParams.w, vDirectionalShadowCoord ) : 1.0;
		}
		#endif

		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );

	}
	

#endif

#if ( NUM_RECT_AREA_LIGHTS > 0 ) && defined( RE_Direct_RectArea )

	RectAreaLight rectAreaLight;

	UNROLL
	for ( int i = 0; i < NUM_RECT_AREA_LIGHTS; i ++ ) {

		rectAreaLight = rectAreaLights[ i ];
		RE_Direct_RectArea( rectAreaLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );

	}
	

#endif

#if defined( RE_IndirectDiffuse )

	vec3 iblIrradiance = vec3(0.0, 0.0, 0.0);

	vec3 irradiance = getAmbientLightIrradiance( u_ambientColor.xyz );

	#if defined( USE_LIGHT_PROBES )

		// bgfx4cj: LightProbe 的 SH3 系数由渲染器绑定为 shCoefficients（vec4[9] 数组 uniform），
		// 消费走 bgfx_pbr_pars 的 getShIrradianceAt（读 shCoefficients），
		// 而非 JS 原文的 lightProbe（vec3[9]，bgfx 后端未绑定该 uniform）。
		// getShIrradianceAt 仅随 bgfx_pbr_pars 注入 standard/physical 着色器，故用 STANDARD 守卫。
		#if defined( STANDARD )

			irradiance += getShIrradianceAt( geometryNormal );

		#else

			irradiance += getLightProbeIrradiance( lightProbe, geometryNormal );

		#endif

	#endif

	#if ( NUM_HEMI_LIGHTS > 0 )

		// bgfx4cj: 半球光循环用 for + 动态下标（对照点光/聚光/方向光改造）。
		// JS 原文用 struct 数组 uniform `hemisphereLights[NUM_HEMI_LIGHTS]`（未迁移），
		// bgfx 后端改为独立数组 uniform u_hemiSkyColor/u_hemiGroundColor/u_hemiDirection
		// （渲染器 BgfxLightBinder 按数组绑定），此处逐槽位构造 struct 再求辐照度。
		UNROLL
		for ( int i = 0; i < NUM_HEMI_LIGHTS; i ++ ) {

			HemisphereLight hemiLight;
			hemiLight.direction = u_hemiDirection[ i ].xyz;
			hemiLight.skyColor = u_hemiSkyColor[ i ].rgb;
			hemiLight.groundColor = u_hemiGroundColor[ i ].rgb;

			irradiance += getHemisphereLightIrradiance( hemiLight, geometryNormal );

		}
		

	#endif

	#ifdef USE_LIGHT_PROBES_GRID

		vec3 probeWorldPos = ( ( vec4( geometryPosition, 1.0 ) - viewMatrix[ 3 ] ) * viewMatrix ).xyz;
		vec3 probeWorldNormal = transformNormalByInverseViewMatrix( geometryNormal, viewMatrix );
		irradiance += getLightProbeGridIrradiance( probeWorldPos, probeWorldNormal );

	#endif

#endif

#if defined( RE_IndirectSpecular )

	vec3 radiance = vec3(0.0, 0.0, 0.0);
	vec3 clearcoatRadiance = vec3(0.0, 0.0, 0.0);

#endif
"#
```
lights_fragment_begin GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lights\_fragment\_end
```cj
public const lights_fragment_end: String = #"
#if defined( RE_IndirectDiffuse )

	#if defined( LAMBERT ) || defined( PHONG )

		irradiance += iblIrradiance;

	#endif

	RE_IndirectDiffuse( irradiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );

#endif

#if defined( RE_IndirectSpecular )

	RE_IndirectSpecular( radiance, iblIrradiance, clearcoatRadiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );

#endif
"#
```
lights_fragment_end GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lights\_fragment\_maps
```cj
public const lights_fragment_maps: String = #"
#if defined( RE_IndirectDiffuse )

	#ifdef USE_LIGHTMAP

		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		vec3 lightMapIrradiance = lightMapTexel.rgb * lightMapIntensity;

		irradiance += lightMapIrradiance;

	#endif

	#if defined( USE_ENVMAP ) && defined( ENVMAP_TYPE_CUBE_UV )

		#if defined( STANDARD ) || defined( LAMBERT ) || defined( PHONG )

			iblIrradiance += getIBLIrradiance( geometryNormal );

		#endif

	#endif

#endif

#if defined( USE_ENVMAP ) && defined( RE_IndirectSpecular )

	#ifdef USE_ANISOTROPY

		radiance += getIBLAnisotropyRadiance( geometryViewDir, geometryNormal, material.roughness, material.anisotropyB, material.anisotropy );

	#else

		radiance += getIBLRadiance( geometryViewDir, geometryNormal, material.roughness );

	#endif

	#ifdef USE_CLEARCOAT

		clearcoatRadiance += getIBLRadiance( geometryViewDir, geometryClearcoatNormal, material.clearcoatRoughness );

	#endif

#endif
"#
```
lights_fragment_maps GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lights\_lambert\_fragment
```cj
public const lights_lambert_fragment: String = #"
	LambertMaterial material;
	material.diffuseColor = diffuseColor.rgb;
	material.specularStrength = specularStrength;
"#
```
lights_lambert_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lights\_lambert\_pars\_fragment
```cj
public const lights_lambert_pars_fragment: String = #"
struct LambertMaterial {

	vec3 diffuseColor;
	float specularStrength;

};

void RE_Direct_Lambert( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {

	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;

	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );

}

void RE_IndirectDiffuse_Lambert( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {

	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );

}

#define RE_Direct				RE_Direct_Lambert
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Lambert
"#
```
lights_lambert_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lights\_pars
```cj
public const lights_pars: String = #"
struct DirectionalLight {
	vec3 direction;
	vec3 color;
};
struct PointLight {
	vec3 position;
	vec3 color;
	float distance;
	float decay;
};
struct SpotLight {
	vec3 position;
	vec3 direction;
	vec3 color;
	float distance;
	float angle;
	float decay;
};
"#
```
lights_pars GLSL 片段字符串

## const lights\_pars\_begin
```cj
public const lights_pars_begin: String = #"
uniform vec4 receiveShadow;  // bgfx4cj: vec4 而非 bool（渲染器用 BGFX_UNIFORM_VEC4 设置）

#if defined( USE_LIGHT_PROBES )

	uniform vec3 lightProbe[ 9 ];

#endif

// get the irradiance (radiance convolved with cosine lobe) at the point 'normal' on the unit sphere
// source: https://graphics.stanford.edu/papers/envmap/envmap.pdf
vec3 shGetIrradianceAt( in vec3 normal, in vec3 shCoefficients[ 9 ] ) {

	// normal is assumed to have unit length

	float x = normal.x, y = normal.y, z = normal.z;

	// band 0
	vec3 result = shCoefficients[ 0 ] * 0.886227;

	// band 1
	result += shCoefficients[ 1 ] * 2.0 * 0.511664 * y;
	result += shCoefficients[ 2 ] * 2.0 * 0.511664 * z;
	result += shCoefficients[ 3 ] * 2.0 * 0.511664 * x;

	// band 2
	result += shCoefficients[ 4 ] * 2.0 * 0.429043 * x * y;
	result += shCoefficients[ 5 ] * 2.0 * 0.429043 * y * z;
	result += shCoefficients[ 6 ] * ( 0.743125 * z * z - 0.247708 );
	result += shCoefficients[ 7 ] * 2.0 * 0.429043 * x * z;
	result += shCoefficients[ 8 ] * 0.429043 * ( x * x - y * y );

	return result;

}

vec3 getLightProbeIrradiance( const in vec3 lightProbe[ 9 ], const in vec3 normal ) {

	vec3 worldNormal = transformNormalByInverseViewMatrix( normal, viewMatrix );

	vec3 irradiance = shGetIrradianceAt( worldNormal, lightProbe );

	return irradiance;

}

vec3 getAmbientLightIrradiance( const in vec3 ambientLightColor ) {

	vec3 irradiance = ambientLightColor;

	return irradiance;

}

float getDistanceAttenuation( const in float lightDistance, const in float cutoffDistance, const in float decayExponent ) {

	// based upon Frostbite 3 Moving to Physically-based Rendering
	// page 32, equation 26: E[window1]
	// https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
	float distanceFalloff = 1.0 / max( pow( lightDistance, decayExponent ), 0.01 );

	if ( cutoffDistance > 0.0 ) {

		distanceFalloff *= pow2( saturate( 1.0 - pow4( lightDistance / cutoffDistance ) ) );

	}

	return distanceFalloff;

}

float getSpotAttenuation( const in float coneCosine, const in float penumbraCosine, const in float angleCosine ) {

	return smoothstep( coneCosine, penumbraCosine, angleCosine );

}

#if NUM_DIR_LIGHTS > 0

 struct DirectionalLight {
  vec3 direction;
  vec3 color;
 };

 void getDirectionalLightInfo( const in DirectionalLight directionalLight, out IncidentLight light ) {

  light.color = directionalLight.color;
  light.direction = directionalLight.direction;
  light.visible = true;

 }

#endif


#if NUM_POINT_LIGHTS > 0

 struct PointLight {
  vec3 position;
  vec3 color;
  float distance;
  float decay;
 };

 // light is an out parameter as having it as a return value caused compiler errors on some devices
 void getPointLightInfo( const in PointLight pointLight, const in vec3 geometryPosition, out IncidentLight light ) {

  vec3 lVector = pointLight.position - geometryPosition;

  light.direction = normalize( lVector );

  float lightDistance = length( lVector );

  light.color = pointLight.color;
  light.color *= getDistanceAttenuation( lightDistance, pointLight.distance, pointLight.decay );
  light.visible = any( light.color != vec3(0.0, 0.0, 0.0) );

 }

#endif


#if NUM_SPOT_LIGHTS > 0

 struct SpotLight {
  vec3 position;
  vec3 direction;
  vec3 color;
  float distance;
  float decay;
  float coneCos;
  float penumbraCos;
 };

 // light is an out parameter as having it as a return value caused compiler errors on some devices
 void getSpotLightInfo( const in SpotLight spotLight, const in vec3 geometryPosition, out IncidentLight light ) {

  vec3 lVector = spotLight.position - geometryPosition;

  light.direction = normalize( lVector );

  float angleCos = dot( light.direction, spotLight.direction );

  float spotAttenuation = getSpotAttenuation( spotLight.coneCos, spotLight.penumbraCos, angleCos );

  if ( spotAttenuation > 0.0 ) {

   float lightDistance = length( lVector );

   light.color = spotLight.color * spotAttenuation;
   light.color *= getDistanceAttenuation( lightDistance, spotLight.distance, spotLight.decay );
   light.visible = any( light.color != vec3(0.0, 0.0, 0.0) );

  } else {

   light.color = vec3(0.0, 0.0, 0.0);
   light.visible = false;

  }

 }

#endif


#if NUM_RECT_AREA_LIGHTS > 0

 struct RectAreaLight {
  vec3 color;
  vec3 position;
  vec3 halfWidth;
  vec3 halfHeight;
 };

 // Pre-computed values of LinearTransformedCosine approximation of BRDF
 // BRDF approximation Texture is 64x64
 uniform sampler2D ltc_1; // RGBA Float
 uniform sampler2D ltc_2; // RGBA Float

#endif


#if NUM_HEMI_LIGHTS > 0

 struct HemisphereLight {
  vec3 direction;
  vec3 skyColor;
  vec3 groundColor;
 };

 vec3 getHemisphereLightIrradiance( const in HemisphereLight hemiLight, const in vec3 normal ) {

  float dotNL = dot( normal, hemiLight.direction );
  float hemiDiffuseWeight = 0.5 * dotNL + 0.5;

  vec3 irradiance = mix( hemiLight.groundColor, hemiLight.skyColor, hemiDiffuseWeight );

  return irradiance;

 }

#endif

#include <lightprobes_pars_fragment>
"#
```
lights_pars_begin GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lights\_phong\_fragment
```cj
public const lights_phong_fragment: String = #"
	BlinnPhongMaterial material;
	material.diffuseColor = diffuseColor.rgb;
	material.specularColor = specular.xyz;
	material.specularShininess = shininess.x;
	material.specularStrength = specularStrength;
"#
```
lights_phong_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lights\_phong\_pars\_fragment
```cj
public const lights_phong_pars_fragment: String = #"
struct BlinnPhongMaterial {

	vec3 diffuseColor;
	vec3 specularColor;
	float specularShininess;
	float specularStrength;

};

void RE_Direct_BlinnPhong( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {

	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;

	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );

	reflectedLight.directSpecular += irradiance * BRDF_BlinnPhong( directLight.direction, geometryViewDir, geometryNormal, material.specularColor, material.specularShininess ) * material.specularStrength;

}

void RE_IndirectDiffuse_BlinnPhong( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {

	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );

}

#define RE_Direct				RE_Direct_BlinnPhong
#define RE_IndirectDiffuse		RE_IndirectDiffuse_BlinnPhong
"#
```
lights_phong_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lights\_physical\_fragment
```cj
public const lights_physical_fragment: String = #"
PhysicalMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.diffuseContribution = diffuseColor.rgb * ( 1.0 - metalnessFactor );
material.metalness = metalnessFactor;

vec3 dxy = max( abs( dFdx( nonPerturbedNormal ) ), abs( dFdy( nonPerturbedNormal ) ) );
float geometryRoughness = max( max( dxy.x, dxy.y ), dxy.z );

material.roughness = max( roughnessFactor, 0.0525 );// 0.0525 corresponds to the base mip of a 256 cubemap.
material.roughness += geometryRoughness;
material.roughness = min( material.roughness, 1.0 );

#ifdef IOR

	material.ior = ior;

	#ifdef USE_SPECULAR

		float specularIntensityFactor = specularIntensity;
		vec3 specularColorFactor = specularColor;

		#ifdef USE_SPECULAR_COLORMAP

			specularColorFactor *= texture2D( specularColorMap, vSpecularColorMapUv ).rgb;

		#endif

		#ifdef USE_SPECULAR_INTENSITYMAP

			specularIntensityFactor *= texture2D( specularIntensityMap, vSpecularIntensityMapUv ).a;

		#endif

		material.specularF90 = mix( specularIntensityFactor, 1.0, metalnessFactor );

	#else

		float specularIntensityFactor = 1.0;
		vec3 specularColorFactor = vec3_splat(1.0);
		material.specularF90 = 1.0;

	#endif

	material.specularColor = min( pow2( ( material.ior - 1.0 ) / ( material.ior + 1.0 ) ) * specularColorFactor, vec3_splat(1.0) ) * specularIntensityFactor;
	material.specularColorBlended = mix( material.specularColor, diffuseColor.rgb, metalnessFactor );

#else

	material.specularColor = vec3_splat(0.04);
	material.specularColorBlended = mix( material.specularColor, diffuseColor.rgb, metalnessFactor );
	material.specularF90 = 1.0;

#endif

#ifdef USE_CLEARCOAT

	material.clearcoat = clearcoat;
	material.clearcoatRoughness = clearcoatRoughness;
	material.clearcoatF0 = vec3_splat(0.04);
	material.clearcoatF90 = 1.0;

	#ifdef USE_CLEARCOATMAP

		material.clearcoat *= texture2D( clearcoatMap, vClearcoatMapUv ).x;

	#endif

	#ifdef USE_CLEARCOAT_ROUGHNESSMAP

		material.clearcoatRoughness *= texture2D( clearcoatRoughnessMap, vClearcoatRoughnessMapUv ).y;

	#endif

	material.clearcoat = saturate( material.clearcoat ); // Burley clearcoat model
	material.clearcoatRoughness = max( material.clearcoatRoughness, 0.0525 );
	material.clearcoatRoughness += geometryRoughness;
	material.clearcoatRoughness = min( material.clearcoatRoughness, 1.0 );

#endif

#ifdef USE_DISPERSION

	material.dispersion = dispersion;

#endif

#ifdef USE_RETROREFLECTIVE

	material.retroreflective = retroreflective;

#endif

#ifdef USE_IRIDESCENCE

	material.iridescence = iridescence;
	material.iridescenceIOR = iridescenceIOR;

	#ifdef USE_IRIDESCENCEMAP

		material.iridescence *= texture2D( iridescenceMap, vIridescenceMapUv ).r;

	#endif

	#ifdef USE_IRIDESCENCE_THICKNESSMAP

		material.iridescenceThickness = (iridescenceThicknessMaximum - iridescenceThicknessMinimum) * texture2D( iridescenceThicknessMap, vIridescenceThicknessMapUv ).g + iridescenceThicknessMinimum;

	#else

		material.iridescenceThickness = iridescenceThicknessMaximum;

	#endif

#endif

#ifdef USE_SHEEN

	material.sheenColor = sheenColor;

	#ifdef USE_SHEEN_COLORMAP

		material.sheenColor *= texture2D( sheenColorMap, vSheenColorMapUv ).rgb;

	#endif

	material.sheenRoughness = clamp( sheenRoughness, 0.0001, 1.0 );

	#ifdef USE_SHEEN_ROUGHNESSMAP

		material.sheenRoughness *= texture2D( sheenRoughnessMap, vSheenRoughnessMapUv ).a;

	#endif

#endif

#ifdef USE_ANISOTROPY

	#ifdef USE_ANISOTROPYMAP

		mat2 anisotropyMat = mat2( anisotropyVector.x, anisotropyVector.y, - anisotropyVector.y, anisotropyVector.x );
		vec3 anisotropyPolar = texture2D( anisotropyMap, vAnisotropyMapUv ).rgb;
		vec2 anisotropyV = anisotropyMat * normalize( 2.0 * anisotropyPolar.rg - vec2( 1.0 ) ) * anisotropyPolar.b;

	#else

		vec2 anisotropyV = anisotropyVector;

	#endif

	material.anisotropy = length( anisotropyV );

	if( material.anisotropy == 0.0 ) {
		anisotropyV = vec2( 1.0, 0.0 );
	} else {
		anisotropyV /= material.anisotropy;
		material.anisotropy = saturate( material.anisotropy );
	}

	// Roughness along the anisotropy bitangent is the material roughness, while the tangent roughness increases with anisotropy.
	material.alphaT = mix( pow2( material.roughness ), 1.0, pow2( material.anisotropy ) );

	material.anisotropyT = tbn[ 0 ] * anisotropyV.x + tbn[ 1 ] * anisotropyV.y;
	material.anisotropyB = tbn[ 1 ] * anisotropyV.x - tbn[ 0 ] * anisotropyV.y;

#endif
"#
```
lights_physical_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lights\_physical\_pars\_fragment
```cj
public const lights_physical_pars_fragment: String = #"

// 环境 BRDF LUT（对照 three.js lights_physical_pars_fragment 的 dfgLUT；
// 用 bgfx SAMPLER 宏声明：GLSL 分支展开为 uniform sampler2D，
// HLSL 分支展开为 SamplerState+Texture2D+static BgfxSampler2D，避免裸 sampler2D 在 HLSL 下 type mismatch）
SAMPLER2D(dfgLUT, __STAGE_DFGLUT__);

struct PhysicalMaterial {

	vec3 diffuseColor;
	vec3 diffuseContribution;
	vec3 specularColor;
	vec3 specularColorBlended;

	float roughness;
	float metalness;
	float specularF90;
	float dispersion;
	vec3 multiScatteringCompensation;

	#ifdef USE_RETROREFLECTIVE
		float retroreflective;
	#endif

	#ifdef USE_CLEARCOAT
		float clearcoat;
		float clearcoatRoughness;
		vec3 clearcoatF0;
		float clearcoatF90;
	#endif

	#ifdef USE_IRIDESCENCE
		float iridescence;
		float iridescenceIOR;
		float iridescenceThickness;
		vec3 iridescenceFresnel;
		vec3 iridescenceF0Dielectric;
		vec3 iridescenceF0Metallic;
	#endif

	#ifdef USE_SHEEN
		vec3 sheenColor;
		float sheenRoughness;
	#endif

	#ifdef IOR
		float ior;
	#endif

	#ifdef USE_TRANSMISSION
		float transmission;
		float transmissionAlpha;
		float thickness;
		float attenuationDistance;
		vec3 attenuationColor;
	#endif

	#ifdef USE_ANISOTROPY
		float anisotropy;
		float alphaT;
		vec3 anisotropyT;
		vec3 anisotropyB;
	#endif

};

// temporary
vec3 clearcoatSpecularDirect = vec3(0.0, 0.0, 0.0);
vec3 clearcoatSpecularIndirect = vec3(0.0, 0.0, 0.0);
vec3 sheenSpecularDirect = vec3(0.0, 0.0, 0.0);
vec3 sheenSpecularIndirect = vec3(0.0, 0.0, 0.0);

vec3 Schlick_to_F0( const in vec3 f, const in float f90, const in float dotVH ) {
    float x = clamp( 1.0 - dotVH, 0.0, 1.0 );
    float x2 = x * x;
    float x5 = clamp( x * x2 * x2, 0.0, 0.9999 );

    return ( f - vec3( f90, f90, f90 ) * x5 ) / ( 1.0 - x5 );
}

// Moving Frostbite to Physically Based Rendering 3.0 - page 12, listing 2
// https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
float V_GGX_SmithCorrelated( const in float alpha, const in float dotNL, const in float dotNV ) {

	float a2 = pow2( alpha );
	float gv = dotNL * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNV ) );
	float gl = dotNV * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNL ) );

	return 0.5 / max( gv + gl, EPSILON );

}

// Microfacet Models for Refraction through Rough Surfaces - equation (33)
// http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
// alpha is "roughness squared" in Disney’s reparameterization
float D_GGX( const in float alpha, const in float dotNH ) {

	float a2 = pow2( alpha );

	float denom = pow2( dotNH ) * ( a2 - 1.0 ) + 1.0; // avoid alpha = 0 with dotNH = 1

	return RECIPROCAL_PI * a2 / pow2( denom );

}

// https://google.github.io/filament/Filament.md.html#materialsystem/anisotropicmodel/anisotropicspecularbrdf
#ifdef USE_ANISOTROPY

	float V_GGX_SmithCorrelated_Anisotropic( const in float alphaT, const in float alphaB, const in float dotTV, const in float dotBV, const in float dotTL, const in float dotBL, const in float dotNV, const in float dotNL ) {

		float gv = dotNL * length( vec3( alphaT * dotTV, alphaB * dotBV, dotNV ) );
		float gl = dotNV * length( vec3( alphaT * dotTL, alphaB * dotBL, dotNL ) );
		return 0.5 / max( gv + gl, EPSILON );

	}

	float D_GGX_Anisotropic( const in float alphaT, const in float alphaB, const in float dotNH, const in float dotTH, const in float dotBH ) {

		float a2 = alphaT * alphaB;
		highp vec3 v = vec3( alphaB * dotTH, alphaT * dotBH, a2 * dotNH );
		highp float v2 = dot( v, v );
		float w2 = a2 / v2;

		return RECIPROCAL_PI * a2 * pow2 ( w2 );

	}

#endif

#ifdef USE_CLEARCOAT

	// GGX Distribution, Schlick Fresnel, GGX_SmithCorrelated Visibility
	vec3 BRDF_GGX_Clearcoat( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material) {

		vec3 f0 = material.clearcoatF0;
		float f90 = material.clearcoatF90;
		float roughness = material.clearcoatRoughness;

		float alpha = pow2( roughness ); // UE4's roughness

		vec3 halfDir = normalize( lightDir + viewDir );

		float dotNL = saturate( dot( normal, lightDir ) );
		float dotNV = saturate( dot( normal, viewDir ) );
		float dotNH = saturate( dot( normal, halfDir ) );
		float dotVH = saturate( dot( viewDir, halfDir ) );

		vec3 F = F_Schlick( f0, f90, dotVH );

		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );

		float D = D_GGX( alpha, dotNH );

		return F * ( V * D );

	}

#endif

vec3 BRDF_GGX( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material ) {

	vec3 f0 = material.specularColorBlended;
	float f90 = material.specularF90;
	float roughness = material.roughness;

	float alpha = pow2( roughness ); // UE4's roughness

	vec3 halfDir = normalize( lightDir + viewDir );

	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );

	vec3 F = F_Schlick( f0, f90, dotVH );

	#ifdef USE_IRIDESCENCE

		F = mix( F, material.iridescenceFresnel, material.iridescence );

	#endif

	#ifdef USE_ANISOTROPY

		float dotTL = dot( material.anisotropyT, lightDir );
		float dotTV = dot( material.anisotropyT, viewDir );
		float dotTH = dot( material.anisotropyT, halfDir );
		float dotBL = dot( material.anisotropyB, lightDir );
		float dotBV = dot( material.anisotropyB, viewDir );
		float dotBH = dot( material.anisotropyB, halfDir );

		float V = V_GGX_SmithCorrelated_Anisotropic( material.alphaT, alpha, dotTV, dotBV, dotTL, dotBL, dotNV, dotNL );

		float D = D_GGX_Anisotropic( material.alphaT, alpha, dotNH, dotTH, dotBH );

	#else

		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );

		float D = D_GGX( alpha, dotNH );

	#endif

	return F * ( V * D );

}

// Rect Area Light

// Real-Time Polygonal-Light Shading with Linearly Transformed Cosines
// by Eric Heitz, Jonathan Dupuy, Stephen Hill and David Neubelt
// code: https://github.com/selfshadow/ltc_code/

vec2 LTC_Uv( const in vec3 N, const in vec3 V, const in float roughness ) {

	const float LUT_SIZE = 64.0;
	const float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
	const float LUT_BIAS = 0.5 / LUT_SIZE;

	float dotNV = saturate( dot( N, V ) );

	// texture parameterized by sqrt( GGX alpha ) and sqrt( 1 - cos( theta ) )
	vec2 uv = vec2( roughness, sqrt( 1.0 - dotNV ) );

	uv = uv * LUT_SCALE + LUT_BIAS;

	return uv;

}

float LTC_ClippedSphereFormFactor( const in vec3 f ) {

	// Real-Time Area Lighting: a Journey from Research to Production (p.102)
	// An approximation of the form factor of a horizon-clipped rectangle.

	float l = length( f );

	return max( ( l * l + f.z ) / ( l + 1.0 ), 0.0 );

}

vec3 LTC_EdgeVectorFormFactor( const in vec3 v1, const in vec3 v2 ) {

	float x = dot( v1, v2 );

	float y = abs( x );

	// rational polynomial approximation to theta / sin( theta ) / 2PI
	float a = 0.8543985 + ( 0.4965155 + 0.0145206 * y ) * y;
	float b = 3.4175940 + ( 4.1616724 + y ) * y;
	float v = a / b;

	float theta_sintheta = ( x > 0.0 ) ? v : 0.5 * inversesqrt( max( 1.0 - x * x, 1e-7 ) ) - v;

	return cross( v1, v2 ) * theta_sintheta;

}

vec3 LTC_Evaluate( const in vec3 N, const in vec3 V, const in vec3 P, const in mat3 mInv, const in vec3 rectCoords[ 4 ] ) {

	// bail if point is on back side of plane of light
	// assumes ccw winding order of light vertices
	vec3 v1 = rectCoords[ 1 ] - rectCoords[ 0 ];
	vec3 v2 = rectCoords[ 3 ] - rectCoords[ 0 ];
	vec3 lightNormal = cross( v1, v2 );

	if( dot( lightNormal, P - rectCoords[ 0 ] ) < 0.0 ) return vec3(0.0, 0.0, 0.0);

	// construct orthonormal basis around N
	vec3 T1, T2;
	T1 = normalize( V - N * dot( V, N ) );
	T2 = - cross( N, T1 ); // negated from paper; possibly due to a different handedness of world coordinate system

	// compute transform
	mat3 mat = mul( mInv, transpose( mat3( T1, T2, N ) ) );

	// transform rect
	vec3 coords[ 4 ];
	coords[ 0 ] = mul( mat, rectCoords[ 0 ] - P );
	coords[ 1 ] = mul( mat, rectCoords[ 1 ] - P );
	coords[ 2 ] = mul( mat, rectCoords[ 2 ] - P );
	coords[ 3 ] = mul( mat, rectCoords[ 3 ] - P );

	// project rect onto sphere
	coords[ 0 ] = normalize( coords[ 0 ] );
	coords[ 1 ] = normalize( coords[ 1 ] );
	coords[ 2 ] = normalize( coords[ 2 ] );
	coords[ 3 ] = normalize( coords[ 3 ] );

	// calculate vector form factor
	vec3 vectorFormFactor = vec3(0.0, 0.0, 0.0);
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 0 ], coords[ 1 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 1 ], coords[ 2 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 2 ], coords[ 3 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 3 ], coords[ 0 ] );

	// adjust for horizon clipping
	float result = LTC_ClippedSphereFormFactor( vectorFormFactor );

/*
	// alternate method of adjusting for horizon clipping (see reference)
	// refactoring required
	float len = length( vectorFormFactor );
	float z = vectorFormFactor.z / len;

	const float LUT_SIZE = 64.0;
	const float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
	const float LUT_BIAS = 0.5 / LUT_SIZE;

	// tabulated horizon-clipped sphere, apparently...
	vec2 uv = vec2( z * 0.5 + 0.5, len );
	uv = uv * LUT_SCALE + LUT_BIAS;

	float scale = texture2D( ltc_2, uv ).w;

	float result = len * scale;
*/

	return vec3( result, result, result );

}

// End Rect Area Light

#if defined( USE_SHEEN )

// https://github.com/google/filament/blob/master/shaders/src/brdf.fs
float D_Charlie( float roughness, float dotNH ) {

	float alpha = pow2( roughness );

	// Estevez and Kulla 2017, "Production Friendly Microfacet Sheen BRDF"
	float invAlpha = 1.0 / alpha;
	float cos2h = dotNH * dotNH;
	float sin2h = max( 1.0 - cos2h, 0.0078125 ); // 2^(-14/2), so sin2h^2 > 0 in fp16

	return ( 2.0 + invAlpha ) * pow( sin2h, invAlpha * 0.5 ) / ( 2.0 * PI );

}

// https://github.com/google/filament/blob/master/shaders/src/brdf.fs
float V_Neubelt( float dotNV, float dotNL ) {

	// Neubelt and Pettineo 2013, "Crafting a Next-gen Material Pipeline for The Order: 1886"
	return saturate( 1.0 / ( 4.0 * ( dotNL + dotNV - dotNL * dotNV ) ) );

}

vec3 BRDF_Sheen( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, vec3 sheenColor, const in float sheenRoughness ) {

	vec3 halfDir = normalize( lightDir + viewDir );

	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );

	float D = D_Charlie( sheenRoughness, dotNH );
	float V = V_Neubelt( dotNV, dotNL );

	return sheenColor * ( D * V );

}

#endif

// This is a curve-fit approximation to the "Charlie sheen" BRDF integrated over the hemisphere from
// Estevez and Kulla 2017, "Production Friendly Microfacet Sheen BRDF".
float IBLSheenBRDF( const in vec3 normal, const in vec3 viewDir, const in float roughness ) {

	float dotNV = saturate( dot( normal, viewDir ) );

	float r2 = roughness * roughness;
	float rInv = 1.0 / ( roughness + 0.1 );

	float a = -1.9362 + 1.0678 * roughness + 0.4573 * r2 - 0.8469 * rInv;
	float b = -0.6014 + 0.5538 * roughness - 0.4670 * r2 - 0.1255 * rInv;

	float DG = exp( a * dotNV + b );

	return saturate( DG );

}

vec3 EnvironmentBRDF( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness ) {

	float dotNV = saturate( dot( normal, viewDir ) );
	vec2 fab = texture2D( dfgLUT, vec2( roughness, dotNV ) ).rg;

	return specularColor * fab.x + specularF90 * fab.y;

}

// Fdez-Agüera's "Multiple-Scattering Microfacet Model for Real-Time Image Based Lighting"
// Approximates multiscattering in order to preserve energy.
// http://www.jcgt.org/published/0008/01/03/
#ifdef USE_IRIDESCENCE
void computeMultiscatteringIridescence( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float iridescence, const in vec3 iridescenceF0, const in float roughness, inout vec3 singleScatter, inout vec3 multiScatter ) {
#else
void computeMultiscattering( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness, inout vec3 singleScatter, inout vec3 multiScatter ) {
#endif

	float dotNV = saturate( dot( normal, viewDir ) );
	vec2 fab = texture2D( dfgLUT, vec2( roughness, dotNV ) ).rg;

	#ifdef USE_IRIDESCENCE

		vec3 Fr = mix( specularColor, iridescenceF0, iridescence );

	#else

		vec3 Fr = specularColor;

	#endif

	vec3 FssEss = Fr * fab.x + specularF90 * fab.y;

	float Ess = fab.x + fab.y;
	float Ems = 1.0 - Ess;

	vec3 Favg = Fr + ( 1.0 - Fr ) * 0.047619; // 1/21
	vec3 Fms = FssEss * Favg / ( 1.0 - mul(Ems , Favg) );

	singleScatter += FssEss;
	multiScatter += Fms * Ems;

}

#if NUM_RECT_AREA_LIGHTS > 0

	void RE_Direct_RectArea_Physical( const in RectAreaLight rectAreaLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {

		vec3 normal = geometryNormal;
		vec3 viewDir = geometryViewDir;
		vec3 position = geometryPosition;
		vec3 lightPos = rectAreaLight.position;
		vec3 halfWidth = rectAreaLight.halfWidth;
		vec3 halfHeight = rectAreaLight.halfHeight;
		vec3 lightColor = rectAreaLight.color;
		float roughness = material.roughness;

		vec3 rectCoords[ 4 ];
		rectCoords[ 0 ] = lightPos + halfWidth - halfHeight; // counterclockwise; light shines in local neg z direction
		rectCoords[ 1 ] = lightPos - halfWidth - halfHeight;
		rectCoords[ 2 ] = lightPos - halfWidth + halfHeight;
		rectCoords[ 3 ] = lightPos + halfWidth + halfHeight;

		vec2 uv = LTC_Uv( normal, viewDir, roughness );

		vec4 t1 = texture2D( ltc_1, uv );
		vec4 t2 = texture2D( ltc_2, uv );

		mat3 mInv = mat3(
			vec3( t1.x, 0, t1.y ),
			vec3(    0, 1,    0 ),
			vec3( t1.z, 0, t1.w )
		);

		// LTC Fresnel Approximation by Stephen Hill
		// http://blog.selfshadow.com/publications/s2016-advances/s2016_ltc_fresnel.pdf
		vec3 fresnel = ( material.specularColorBlended * t2.x + ( material.specularF90 - material.specularColorBlended ) * t2.y );

		reflectedLight.directSpecular += lightColor * fresnel * LTC_Evaluate( normal, viewDir, position, mInv, rectCoords );

		reflectedLight.directDiffuse += lightColor * material.diffuseContribution * LTC_Evaluate( normal, viewDir, position, mat3( 1.0 ), rectCoords );

		#ifdef USE_CLEARCOAT

			vec3 Ncc = geometryClearcoatNormal;

			vec2 uvClearcoat = LTC_Uv( Ncc, viewDir, material.clearcoatRoughness );

			vec4 t1Clearcoat = texture2D( ltc_1, uvClearcoat );
			vec4 t2Clearcoat = texture2D( ltc_2, uvClearcoat );

			mat3 mInvClearcoat = mat3(
				vec3( t1Clearcoat.x, 0, t1Clearcoat.y ),
				vec3(             0, 1,             0 ),
				vec3( t1Clearcoat.z, 0, t1Clearcoat.w )
			);

			// LTC Fresnel Approximation for clearcoat
			vec3 fresnelClearcoat = material.clearcoatF0 * t2Clearcoat.x + ( material.clearcoatF90 - material.clearcoatF0 ) * t2Clearcoat.y;

			clearcoatSpecularDirect += lightColor * fresnelClearcoat * LTC_Evaluate( Ncc, viewDir, position, mInvClearcoat, rectCoords );

		#endif

	}

#endif

void RE_Direct_Physical( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {

	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );

	vec3 irradiance = dotNL * directLight.color;

	#ifdef USE_CLEARCOAT

		float dotNLcc = saturate( dot( geometryClearcoatNormal, directLight.direction ) );

		vec3 ccIrradiance = dotNLcc * directLight.color;

		clearcoatSpecularDirect += ccIrradiance * BRDF_GGX_Clearcoat( directLight.direction, geometryViewDir, geometryClearcoatNormal, material );

	#endif

	#ifdef USE_SHEEN
 
 		sheenSpecularDirect += irradiance * BRDF_Sheen( directLight.direction, geometryViewDir, geometryNormal, material.sheenColor, material.sheenRoughness );
 
 		float sheenAlbedoV = IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );
 		float sheenAlbedoL = IBLSheenBRDF( geometryNormal, directLight.direction, material.sheenRoughness );
 
 		float sheenEnergyComp = 1.0 - max3( material.sheenColor ) * max( sheenAlbedoV, sheenAlbedoL );
 
 		irradiance *= sheenEnergyComp;
 
 	#endif

	vec3 specularBRDF = BRDF_GGX( directLight.direction, geometryViewDir, geometryNormal, material );

	#ifdef USE_RETROREFLECTIVE

		// Minimal Retroreflective Microfacet Model:
		// https://jcgt.org/published/0015/01/04/
		vec3 retroViewDir = reflect( - geometryViewDir, geometryNormal );
		vec3 retroSpecularBRDF = BRDF_GGX( directLight.direction, retroViewDir, geometryNormal, material );

		specularBRDF = mix( specularBRDF, retroSpecularBRDF, saturate( material.retroreflective ) );

	#endif

	reflectedLight.directSpecular += irradiance * specularBRDF * material.multiScatteringCompensation;

	// Light reflected by the specular interface is not available to the diffuse layer ( glTF fresnel_mix )
	vec3 halfDir = normalize( directLight.direction + geometryViewDir );
	float dotVH = saturate( dot( geometryViewDir, halfDir ) );
	vec3 F = F_Schlick( material.specularColor, material.specularF90, dotVH );

	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseContribution ) * ( 1.0 - F );
}

void RE_IndirectDiffuse_Physical( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {

	// Energy reflected by the specular lobe is not available to the diffuse layer
	vec3 singleScattering = vec3(0.0, 0.0, 0.0);
	vec3 multiScattering = vec3(0.0, 0.0, 0.0);

	#ifdef USE_IRIDESCENCE

		computeMultiscatteringIridescence( geometryNormal, geometryViewDir, material.specularColor, material.specularF90, material.iridescence, material.iridescenceF0Dielectric, material.roughness, singleScattering, multiScattering );

	#else

		computeMultiscattering( geometryNormal, geometryViewDir, material.specularColor, material.specularF90, material.roughness, singleScattering, multiScattering );

	#endif

	vec3 diffuse = irradiance * BRDF_Lambert( material.diffuseContribution ) * ( 1.0 - singleScattering - multiScattering );

	#ifdef USE_SHEEN

		float sheenAlbedo = IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );

		sheenSpecularIndirect += irradiance * material.sheenColor * sheenAlbedo * RECIPROCAL_PI;

		float sheenEnergyComp = 1.0 - max3( material.sheenColor ) * sheenAlbedo;

		diffuse *= sheenEnergyComp;

	#endif

	reflectedLight.indirectDiffuse += diffuse;

}

void RE_IndirectSpecular_Physical( const in vec3 radiance, const in vec3 irradiance, const in vec3 clearcoatRadiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight) {

	#ifdef USE_CLEARCOAT

		clearcoatSpecularIndirect += clearcoatRadiance * EnvironmentBRDF( geometryClearcoatNormal, geometryViewDir, material.clearcoatF0, material.clearcoatF90, material.clearcoatRoughness );

	#endif

	#ifdef USE_SHEEN

		sheenSpecularIndirect += irradiance * material.sheenColor * IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness ) * RECIPROCAL_PI;

 	#endif

	// Both indirect specular and indirect diffuse light accumulate here
	// Compute multiscattering separately for dielectric and metallic, then mix

	vec3 singleScatteringDielectric = vec3(0.0, 0.0, 0.0);
	vec3 multiScatteringDielectric = vec3(0.0, 0.0, 0.0);

	vec3 singleScatteringMetallic = vec3(0.0, 0.0, 0.0);
	vec3 multiScatteringMetallic = vec3(0.0, 0.0, 0.0);

	#ifdef USE_IRIDESCENCE

		computeMultiscatteringIridescence( geometryNormal, geometryViewDir, material.specularColor, material.specularF90, material.iridescence, material.iridescenceF0Dielectric, material.roughness, singleScatteringDielectric, multiScatteringDielectric );
		computeMultiscatteringIridescence( geometryNormal, geometryViewDir, material.diffuseColor, material.specularF90, material.iridescence, material.iridescenceF0Metallic, material.roughness, singleScatteringMetallic, multiScatteringMetallic );

	#else

		computeMultiscattering( geometryNormal, geometryViewDir, material.specularColor, material.specularF90, material.roughness, singleScatteringDielectric, multiScatteringDielectric );
		computeMultiscattering( geometryNormal, geometryViewDir, material.diffuseColor, material.specularF90, material.roughness, singleScatteringMetallic, multiScatteringMetallic );

	#endif

	// Mix based on metalness
	vec3 singleScattering = mix( singleScatteringDielectric, singleScatteringMetallic, material.metalness );
	vec3 multiScattering = mix( multiScatteringDielectric, multiScatteringMetallic, material.metalness );

	// Diffuse energy conservation uses dielectric path
	vec3 totalScatteringDielectric = singleScatteringDielectric + multiScatteringDielectric;
	vec3 diffuse = material.diffuseContribution * ( 1.0 - totalScatteringDielectric );

	vec3 cosineWeightedIrradiance = irradiance * RECIPROCAL_PI;

	vec3 indirectSpecular = radiance * singleScattering;
	indirectSpecular += multiScattering * cosineWeightedIrradiance;

	vec3 indirectDiffuse = diffuse * cosineWeightedIrradiance;

	#ifdef USE_SHEEN

		float sheenAlbedo = IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );

		float sheenEnergyComp = 1.0 - max3( material.sheenColor ) * sheenAlbedo;

		indirectSpecular *= sheenEnergyComp;
		indirectDiffuse *= sheenEnergyComp;

	#endif

	reflectedLight.indirectSpecular += indirectSpecular;
	reflectedLight.indirectDiffuse += indirectDiffuse;

}

#define RE_Direct				RE_Direct_Physical
#define RE_Direct_RectArea		RE_Direct_RectArea_Physical
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Physical
#define RE_IndirectSpecular		RE_IndirectSpecular_Physical

// ref: https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
float computeSpecularOcclusion( const in float dotNV, const in float ambientOcclusion, const in float roughness ) {

	return saturate( pow( dotNV + ambientOcclusion, exp2( - 16.0 * roughness - 1.0 ) ) - 1.0 + ambientOcclusion );

}
"#
```
lights_physical_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lights\_toon\_fragment
```cj
public const lights_toon_fragment: String = #"
ToonMaterial material;
material.diffuseColor = diffuseColor.rgb;
"#
```
lights_toon_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const lights\_toon\_pars\_fragment
```cj
public const lights_toon_pars_fragment: String = #"
struct ToonMaterial {

	vec3 diffuseColor;

};

void RE_Direct_Toon( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {

	vec3 irradiance = getGradientIrradiance( geometryNormal, directLight.direction ) * directLight.color;

	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );

}

void RE_IndirectDiffuse_Toon( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {

	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );

}

#define RE_Direct				RE_Direct_Toon
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Toon
"#
```
lights_toon_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const logdepthbuf\_fragment
```cj
public const logdepthbuf_fragment: String = #"
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )

	// Doing a strict comparison with == 1.0 can cause noise artifacts
	// on some platforms. See issue #17623.
	gl_FragDepth = vIsPerspective == 0.0 ? gl_FragCoord.z : log2( vFragDepth ) * logDepthBufFC * 0.5;

#endif
"#
```
logdepthbuf_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const logdepthbuf\_pars\_fragment
```cj
public const logdepthbuf_pars_fragment: String = #"
#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )

	uniform float logDepthBufFC;

#endif
"#
```
logdepthbuf_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const logdepthbuf\_pars\_vertex
```cj
public const logdepthbuf_pars_vertex: String = #""#
```
logdepthbuf_pars_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const logdepthbuf\_vertex
```cj
public const logdepthbuf_vertex: String = #"
#ifdef USE_LOGARITHMIC_DEPTH_BUFFER

	vFragDepth = 1.0 + gl_Position.w;
	vIsPerspective = float( isPerspectiveMatrix( projectionMatrix ) );

#endif
"#
```
logdepthbuf_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const map\_fragment
```cj
public const map_fragment: String = #"
#ifdef USE_MAP

	vec4 sampledDiffuseColor = texture2D( map, vMapUv );

	#ifdef DECODE_VIDEO_TEXTURE

		// use inline sRGB decode until browsers properly support SRGB8_ALPHA8 with video textures (#26516)

		sampledDiffuseColor = sRGBTransferEOTF( sampledDiffuseColor );

	#endif

	diffuseColor *= sampledDiffuseColor;

#endif
"#
```
map_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const map\_pars\_fragment
```cj
public const map_pars_fragment: String = #"

	// 必须用 SAMPLER2D 宏而非裸 uniform sampler2D：HLSL 分支下
	// bgfx_shader.sh 定义 #define sampler2D BgfxSampler2D，裸声明会被替换成 struct，
	// bgfx 无法按名绑定 sampler uniform → 贴图采样不生效。
	SAMPLER2D(map, __STAGE_MAP__);
	uniform vec4 u_useMap;

"#
```
map_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const map\_particle\_fragment
```cj
public const map_particle_fragment: String = #"
#if defined( USE_MAP ) || defined( USE_ALPHAMAP )

	#if defined( USE_POINTS_UV )

		vec2 uv = vUv;

	#else

		vec2 uv = ( uvTransform * vec3( gl_PointCoord.x, 1.0 - gl_PointCoord.y, 1 ) ).xy;

	#endif

#endif

#ifdef USE_MAP

	diffuseColor *= texture2D( map, uv );

#endif

#ifdef USE_ALPHAMAP

	diffuseColor.a *= texture2D( alphaMap, uv ).g;

#endif
"#
```
map_particle_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const map\_particle\_pars\_fragment
```cj
public const map_particle_pars_fragment: String = #"
#if defined( USE_POINTS_UV )

#else

	#if defined( USE_MAP ) || defined( USE_ALPHAMAP )

		uniform mat3 uvTransform;

	#endif

#endif

#ifdef USE_MAP

	uniform sampler2D map;

#endif

#ifdef USE_ALPHAMAP

	uniform sampler2D alphaMap;

#endif
"#
```
map_particle_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const metalnessmap\_fragment
```cj
public const metalnessmap_fragment: String = #"
float metalnessFactor = metalness;

#ifdef USE_METALNESSMAP

	vec4 texelMetalness = texture2D( metalnessMap, vMetalnessMapUv );

	// reads channel B, compatible with a combined OcclusionRoughnessMetallic (RGB) texture
	metalnessFactor *= texelMetalness.b;

#endif
"#
```
metalnessmap_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const metalnessmap\_pars\_fragment
```cj
public const metalnessmap_pars_fragment: String = #"
#ifdef USE_METALNESSMAP

	// 必须用 SAMPLER2D 宏而非裸 uniform sampler2D：HLSL 分支下
	// bgfx_shader.sh 定义 #define sampler2D BgfxSampler2D，裸声明会被替换成 struct，
	// bgfx 无法按名绑定 sampler uniform → 贴图采样不生效。
	// stage 4 避开已占用的 u_envMap=2 / dfgLUT=3。
	SAMPLER2D(metalnessMap, __STAGE_METALNESS_MAP__);

#endif
"#
```
metalnessmap_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const morphcolor\_vertex
```cj
public const morphcolor_vertex: String = #"
#if defined( USE_MORPHCOLORS )

	// morphTargetBaseInfluence is set based on BufferGeometry.morphTargetsRelative value:
	// When morphTargetsRelative is false, this is set to 1 - sum(influences); this results in normal = sum((target - base) * influence)
	// When morphTargetsRelative is true, this is set to 1; as a result, all morph targets are simply added to the base after weighting
	vColor *= morphTargetBaseInfluence;

	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {

		#if defined( USE_COLOR_ALPHA )

			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ) * morphTargetInfluences[ i ];

		#elif defined( USE_COLOR )

			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ).rgb * morphTargetInfluences[ i ];

		#endif

	}

#endif
"#
```
morphcolor_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const morphinstance\_vertex
```cj
public const morphinstance_vertex: String = #"
#ifdef USE_INSTANCING_MORPH

	float morphTargetInfluences[ MORPHTARGETS_COUNT ];

	float morphTargetBaseInfluence = texelFetch( morphTexture, ivec2( 0, gl_InstanceID ), 0 ).r;

	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {

		morphTargetInfluences[i] =  texelFetch( morphTexture, ivec2( i + 1, gl_InstanceID ), 0 ).r;

	}
#endif
"#
```
morphinstance_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const morphnormal\_vertex
```cj
public const morphnormal_vertex: String = #"
#ifdef USE_MORPHNORMALS

	// morphTargetBaseInfluence is set based on BufferGeometry.morphTargetsRelative value:
	// When morphTargetsRelative is false, this is set to 1 - sum(influences); this results in normal = sum((target - base) * influence)
	// When morphTargetsRelative is true, this is set to 1; as a result, all morph targets are simply added to the base after weighting
	objectNormal *= morphTargetBaseInfluence;

	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {

		if ( morphTargetInfluences[ i ] != 0.0 ) objectNormal += getMorph( gl_VertexID, i, 1 ).xyz * morphTargetInfluences[ i ];

	}

#endif
"#
```
morphnormal_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const morphtarget\_pars\_vertex
```cj
public const morphtarget_pars_vertex: String = #"
#ifdef USE_MORPHTARGETS

	#ifndef USE_INSTANCING_MORPH

		uniform float morphTargetBaseInfluence;
		uniform float morphTargetInfluences[ MORPHTARGETS_COUNT ];

	#endif

	uniform sampler2DArray morphTargetsTexture;
	uniform ivec2 morphTargetsTextureSize;

	vec4 getMorph( const in int vertexIndex, const in int morphTargetIndex, const in int offset ) {

		int texelIndex = vertexIndex * MORPHTARGETS_TEXTURE_STRIDE + offset;
		int y = texelIndex / morphTargetsTextureSize.x;
		int x = texelIndex - y * morphTargetsTextureSize.x;

		ivec3 morphUV = ivec3( x, y, morphTargetIndex );
		return texelFetch( morphTargetsTexture, morphUV, 0 );

	}

#endif
"#
```
morphtarget_pars_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const morphtarget\_vertex
```cj
public const morphtarget_vertex: String = #"
#ifdef USE_MORPHTARGETS

	// morphTargetBaseInfluence is set based on BufferGeometry.morphTargetsRelative value:
	// When morphTargetsRelative is false, this is set to 1 - sum(influences); this results in position = sum((target - base) * influence)
	// When morphTargetsRelative is true, this is set to 1; as a result, all morph targets are simply added to the base after weighting
	transformed *= morphTargetBaseInfluence;

	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {

		if ( morphTargetInfluences[ i ] != 0.0 ) transformed += getMorph( gl_VertexID, i, 0 ).xyz * morphTargetInfluences[ i ];

	}

#endif
"#
```
morphtarget_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const normal\_fragment
```cj
public const normal_fragment: String = #"
vec3 normal = normalize( vNormal );
"#
```
normal_fragment GLSL 片段字符串

## const normal\_fragment\_begin
```cj
public const normal_fragment_begin: String = #"
float faceDirection = gl_FrontFacing ? 1.0 : - 1.0;

#ifdef FLAT_SHADED

	vec3 fdx = dFdx( vViewPosition );
	vec3 fdy = dFdy( vViewPosition );
	vec3 normal = normalize( cross( fdx, fdy ) );

#else

	vec3 normal = normalize( vNormal );

	#ifdef DOUBLE_SIDED

		normal *= faceDirection;

	#endif

#endif

#if defined( USE_NORMALMAP_TANGENTSPACE ) || defined( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY )

	#ifdef USE_TANGENT

		mat3 tbn = mat3( normalize( vTangent ), normalize( vBitangent ), normal );

	#else

		mat3 tbn = getTangentFrame( - vViewPosition, normal,
		#if defined( USE_NORMALMAP )
			vNormalMapUv
		#elif defined( USE_CLEARCOAT_NORMALMAP )
			vClearcoatNormalMapUv
		#else
			vUv
		#endif
		);

	#endif

	#ifdef DOUBLE_SIDED

		tbn[0] *= faceDirection;
		tbn[1] *= faceDirection;

	#endif

#endif

#ifdef USE_CLEARCOAT_NORMALMAP

	#ifdef USE_TANGENT

		mat3 tbn2 = mat3( normalize( vTangent ), normalize( vBitangent ), normal );

	#else

		mat3 tbn2 = getTangentFrame( - vViewPosition, normal, vClearcoatNormalMapUv );

	#endif

	#ifdef DOUBLE_SIDED

		tbn2[0] *= faceDirection;
		tbn2[1] *= faceDirection;

	#endif

#endif

// non perturbed normal for clearcoat among others

vec3 nonPerturbedNormal = normal;
"#
```
normal_fragment_begin GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const normal\_fragment\_maps
```cj
public const normal_fragment_maps: String = #"

#ifdef USE_NORMALMAP_OBJECTSPACE

	normal = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0; // overrides both flatShading and attribute normals

	#ifdef FLIP_SIDED

		normal = - normal;

	#endif

	#ifdef DOUBLE_SIDED

		normal = normal * faceDirection;

	#endif

	normal = normalize( normalMatrix * normal );

#elif defined( USE_NORMALMAP_TANGENTSPACE )

	vec3 mapN = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;

	#if defined( USE_PACKED_NORMALMAP )

		mapN = vec3( mapN.xy, sqrt( saturate( 1.0 - dot( mapN.xy, mapN.xy ) ) ) );

	#endif

	mapN.xy *= normalScale;

	normal = normalize( tbn * mapN );

#elif defined( USE_BUMPMAP )

	normal = perturbNormalArb( - vViewPosition, normal, dHdxy_fwd(), faceDirection );

#endif
"#
```
normal_fragment_maps GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const normal\_pars\_fragment
```cj
public const normal_pars_fragment: String = #"

"#
```
normal_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const normal\_pars\_vertex
```cj
public const normal_pars_vertex: String = #"

"#
```
normal_pars_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const normal\_vertex
```cj
public const normal_vertex: String = #"
#ifndef FLAT_SHADED // normal is computed with derivatives when FLAT_SHADED

	vNormal = normalize( transformedNormal );

	#ifdef USE_TANGENT

		vTangent = normalize( transformedTangent );
		vBitangent = normalize( cross( vNormal, vTangent ) * tangent.w );

		#ifdef FLIP_SIDED

			vBitangent = - vBitangent;

		#endif

	#endif

#endif
"#
```
normal_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const normalmap\_pars\_fragment
```cj
public const normalmap_pars_fragment: String = #"
#ifdef USE_NORMALMAP

	uniform sampler2D u_normalMap;
	uniform vec2 u_normalScale;

#endif
"#
```
normalmap_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const opaque\_fragment
```cj
public const opaque_fragment: String = #"
#ifdef OPAQUE
diffuseColor.a = 1.0;
#endif

#ifdef USE_TRANSMISSION
diffuseColor.a *= material.transmissionAlpha;
#endif

gl_FragColor = vec4( outgoingLight, diffuseColor.a );
"#
```
opaque_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const output\_fragment
```cj
public const output_fragment: String = #"
// output_fragment - default
"#
```
output_fragment GLSL 片段字符串

## const packing
```cj
public const packing: String = #"
vec3 packNormalToRGB( const in vec3 normal ) {
	return normalize( normal ) * 0.5 + 0.5;
}

vec3 unpackRGBToNormal( const in vec3 rgb ) {
	return 2.0 * rgb.xyz - 1.0;
}

const float PackUpscale = 256. / 255.; // fraction -> 0..1 (including 1)
const float UnpackDownscale = 255. / 256.; // 0..1 -> fraction (excluding 1)
const float ShiftRight8 = 1. / 256.;
const float Inv255 = 1. / 255.;

const vec4 PackFactors = vec4( 1.0, 256.0, 256.0 * 256.0, 256.0 * 256.0 * 256.0 );

const vec2 UnpackFactors2 = vec2( UnpackDownscale, 1.0 / PackFactors.g );
const vec3 UnpackFactors3 = vec3( UnpackDownscale / PackFactors.rg, 1.0 / PackFactors.b );
const vec4 UnpackFactors4 = vec4( UnpackDownscale / PackFactors.rgb, 1.0 / PackFactors.a );

vec4 packDepthToRGBA( const in float v ) {
	if( v <= 0.0 )
		return vec4( 0., 0., 0., 0. );
	if( v >= 1.0 )
		return vec4( 1., 1., 1., 1. );
	float vuf;
	float af = modf( v * PackFactors.a, vuf );
	float bf = modf( vuf * ShiftRight8, vuf );
	float gf = modf( vuf * ShiftRight8, vuf );
	return vec4( vuf * Inv255, gf * PackUpscale, bf * PackUpscale, af );
}

vec3 packDepthToRGB( const in float v ) {
	if( v <= 0.0 )
		return vec3( 0., 0., 0. );
	if( v >= 1.0 )
		return vec3( 1., 1., 1. );
	float vuf;
	float bf = modf( v * PackFactors.b, vuf );
	float gf = modf( vuf * ShiftRight8, vuf );
	// the 0.9999 tweak is unimportant, very tiny empirical improvement
	// return vec3( vuf * Inv255, gf * PackUpscale, bf * 0.9999 );
	return vec3( vuf * Inv255, gf * PackUpscale, bf );
}

vec2 packDepthToRG( const in float v ) {
	if( v <= 0.0 )
		return vec2( 0., 0. );
	if( v >= 1.0 )
		return vec2( 1., 1. );
	float vuf;
	float gf = modf( v * 256., vuf );
	return vec2( vuf * Inv255, gf );
}

float unpackRGBAToDepth( const in vec4 v ) {
	return dot( v, UnpackFactors4 );
}

float unpackRGBToDepth( const in vec3 v ) {
	return dot( v, UnpackFactors3 );
}

float unpackRGToDepth( const in vec2 v ) {
	return v.r * UnpackFactors2.r + v.g * UnpackFactors2.g;
}

vec4 pack2HalfToRGBA( const in vec2 v ) {
	vec4 r = vec4( v.x, fract( v.x * 255.0 ), v.y, fract( v.y * 255.0 ) );
	return vec4( r.x - r.y / 255.0, r.y, r.z - r.w / 255.0, r.w );
}

vec2 unpackRGBATo2Half( const in vec4 v ) {
	return vec2( v.x + ( v.y / 255.0 ), v.z + ( v.w / 255.0 ) );
}

// NOTE (bgfx4cj 左手系): viewZ, the z-coordinate in camera space, is positive for points in front of the camera

float viewZToOrthographicDepth( const in float viewZ, const in float near, const in float far ) {
 // near maps to 0; far maps to 1 (left-handed +Z)
 return ( viewZ - near ) / ( far - near );
}

float orthographicDepthToViewZ( const in float depth, const in float near, const in float far ) {

 #ifdef USE_REVERSED_DEPTH_BUFFER

  return far - depth * ( far - near );

 #else

  return depth * ( far - near ) + near;

 #endif
}

// NOTE: https://twitter.com/gonnavis/status/1377183786949959682

float viewZToPerspectiveDepth( const in float viewZ, const in float near, const in float far ) {
 // near maps to 0; far maps to 1 (left-handed +Z)
 return ( ( viewZ - near ) * far ) / ( ( far - near ) * viewZ );
}

float perspectiveDepthToViewZ( const in float depth, const in float near, const in float far ) {

 #ifdef USE_REVERSED_DEPTH_BUFFER

  return ( near * far ) / ( ( far - near ) * depth + far );

 #else

  return ( near * far ) / ( far - ( far - near ) * depth );

 #endif
}
"#
```
packing GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const premultiplied\_alpha\_fragment
```cj
public const premultiplied_alpha_fragment: String = #"
#ifdef PREMULTIPLIED_ALPHA

	gl_FragColor.rgb *= gl_FragColor.a;

#endif
"#
```
premultiplied_alpha_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const project\_vertex
```cj
public const project_vertex: String = #"
vec4 mvPosition = vec4( transformed, 1.0 );

#ifdef USE_BATCHING

	mvPosition = batchingMatrix * mvPosition;

#endif

#ifdef USE_INSTANCING

	mvPosition = instanceMatrix * mvPosition;

#endif

mvPosition = mul( u_view, mul( u_model[0], mvPosition ) );

v_viewPos = -mvPosition.xyz;

gl_Position = mul( u_proj, mvPosition );
"#
```
project_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const roughnessmap\_fragment
```cj
public const roughnessmap_fragment: String = #"
float roughnessFactor = roughness;

#ifdef USE_ROUGHNESSMAP

	vec4 texelRoughness = texture2D( roughnessMap, vRoughnessMapUv );

	// reads channel G, compatible with a combined OcclusionRoughnessMetallic (RGB) texture
	roughnessFactor *= texelRoughness.g;

#endif
"#
```
roughnessmap_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const roughnessmap\_pars\_fragment
```cj
public const roughnessmap_pars_fragment: String = #"
#ifdef USE_ROUGHNESSMAP

	// 必须用 SAMPLER2D 宏而非裸 uniform sampler2D：HLSL 分支下
	// bgfx_shader.sh 定义 #define sampler2D BgfxSampler2D，裸声明会被替换成 struct，
	// bgfx 无法按名绑定 sampler uniform → 贴图采样不生效。
	SAMPLER2D(roughnessMap, __STAGE_ROUGHNESS_MAP__);

#endif
"#
```
roughnessmap_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const shadow\_blur\_vertex
```cj
public const shadow_blur_vertex: String = #"
// HBlur/VBlur pass 顶点着色器
// 对照 16-shadowmaps: vs_shadowmaps_hblur.sc / vs_shadowmaps_vblur.sc
//
// 预计算 9 个采样点 UV，通过 varying 传入 fragment
// 由 #define HBLUR_PASS / VBLUR_PASS 切换偏移方向

$input a_position, a_texcoord0

$output v_texcoord0, v_texcoord1, v_texcoord2, v_texcoord3, v_texcoord4

#include <bgfx_shader.sh>

uniform vec4 u_inverseTextureSize;

void main()
{
    vec2 texcoord = a_texcoord0;

    // 中心采样点
    v_texcoord0 = texcoord;

    // 8 个偏移采样点（4 对对称偏移）
    // u_inverseTextureSize.xy = 1/width, 1/height（纹理尺寸倒数）
    vec2 invTexSize = u_inverseTextureSize.xy;

#if defined( HBLUR_PASS )
    // 水平模糊：UV 偏移方向 = u（水平）
    vec2 offset = vec2(invTexSize.x, 0.0);
#elif defined( VBLUR_PASS )
    // 垂直模糊：UV 偏移方向 = v（垂直）
    vec2 offset = vec2(0.0, invTexSize.y);
#else
    // 兜底：默认水平模糊
    vec2 offset = vec2(invTexSize.x, 0.0);
#endif

    // 9-tap Gaussian 偏移（权重 1.0, 0.9, 0.55, 0.18, 0.1）
    // 对照 blur9 的采样模式
    v_texcoord1 = vec4(texcoord + offset * 1.0, texcoord - offset * 1.0);
    v_texcoord2 = vec4(texcoord + offset * 2.0, texcoord - offset * 2.0);
    v_texcoord3 = vec4(texcoord + offset * 3.0, texcoord - offset * 3.0);
    v_texcoord4 = vec4(texcoord + offset * 4.0, texcoord - offset * 4.0);

    // 全屏四边形：a_position 已是 NDC 坐标
    gl_Position = vec4(a_position, 0.0, 1.0);
}
"#
```
HBlur/VBlur pass 顶点着色器 chunk。

预计算 9 个采样点 UV 坐标，通过 varying 传入 fragment：
v_texcoord0（中心）+ v_texcoord1..4（8 个偏移）

HBlur: UV 偏移方向 = 水平（u 增减）
VBlur: UV 偏移方向 = 垂直（v 增减）

由编译期 #define HBLUR_PASS / VBLUR_PASS 切换偏移方向。

## const shadow\_common
```cj
public const shadow_common: String = #"

// ===== Vogel disk + Poisson 采样 (PCF/PCSS 共用) =====
// 对照 16-shadowmaps/common.sh: sampleVogelDisk/samplePoisson

vec2 sampleVogelDisk(int index, int sampleCount)
{
    const float goldenAngle = 2.39996323; // radians
    float i = float(index);
    float r = sqrt((i + 0.5) / float(sampleCount));
    float a = i * goldenAngle;
    return vec2(cos(a), sin(a)) * r;
}

vec2 samplePoisson(int index)
{
    return sampleVogelDisk(index, 10);
}

// ===== 辅助函数 =====
// 对照 16-shadowmaps/common.sh: linstep/attenuation/spot/lit

float linstep(float _edge0, float _edge1, float _x)
{
    return clamp((_x-_edge0)/(_edge1-_edge0), 0.0, 1.0);
}

float attenuation(float _dist, vec3 _attn)
{
    return 1.0 / ( _attn.x                  //const
                 + _attn.y * _dist          //linear
                 + _attn.z * _dist * _dist  //quadrantic
                 );
}

float spot(float _ldotsd, float _inner, float _outer)
{
    float inner = cos(radians(_inner));
    float outer = cos(radians(min(_outer, _inner - 0.001)));
    float spot = clamp((_ldotsd - inner) / (outer - inner), 0.0, 1.0);
    return spot;
}

vec2 lit(vec3 _ld, vec3 _n, vec3 _vd, float _exp)
{
    //diff
    float ndotl = dot(_n, _ld);

    //spec
    vec3 r = 2.0*ndotl*_n - _ld; // reflect(_ld, _n);
    float rdotv = dot(r, _vd);
    float spec = step(0.0, ndotl) * pow(max(0.0, rdotv), _exp) * (2.0 + _exp)/8.0;

    return max(vec2(ndotl, spec), 0.0);
}

// ===== 光源求值 (evalLight) =====
// 对照 16-shadowmaps/common.sh: Light struct + evalLight

struct Light
{
    vec3 l;
    vec3 ld;
    float attn;
};

Light evalLight(vec3 _v, vec4 _l, vec3 _spotDirection, float _spotInner, float _spotOuter, vec3 _attnParams)
{
    Light light;

    //directional
    light.l    = _l.xyz;
    light.ld   = -normalize(light.l);
    light.attn = 1.0;

    if (0.0 != _l.w) //point or spot
    {
        light.l  = _l.xyz - _v;
        light.ld = normalize(light.l);

        float ldotsd = max(0.0, dot(-light.ld, normalize(_spotDirection)));
        float falloff = spot(ldotsd, _spotOuter, _spotInner);
        light.attn = attenuation(length(light.l), _attnParams) * mix(falloff, 1.0, step(90, _spotOuter));
    }

    return light;
}

// ===== texcoordInRange =====
// 对照 16-shadowmaps/common.sh: texcoordInRange

float texcoordInRange(vec2 _texcoord)
{
    bool inRange = all(greaterThan(_texcoord, vec2_splat(0.0)))
                && all(lessThan   (_texcoord, vec2_splat(1.0)))
                 ;

    return float(inRange);
}

// ===== 采样旋转工具 =====
// 对照 16-shadowmaps/common.sh: rotateSample/interleavedGradientNoise

// Rotate a 2D sample by a precomputed sin/cos pair.
// _sincos = vec2(sin(angle), cos(angle))
vec2 rotateSample(vec2 _sample, vec2 _sincos)
{
    return vec2(_sample.x * _sincos.y - _sample.y * _sincos.x,
                _sample.x * _sincos.x + _sample.y * _sincos.y);
}

// Interleaved gradient noise for per-pixel Poisson disk rotation.
// Produces well-distributed noise that avoids the clustering artifacts of
// traditional fract(sin(...)) hashes. Converts structured Poisson banding
// into smooth, perceptually-uniform noise.
// Source: "Next Generation Post Processing in Call of Duty: AW" (Jimenez 2014)
float interleavedGradientNoise(vec2 _screenPos)
{
    vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
    return fract(magic.z * fract(dot(_screenPos, magic.xy)));
}

// ===== Hard Shadow (BASIC_SHADOW_MAP) =====
// 对照 16-shadowmaps/common.sh: hardShadowLod/hardShadow

float hardShadowLod(sampler2D _sampler, float lod, vec4 _shadowCoord, float _bias)
{
    vec2 texCoord = _shadowCoord.xy/_shadowCoord.w;

    bool outside = any(greaterThan(texCoord, vec2_splat(1.0)))
                || any(lessThan   (texCoord, vec2_splat(0.0)))
                 ;

    if (outside)
    {
        return 1.0;
    }

    float receiver = (_shadowCoord.z-_bias)/_shadowCoord.w;
    float occluder = unpackRgbaToFloat(texture2DLod(_sampler, texCoord, lod) );

    float visibility = step(receiver, occluder);
    return visibility;
}

float hardShadow(sampler2D _sampler, vec4 _shadowCoord, float _bias)
{
    return hardShadowLod(_sampler, 0.0, _shadowCoord, _bias);
}

// ===== PCF (PCF_SHADOW_MAP) =====
// 对照 16-shadowmaps/common.sh: PCFLodOffset/PCFLod/PCF
// BLOCKER_SEARCH_NUM_SAMPLES / PCF_LOD_OFFSET_NUM_SAMPLES 由调用方 #define

float PCFLodOffset(sampler2D _sampler, float lod, vec2 offset, vec4 _shadowCoord, float _bias, vec2 _texelSize, vec2 _diskRotation)
{
    float result = 0.0;

    for ( int i = 0; i < PCF_LOD_OFFSET_NUM_SAMPLES; ++i )
    {
        vec2 jitteredOffset = rotateSample(samplePoisson(i), _diskRotation) * offset;
        result += hardShadowLod(_sampler, lod, _shadowCoord + vec4(jitteredOffset, 0.0, 0.0), _bias);
    }
    return result / float(PCF_LOD_OFFSET_NUM_SAMPLES);
}

float PCFLod(sampler2D _sampler, float lod, vec2 filterRadius, vec4 _shadowCoord, float _bias, vec4 _pcfParams, vec2 _texelSize, vec2 _diskRotation)
{
    vec2 offset = filterRadius * _pcfParams.zw * _texelSize * _shadowCoord.w;

    return PCFLodOffset(_sampler, lod, offset, _shadowCoord, _bias, _texelSize, _diskRotation);
}

float PCF(sampler2D _sampler, vec4 _shadowCoord, float _bias, vec4 _pcfParams, vec2 _texelSize, vec2 fragCoord)
{
    // Per-pixel Poisson disk rotation from shadow map texel coordinates
    vec2 noiseCoord = fragCoord;
    //vec2 noiseCoord = (_shadowCoord.xy / _shadowCoord.w) * (1.0 / _texelSize.x);
    float angle = interleavedGradientNoise(noiseCoord) * 6.283185;
    vec2 diskRotation = vec2(sin(angle), cos(angle));
    return PCFLod(_sampler, 0.0, vec2(2.0, 2.0), _shadowCoord, _bias, _pcfParams, _texelSize, diskRotation);
}

// ===== VSM (VSM_SHADOW_MAP) =====
// 对照 16-shadowmaps/common.sh: VSM

float VSM(sampler2D _sampler, vec4 _shadowCoord, float _bias, float _depthMultiplier, float _minVariance)
{
    vec2 texCoord = _shadowCoord.xy/_shadowCoord.w;

    bool outside = any(greaterThan(texCoord, vec2_splat(1.0)))
                || any(lessThan   (texCoord, vec2_splat(0.0)))
                 ;

    if (outside)
    {
        return 1.0;
    }

    float receiver = (_shadowCoord.z-_bias)/_shadowCoord.w * _depthMultiplier;
    vec4 rgba = texture2D(_sampler, texCoord);
    vec2 occluder = vec2(unpackHalfFloat(rgba.rg), unpackHalfFloat(rgba.ba)) * _depthMultiplier;

    if (receiver < occluder.x)
    {
        return 1.0;
    }

    float variance = max(occluder.y - (occluder.x*occluder.x), _minVariance);
    float d = receiver - occluder.x;

    float visibility = variance / (variance + d*d);

    return visibility;
}

// ===== ESM (ESM_SHADOW_MAP) =====
// 对照 16-shadowmaps/common.sh: ESM

float ESM(sampler2D _sampler, vec4 _shadowCoord, float _bias, float _depthMultiplier)
{
    vec2 texCoord = _shadowCoord.xy/_shadowCoord.w;

    bool outside = any(greaterThan(texCoord, vec2_splat(1.0)))
                || any(lessThan   (texCoord, vec2_splat(0.0)))
                 ;

    if (outside)
    {
        return 1.0;
    }

    float receiver = (_shadowCoord.z-_bias)/_shadowCoord.w;
    float occluder = unpackRgbaToFloat(texture2D(_sampler, texCoord) );

    float visibility = clamp(exp(_depthMultiplier * (occluder-receiver) ), 0.0, 1.0);

    return visibility;
}

// ===== blur9: 9-tap Gaussian blur (VSM/ESM 共用) =====
// 对照 16-shadowmaps/common.sh: blur9/blur9VSM

vec4 blur9(sampler2D _sampler, vec2 _uv0, vec4 _uv1, vec4 _uv2, vec4 _uv3, vec4 _uv4)
{
#define _BLUR9_WEIGHT_0 1.0
#define _BLUR9_WEIGHT_1 0.9
#define _BLUR9_WEIGHT_2 0.55
#define _BLUR9_WEIGHT_3 0.18
#define _BLUR9_WEIGHT_4 0.1
#define _BLUR9_NORMALIZE (_BLUR9_WEIGHT_0+2.0*(_BLUR9_WEIGHT_1+_BLUR9_WEIGHT_2+_BLUR9_WEIGHT_3+_BLUR9_WEIGHT_4) )
#define BLUR9_WEIGHT(_x) (_BLUR9_WEIGHT_##_x/_BLUR9_NORMALIZE)

    float blur;
    blur  = unpackRgbaToFloat(texture2D(_sampler, _uv0)    * BLUR9_WEIGHT(0));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv1.xy) * BLUR9_WEIGHT(1));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv1.zw) * BLUR9_WEIGHT(1));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv2.xy) * BLUR9_WEIGHT(2));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv2.zw) * BLUR9_WEIGHT(2));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv3.xy) * BLUR9_WEIGHT(3));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv3.zw) * BLUR9_WEIGHT(3));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv4.xy) * BLUR9_WEIGHT(4));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv4.zw) * BLUR9_WEIGHT(4));
    return packFloatToRgba(blur);
}

vec4 blur9VSM(sampler2D _sampler, vec2 _uv0, vec4 _uv1, vec4 _uv2, vec4 _uv3, vec4 _uv4)
{
#define _BLUR9_WEIGHT_0 1.0
#define _BLUR9_WEIGHT_1 0.9
#define _BLUR9_WEIGHT_2 0.55
#define _BLUR9_WEIGHT_3 0.18
#define _BLUR9_WEIGHT_4 0.1
#define _BLUR9_NORMALIZE (_BLUR9_WEIGHT_0+2.0*(_BLUR9_WEIGHT_1+_BLUR9_WEIGHT_2+_BLUR9_WEIGHT_3+_BLUR9_WEIGHT_4) )
#define BLUR9_WEIGHT(_x) (_BLUR9_WEIGHT_##_x/_BLUR9_NORMALIZE)

    vec2 blur;
    vec4 val;
    val = texture2D(_sampler, _uv0) * BLUR9_WEIGHT(0);
    blur = vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv1.xy) * BLUR9_WEIGHT(1);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv1.zw) * BLUR9_WEIGHT(1);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv2.xy) * BLUR9_WEIGHT(2);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv2.zw) * BLUR9_WEIGHT(2);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv3.xy) * BLUR9_WEIGHT(3);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv3.zw) * BLUR9_WEIGHT(3);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv4.xy) * BLUR9_WEIGHT(4);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv4.zw) * BLUR9_WEIGHT(4);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));

    return vec4(packHalfFloat(blur.x), packHalfFloat(blur.y));
}

// ===== PCSS (PCSS_SHADOW_MAP): blocker search → penumbra → PCF =====
// 对照 16-shadowmaps/common.sh: findBlocker/PCSS
// BLOCKER_SEARCH_NUM_SAMPLES 由调用方 #define (16)

// Returns vec3(avgBlockerDepth, closestBlockerDepth, blockerRatio)
//   avgBlockerDepth:     mean depth of all blockers found (for general penumbra)
//   closestBlockerDepth: maximum depth among blockers (nearest to receiver, for contact hardening)
//   blockerRatio:        fraction of search samples that found a blocker [0..1]
// _diskRotation = vec2(sin(angle), cos(angle)) for per-pixel Poisson disk rotation
vec3 findBlocker(sampler2D _sampler, vec4 _shadowCoord, vec2 _searchSize, float _bias, vec2 _diskRotation)
{
    int blockerCount = 0;
    float avgBlockerDepth = 0.0;
    float closestBlockerDepth = 0.0;
    vec2 texCoord = _shadowCoord.xy / _shadowCoord.w;
    float receiverDepth = (_shadowCoord.z / _shadowCoord.w) - _bias;

    // Search around the shadow coordinate to find blockers
    for( int i = 0; i < BLOCKER_SEARCH_NUM_SAMPLES; ++i )
    {
        vec2 offset = rotateSample(samplePoisson(i), _diskRotation) * _searchSize;
        float shadowMapDepth = unpackRgbaToFloat(texture2D(_sampler, texCoord + offset));
        if (shadowMapDepth < receiverDepth)
        {
            avgBlockerDepth += shadowMapDepth;
            closestBlockerDepth = max(closestBlockerDepth, shadowMapDepth);
            blockerCount++;
        }
    }

    // Calculate average blocker depth
    if (blockerCount > 0)
    {
        avgBlockerDepth /= float(blockerCount);
    }
    else
    {
        avgBlockerDepth = -1.0; // No blockers found
    }

    float blockerRatio = float(blockerCount) / float(BLOCKER_SEARCH_NUM_SAMPLES);
    return vec3(avgBlockerDepth, closestBlockerDepth, blockerRatio);
}

float PCSS(sampler2D _sampler, vec4 _shadowCoord, float _bias, vec4 _pcssParams, vec2 _texelSize, vec2 fragCoord)
{
    // -----------------------------------------------------------------------
    // PCSS Parameters
    // -----------------------------------------------------------------------

    // Blocker search radius in UV space (~10 texels on 1024 map).
    float searchRadiusUV = 0.01;

    // Penumbra scale. Amplifies the squared depth ratio into a UV-space
    // filter radius. Higher = softer shadows at distance.
    float penumbraScaleX = _pcssParams.z;
    float penumbraScaleY = _pcssParams.w;

    // Maximum filter radius in UV space (~50 texels on 1024 map).
    float maxFilterRadius = 0.25;

    // -----------------------------------------------------------------------
    // Per-pixel Poisson disk rotation (Interleaved Gradient Noise)
    // -----------------------------------------------------------------------
    vec2 noiseCoord = fragCoord;
    //vec2 noiseCoord = (_shadowCoord.xy / _shadowCoord.w) * (1.0 / _texelSize.x);
    float noise = interleavedGradientNoise(noiseCoord);
    float rotationAngle = noise * 6.283185;
    vec2 diskRotation = vec2(sin(rotationAngle), cos(rotationAngle));

    // Receiver depth in normalized shadow map space
    float receiverDepth = (_shadowCoord.z / _shadowCoord.w) - _bias;

    // -----------------------------------------------------------------------
    // Step 1: Blocker Search
    // -----------------------------------------------------------------------
    vec3 blockerResult = findBlocker(_sampler, _shadowCoord, vec2(searchRadiusUV, searchRadiusUV), _bias, diskRotation);
    float avgBlockerDepth = blockerResult.x;
    float blockerRatio = blockerResult.z;

    if (avgBlockerDepth < -0.99)
    {
        return 1.0;
    }

    // -----------------------------------------------------------------------
    // Step 2: Penumbra Estimation (standard PCSS, Fernando 2005)
    //
    //   penumbraWidth = lightSize * (d_receiver - d_blocker) / d_blocker
    //
    // The depth gap at contact equals the object's thickness along the
    // light direction. For curved objects (spheres, characters), the gap
    // varies across the shadow giving the contact-hardening gradient.
    // For flat objects (cubes), the gap is constant → uniform penumbra.
    // -----------------------------------------------------------------------
    float penumbraWidth = penumbraScaleX * max(0.0, receiverDepth - avgBlockerDepth) / avgBlockerDepth;
    float penumbraHeight = penumbraScaleY * max(0.0, receiverDepth - avgBlockerDepth) / avgBlockerDepth;
    float filterRadiusU = clamp(penumbraWidth, 0.0, maxFilterRadius);
    float filterRadiusV = clamp(penumbraHeight, 0.0, maxFilterRadius);

    // -----------------------------------------------------------------------
    // Step 3: Percentage-Closer Filtering
    // -----------------------------------------------------------------------
    float visibility = PCFLodOffset(_sampler, 0.0, vec2(filterRadiusU, filterRadiusV), _shadowCoord, _bias, _texelSize, diskRotation);

    // -----------------------------------------------------------------------
    // Step 4: Edge fade based on blocker ratio
    // -----------------------------------------------------------------------
    float edgeFade = smoothstep(0.0, 0.25, blockerRatio);
    visibility = mix(1.0, visibility, edgeFade);

    return visibility;
}
"#
```
shadow_common GLSL fragment string

## const shadow\_hblur\_fragment
```cj
public const shadow_hblur_fragment: String = #"
// HBlur pass 片段着色器（水平 9-tap Gaussian）
// 对照 16-shadowmaps: fs_shadowmaps_hblur.sc / fs_shadowmaps_hblur_vsm.sc

$input v_texcoord0, v_texcoord1, v_texcoord2, v_texcoord3, v_texcoord4

#include <bgfx_shader.sh>

SAMPLER2D(s_shadowMap0, 4);

void main()
{
#if defined( SHADOWMAP_TYPE_VSM )
    // VSM 路径：blur9VSM 处理 depth + depth² 双通道
    gl_FragColor = blur9VSM(s_shadowMap0
                          , v_texcoord0
                          , v_texcoord1
                          , v_texcoord2
                          , v_texcoord3
                          , v_texcoord4
                          );
#else
    // RGBA 路径：blur9 处理单通道 depth
    gl_FragColor = blur9(s_shadowMap0
                       , v_texcoord0
                       , v_texcoord1
                       , v_texcoord2
                       , v_texcoord3
                       , v_texcoord4
                       );
#endif
}
"#
```
HBlur pass 片段着色器 chunk（水平 9-tap Gaussian）。

RGBA 路径：gl_FragColor = blur9(s_shadowMap0, ...)
VSM 路径：gl_FragColor = blur9VSM(s_shadowMap0, ...)

9 个采样点 UV 坐标由 vertex 端预计算，通过 varying 传入：
v_texcoord0（中心）+ v_texcoord1..4（8 个偏移）

## const shadow\_packdepth\_fragment
```cj
public const shadow_packdepth_fragment: String = #"
// PackDepth pass 片段着色器
// 对照 16-shadowmaps: fs_shadowmaps_packdepth*.sc
//
// 四种变体由编译期 #define 组合切换：
//   SHADOWMAP_TYPE_VSM × { SM_LINEAR, SM_INVZ }
//   SHADOWMAP_TYPE_RGBA × { SM_LINEAR, SM_INVZ }

$input v_position

#if defined( SM_LINEAR )
$input v_depth
#endif

#include <bgfx_shader.sh>

void main()
{
#if defined( SM_LINEAR )
    // Linear 模式：depth = v_depth（线性光空间距离）
    float depth = v_depth;
#else
    // InvZ 模式（默认）：depth = v_position.z / v_position.w * 0.5 + 0.5
    float depth = v_position.z / v_position.w * 0.5 + 0.5;
#endif

#if defined( SHADOWMAP_TYPE_VSM )
    // VSM 路径：打包 depth + depth²（2× half float）
    float depthSq = depth * depth;
    gl_FragColor = vec4(packHalfFloat(depth), packHalfFloat(depthSq));
#else
    // RGBA 路径：打包 depth 为 RGBA8
    gl_FragColor = packFloatToRgba(depth);
#endif
}
"#
```
PackDepth pass 片段着色器 chunk。

四种变体由编译期 #define 切换：
- SHADOWMAP_TYPE_VSM：打包为 depth + depth²（2× half float）
- SM_LINEAR：使用线性光空间距离而非透视 Z 倒数

RGBA 路径：gl_FragColor = packFloatToRgba(depth)
VSM 路径：gl_FragColor = vec4(packHalfFloat(depth), packHalfFloat(depth*depth))

## const shadow\_packdepth\_vertex
```cj
public const shadow_packdepth_vertex: String = #"
// PackDepth pass 顶点着色器
// 对照 16-shadowmaps: vs_shadowmaps_packdepth.sc / vs_shadowmaps_packdepth_linear.sc
//
// InvZ 模式：传递 v_position（NDC），fragment 端算 depth = z/w*0.5+0.5
// Linear 模式：额外传递 v_depth（线性光空间距离）
// 两种模式由编译期 #define SM_LINEAR 切换

$input a_position

#if defined( SM_LINEAR )
$output v_depth
uniform mat4 u_lightMtx;
#endif

$output v_position

#include <bgfx_shader.sh>

void main()
{
    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));

#if defined( SM_LINEAR )
    // Linear 模式：v_depth = 光空间线性距离（由 u_lightMtx 变换）
    v_depth = mul(u_lightMtx, vec4(a_position, 1.0)).z;
#endif

    v_position = gl_Position;
}
"#
```
PackDepth pass 顶点着色器 chunk。

InvZ 模式（默认）：depth = v_position.z / v_position.w * 0.5 + 0.5
Linear 模式：depth = v_depth（由 vertex 端预先计算的线性光空间距离）

顶点着色器仅负责传递 v_position（NDC）和 v_depth（线性深度），
打包逻辑在 fragment 端完成。

## const shadow\_unpackdepth\_fragment
```cj
public const shadow_unpackdepth_fragment: String = #"
// UnpackDepth pass 片段着色器（debug 用）
// 对照 16-shadowmaps: fs_shadowmaps_unpackdepth.sc / fs_shadowmaps_unpackdepth_vsm.sc

$input v_texcoord0

#include <bgfx_shader.sh>

SAMPLER2D(s_shadowMap0, 4);

uniform vec4 u_params2;
#define u_depthValuePow u_params2.x

void main()
{
#if defined( SHADOWMAP_TYPE_VSM )
    // VSM 路径：从 RG half float 解包 depth
    vec4 val = texture2D(s_shadowMap0, v_texcoord0);
    float depth = unpackHalfFloat(val.rg);
#else
    // RGBA 路径：从 RGBA8 解包 depth
    float depth = unpackRgbaToFloat(texture2D(s_shadowMap0, v_texcoord0));
#endif

    vec3 rgba = pow(vec3_splat(depth), vec3_splat(u_depthValuePow));
    gl_FragColor = vec4(rgba, 1.0);
}
"#
```
UnpackDepth pass 片段着色器 chunk（debug 用）。

RGBA 路径：depth = unpackRgbaToFloat(texture2D(s_shadowMap0, v_texcoord0))
VSM 路径：depth = unpackHalfFloat(texture2D(s_shadowMap0, v_texcoord0).rg)

可视化：gl_FragColor = vec4(pow(depth, u_depthValuePow))

## const shadow\_vblur\_fragment
```cj
public const shadow_vblur_fragment: String = #"
// VBlur pass 片段着色器（垂直 9-tap Gaussian）
// 对照 16-shadowmaps: fs_shadowmaps_vblur.sc / fs_shadowmaps_vblur_vsm.sc
//
// 实现与 HBlur 一致，区别仅在于 vertex 端 UV 偏移方向

$input v_texcoord0, v_texcoord1, v_texcoord2, v_texcoord3, v_texcoord4

#include <bgfx_shader.sh>

SAMPLER2D(s_shadowMap0, 4);

void main()
{
#if defined( SHADOWMAP_TYPE_VSM )
    gl_FragColor = blur9VSM(s_shadowMap0
                          , v_texcoord0
                          , v_texcoord1
                          , v_texcoord2
                          , v_texcoord3
                          , v_texcoord4
                          );
#else
    gl_FragColor = blur9(s_shadowMap0
                       , v_texcoord0
                       , v_texcoord1
                       , v_texcoord2
                       , v_texcoord3
                       , v_texcoord4
                       );
#endif
}
"#
```
VBlur pass 片段着色器 chunk（垂直 9-tap Gaussian）。

实现与 HBlur 完全一致（9-tap Gaussian），区别仅在于 vertex 端
UV 偏移方向（水平 vs 垂直）。

## const shadowmap\_fragment
```cj
public const shadowmap_fragment: String = #"
// shadowmap_fragment：占位 chunk
// 主光路的阴影乘法已由 lights_fragment_begin.cj 在各光源循环内完成：
//   directLight.color *= ... getShadow(...) ...
// 本 chunk 仅保留为 ShaderLib 拼接接口的占位符。
// getShadowMask()（见 shadowmask_pars_fragment.cj）专供 MeshShadowMaterial 等仅显示阴影的材质使用。
"#
```
shadowmap_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const shadowmap\_pars\_fragment
```cj
public const shadowmap_pars_fragment: String = #"
#if NUM_SPOT_LIGHT_MAPS > 0

	uniform sampler2D spotLightMap[ NUM_SPOT_LIGHT_MAPS ];

#endif

#ifdef USE_SHADOWMAP

	#if NUM_DIR_LIGHT_SHADOWS > 0

		// bgfx4cj: 数组化方向光阴影 sampler（对齐 Three.js directionalShadowMap[NUM_DIR_LIGHT_SHADOWS]）
		// bgfx 数组 sampler 通过 setTexture(stage+i, uniform, tex) 逐个绑定连续寄存器
		// ★类型按 SHADOWMAP_TYPE 区分（对照参考版 SAMPLER2DSHADOW/SAMPLER2D 分支）：
		//   - PCF：sampler2DShadow（shadow2D 硬件比较采样）
		//   - VSM/BASIC：sampler2D（texture2D 普通采样读 .rg mean/variance / .r 深度）
		// 类型不匹配会导致 VSM 变体 texture2D 采样比较采样器 → 采样结果错误 → 波浪纹/噪点
		#if defined( SHADOWMAP_TYPE_PCF )
		uniform sampler2DShadow directionalShadowMap[ NUM_DIR_LIGHT_SHADOWS ];
		#else
		uniform sampler2D directionalShadowMap[ NUM_DIR_LIGHT_SHADOWS ];
		#endif

	#endif

 // bgfx4cj: shadowParams/shadowMapSize 全局参数，所有阴影类型（方向光/点光源/聚光）共用，
 // 声明在所有 #if NUM_XXX_LIGHT_SHADOWS 之外，确保任何类型启用阴影时均可访问。
 uniform vec4 shadowParams;   // x=intensity, y=bias(保留备用), z=normalBias(保留备用), w=radius
 uniform vec4 shadowMapSize;  // x=width, y=height
 // per-light 独立 bias/normalBias（对齐 three.js：每个 light.shadow.bias/normalBias 独立）：
 // 方向光/聚光阴影沿投影深度方向偏移，过大 bias 导致盒子内壁棱线处阴影错位（接缝缝隙），
 // 抗 acne 主要靠 normalBias（沿世界法线偏移 shadowWorldPosition，棱线处连续，不产生接缝）；
 // 点光源自阴影（acne）在 fragment 端 dp += bias，需要更大负 bias。
 // 类型必须为 vec4：bgfx UniformType 无 Float 类型，C++ 端按 Vec4 绑定（x/y 分量生效）。
 #if NUM_DIR_LIGHT_SHADOWS > 0
 uniform vec4 u_dirShadowParams[ NUM_DIR_LIGHT_SHADOWS ];    // x=bias, y=normalBias（方向光）
 #endif
 #if NUM_SPOT_LIGHT_SHADOWS > 0
 uniform vec4 u_spotShadowParams[ NUM_SPOT_LIGHT_SHADOWS ];  // x=bias, y=normalBias（聚光）
 #endif
 #if NUM_POINT_LIGHT_SHADOWS > 0
 uniform vec4 u_pointShadowParams[ NUM_POINT_LIGHT_SHADOWS ]; // x=bias（点光源）
 #endif

	#if NUM_SPOT_LIGHT_SHADOWS > 0

		// bgfx4cj: 数组化聚光灯阴影 sampler（对齐 Three.js spotShadowMap[NUM_SPOT_LIGHT_SHADOWS]）
		uniform sampler2DShadow spotShadowMap[ NUM_SPOT_LIGHT_SHADOWS ];

		// bgfx4cj: spot 阴影暂用 shadowParams/shadowMapSize 全局参数

	#endif

	#if NUM_POINT_LIGHT_SHADOWS > 0

	 // bgfx4cj: 数组化点光源阴影 cube sampler（对齐 Three.js pointShadowMap[NUM_POINT_LIGHT_SHADOWS]）
	 uniform samplerCubeShadow pointShadowMap[ NUM_POINT_LIGHT_SHADOWS ];

		// bgfx4cj: point 阴影采样的光源世界坐标数组（fragment 端算 worldPos - lightPos[i] 用）
		// 声明在 fragment 段，因 getPointShadow 调用在 fragment 段，uniform 跨段不可见
		uniform vec4 u_pointShadowLightPos[ NUM_POINT_LIGHT_SHADOWS ];
		// bgfx4cj: point 阴影相机的 near/far 数组（bgfx 无 Vec2 uniform，用 Vec4 打包，xy=near/far）
		uniform vec4 u_pointShadowNearFar[ NUM_POINT_LIGHT_SHADOWS ];

		// bgfx4cj: point 阴影暂用 shadowParams/shadowMapSize 全局参数

	#endif

	#if defined( SHADOWMAP_TYPE_PCF )

		// Interleaved Gradient Noise for randomizing sampling patterns
		float interleavedGradientNoise( vec2 position ) {

			return fract( 52.9829189 * fract( dot( position, vec2( 0.06711056, 0.00583715 ) ) ) );

		}

		// Vogel disk sampling for uniform circular distribution
		vec2 vogelDiskSample( int sampleIndex, int samplesCount, float phi ) {

			const float goldenAngle = 2.399963229728653;
			float r = sqrt( ( float( sampleIndex ) + 0.5 ) / float( samplesCount ) );
			float theta = float( sampleIndex ) * goldenAngle + phi;
			return vec2( cos( theta ), sin( theta ) ) * r;

		}

	#endif

	#if defined( SHADOWMAP_TYPE_PCF )

		float getShadow( sampler2DShadow shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {

			float shadow = 1.0;

			shadowCoord.xyz /= shadowCoord.w;
			shadowCoord.z += shadowBias;

			bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
			bool frustumTest = inFrustum && shadowCoord.z <= 1.0;

			if ( frustumTest ) {

				// Hardware PCF with LinearFilter gives us 4-tap filtering per sample
				// 5 samples using Vogel disk + IGN = effectively 20 filtered taps with better distribution
				vec2 texelSize = vec2( 1.0,1.0 ) / shadowMapSize;
				float radius = shadowRadius * texelSize.x;

				// Use IGN to rotate sampling pattern per pixel.
				// bgfx4cj: 用 shadowCoord.xy 替代 gl_FragCoord.xy（bgfx HLSL 路径未声明 gl_FragCoord），
				// 二者均为 per-pixel 唯一的 vec2 种子，对 IGN 旋转效果等价。
				float phi = interleavedGradientNoise( shadowCoord.xy ) * PI2;

				shadow = (
					shadow2D( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 0, 5, phi ) * radius, shadowCoord.z ) ) +
					shadow2D( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 1, 5, phi ) * radius, shadowCoord.z ) ) +
					shadow2D( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 2, 5, phi ) * radius, shadowCoord.z ) ) +
					shadow2D( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 3, 5, phi ) * radius, shadowCoord.z ) ) +
					shadow2D( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 4, 5, phi ) * radius, shadowCoord.z ) )
				) * 0.2;

			}

			return mix( 1.0, shadow, shadowIntensity );

		}

	#elif defined( SHADOWMAP_TYPE_VSM )

		float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {

			float shadow = 1.0;

			shadowCoord.xyz /= shadowCoord.w;

			#ifdef USE_REVERSED_DEPTH_BUFFER

				shadowCoord.z -= shadowBias;

			#else

				shadowCoord.z += shadowBias;

			#endif

			bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
			bool frustumTest = inFrustum && shadowCoord.z <= 1.0;

			if ( frustumTest ) {

				vec2 distribution = texture2D( shadowMap, shadowCoord.xy ).rg;

				float mean = distribution.x;
				float variance = distribution.y * distribution.y;

				#ifdef USE_REVERSED_DEPTH_BUFFER

					float hard_shadow = step( mean, shadowCoord.z );

				#else

					float hard_shadow = step( shadowCoord.z, mean );

				#endif
				
				// Early return if fully lit
				if ( hard_shadow == 1.0 ) {

					shadow = 1.0;

				} else {

					// Variance must be non-zero to avoid division by zero
					variance = max( variance, 0.0000001 );

					// Distance from mean
					float d = shadowCoord.z - mean;

					// Chebyshev's inequality for upper bound on probability
					float p_max = variance / ( variance + d * d );

					// Reduce light bleeding by remapping [amount, 1] to [0, 1]
					p_max = clamp( ( p_max - 0.3 ) / 0.65, 0.0, 1.0 );

					shadow = max( hard_shadow, p_max );

				}

			}

			return mix( 1.0, shadow, shadowIntensity );

		}

	#else // SHADOWMAP_TYPE_BASIC

		float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {

			float shadow = 1.0;

			shadowCoord.xyz /= shadowCoord.w;

			#ifdef USE_REVERSED_DEPTH_BUFFER

				shadowCoord.z -= shadowBias;

			#else

				shadowCoord.z += shadowBias;

			#endif

			bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
			bool frustumTest = inFrustum && shadowCoord.z <= 1.0;

			if ( frustumTest ) {

				float depth = texture2D( shadowMap, shadowCoord.xy ).r;

				#ifdef USE_REVERSED_DEPTH_BUFFER

					shadow = step( depth, shadowCoord.z );

				#else

					shadow = step( shadowCoord.z, depth );

				#endif

			}

			return mix( 1.0, shadow, shadowIntensity );

		}

	#endif

	#if NUM_POINT_LIGHT_SHADOWS > 0

	 #if defined( SHADOWMAP_TYPE_PCF )


	 // bgfx4cj: 使用 shadowCube 硬件比较（shadowCoord.w=dp, shadowCube 内部 SampleCmpLevelZero）
	 // 配合 SAMPLERCUBESHADOW + SAMPLER_COMPARE_LEQUAL flags

	float getPointShadow( samplerCubeShadow shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {

		float shadow = 1.0;

		vec3 lightToPosition = shadowCoord.xyz;
		vec3 bd3D = normalize( lightToPosition );
		vec3 absVec = abs( lightToPosition );
		float viewSpaceZ = max( max( absVec.x, absVec.y ), absVec.z );

		if ( viewSpaceZ - shadowCameraFar <= 0.0 && viewSpaceZ - shadowCameraNear >= 0.0 ) {

			float dp = ( shadowCameraFar * ( viewSpaceZ - shadowCameraNear ) ) / ( viewSpaceZ * ( shadowCameraFar - shadowCameraNear ) );
			dp += shadowBias;

			// bgfx4cj: 用 shadowCube 硬件比较替代手动 textureCube().r + step()
			shadow = shadowCube( shadowMap, vec4( bd3D, dp ) );

		}

		return mix( 1.0, shadow, shadowIntensity );

	}

	#elif defined( SHADOWMAP_TYPE_BASIC )

	float getPointShadow( samplerCubeShadow shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {

		float shadow = 1.0;

		// for point lights, the uniform @vShadowCoord is re-purposed to hold
		// the vector from the light to the world-space position of the fragment.
		vec3 lightToPosition = shadowCoord.xyz;

		// For cube shadow maps, depth is stored as distance along each face's view axis, not radial distance
		// The view-space depth is the maximum component of the direction vector (which face is sampled)
		vec3 absVec = abs( lightToPosition );
		float viewSpaceZ = max( max( absVec.x, absVec.y ), absVec.z );

		if ( viewSpaceZ - shadowCameraFar <= 0.0 && viewSpaceZ - shadowCameraNear >= 0.0 ) {

			// viewZ to perspective depth

			float dp = ( shadowCameraFar * ( viewSpaceZ - shadowCameraNear ) ) / ( viewSpaceZ * ( shadowCameraFar - shadowCameraNear ) );
			dp += shadowBias;

			// Direction from light to fragment
			vec3 bd3D = normalize( lightToPosition );

			// bgfx4cj: BASIC 模式同样使用 shadowCube 硬件比较
			shadow = shadowCube( shadowMap, vec4( bd3D, dp ) );

		}

		return mix( 1.0, shadow, shadowIntensity );

	}

	#endif

	#endif

#endif
"#
```
shadowmap_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const shadowmap\_pars\_vertex
```cj
public const shadowmap_pars_vertex: String = #"

#if NUM_SPOT_LIGHT_COORDS > 0

	// bgfx4cj: spot 阴影矩阵数组化（对齐 Three.js mat4 spotLightMatrix[NUM_SPOT_LIGHT_COORDS]），
	// 每个带阴影的 spot 光源一份 bias × lightViewProj。
	// varying vSpotLightCoord[] 由 ShaderLibs.cj 头部 $output/$input 声明（bgfx 不支持 chunk 内 varying 关键字）
	uniform mat4 spotLightMatrix[ NUM_SPOT_LIGHT_COORDS ];

#endif

#ifdef USE_SHADOWMAP

	#if NUM_DIR_LIGHT_SHADOWS > 0

	  // bgfx4cj: 数组化 directionalShadowMatrix[NUM_DIR_LIGHT_SHADOWS]
	  // varying vDirectionalShadowCoord[] 由 ShaderLibs.cj 头部 $output/$input 声明
	  uniform mat4 directionalShadowMatrix[ NUM_DIR_LIGHT_SHADOWS ];

	#endif

	// bgfx4cj: shadowParams 全局参数，所有阴影类型共用（同 shadowmap_pars_fragment.cj 的处理）
	uniform vec4 shadowParams;  // x=intensity, y=bias, z=normalBias, w=radius

	#if NUM_DIR_LIGHT_SHADOWS > 0

	  // per-light bias/normalBias（vertex 端法线偏移 shadowWorldPosition 用，同 fragment 段声明）
	  uniform vec4 u_dirShadowParams[ NUM_DIR_LIGHT_SHADOWS ];  // x=bias, y=normalBias

	#endif

	#if NUM_SPOT_LIGHT_SHADOWS > 0

	  // per-light bias/normalBias（聚光 vertex 法线偏移用）
	  uniform vec4 u_spotShadowParams[ NUM_SPOT_LIGHT_SHADOWS ];  // x=bias, y=normalBias

	#endif

	#if NUM_SPOT_LIGHT_SHADOWS > 0

		// bgfx4cj: spot 阴影矩阵声明在 NUM_SPOT_LIGHT_COORDS > 0 域（见上方），此处保留占位以对齐 three.js 原结构

	#endif



	/*
	#if NUM_RECT_AREA_LIGHTS > 0

		// TODO (abelnation): uniforms for area light shadows
		// Ignore: JS 原文 TODO（area light shadows），属 three.js 上游未实现项。

	#endif
	*/

#endif
"#
```
shadowmap_pars_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const shadowmap\_vertex
```cj
public const shadowmap_vertex: String = #"

#if ( defined( USE_SHADOWMAP ) && ( NUM_DIR_LIGHT_SHADOWS > 0 || NUM_POINT_LIGHT_SHADOWS > 0 ) ) || ( NUM_SPOT_LIGHT_COORDS > 0 )

	#ifdef HAS_NORMAL

		// Offsetting the position used for querying occlusion along the world normal can be used to reduce shadow acne.

		vec3 shadowWorldNormal = transformNormalByInverseViewMatrix( transformedNormal, viewMatrix );

	#else

		vec3 shadowWorldNormal = vec3(0.0, 0.0, 0.0); // fallback, see #21483

	#endif

	vec4 shadowWorldPosition;

#endif

#if defined( USE_SHADOWMAP )

  #if NUM_DIR_LIGHT_SHADOWS > 0

   // bgfx4cj: 方向光阴影坐标（varying 单实例，用 directionalShadowMatrix 数组的第 0 个矩阵）。
   // normalBias 用 per-light 数组 u_dirShadowParams[0].y（对齐 three.js：每光源独立 shadowNormalBias）。
   // 法线偏移沿世界法线方向，棱线处相邻面自然连续，不产生接缝缝隙（depth bias 才造成接缝）。
   shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * u_dirShadowParams[0].y, 0 );
   vDirectionalShadowCoord = mul(directionalShadowMatrix[0], shadowWorldPosition);

  #endif

	/*
	#if NUM_RECT_AREA_LIGHTS > 0

		// TODO (abelnation): update vAreaShadowCoord with area light info
		// Ignore: JS 原文 TODO（area light shadow coord），属 three.js 上游未实现项。

	#endif
	*/

#endif

// spot lights can be evaluated without active shadow mapping (when SpotLight.map is used)

#if NUM_SPOT_LIGHT_COORDS > 0

 // bgfx4cj: spot 阴影坐标（varying 单实例，用 spotLightMatrix 数组的第 0 个矩阵）。
 shadowWorldPosition = worldPosition;
 #if defined( USE_SHADOWMAP )
  shadowWorldPosition.xyz += shadowWorldNormal * u_spotShadowParams[0].y;
 #endif
 vSpotLightCoord = mul ( spotLightMatrix[0] , shadowWorldPosition );

#endif
"#
```
shadowmap_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const shadowmask\_pars\_fragment
```cj
public const shadowmask_pars_fragment: String = #"
float getShadowMask() {

	float shadow = 1.0;

	#ifdef USE_SHADOWMAP

	#if NUM_DIR_LIGHT_SHADOWS > 0

	// bgfx4cj: 数组化方向光阴影，按光源下标逐个累乘。
	#if NUM_DIR_LIGHT_SHADOWS >= 1
	shadow *= receiveShadow.x > 0.5 ? getShadow( directionalShadowMap[0], shadowMapSize.xy, shadowParams.x, u_dirShadowParams[0].x, shadowParams.w, vDirectionalShadowCoord ) : 1.0;
	#endif
	#if NUM_DIR_LIGHT_SHADOWS >= 2
	shadow *= receiveShadow.x > 0.5 ? getShadow( directionalShadowMap[1], shadowMapSize.xy, shadowParams.x, u_dirShadowParams[1].x, shadowParams.w, vDirectionalShadowCoord ) : 1.0;
	#endif
	#if NUM_DIR_LIGHT_SHADOWS >= 3
	shadow *= receiveShadow.x > 0.5 ? getShadow( directionalShadowMap[2], shadowMapSize.xy, shadowParams.x, u_dirShadowParams[2].x, shadowParams.w, vDirectionalShadowCoord ) : 1.0;
	#endif
	#if NUM_DIR_LIGHT_SHADOWS >= 4
	shadow *= receiveShadow.x > 0.5 ? getShadow( directionalShadowMap[3], shadowMapSize.xy, shadowParams.x, u_dirShadowParams[3].x, shadowParams.w, vDirectionalShadowCoord ) : 1.0;
	#endif

	#endif

	#if NUM_SPOT_LIGHT_SHADOWS > 0

	// bgfx4cj: 数组化聚光灯阴影，按光源下标逐个累乘。
	#if NUM_SPOT_LIGHT_SHADOWS >= 1
	shadow *= receiveShadow.x > 0.5 ? getShadow( spotShadowMap[0], shadowMapSize.xy, shadowParams.x, u_spotShadowParams[0].x, shadowParams.w, vSpotLightCoord ) : 1.0;
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS >= 2
	shadow *= receiveShadow.x > 0.5 ? getShadow( spotShadowMap[1], shadowMapSize.xy, shadowParams.x, u_spotShadowParams[1].x, shadowParams.w, vSpotLightCoord ) : 1.0;
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS >= 3
	shadow *= receiveShadow.x > 0.5 ? getShadow( spotShadowMap[2], shadowMapSize.xy, shadowParams.x, u_spotShadowParams[2].x, shadowParams.w, vSpotLightCoord ) : 1.0;
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS >= 4
	shadow *= receiveShadow.x > 0.5 ? getShadow( spotShadowMap[3], shadowMapSize.xy, shadowParams.x, u_spotShadowParams[3].x, shadowParams.w, vSpotLightCoord ) : 1.0;
	#endif

	#endif

	#if NUM_POINT_LIGHT_SHADOWS > 0 && ( defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_BASIC ) )

	// bgfx4cj: 数组化点光源 cube 阴影，按光源下标逐个累乘。
	#if NUM_POINT_LIGHT_SHADOWS >= 1
	shadow *= receiveShadow.x > 0.5 ? getPointShadow( pointShadowMap[0], shadowMapSize.xy, shadowParams.x, u_pointShadowParams[0].x, shadowParams.w, vec4( v_worldPos - u_pointShadowLightPos[0].xyz, 1.0 ), u_pointShadowNearFar[0].x, u_pointShadowNearFar[0].y ) : 1.0;
	#endif
	#if NUM_POINT_LIGHT_SHADOWS >= 2
	shadow *= receiveShadow.x > 0.5 ? getPointShadow( pointShadowMap[1], shadowMapSize.xy, shadowParams.x, u_pointShadowParams[1].x, shadowParams.w, vec4( v_worldPos - u_pointShadowLightPos[1].xyz, 1.0 ), u_pointShadowNearFar[1].x, u_pointShadowNearFar[1].y ) : 1.0;
	#endif
	#if NUM_POINT_LIGHT_SHADOWS >= 3
	shadow *= receiveShadow.x > 0.5 ? getPointShadow( pointShadowMap[2], shadowMapSize.xy, shadowParams.x, u_pointShadowParams[2].x, shadowParams.w, vec4( v_worldPos - u_pointShadowLightPos[2].xyz, 1.0 ), u_pointShadowNearFar[2].x, u_pointShadowNearFar[2].y ) : 1.0;
	#endif

	#endif

	/*
	#if NUM_RECT_AREA_LIGHTS > 0

		// TODO (abelnation): update shadow for Area light
		// Ignore: JS 原文 TODO（area light shadow），属 three.js 上游未实现项。

	#endif
	*/

	#endif

	return shadow;

}
"#
```
shadowmask_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const skinbase\_vertex
```cj
public const skinbase_vertex: String = #"
#ifdef USE_SKINNING

	mat4 boneMatX = getBoneMatrix( skinIndex.x );
	mat4 boneMatY = getBoneMatrix( skinIndex.y );
	mat4 boneMatZ = getBoneMatrix( skinIndex.z );
	mat4 boneMatW = getBoneMatrix( skinIndex.w );

#endif
"#
```
skinbase_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const skinning\_pars\_vertex
```cj
public const skinning_pars_vertex: String = #"
#ifdef USE_SKINNING

	uniform mat4 bindMatrix;
	uniform mat4 bindMatrixInverse;

	uniform highp sampler2D boneTexture;

	mat4 getBoneMatrix( const in float i ) {

		int size = textureSize( boneTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( boneTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( boneTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( boneTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( boneTexture, ivec2( x + 3, y ), 0 );

		return mat4( v1, v2, v3, v4 );

	}

#endif
"#
```
skinning_pars_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const skinning\_vertex
```cj
public const skinning_vertex: String = #"
#ifdef USE_SKINNING

	vec4 skinVertex = bindMatrix * vec4( transformed, 1.0 );

	vec4 skinned = vec4( 0.0 );
	skinned += boneMatX * skinVertex * skinWeight.x;
	skinned += boneMatY * skinVertex * skinWeight.y;
	skinned += boneMatZ * skinVertex * skinWeight.z;
	skinned += boneMatW * skinVertex * skinWeight.w;

	transformed = ( bindMatrixInverse * skinned ).xyz;

#endif
"#
```
skinning_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const skinnormal\_vertex
```cj
public const skinnormal_vertex: String = #"
#ifdef USE_SKINNING

	mat4 skinMatrix = mat4( 0.0 );
	skinMatrix += skinWeight.x * boneMatX;
	skinMatrix += skinWeight.y * boneMatY;
	skinMatrix += skinWeight.z * boneMatZ;
	skinMatrix += skinWeight.w * boneMatW;
	skinMatrix = bindMatrixInverse * skinMatrix * bindMatrix;

	objectNormal = vec4( skinMatrix * vec4( objectNormal, 0.0 ) ).xyz;

	#ifdef USE_TANGENT

		objectTangent = vec4( skinMatrix * vec4( objectTangent, 0.0 ) ).xyz;

	#endif

#endif
"#
```
skinnormal_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const specularmap\_fragment
```cj
public const specularmap_fragment: String = #"
float specularStrength;

#ifdef USE_SPECULARMAP

	vec4 texelSpecular = texture2D( specularMap, vSpecularMapUv );
	specularStrength = texelSpecular.r;

#else

	specularStrength = 1.0;

#endif
"#
```
specularmap_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const specularmap\_pars\_fragment
```cj
public const specularmap_pars_fragment: String = #"
#ifdef USE_SPECULARMAP

	uniform sampler2D specularMap;

#endif
"#
```
specularmap_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const tonemapping\_fragment
```cj
public const tonemapping_fragment: String = #"
#if defined( TONE_MAPPING )

	gl_FragColor.rgb = toneMapping( gl_FragColor.rgb );

#endif
"#
```
tonemapping_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const tonemapping\_pars\_fragment
```cj
public const tonemapping_pars_fragment: String = #"
#ifndef saturate
// <common> may have defined saturate() already
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif

uniform float toneMappingExposure;

// exposure only
vec3 LinearToneMapping( vec3 color ) {

	return saturate( toneMappingExposure * color );

}

// source: https://www.cs.utah.edu/docs/techreports/2002/pdf/UUCS-02-001.pdf
vec3 ReinhardToneMapping( vec3 color ) {

	color *= toneMappingExposure;
	return saturate( color / ( vec3( 1.0, 1.0, 1.0 ) + color ) );

}

// source: http://filmicworlds.com/blog/filmic-tonemapping-operators/
vec3 CineonToneMapping( vec3 color ) {

	// filmic operator by Jim Hejl and Richard Burgess-Dawson
	color *= toneMappingExposure;
	color = max( vec3(0.0, 0.0, 0.0), color - 0.004 );
	return pow( ( color * ( 6.2 * color + 0.5 ) ) / ( color * ( 6.2 * color + 1.7 ) + 0.06 ), vec3( 2.2, 2.2, 2.2 ) );

}

// source: https://github.com/selfshadow/ltc_code/blob/master/webgl/shaders/ltc/ltc_blit.fs
vec3 RRTAndODTFit( vec3 v ) {

	vec3 a = v * ( v + 0.0245786 ) - 0.000090537;
	vec3 b = v * ( 0.983729 * v + 0.4329510 ) + 0.238081;
	return a / b;

}

// this implementation of ACES is modified to accommodate a brighter viewing environment.
// the scale factor of 1/0.6 is subjective. see discussion in #19621.

vec3 ACESFilmicToneMapping( vec3 color ) {

	// sRGB => XYZ => D65_2_D60 => AP1 => RRT_SAT
	const mat3 ACESInputMat = mat3(
		vec3( 0.59719, 0.07600, 0.02840 ), // transposed from source
		vec3( 0.35458, 0.90834, 0.13383 ),
		vec3( 0.04823, 0.01566, 0.83777 )
	);

	// ODT_SAT => XYZ => D60_2_D65 => sRGB
	const mat3 ACESOutputMat = mat3(
		vec3(  1.60475, -0.10208, -0.00327 ), // transposed from source
		vec3( -0.53108,  1.10813, -0.07276 ),
		vec3( -0.07367, -0.00605,  1.07602 )
	);

	color *= toneMappingExposure / 0.6;

	color = ACESInputMat * color;

	// Apply RRT and ODT
	color = RRTAndODTFit( color );

	color = ACESOutputMat * color;

	// Clamp to [0, 1]
	return saturate( color );

}

// Matrices for rec 2020 <> rec 709 color space conversion
// matrix provided in row-major order so it has been transposed
// https://www.itu.int/pub/R-REP-BT.2407-2017
const mat3 LINEAR_REC2020_TO_LINEAR_SRGB = mat3(
	vec3( 1.6605, - 0.1246, - 0.0182 ),
	vec3( - 0.5876, 1.1329, - 0.1006 ),
	vec3( - 0.0728, - 0.0083, 1.1187 )
);

const mat3 LINEAR_SRGB_TO_LINEAR_REC2020 = mat3(
	vec3( 0.6274, 0.0691, 0.0164 ),
	vec3( 0.3293, 0.9195, 0.0880 ),
	vec3( 0.0433, 0.0113, 0.8956 )
);

// https://iolite-engine.com/blog_posts/minimal_agx_implementation
// Mean error^2: 3.6705141e-06
vec3 agxDefaultContrastApprox( vec3 x ) {

	vec3 x2 = x * x;
	vec3 x4 = x2 * x2;

	return + 15.5 * x4 * x2
		- 40.14 * x4 * x
		+ 31.96 * x4
		- 6.868 * x2 * x
		+ 0.4298 * x2
		+ 0.1191 * x
		- 0.00232;

}

// AgX Tone Mapping implementation based on Filament, which in turn is based
// on Blender's implementation using rec 2020 primaries
// https://github.com/google/filament/pull/7236
// Inputs and outputs are encoded as Linear-sRGB.

vec3 AgXToneMapping( vec3 color ) {

	// AgX constants
	const mat3 AgXInsetMatrix = mat3(
		vec3( 0.856627153315983, 0.137318972929847, 0.11189821299995 ),
		vec3( 0.0951212405381588, 0.761241990602591, 0.0767994186031903 ),
		vec3( 0.0482516061458583, 0.101439036467562, 0.811302368396859 )
	);

	// explicit AgXOutsetMatrix generated from Filaments AgXOutsetMatrixInv
	const mat3 AgXOutsetMatrix = mat3(
		vec3( 1.1271005818144368, - 0.1413297634984383, - 0.14132976349843826 ),
		vec3( - 0.11060664309660323, 1.157823702216272, - 0.11060664309660294 ),
		vec3( - 0.016493938717834573, - 0.016493938717834257, 1.2519364065950405 )
	);

	// LOG2_MIN      = -10.0
	// LOG2_MAX      =  +6.5
	// MIDDLE_GRAY   =  0.18
	const float AgxMinEv = - 12.47393;  // log2( pow( 2, LOG2_MIN ) * MIDDLE_GRAY )
	const float AgxMaxEv = 4.026069;    // log2( pow( 2, LOG2_MAX ) * MIDDLE_GRAY )

	color *= toneMappingExposure;

	color = LINEAR_SRGB_TO_LINEAR_REC2020 * color;

	color = AgXInsetMatrix * color;

	// Log2 encoding
	color = max( color, 1e-10 ); // avoid 0 or negative numbers for log2
	color = log2( color );
	color = ( color - AgxMinEv ) / ( AgxMaxEv - AgxMinEv );

	color = clamp( color, 0.0, 1.0 );

	// Apply sigmoid
	color = agxDefaultContrastApprox( color );

	// Apply AgX look
	// v = agxLook(v, look);

	color = AgXOutsetMatrix * color;

	// Linearize
	color = pow( max( vec3(0.0, 0.0, 0.0), color ), vec3( 2.2, 2.2, 2.2 ) );

	color = LINEAR_REC2020_TO_LINEAR_SRGB * color;

	// Gamut mapping. Simple clamp for now.
	color = clamp( color, 0.0, 1.0 );

	return color;

}

// https://modelviewer.dev/examples/tone-mapping

vec3 NeutralToneMapping( vec3 color ) {

	const float StartCompression = 0.8 - 0.04;
	const float Desaturation = 0.15;

	color *= toneMappingExposure;

	float x = min( color.r, min( color.g, color.b ) );

	float offset = x < 0.08 ? x - 6.25 * x * x : 0.04;

	color -= offset;

	float peak = max( color.r, max( color.g, color.b ) );

	if ( peak < StartCompression ) return color;

	float d = 1. - StartCompression;

	float newPeak = 1. - d * d / ( peak + d - StartCompression );

	color *= newPeak / peak;

	float g = 1. - 1. / ( Desaturation * ( peak - newPeak ) + 1. );

	return mix( color, vec3( newPeak, newPeak, newPeak ), g );

}

vec3 CustomToneMapping( vec3 color ) { return color; }
"#
```
tonemapping_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const transmission\_fragment
```cj
public const transmission_fragment: String = #"
#ifdef USE_TRANSMISSION

	material.transmission = transmission;
	material.transmissionAlpha = 1.0;
	material.thickness = thickness;
	material.attenuationDistance = attenuationDistance;
	material.attenuationColor = attenuationColor;

	#ifdef USE_TRANSMISSIONMAP

		material.transmission *= texture2D( transmissionMap, vTransmissionMapUv ).r;

	#endif

	#ifdef USE_THICKNESSMAP

		material.thickness *= texture2D( thicknessMap, vThicknessMapUv ).g;

	#endif

	vec3 pos = vWorldPosition;
	vec3 v = normalize( cameraPosition - pos );
	vec3 n = transformNormalByInverseViewMatrix( normal, viewMatrix );

	vec4 transmitted = getIBLVolumeRefraction(
		n, v, material.roughness, material.diffuseContribution, material.specularColorBlended, material.specularF90,
		pos, modelMatrix, viewMatrix, projectionMatrix, material.dispersion, material.ior, material.thickness,
		material.attenuationColor, material.attenuationDistance );

	material.transmissionAlpha = mix( material.transmissionAlpha, transmitted.a, material.transmission );

	totalDiffuse = mix( totalDiffuse, transmitted.rgb, material.transmission );

#endif
"#
```
transmission_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const transmission\_pars\_fragment
```cj
public const transmission_pars_fragment: String = #"
#ifdef USE_TRANSMISSION

	// Transmission code is based on glTF-Sampler-Viewer
	// https://github.com/KhronosGroup/glTF-Sample-Viewer

	uniform float transmission;
	uniform float thickness;
	uniform float attenuationDistance;
	uniform vec3 attenuationColor;

	#ifdef USE_TRANSMISSIONMAP

		uniform sampler2D transmissionMap;

	#endif

	#ifdef USE_THICKNESSMAP

		uniform sampler2D thicknessMap;

	#endif

	uniform vec2 transmissionSamplerSize;
	uniform sampler2D transmissionSamplerMap;

	uniform mat4 modelMatrix;
	uniform mat4 projectionMatrix;

	// Mipped Bicubic Texture Filtering by N8
	// https://www.shadertoy.com/view/Dl2SDW

	float w0( float a ) {

		return ( 1.0 / 6.0 ) * ( a * ( a * ( - a + 3.0 ) - 3.0 ) + 1.0 );

	}

	float w1( float a ) {

		return ( 1.0 / 6.0 ) * ( a *  a * ( 3.0 * a - 6.0 ) + 4.0 );

	}

	float w2( float a ){

		return ( 1.0 / 6.0 ) * ( a * ( a * ( - 3.0 * a + 3.0 ) + 3.0 ) + 1.0 );

	}

	float w3( float a ) {

		return ( 1.0 / 6.0 ) * ( a * a * a );

	}

	// g0 and g1 are the two amplitude functions
	float g0( float a ) {

		return w0( a ) + w1( a );

	}

	float g1( float a ) {

		return w2( a ) + w3( a );

	}

	// h0 and h1 are the two offset functions
	float h0( float a ) {

		return - 1.0 + w1( a ) / ( w0( a ) + w1( a ) );

	}

	float h1( float a ) {

		return 1.0 + w3( a ) / ( w2( a ) + w3( a ) );

	}

	vec4 bicubic( sampler2D tex, vec2 uv, vec4 texelSize, float lod ) {

		uv = uv * texelSize.zw + 0.5;

		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );

		float g0x = g0( fuv.x );
		float g1x = g1( fuv.x );
		float h0x = h0( fuv.x );
		float h1x = h1( fuv.x );
		float h0y = h0( fuv.y );
		float h1y = h1( fuv.y );

		vec2 p0 = ( vec2( iuv.x + h0x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p1 = ( vec2( iuv.x + h1x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p2 = ( vec2( iuv.x + h0x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		vec2 p3 = ( vec2( iuv.x + h1x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;

		return g0( fuv.y ) * ( g0x * textureLod( tex, p0, lod ) + g1x * textureLod( tex, p1, lod ) ) +
			g1( fuv.y ) * ( g0x * textureLod( tex, p2, lod ) + g1x * textureLod( tex, p3, lod ) );

	}

	vec4 textureBicubic( sampler2D sampler, vec2 uv, float lod ) {

		vec2 fLodSize = vec2( textureSize( sampler, int( lod ) ) );
		vec2 cLodSize = vec2( textureSize( sampler, int( lod + 1.0 ) ) );
		vec2 fLodSizeInv = 1.0 / fLodSize;
		vec2 cLodSizeInv = 1.0 / cLodSize;
		vec4 fSample = bicubic( sampler, uv, vec4( fLodSizeInv, fLodSize ), floor( lod ) );
		vec4 cSample = bicubic( sampler, uv, vec4( cLodSizeInv, cLodSize ), ceil( lod ) );
		return mix( fSample, cSample, fract( lod ) );

	}

	vec3 getVolumeTransmissionRay( const in vec3 n, const in vec3 v, const in float thickness, const in float ior, const in mat4 modelMatrix ) {

		// Direction of refracted light.
		vec3 refractionVector = refract( - v, normalize( n ), 1.0 / ior );

		// Compute rotation-independent scaling of the model matrix.
		vec3 modelScale;
		modelScale.x = length( vec3( modelMatrix[ 0 ].xyz ) );
		modelScale.y = length( vec3( modelMatrix[ 1 ].xyz ) );
		modelScale.z = length( vec3( modelMatrix[ 2 ].xyz ) );

		// The thickness is specified in local space.
		return normalize( refractionVector ) * thickness * modelScale;

	}

	float applyIorToRoughness( const in float roughness, const in float ior ) {

		// Scale roughness with IOR so that an IOR of 1.0 results in no microfacet refraction and
		// an IOR of 1.5 results in the default amount of microfacet refraction.
		return roughness * clamp( ior * 2.0 - 2.0, 0.0, 1.0 );

	}

	vec4 getTransmissionSample( const in vec2 fragCoord, const in float roughness, const in float ior ) {

		float lod = log2( transmissionSamplerSize.x ) * applyIorToRoughness( roughness, ior );
		return textureBicubic( transmissionSamplerMap, fragCoord.xy, lod );

	}

	vec3 volumeAttenuation( const in float transmissionDistance, const in vec3 attenuationColor, const in float attenuationDistance ) {

		if ( isinf( attenuationDistance ) ) {

			// Attenuation distance is +∞, i.e. the transmitted color is not attenuated at all.
			return vec3( 1.0 );

		} else {

			// Compute light attenuation using Beer's law.
			vec3 attenuationCoefficient = -log( attenuationColor ) / attenuationDistance;
			vec3 transmittance = exp( - attenuationCoefficient * transmissionDistance ); // Beer's law
			return transmittance;

		}

	}

	vec4 getIBLVolumeRefraction( const in vec3 n, const in vec3 v, const in float roughness, const in vec3 diffuseColor,
		const in vec3 specularColor, const in float specularF90, const in vec3 position, const in mat4 modelMatrix,
		const in mat4 viewMatrix, const in mat4 projMatrix, const in float dispersion, const in float ior, const in float thickness,
		const in vec3 attenuationColor, const in float attenuationDistance ) {

		vec4 transmittedLight;
		vec3 transmittance;

		#ifdef USE_DISPERSION

			float halfSpread = ( ior - 1.0 ) * 0.025 * dispersion;
			vec3 iors = vec3( ior - halfSpread, ior, ior + halfSpread );

			for ( int i = 0; i < 3; i ++ ) {

				vec3 transmissionRay = getVolumeTransmissionRay( n, v, thickness, iors[ i ], modelMatrix );
				vec3 refractedRayExit = position + transmissionRay;

				// Project refracted vector on the framebuffer, while mapping to normalized device coordinates.
				vec4 ndcPos = projMatrix * viewMatrix * vec4( refractedRayExit, 1.0 );
				vec2 refractionCoords = ndcPos.xy / ndcPos.w;
				refractionCoords += 1.0;
				refractionCoords /= 2.0;

				// Sample framebuffer to get pixel the refracted ray hits.
				vec4 transmissionSample = getTransmissionSample( refractionCoords, roughness, iors[ i ] );
				transmittedLight[ i ] = transmissionSample[ i ];
				transmittedLight.a += transmissionSample.a;

				transmittance[ i ] = diffuseColor[ i ] * volumeAttenuation( length( transmissionRay ), attenuationColor, attenuationDistance )[ i ];

			}

			transmittedLight.a /= 3.0;

		#else

			vec3 transmissionRay = getVolumeTransmissionRay( n, v, thickness, ior, modelMatrix );
			vec3 refractedRayExit = position + transmissionRay;

			// Project refracted vector on the framebuffer, while mapping to normalized device coordinates.
			vec4 ndcPos = projMatrix * viewMatrix * vec4( refractedRayExit, 1.0 );
			vec2 refractionCoords = ndcPos.xy / ndcPos.w;
			refractionCoords += 1.0;
			refractionCoords /= 2.0;

			// Sample framebuffer to get pixel the refracted ray hits.
			transmittedLight = getTransmissionSample( refractionCoords, roughness, ior );
			transmittance = diffuseColor * volumeAttenuation( length( transmissionRay ), attenuationColor, attenuationDistance );

		#endif

		vec3 attenuatedColor = transmittance * transmittedLight.rgb;

		// Get the specular component.
		vec3 F = EnvironmentBRDF( n, v, specularColor, specularF90, roughness );

		// As less light is transmitted, the opacity should be increased. This simple approximation does a decent job
		// of modulating a CSS background, and has no effect when the buffer is opaque, due to a solid object or clear color.
		float transmittanceFactor = ( transmittance.r + transmittance.g + transmittance.b ) / 3.0;

		return vec4( ( 1.0 - F ) * attenuatedColor, 1.0 - ( 1.0 - transmittedLight.a ) * transmittanceFactor );

	}
#endif
"#
```
transmission_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const uv\_pars\_fragment
```cj
public const uv_pars_fragment: String = #"

#ifdef USE_TRANSMISSIONMAP

	uniform mat3 transmissionMapTransform;

#endif
#ifdef USE_THICKNESSMAP

	uniform mat3 thicknessMapTransform;

#endif
"#
```
uv_pars_fragment GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const uv\_pars\_vertex
```cj
public const uv_pars_vertex: String = #"
#ifdef USE_MAP

	uniform mat3 mapTransform;

#endif
#ifdef USE_ALPHAMAP

	uniform mat3 alphaMapTransform;

#endif
#ifdef USE_LIGHTMAP

	uniform mat3 lightMapTransform;

#endif
#ifdef USE_AOMAP

	uniform mat3 aoMapTransform;

#endif
#ifdef USE_BUMPMAP

	uniform mat3 bumpMapTransform;

#endif
#ifdef USE_NORMALMAP

	uniform mat3 normalMapTransform;

#endif
#ifdef USE_DISPLACEMENTMAP

	uniform mat3 displacementMapTransform;

#endif
#ifdef USE_EMISSIVEMAP

	uniform mat3 emissiveMapTransform;

#endif
#ifdef USE_METALNESSMAP

	uniform mat3 metalnessMapTransform;

#endif
#ifdef USE_ROUGHNESSMAP

	uniform mat3 roughnessMapTransform;

#endif
#ifdef USE_ANISOTROPYMAP

	uniform mat3 anisotropyMapTransform;

#endif
#ifdef USE_CLEARCOATMAP

	uniform mat3 clearcoatMapTransform;

#endif
#ifdef USE_CLEARCOAT_NORMALMAP

	uniform mat3 clearcoatNormalMapTransform;

#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP

	uniform mat3 clearcoatRoughnessMapTransform;

#endif
#ifdef USE_SHEEN_COLORMAP

	uniform mat3 sheenColorMapTransform;

#endif
#ifdef USE_SHEEN_ROUGHNESSMAP

	uniform mat3 sheenRoughnessMapTransform;

#endif
#ifdef USE_IRIDESCENCEMAP

	uniform mat3 iridescenceMapTransform;

#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP

	uniform mat3 iridescenceThicknessMapTransform;

#endif
#ifdef USE_SPECULARMAP

	uniform mat3 specularMapTransform;

#endif
#ifdef USE_SPECULAR_COLORMAP

	uniform mat3 specularColorMapTransform;

#endif
#ifdef USE_SPECULAR_INTENSITYMAP

	uniform mat3 specularIntensityMapTransform;

#endif
#ifdef USE_TRANSMISSIONMAP

	uniform mat3 transmissionMapTransform;

#endif
#ifdef USE_THICKNESSMAP

	uniform mat3 thicknessMapTransform;

#endif
"#
```
uv_pars_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const uv\_vertex
```cj
public const uv_vertex: String = #"
#if defined( USE_UV ) || defined( USE_ANISOTROPY )

	vUv = vec3( uv, 1 ).xy;

#endif
#ifdef USE_MAP

	// 对照 three.js uv_vertex：vMapUv = (mapTransform * vec3(uv,1)).xy。
	// bgfx4cj 修复：默认 mapTransform 为单位矩阵（无 offset/repeat/rotation 时），
	// 直接 vMapUv = MAP_UV 等价且规避 Mat3 uniform 在 HLSL 转译下可能未生效
	// （0 矩阵 → v_mapUv 恒 0 → 采样 (0,0) → 纹理显示为左上角单像素颜色）。
	vMapUv = MAP_UV;

#endif
#ifdef USE_ALPHAMAP

	vAlphaMapUv = mul( alphaMapTransform, vec3( ALPHAMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_LIGHTMAP

	vLightMapUv = mul( lightMapTransform, vec3( LIGHTMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_AOMAP

	vAoMapUv = mul( aoMapTransform, vec3( AOMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_BUMPMAP

	vBumpMapUv = mul( bumpMapTransform, vec3( BUMPMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_NORMALMAP

	vNormalMapUv = mul( normalMapTransform, vec3( NORMALMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_DISPLACEMENTMAP

	vDisplacementMapUv = mul( displacementMapTransform, vec3( DISPLACEMENTMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_EMISSIVEMAP

	vEmissiveMapUv = mul( emissiveMapTransform, vec3( EMISSIVEMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_METALNESSMAP

	vMetalnessMapUv = mul( metalnessMapTransform, vec3( METALNESSMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_ROUGHNESSMAP

	vRoughnessMapUv = mul( roughnessMapTransform, vec3( ROUGHNESSMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_ANISOTROPYMAP

	vAnisotropyMapUv = mul( anisotropyMapTransform, vec3( ANISOTROPYMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_CLEARCOATMAP

	vClearcoatMapUv = mul( clearcoatMapTransform, vec3( CLEARCOATMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_CLEARCOAT_NORMALMAP

	vClearcoatNormalMapUv = mul( clearcoatNormalMapTransform, vec3( CLEARCOAT_NORMALMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP

	vClearcoatRoughnessMapUv = mul( clearcoatRoughnessMapTransform, vec3( CLEARCOAT_ROUGHNESSMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_IRIDESCENCEMAP

	vIridescenceMapUv = mul( iridescenceMapTransform, vec3( IRIDESCENCEMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP

	vIridescenceThicknessMapUv = mul( iridescenceThicknessMapTransform, vec3( IRIDESCENCE_THICKNESSMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_SHEEN_COLORMAP

	vSheenColorMapUv = mul( sheenColorMapTransform, vec3( SHEEN_COLORMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_SHEEN_ROUGHNESSMAP

	vSheenRoughnessMapUv = mul( sheenRoughnessMapTransform, vec3( SHEEN_ROUGHNESSMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_SPECULARMAP

	vSpecularMapUv = mul( specularMapTransform, vec3( SPECULARMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_SPECULAR_COLORMAP

	vSpecularColorMapUv = mul( specularColorMapTransform, vec3( SPECULAR_COLORMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_SPECULAR_INTENSITYMAP

	vSpecularIntensityMapUv = mul( specularIntensityMapTransform, vec3( SPECULAR_INTENSITYMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_TRANSMISSIONMAP

	vTransmissionMapUv = mul( transmissionMapTransform, vec3( TRANSMISSIONMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_THICKNESSMAP

	vThicknessMapUv = mul( thicknessMapTransform, vec3( THICKNESSMAP_UV, 1 ) ).xy;

#endif
"#
```
uv_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

## const worldpos\_vertex
```cj
public const worldpos_vertex: String = #"
#if defined( USE_ENVMAP ) || defined( DISTANCE ) || defined ( USE_SHADOWMAP ) || defined ( USE_TRANSMISSION ) || NUM_SPOT_LIGHT_COORDS > 0 || NUM_DIR_LIGHTS > 0 || NUM_POINT_LIGHTS > 0 || NUM_SPOT_LIGHTS > 0 || NUM_HEMI_LIGHTS > 0

	vec4 worldPosition = vec4( transformed, 1.0 );

	#ifdef USE_BATCHING

		worldPosition = batchingMatrix * worldPosition;

	#endif

	#ifdef USE_INSTANCING

		worldPosition = instanceMatrix * worldPosition;

	#endif

	worldPosition = mul( modelMatrix, worldPosition );

	v_worldPos = worldPosition.xyz;

#endif
"#
```
worldpos_vertex GLSL 片段字符串

使用仓颉三引号多行字符串语法 `"""..."""`。

