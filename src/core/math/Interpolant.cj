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
 * @file[zh-cn] Interpolant
 * @brief[zh-cn] 插值器基类
 * @explain[zh-cn] 提供参数化样本的插值基类，包含区间查找和插值模板方法。
 *
 * @file[en] Interpolant
 * @brief[en] Interpolant
 * @explain[en] Provides the interpolation base class for parameterized samples, including interval search and interpolation template methods.
 */
package three.core.math

import std.collection.*

/**
 * @brief[zh-cn] 插值器基类，提供区间查找和插值模板方法
 * @explain[zh-cn] 子类需重写 interpolate_ 方法实现具体插值算法（线性、三次、离散等）
 *
 * @brief[en] Interpolant base class, providing interval search and interpolation template methods
 * @explain[en] Subclasses must override the interpolate_ method to implement specific interpolation algorithms (linear, cubic, discrete, etc.)
 */
public open class Interpolant {
    /**
     * @brief[zh-cn] 参数位置数组
     *
     * @brief[en] Parameter positions array
     */
    public var parameterPositions: Array<Float64>
    /**
     * @brief[zh-cn] 缓存索引
     *
     * @brief[en] Cached index
     */
    private var _cachedIndex: Int64
    /**
     * @brief[zh-cn] 结果缓冲区
     *
     * @brief[en] Result buffer
     */
    public var resultBuffer: Array<Float64>
    /**
     * @brief[zh-cn] 采样值数组
     *
     * @brief[en] Sample values array
     */
    public var sampleValues: Array<Float64>
    /**
     * @brief[zh-cn] 值大小（每个采样值的分量数）
     *
     * @brief[en] Value size (number of components per sample value)
     */
    public var valueSize: Int64
    /**
     * @brief[zh-cn] 插值设置
     *
     * @brief[en] Interpolation settings
     */
    public var settings: Option<HashMap<String, Int64>>
    /**
     * @brief[zh-cn] 默认设置
     *
     * @brief[en] Default settings
     */
    public var DefaultSettings_: HashMap<String, Int64>
    /**
     * @brief[zh-cn] 缓存索引（AnimationMixer 内存管理用）
     *
     * @brief[en] Cache index (for AnimationMixer memory management)
     */
    public var __cacheIndex: Option<Int64>

    public init(parameterPositions: Array<Float64>, sampleValues: Array<Float64>, sampleSize: Int64, resultBuffer: Option<Array<Float64>>) {
        this.parameterPositions = parameterPositions
        this._cachedIndex = 0
        this.resultBuffer = match (resultBuffer) {
            case Some(buf) => buf
            case None => Array<Float64>(sampleSize, { _ => 0.0 })
        }
        this.sampleValues = sampleValues
        this.valueSize = sampleSize
        this.settings = None
        this.DefaultSettings_ = HashMap<String, Int64>()
        this.__cacheIndex = None
    }

    /**
     * @brief[zh-cn] 在位置 t 处求值
     * @param[zh-cn] t 插值因子
     * @return[zh-cn] 结果缓冲区
     *
     * @brief[en] Evaluate at position t
     * @param[en] t Interpolation factor
     * @return[en] Result buffer
     */
    public func evaluate(t: Float64): Array<Float64> {
        let pp = this.parameterPositions
        var i1 = this._cachedIndex
        var t1 = pp[i1]
        var t0 = pp[i1 - 1]

        // 验证区间 - 使用标志变量替代 labeled break
        var intervalValid = false
        var seekDone = false
        var linearScanDone = false
        var right: Int64 = 0

        while (!intervalValid) {
            // forward scan
            if (!(t < t1)) {
                var giveUpAt = i1 + 2
                var forwardDone = false
                while (!forwardDone) {
                    if (t1.isNaN()) {
                        // 即 JS 中 t1 === undefined 的情况
                        if (t < t0) {
                            break // break forward_scan
                        }
                        // after end
                        i1 = pp.size
                        this._cachedIndex = i1
                        return this.copySampleValue_(i1 - 1)
                    }
                    if (i1 == giveUpAt) {
                        forwardDone = true
                        break
                    }
                    t0 = t1
                    i1 += 1
                    t1 = pp[i1]
                    if (t < t1) {
                        seekDone = true
                        forwardDone = true
                        break
                    }
                }
                if (seekDone) { intervalValid = true; break }
                if (!forwardDone) {
                    // prepare binary search on the right side of the index
                    right = pp.size
                    linearScanDone = true
                    break
                }
            }

            if (!linearScanDone && !seekDone) {
                // reverse scan
                if (!(t >= t0)) {
                    let t1global = pp[1]
                    if (t < t1global) {
                        i1 = 2
                        t0 = t1global
                    }
                    var giveUpAt = i1 - 2
                    var reverseDone = false
                    while (!reverseDone) {
                        if (t0.isNaN()) {
                            // before start
                            this._cachedIndex = 0
                            return this.copySampleValue_(0)
                        }
                        if (i1 == giveUpAt) {
                            reverseDone = true
                            break
                        }
                        t1 = t0
                        i1 -= 1
                        t0 = pp[i1 - 1]
                        if (t >= t0) {
                            seekDone = true
                            reverseDone = true
                            break
                        }
                    }
                    if (seekDone) { intervalValid = true; break }
                    if (!reverseDone) {
                        // prepare binary search on the left side of the index
                        right = i1
                        i1 = 0
                        linearScanDone = true
                        break
                    }
                } else {
                    // the interval is valid
                    intervalValid = true
                    break
                }
            }

            if (linearScanDone) {
                // binary search
                while (i1 < right) {
                    let mid = (i1 + right) / 2
                    if (t < pp[mid]) {
                        right = mid
                    } else {
                        i1 = mid + 1
                    }
                }
                t1 = pp[i1]
                t0 = pp[i1 - 1]

                // check boundary cases, again
                if (t0.isNaN()) {
                    this._cachedIndex = 0
                    return this.copySampleValue_(0)
                }
                if (t1.isNaN()) {
                    i1 = pp.size
                    this._cachedIndex = i1
                    return this.copySampleValue_(i1 - 1)
                }
                intervalValid = true
                break
            }

            intervalValid = true
        }

        this._cachedIndex = i1
        this.intervalChanged_(i1, t0, t1)
        return this.interpolate_(i1, t0, t, t1)
    }

    /**
     * @brief[zh-cn] 获取插值设置
     * @return[zh-cn] 设置对象
     *
     * @brief[en] Get interpolation settings
     * @return[en] Settings object
     */
    public func getSettings_(): HashMap<String, Int64> {
        return this.settings ?? this.DefaultSettings_
    }

    /**
     * @brief[zh-cn] 复制采样值到结果缓冲区
     * @param[zh-cn] index 采样值缓冲区索引
     * @return[zh-cn] 结果缓冲区
     *
     * @brief[en] Copy sample value to result buffer
     * @param[en] index Sample value buffer index
     * @return[en] Result buffer
     */
    public func copySampleValue_(index: Int64): Array<Float64> {
        let result = this.resultBuffer
        let values = this.sampleValues
        let stride = this.valueSize
        let offset = index * stride
        for (i in 0..stride) {
            result[i] = values[offset + i]
        }
        return result
    }

    /**
     * @brief[zh-cn] 插值方法，子类重写
     * @param[zh-cn] i1 采样值缓冲区索引
     * t0 上一个插值因子
     * t 当前插值因子
     * t1 下一个插值因子
     * @return[zh-cn] 结果缓冲区
     *
     * @brief[en] Interpolation method, override by subclasses
     * @param[en] i1 Sample value buffer index
     * t0 Previous interpolation factor
     * t Current interpolation factor
     * t1 Next interpolation factor
     * @return[en] Result buffer
     */
    public open func interpolate_(i1: Int64, t0: Float64, t: Float64, t1: Float64): Array<Float64> {
        throw Exception("THREE.Interpolant: Call to abstract method.")
        // 子类应返回 this.resultBuffer
    }

    /**
     * @brief[zh-cn] 区间变化时调用，子类可重写
     * @param[zh-cn] i1 采样值缓冲区索引
     * t0 上一个插值因子
     * t1 下一个插值因子
     *
     * @brief[en] Called when interval changes, subclasses can override
     * @param[en] i1 Sample value buffer index
     * t0 Previous interpolation factor
     * t1 Next interpolation factor
     */
    public open func intervalChanged_(i1: Int64, t0: Float64, t1: Float64): Unit {
        // empty
    }
}