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
 * @file[zh-cn] Boids
 * @brief[zh-cn] 鸟群算法（Boids）实现
 * @explain[zh-cn]包含三大经典行为：对齐（Alignment）跟随邻居平均方向、聚合（Cohesion）朝邻居中心移动、分离（Separation）远离过近的邻居。使用 three.core.math.Vector2 作为二维向量。注意：Vector2 方法会 mutate 自身并返回 this，因此在需要保留原值时先调用 clone()。
 *
 * @file[en] Boids
 * @brief[en] Boids flocking algorithm implementation
 * @explain[en] Includes three classic behaviors: Alignment (follow neighbor average direction), Cohesion (move toward neighbor center), Separation (move away from too-close neighbors). Uses three.core.math.Vector2 as 2D vector. Note: Vector2 methods mutate self and return this, so call clone() first when preserving original values is needed.
 */
package three.core.dsa

import std.math.*
import three.core.math.Vector2

/**
 * @brief[zh-cn] 鸟群配置参数
 *
 * @brief[en] Flock configuration parameters
 */
public class FlockConfig {
    /**
     * @brief[zh-cn] 对齐感知半径
     *
     * @brief[en] Alignment perception radius
     */
    public var alignRadius: Float64

    /**
     * @brief[zh-cn] 聚合感知半径
     *
     * @brief[en] Cohesion perception radius
     */
    public var cohesionRadius: Float64

    /**
     * @brief[zh-cn] 分离最短距离感知半径
     *
     * @brief[en] Separation minimum distance perception radius
     */
    public var separationRadius: Float64

    /**
     * @brief[zh-cn] 对齐权重
     *
     * @brief[en] Alignment weight
     */
    public var alignWeight: Float64

    /**
     * @brief[zh-cn] 聚合权重
     *
     * @brief[en] Cohesion weight
     */
    public var cohesionWeight: Float64

    /**
     * @brief[zh-cn] 分离权重
     *
     * @brief[en] Separation weight
     */
    public var separationWeight: Float64

    /**
     * @brief[zh-cn] 最大速度
     *
     * @brief[en] Maximum speed
     */
    public var maxSpeed: Float64

    /**
     * @brief[zh-cn] 最大转向力（加速度限制）
     *
     * @brief[en] Maximum steering force (acceleration limit)
     */
    public var maxForce: Float64

    /**
     * @brief[zh-cn] 世界宽度（用于环绕）
     *
     * @brief[en] World width (for wrapping)
     */
    public var worldWidth: Float64

    /**
     * @brief[zh-cn] 世界高度（用于环绕）
     *
     * @brief[en] World height (for wrapping)
     */
    public var worldHeight: Float64

    /**
     * @brief[zh-cn] 构造鸟群配置参数
     * @param[zh-cn] alignRadius 对齐感知半径，默认 50.0
     * cohesionRadius 聚合感知半径，默认 50.0
     * separationRadius 分离最短距离感知半径，默认 25.0
     * alignWeight 对齐权重，默认 1.0
     * cohesionWeight 聚合权重，默认 1.0
     * separationWeight 分离权重，默认 1.5
     * maxSpeed 最大速度，默认 2.0
     * maxForce 最大转向力，默认 0.05
     * worldWidth 世界宽度，默认 800.0
     * worldHeight 世界高度，默认 600.0
     *
     * @brief[en] Construct flock configuration parameters
     * @param[en] alignRadius Alignment perception radius, defaults to 50.0
     * cohesionRadius Cohesion perception radius, defaults to 50.0
     * separationRadius Separation minimum distance perception radius, defaults to 25.0
     * alignWeight Alignment weight, defaults to 1.0
     * cohesionWeight Cohesion weight, defaults to 1.0
     * separationWeight Separation weight, defaults to 1.5
     * maxSpeed Maximum speed, defaults to 2.0
     * maxForce Maximum steering force, defaults to 0.05
     * worldWidth World width, defaults to 800.0
     * worldHeight World height, defaults to 600.0
     */
    public init(
        alignRadius!: Float64 = 50.0,
        cohesionRadius!: Float64 = 50.0,
        separationRadius!: Float64 = 25.0,
        alignWeight!: Float64 = 1.0,
        cohesionWeight!: Float64 = 1.0,
        separationWeight!: Float64 = 1.5,
        maxSpeed!: Float64 = 2.0,
        maxForce!: Float64 = 0.05,
        worldWidth!: Float64 = 800.0,
        worldHeight!: Float64 = 600.0
    ) {
        this.alignRadius = alignRadius
        this.cohesionRadius = cohesionRadius
        this.separationRadius = separationRadius
        this.alignWeight = alignWeight
        this.cohesionWeight = cohesionWeight
        this.separationWeight = separationWeight
        this.maxSpeed = maxSpeed
        this.maxForce = maxForce
        this.worldWidth = worldWidth
        this.worldHeight = worldHeight
    }
}

/**
 * @brief[zh-cn] 单个 Boid（鸟个体）
 *
 * @brief[en] Single Boid (bird individual)
 */
public class Boid {
    /**
     * @brief[zh-cn] 位置
     *
     * @brief[en] Position
     */
    public var pos: Vector2

    /**
     * @brief[zh-cn] 速度
     *
     * @brief[en] Velocity
     */
    public var vel: Vector2

    /**
     * @brief[zh-cn] 加速度
     *
     * @brief[en] Acceleration
     */
    public var acc: Vector2

    /**
     * @brief[zh-cn] 最大速度
     *
     * @brief[en] Maximum speed
     */
    public var maxSpeed: Float64

    /**
     * @brief[zh-cn] 最大转向力
     *
     * @brief[en] Maximum steering force
     */
    public var maxForce: Float64

    /**
     * @brief[zh-cn] 构造一个 Boid 个体
     * @param[zh-cn] pos 初始位置
     * vel 初始速度
     * maxSpeed 最大速度
     * maxForce 最大转向力
     *
     * @brief[en] Construct a Boid individual
     * @param[en] pos Initial position
     * vel Initial velocity
     * maxSpeed Maximum speed
     * maxForce Maximum steering force
     */
    public init(pos: Vector2, vel: Vector2, maxSpeed: Float64, maxForce: Float64) {
        this.pos = pos
        this.vel = vel
        this.acc = Vector2(0.0, 0.0)
        this.maxSpeed = maxSpeed
        this.maxForce = maxForce
    }

    /**
     * @brief[zh-cn] 施加力到加速度
     * @param[zh-cn] force 力向量
     *
     * @brief[en] Apply force to acceleration
     * @param[en] force Force vector
     */
    public func applyForce(force: Vector2): Unit {
        this.acc.add(force)
    }

    /**
     * @brief[zh-cn] 将引导力转换为转向力并限制
     * @param[zh-cn] targetVel 目标速度
     * @return[zh-cn] 转向力（新向量）
     *
     * @brief[en] Convert steering force and clamp it
     * @param[en] targetVel Target velocity
     * @return[en] Steering force (new vector)
     */
    public func steerTowards(targetVel: Vector2): Vector2 {
        let desired = targetVel.clone().clampLength(0.0, this.maxSpeed)
        let steer = desired.sub(this.vel) // desired - vel (desired is already a clone)
        return steer.clampLength(0.0, this.maxForce)
    }

    /**
     * @brief[zh-cn] 更新位置
     * @param[zh-cn] dt 时间步长
     * cfg 鸟群配置
     *
     * @brief[en] Update position
     * @param[en] dt Time step
     * cfg Flock configuration
     */
    public func update(dt: Float64, cfg: FlockConfig): Unit {
        // 限制加速度
        this.acc.clampLength(0.0, this.maxForce)
        // 更新速度与位置: vel += acc * dt
        this.vel.add(this.acc.clone().multiplyScalar(dt))
        this.vel.clampLength(0.0, this.maxSpeed)
        // pos += vel * dt
        this.pos.add(this.vel.clone().multiplyScalar(dt))

        // 环绕
        if (this.pos.x < 0.0) { this.pos.x += cfg.worldWidth }
        if (this.pos.x >= cfg.worldWidth) { this.pos.x -= cfg.worldWidth }
        if (this.pos.y < 0.0) { this.pos.y += cfg.worldHeight }
        if (this.pos.y >= cfg.worldHeight) { this.pos.y -= cfg.worldHeight }

        // 重置加速度
        this.acc.set(0.0, 0.0)
    }

    /**
     * @brief[zh-cn] 根据邻居计算三大行为的力
     * @param[zh-cn] boids 所有鸟群个体
     * cfg 鸟群配置
     *
     * @brief[en] Compute the three behavioral forces based on neighbors
     * @param[en] boids All boid individuals
     * cfg Flock configuration
     */
    public func flock(boids: Array<Boid>, cfg: FlockConfig): Unit {
        var alignSum = Vector2(0.0, 0.0)
        var alignCount = 0

        var cohesionSum = Vector2(0.0, 0.0)
        var cohesionCount = 0

        var separationSum = Vector2(0.0, 0.0)
        var separationCount = 0

        for (other in boids) {
            if (refEq(other, this)) { continue }
            let d = this.pos.distanceTo(other.pos)

            if (d < cfg.alignRadius) {
                alignSum.add(other.vel)
                alignCount += 1
            }
            if (d < cfg.cohesionRadius) {
                cohesionSum.add(other.pos)
                cohesionCount += 1
            }
            if (d < cfg.separationRadius && d > 0.0) {
                // 远离很近的邻居，距离越近作用越强
                let diff = this.pos.clone().sub(other.pos)
                let normalized = diff.normalize()
                normalized.multiplyScalar(1.0 / d)
                separationSum.add(normalized)
                separationCount += 1
            }
        }

        // 对齐力
        if (alignCount > 0) {
            let avgHeading = alignSum.multiplyScalar(1.0 / Float64(alignCount))
            let alignForce = steerTowards(avgHeading)
            alignForce.multiplyScalar(cfg.alignWeight)
            applyForce(alignForce)
        }

        // 聚合力
        if (cohesionCount > 0) {
            let avgPos = cohesionSum.multiplyScalar(1.0 / Float64(cohesionCount))
            let toCenter = avgPos.sub(this.pos)
            let cohesionForce = steerTowards(toCenter)
            cohesionForce.multiplyScalar(cfg.cohesionWeight)
            applyForce(cohesionForce)
        }

        // 分离力
        if (separationCount > 0) {
            let sep = separationSum.multiplyScalar(1.0 / Float64(separationCount))
            let separationForce = steerTowards(sep)
            separationForce.multiplyScalar(cfg.separationWeight)
            applyForce(separationForce)
        }
    }
}

/**
 * @brief[zh-cn] 鸟群（管理所有 Boid）
 *
 * @brief[en] Flock (manages all Boids)
 */
public class Flock {
    /**
     * @brief[zh-cn] 所有鸟群个体
     *
     * @brief[en] All boid individuals
     */
    public var boids: Array<Boid>

    /**
     * @brief[zh-cn] 鸟群配置
     *
     * @brief[en] Flock configuration
     */
    public var cfg: FlockConfig

    /**
     * @brief[zh-cn] 构造鸟群
     * @param[zh-cn] boids 鸟群个体数组
     * cfg 鸟群配置
     *
     * @brief[en] Construct a flock
     * @param[en] boids Array of boid individuals
     * cfg Flock configuration
     */
    public init(boids: Array<Boid>, cfg: FlockConfig) {
        this.boids = boids
        this.cfg = cfg
    }

    /**
     * @brief[zh-cn] 单步推进
     * @param[zh-cn] dt 时间步长
     *
     * @brief[en] Advance one simulation step
     * @param[en] dt Time step
     */
    public func step(dt: Float64): Unit {
        // 先计算所有 boid 的群体力
        for (b in boids) {
            b.flock(boids, cfg)
        }
        // 再更新所有 boid
        for (b in boids) {
            b.update(dt, cfg)
        }
    }

    /**
     * @brief[zh-cn] 计算群体质心
     * @return[zh-cn] 质心位置
     *
     * @brief[en] Compute the center of mass of the flock
     * @return[en] Center of mass position
     */
    public func centerOfMass(): Vector2 {
        var sumX = 0.0
        var sumY = 0.0
        for (b in boids) {
            sumX += b.pos.x
            sumY += b.pos.y
        }
        return Vector2(sumX / Float64(boids.size), sumY / Float64(boids.size))
    }

    /**
     * @brief[zh-cn] 计算平均速度
     * @return[zh-cn] 平均速度
     *
     * @brief[en] Compute the average speed
     * @return[en] Average speed
     */
    public func averageSpeed(): Float64 {
        var s = 0.0
        for (b in boids) {
            s += b.vel.length()
        }
        return s / Float64(boids.size)
    }

    /**
     * @brief[zh-cn] 计算平均最近邻居距离
     * @return[zh-cn] 平均最近邻居距离
     *
     * @brief[en] Compute the average nearest neighbor distance
     * @return[en] Average nearest neighbor distance
     */
    public func averageNeighborDistance(): Float64 {
        var sum = 0.0
        for (b in boids) {
            var minD = Float64.Inf
            for (o in boids) {
                if (refEq(b, o)) { continue }
                let d = b.pos.distanceTo(o.pos)
                if (d < minD) { minD = d }
            }
            sum += minD
        }
        return sum / Float64(boids.size)
    }
}
