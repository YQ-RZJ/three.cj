/**
 * @file SimplexNoise
 * @brief Simplex 噪声（2D/3D/4D + Seamless2D）
 *
 * 实现要点：
 * - grad2/grad3/grad4 梯度表使用 Float64 扁平数组
 * - 构造时预计算 permGrad2x/y、permGrad3x/y/z、permGrad4x/y/z/w（避免运行时查表取模）
 * - 4D 使用 rankx/ranky/rankz/rankw 排名方式，替代旧 SIMPLEX 查找表
 * - 置换表使用 Fisher-Yates 洗牌
 * - 新增 createSeamlessNoise2D（无缝拼接噪声，命名采用 Seamless 风格）
 *
 * @package three.core.dsa
 */
package three.core.dsa

import std.math.*
import std.random.*

/**
 * Simplex 噪声（2D/3D/4D + Seamless2D）。
 *
 * 提供 noise2D / noise3D / noise4D / createSeamlessNoise2D 接口。
 */
public class SimplexNoise {
    // ===== 常量 =====

    private static let F2: Float64 = 0.5 * (sqrt(3.0) - 1.0)
    private static let G2: Float64 = (3.0 - sqrt(3.0)) / 6.0
    private static let F3: Float64 = 1.0 / 3.0
    private static let G3: Float64 = 1.0 / 6.0
    private static let F4: Float64 = (sqrt(5.0) - 1.0) / 4.0
    private static let G4: Float64 = (5.0 - sqrt(5.0)) / 20.0

    // ===== 梯度表（扁平 Float64 数组）=====

    /** 2D 梯度：12 个方向，每个 2 分量 */
    private static let GRAD2: Array<Float64> = [
        1.0, 1.0,
        -1.0, 1.0,
        1.0, -1.0,
        -1.0, -1.0,
        1.0, 0.0,
        -1.0, 0.0,
        1.0, 0.0,
        -1.0, 0.0,
        0.0, 1.0,
        0.0, -1.0,
        0.0, 1.0,
        0.0, -1.0,
    ]

    /** 3D 梯度：12 个方向，每个 3 分量 */
    private static let GRAD3: Array<Float64> = [
        1.0, 1.0, 0.0,
        -1.0, 1.0, 0.0,
        1.0, -1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, 0.0, 1.0,
        -1.0, 0.0, 1.0,
        1.0, 0.0, -1.0,
        -1.0, 0.0, -1.0,
        0.0, 1.0, 1.0,
        0.0, -1.0, 1.0,
        0.0, 1.0, -1.0,
        0.0, -1.0, -1.0,
    ]

    /** 4D 梯度：32 个方向，每个 4 分量 */
    private static let GRAD4: Array<Float64> = [
        0.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, -1.0, 0.0, 1.0, -1.0, 1.0, 0.0, 1.0, -1.0, -1.0,
        0.0, -1.0, 1.0, 1.0, 0.0, -1.0, 1.0, -1.0, 0.0, -1.0, -1.0, 1.0, 0.0, -1.0, -1.0, -1.0,
        1.0, 0.0, 1.0, 1.0, 1.0, 0.0, 1.0, -1.0, 1.0, 0.0, -1.0, 1.0, 1.0, 0.0, -1.0, -1.0,
        -1.0, 0.0, 1.0, 1.0, -1.0, 0.0, 1.0, -1.0, -1.0, 0.0, -1.0, 1.0, -1.0, 0.0, -1.0, -1.0,
        1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 0.0, -1.0, 1.0, -1.0, 0.0, 1.0, 1.0, -1.0, 0.0, -1.0,
        -1.0, 1.0, 0.0, 1.0, -1.0, 1.0, 0.0, -1.0, -1.0, -1.0, 0.0, 1.0, -1.0, -1.0, 0.0, -1.0,
        1.0, 1.0, 1.0, 0.0, 1.0, 1.0, -1.0, 0.0, 1.0, -1.0, 1.0, 0.0, 1.0, -1.0, -1.0, 0.0,
        -1.0, 1.0, 1.0, 0.0, -1.0, 1.0, -1.0, 0.0, -1.0, -1.0, 1.0, 0.0, -1.0, -1.0, -1.0, 0.0,
    ]

    // ===== 预计算梯度查找表（permGrad2x/y、permGrad3x/y/z、permGrad4x/y/z/w）=====

    /** 置换表（512 项，perm[i] = p[i & 255]，避免索引回绕） */
    private let _perm: Array<Int64>

    /** 2D 预计算梯度 x 分量 */
    private let _permGrad2x: Array<Float64>
    /** 2D 预计算梯度 y 分量 */
    private let _permGrad2y: Array<Float64>

    /** 3D 预计算梯度 x 分量 */
    private let _permGrad3x: Array<Float64>
    /** 3D 预计算梯度 y 分量 */
    private let _permGrad3y: Array<Float64>
    /** 3D 预计算梯度 z 分量 */
    private let _permGrad3z: Array<Float64>

    /** 4D 预计算梯度 x 分量 */
    private let _permGrad4x: Array<Float64>
    /** 4D 预计算梯度 y 分量 */
    private let _permGrad4y: Array<Float64>
    /** 4D 预计算梯度 z 分量 */
    private let _permGrad4z: Array<Float64>
    /** 4D 预计算梯度 w 分量 */
    private let _permGrad4w: Array<Float64>

    /**
     * 构造：用 Fisher-Yates 洗牌生成 512 项置换表，并预计算 permGrad 数组。
     *
     * @param seed 伪随机种子（默认 987654321；同种子结果可复现）
     */
    public init(seed!: UInt64 = 987654321u64) {
        let rng = Random(seed)
        // buildPermutationTable: Fisher-Yates 洗牌
        let p = Array<Int64>(256, { i => Int64(i) })
        for (i in 0..255) {
            let r = i + Int64(rng.nextFloat64() * Float64(256 - i))
            if (r != i) {
                let tmp = p[i]
                p[i] = p[r]
                p[r] = tmp
            }
        }
        let perm = Array<Int64>(512, { i => p[i & 255] })
        this._perm = perm

        // 预计算 permGrad2x/y（perm.map(v => grad2[(v % 12) * 2/2+1])）
        let pg2x = Array<Float64>(512, { _ => 0.0 })
        let pg2y = Array<Float64>(512, { _ => 0.0 })
        let pg3x = Array<Float64>(512, { _ => 0.0 })
        let pg3y = Array<Float64>(512, { _ => 0.0 })
        let pg3z = Array<Float64>(512, { _ => 0.0 })
        let pg4x = Array<Float64>(512, { _ => 0.0 })
        let pg4y = Array<Float64>(512, { _ => 0.0 })
        let pg4z = Array<Float64>(512, { _ => 0.0 })
        let pg4w = Array<Float64>(512, { _ => 0.0 })
        for (i in 0..512) {
            let v = Int64(perm[i])
            let m2 = (v % 12) * 2
            pg2x[i] = SimplexNoise.GRAD2[m2]
            pg2y[i] = SimplexNoise.GRAD2[m2 + 1]

            let m3 = (v % 12) * 3
            pg3x[i] = SimplexNoise.GRAD3[m3]
            pg3y[i] = SimplexNoise.GRAD3[m3 + 1]
            pg3z[i] = SimplexNoise.GRAD3[m3 + 2]

            let m4 = (v % 32) * 4
            pg4x[i] = SimplexNoise.GRAD4[m4]
            pg4y[i] = SimplexNoise.GRAD4[m4 + 1]
            pg4z[i] = SimplexNoise.GRAD4[m4 + 2]
            pg4w[i] = SimplexNoise.GRAD4[m4 + 3]
        }
        this._permGrad2x = pg2x
        this._permGrad2y = pg2y
        this._permGrad3x = pg3x
        this._permGrad3y = pg3y
        this._permGrad3z = pg3z
        this._permGrad4x = pg4x
        this._permGrad4y = pg4y
        this._permGrad4z = pg4z
        this._permGrad4w = pg4w
    }

    // ===== 2D Simplex 噪声 =====

    /**
     * 2D Simplex 噪声，返回 [-1, 1]。
     */
    public func noise2D(x: Float64, y: Float64): Float64 {
        var n0: Float64 = 0.0
        var n1: Float64 = 0.0
        var n2: Float64 = 0.0

        // 输入空间斜切，确定所在 simplex 单元
        let s = (x + y) * SimplexNoise.F2
        let i = Int64(floor(x + s))
        let j = Int64(floor(y + s))
        let t = Float64(i + j) * SimplexNoise.G2
        let X0 = Float64(i) - t
        let Y0 = Float64(j) - t
        let x0 = x - X0
        let y0 = y - Y0

        // 判断所在 simplex（下三角 XY 或上三角 YX）
        let i1: Int64
        let j1: Int64
        if (x0 > y0) {
            i1 = 1; j1 = 0
        } else {
            i1 = 0; j1 = 1
        }

        let x1 = x0 - Float64(i1) + SimplexNoise.G2
        let y1 = y0 - Float64(j1) + SimplexNoise.G2
        let x2 = x0 - 1.0 + 2.0 * SimplexNoise.G2
        let y2 = y0 - 1.0 + 2.0 * SimplexNoise.G2

        // 哈希梯度索引
        let ii = i & 255
        let jj = j & 255

        // 三个角贡献
        var t0 = 0.5 - x0 * x0 - y0 * y0
        if (t0 >= 0.0) {
            let gi0 = Int64(ii + this._perm[Int64(jj)])
            t0 *= t0
            n0 = t0 * t0 * (this._permGrad2x[gi0] * x0 + this._permGrad2y[gi0] * y0)
        }
        var t1 = 0.5 - x1 * x1 - y1 * y1
        if (t1 >= 0.0) {
            let gi1 = Int64(ii + i1 + this._perm[Int64(jj + j1)])
            t1 *= t1
            n1 = t1 * t1 * (this._permGrad2x[gi1] * x1 + this._permGrad2y[gi1] * y1)
        }
        var t2 = 0.5 - x2 * x2 - y2 * y2
        if (t2 >= 0.0) {
            let gi2 = Int64(ii + 1 + this._perm[Int64(jj + 1)])
            t2 *= t2
            n2 = t2 * t2 * (this._permGrad2x[gi2] * x2 + this._permGrad2y[gi2] * y2)
        }

        // 结果缩放至 [-1, 1]
        return 70.0 * (n0 + n1 + n2)
    }

    /**
     * 2D Simplex 噪声（兼容旧接口 noise(xin, yin)）。
     */
    public func noise(xin: Float64, yin: Float64): Float64 {
        return noise2D(xin, yin)
    }

    // ===== 3D Simplex 噪声 =====

    /**
     * 3D Simplex 噪声，返回 [-1, 1]。
     */
    public func noise3d(xin: Float64, yin: Float64, zin: Float64): Float64 {
        var n0: Float64 = 0.0
        var n1: Float64 = 0.0
        var n2: Float64 = 0.0
        var n3: Float64 = 0.0

        // 输入空间斜切
        let s = (xin + yin + zin) * SimplexNoise.F3
        let i = Int64(floor(xin + s))
        let j = Int64(floor(yin + s))
        let k = Int64(floor(zin + s))
        let t = Float64(i + j + k) * SimplexNoise.G3
        let X0 = Float64(i) - t
        let Y0 = Float64(j) - t
        let Z0 = Float64(k) - t
        let x0 = xin - X0
        let y0 = yin - Y0
        let z0 = zin - Z0

        // 判断所在 simplex（四面体）
        let i1: Int64
        let j1: Int64
        let k1: Int64
        let i2: Int64
        let j2: Int64
        let k2: Int64
        if (x0 >= y0) {
            if (y0 >= z0) {
                i1 = 1; j1 = 0; k1 = 0; i2 = 1; j2 = 1; k2 = 0
            } else if (x0 >= z0) {
                i1 = 1; j1 = 0; k1 = 0; i2 = 1; j2 = 0; k2 = 1
            } else {
                i1 = 0; j1 = 0; k1 = 1; i2 = 1; j2 = 0; k2 = 1
            }
        } else {
            if (y0 < z0) {
                i1 = 0; j1 = 0; k1 = 1; i2 = 0; j2 = 1; k2 = 1
            } else if (x0 < z0) {
                i1 = 0; j1 = 1; k1 = 0; i2 = 0; j2 = 1; k2 = 1
            } else {
                i1 = 0; j1 = 1; k1 = 0; i2 = 1; j2 = 1; k2 = 0
            }
        }

        // 各角偏移
        let x1 = x0 - Float64(i1) + SimplexNoise.G3
        let y1 = y0 - Float64(j1) + SimplexNoise.G3
        let z1 = z0 - Float64(k1) + SimplexNoise.G3
        let x2 = x0 - Float64(i2) + 2.0 * SimplexNoise.G3
        let y2 = y0 - Float64(j2) + 2.0 * SimplexNoise.G3
        let z2 = z0 - Float64(k2) + 2.0 * SimplexNoise.G3
        let x3 = x0 - 1.0 + 3.0 * SimplexNoise.G3
        let y3 = y0 - 1.0 + 3.0 * SimplexNoise.G3
        let z3 = z0 - 1.0 + 3.0 * SimplexNoise.G3

        // 哈希梯度索引
        let ii = i & 255
        let jj = j & 255
        let kk = k & 255

        // 四个角贡献
        var t0 = 0.6 - x0 * x0 - y0 * y0 - z0 * z0
        if (t0 >= 0.0) {
            let gi0 = Int64(ii + this._perm[Int64(jj + this._perm[Int64(kk)])])
            t0 *= t0
            n0 = t0 * t0 * (this._permGrad3x[gi0] * x0 + this._permGrad3y[gi0] * y0 + this._permGrad3z[gi0] * z0)
        }
        var t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1
        if (t1 >= 0.0) {
            let gi1 = Int64(ii + i1 + this._perm[Int64(jj + j1 + this._perm[Int64(kk + k1)])])
            t1 *= t1
            n1 = t1 * t1 * (this._permGrad3x[gi1] * x1 + this._permGrad3y[gi1] * y1 + this._permGrad3z[gi1] * z1)
        }
        var t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2
        if (t2 >= 0.0) {
            let gi2 = Int64(ii + i2 + this._perm[Int64(jj + j2 + this._perm[Int64(kk + k2)])])
            t2 *= t2
            n2 = t2 * t2 * (this._permGrad3x[gi2] * x2 + this._permGrad3y[gi2] * y2 + this._permGrad3z[gi2] * z2)
        }
        var t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3
        if (t3 >= 0.0) {
            let gi3 = Int64(ii + 1 + this._perm[Int64(jj + 1 + this._perm[Int64(kk + 1)])])
            t3 *= t3
            n3 = t3 * t3 * (this._permGrad3x[gi3] * x3 + this._permGrad3y[gi3] * y3 + this._permGrad3z[gi3] * z3)
        }

        // 结果缩放至 [-1, 1]
        return 32.0 * (n0 + n1 + n2 + n3)
    }

    // ===== 4D Simplex 噪声 =====

    /**
     * 4D Simplex 噪声，返回 [-1, 1]。
     *
     * 使用 rankx/ranky/rankz/rankw 排名方式确定 simplex 各角偏移
     * （替代旧 SIMPLEX 查找表 + 位编码方式）。
     */
    public func noise4d(x: Float64, y: Float64, z: Float64, w: Float64): Float64 {
        var n0: Float64 = 0.0
        var n1: Float64 = 0.0
        var n2: Float64 = 0.0
        var n3: Float64 = 0.0
        var n4: Float64 = 0.0

        // 输入空间斜切（4D）
        let s = (x + y + z + w) * SimplexNoise.F4
        let i = Int64(floor(x + s))
        let j = Int64(floor(y + s))
        let k = Int64(floor(z + s))
        let l = Int64(floor(w + s))
        let t = Float64(i + j + k + l) * SimplexNoise.G4
        let X0 = Float64(i) - t
        let Y0 = Float64(j) - t
        let Z0 = Float64(k) - t
        let W0 = Float64(l) - t
        let x0 = x - X0
        let y0 = y - Y0
        let z0 = z - Z0
        let w0 = w - W0

        // 六组两两比较，确定各坐标排名（rankx/ranky/rankz/rankw）
        var rankx: Int64 = 0
        var ranky: Int64 = 0
        var rankz: Int64 = 0
        var rankw: Int64 = 0
        if (x0 > y0) { rankx++ } else { ranky++ }
        if (x0 > z0) { rankx++ } else { rankz++ }
        if (x0 > w0) { rankx++ } else { rankw++ }
        if (y0 > z0) { ranky++ } else { rankz++ }
        if (y0 > w0) { ranky++ } else { rankw++ }
        if (z0 > w0) { rankz++ } else { rankw++ }

        // 依据排名确定各角偏移（rank >= 3 为最大坐标，rank >= 2 为次大，rank >= 1 为第三）
        let i1 = if (rankx >= 3) { 1 } else { 0 }
        let j1 = if (ranky >= 3) { 1 } else { 0 }
        let k1 = if (rankz >= 3) { 1 } else { 0 }
        let l1 = if (rankw >= 3) { 1 } else { 0 }
        let i2 = if (rankx >= 2) { 1 } else { 0 }
        let j2 = if (ranky >= 2) { 1 } else { 0 }
        let k2 = if (rankz >= 2) { 1 } else { 0 }
        let l2 = if (rankw >= 2) { 1 } else { 0 }
        let i3 = if (rankx >= 1) { 1 } else { 0 }
        let j3 = if (ranky >= 1) { 1 } else { 0 }
        let k3 = if (rankz >= 1) { 1 } else { 0 }
        let l3 = if (rankw >= 1) { 1 } else { 0 }

        // 各角偏移
        let x1 = x0 - Float64(i1) + SimplexNoise.G4
        let y1 = y0 - Float64(j1) + SimplexNoise.G4
        let z1 = z0 - Float64(k1) + SimplexNoise.G4
        let w1 = w0 - Float64(l1) + SimplexNoise.G4
        let x2 = x0 - Float64(i2) + 2.0 * SimplexNoise.G4
        let y2 = y0 - Float64(j2) + 2.0 * SimplexNoise.G4
        let z2 = z0 - Float64(k2) + 2.0 * SimplexNoise.G4
        let w2 = w0 - Float64(l2) + 2.0 * SimplexNoise.G4
        let x3 = x0 - Float64(i3) + 3.0 * SimplexNoise.G4
        let y3 = y0 - Float64(j3) + 3.0 * SimplexNoise.G4
        let z3 = z0 - Float64(k3) + 3.0 * SimplexNoise.G4
        let w3 = w0 - Float64(l3) + 3.0 * SimplexNoise.G4
        let x4 = x0 - 1.0 + 4.0 * SimplexNoise.G4
        let y4 = y0 - 1.0 + 4.0 * SimplexNoise.G4
        let z4 = z0 - 1.0 + 4.0 * SimplexNoise.G4
        let w4 = w0 - 1.0 + 4.0 * SimplexNoise.G4

        // 哈希梯度索引
        let ii = i & 255
        let jj = j & 255
        let kk = k & 255
        let ll = l & 255

        // 五个角贡献
        var t0 = 0.6 - x0 * x0 - y0 * y0 - z0 * z0 - w0 * w0
        if (t0 >= 0.0) {
            let gi0 = Int64(ii + this._perm[Int64(jj + this._perm[Int64(kk + this._perm[Int64(ll)])])])
            t0 *= t0
            n0 = t0 * t0 * (this._permGrad4x[gi0] * x0 + this._permGrad4y[gi0] * y0 + this._permGrad4z[gi0] * z0 + this._permGrad4w[gi0] * w0)
        }
        var t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1 - w1 * w1
        if (t1 >= 0.0) {
            let gi1 = Int64(ii + i1 + this._perm[Int64(jj + j1 + this._perm[Int64(kk + k1 + this._perm[Int64(ll + l1)])])])
            t1 *= t1
            n1 = t1 * t1 * (this._permGrad4x[gi1] * x1 + this._permGrad4y[gi1] * y1 + this._permGrad4z[gi1] * z1 + this._permGrad4w[gi1] * w1)
        }
        var t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2 - w2 * w2
        if (t2 >= 0.0) {
            let gi2 = Int64(ii + i2 + this._perm[Int64(jj + j2 + this._perm[Int64(kk + k2 + this._perm[Int64(ll + l2)])])])
            t2 *= t2
            n2 = t2 * t2 * (this._permGrad4x[gi2] * x2 + this._permGrad4y[gi2] * y2 + this._permGrad4z[gi2] * z2 + this._permGrad4w[gi2] * w2)
        }
        var t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3 - w3 * w3
        if (t3 >= 0.0) {
            let gi3 = Int64(ii + i3 + this._perm[Int64(jj + j3 + this._perm[Int64(kk + k3 + this._perm[Int64(ll + l3)])])])
            t3 *= t3
            n3 = t3 * t3 * (this._permGrad4x[gi3] * x3 + this._permGrad4y[gi3] * y3 + this._permGrad4z[gi3] * z3 + this._permGrad4w[gi3] * w3)
        }
        var t4 = 0.6 - x4 * x4 - y4 * y4 - z4 * z4 - w4 * w4
        if (t4 >= 0.0) {
            let gi4 = Int64(ii + 1 + this._perm[Int64(jj + 1 + this._perm[Int64(kk + 1 + this._perm[Int64(ll + 1)])])])
            t4 *= t4
            n4 = t4 * t4 * (this._permGrad4x[gi4] * x4 + this._permGrad4y[gi4] * y4 + this._permGrad4z[gi4] * z4 + this._permGrad4w[gi4] * w4)
        }

        // 结果缩放至 [-1, 1]
        return 27.0 * (n0 + n1 + n2 + n3 + n4)
    }

    // ===== Seamless Noise（无缝噪声 2D）=====

    /**
     * 2D 无缝噪声，在 diameter 范围内循环重复，实现无缝拼接。
     *
     * 算法：对输入坐标做 Python 风格取模（pyMod）映射到 [0, diameter)，
     * 检测坐标是否处于边界（margin，即 (x+1) mod diameter < 1），
     * 对于跨越边界的 simplex 单元，将梯度索引置为 -1（与偏移 +1 相加后归 0），
     * 从而实现边界两侧梯度一致的无缝拼接。
     *
     * 与标准 noise2D 的差异：使用未斜切（un-skewed）的轴对齐网格单元
     * （i = floor(xin)），而非标准版的斜切网格（i = floor(x + s)），
     * 因此噪声图案与 noise2D 不同，但支持无缝循环。
     *
     * @param x x 坐标
     * @param y y 坐标
     * @param diameter 循环直径（噪声在此范围内无缝重复）
     * @return 噪声值 [-1, 1]
     */
    public func createSeamlessNoise2D(x: Float64, y: Float64, diameter: Float64): Float64 {
        var n0: Float64 = 0.0
        var n1: Float64 = 0.0
        var n2: Float64 = 0.0

        let xin = pyMod(x, diameter)
        let yin = pyMod(y, diameter)
        let btwX = pyMod(x + 1.0, diameter)
        let btwY = pyMod(y + 1.0, diameter)
        let xMarge = btwX >= 0.0 && btwX < 1.0
        let yMarge = btwY >= 0.0 && btwY < 1.0

        // 原始超晶格转正超晶格
        let i = Int64(floor(xin))
        let j = Int64(floor(yin))
        // 正超晶格转原始超晶格
        let X0 = xin - Float64(i)
        let Y0 = yin - Float64(j)
        let t = (X0 + Y0) * SimplexNoise.G2
        let x0 = X0 - t
        let y0 = Y0 - t

        // 判断所在 simplex
        let i1: Int64
        let j1: Int64
        if (x0 > y0) {
            i1 = 1; j1 = 0
        } else {
            i1 = 0; j1 = 1
        }

        let x1 = x0 - Float64(i1) + SimplexNoise.G2
        let y1 = y0 - Float64(j1) + SimplexNoise.G2
        let x2 = x0 - 1.0 + 2.0 * SimplexNoise.G2
        let y2 = y0 - 1.0 + 2.0 * SimplexNoise.G2

        var ii = i & 255
        var jj = j & 255

        // 晶格原点
        var t0 = 0.5 - x0 * x0 - y0 * y0
        if (t0 >= 0.0) {
            let gi0 = Int64(ii + this._perm[Int64(jj)])
            t0 *= t0
            n0 = t0 * t0 * (this._permGrad2x[gi0] * x0 + this._permGrad2y[gi0] * y0)
        }

        // 晶格侧点
        var t1 = 0.5 - x1 * x1 - y1 * y1
        if (t1 >= 0.0) {
            var ii1 = ii
            var jj1 = jj
            if (xMarge && i1 == 1) { ii1 = -1 }
            if (yMarge && j1 == 1) { jj1 = -1 }
            let gi1 = Int64(ii1 + i1 + this._perm[Int64(jj1 + j1)])
            t1 *= t1
            n1 = t1 * t1 * (this._permGrad2x[gi1] * x1 + this._permGrad2y[gi1] * y1)
        }

        // 晶格中间点
        var t2 = 0.5 - x2 * x2 - y2 * y2
        if (t2 >= 0.0) {
            var ii2 = ii
            var jj2 = jj
            if (xMarge) { ii2 = -1 }
            if (yMarge) { jj2 = -1 }
            let gi2 = Int64(ii2 + 1 + this._perm[Int64(jj2 + 1)])
            t2 *= t2
            n2 = t2 * t2 * (this._permGrad2x[gi2] * x2 + this._permGrad2y[gi2] * y2)
        }

        return 70.0 * (n0 + n1 + n2)
    }

    /**
     * Python 风格取模（结果符号与除数相同）。
     *
     * Cangjie 的 Float64 不支持 `%` 运算符，使用 std.math.fmod 实现：
     * r = fmod(x, y)，结果符号与 x 相同，再用 r + y 修正到 [0, y) 区间。
     */
    private static func pyMod(x: Float64, y: Float64): Float64 {
        let r = fmod(x, y)
        if (r < 0.0) {
            return r + y
        }
        return r
    }
}
