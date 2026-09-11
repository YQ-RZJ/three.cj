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
 * @file[zh-cn] earcut 多边形三角剖分算法
 * @brief[zh-cn] 移植自 mapbox/earcut v3.0.2 的多边形三角剖分算法
 * @explain[zh-cn] 
 * 使用双向循环链表（Node）表示多边形环。
 * 数据结构与算法实现与 JS earcut 等价。
 *
 * @file[en] Earcut Polygon Triangulation Algorithm
 * @brief[en] Polygon triangulation algorithm ported from mapbox/earcut v3.0.2
 * @explain[en] 
 * Uses a doubly circular linked list (Node) to represent polygon rings.
 * Data structure and algorithm implementation are equivalent to JS earcut.
 */
package three.rendering.geometry

import std.math.*
import std.collection.*
import std.sort.*

/**
 * @brief[zh-cn] 链表节点，表示多边形的一个顶点
 * @explain[zh-cn] 
 * 使用非可选引用 + valid 标志替代 Option 以简化链式访问。
 *
 * @brief[en] Linked list node representing a polygon vertex
 * @explain[en] 
 * Uses non-optional references + valid flag instead of Option to simplify chained access.
 */
class Node {
    /**
     * @brief[zh-cn] 顶点索引
     *
     * @brief[en] Vertex index
     */
    var i: Int64
    /**
     * @brief[zh-cn] X 坐标
     *
     * @brief[en] X coordinate
     */
    var x: Float64
    /**
     * @brief[zh-cn] Y 坐标
     *
     * @brief[en] Y coordinate
     */
    var y: Float64
    /**
     * @brief[zh-cn] 前驱节点
     *
     * @brief[en] Previous node
     */
    var prev: ?Node
    /**
     * @brief[zh-cn] 后继节点
     *
     * @brief[en] Next node
     */
    var next: ?Node
    /**
     * @brief[zh-cn] z-order 值
     *
     * @brief[en] z-order value
     */
    var z: Int64
    /**
     * @brief[zh-cn] z-order 链表前驱
     *
     * @brief[en] z-order list previous node
     */
    var prevZ: ?Node
    /**
     * @brief[zh-cn] z-order 链表后继
     *
     * @brief[en] z-order list next node
     */
    var nextZ: ?Node
    /**
     * @brief[zh-cn] 是否为 Steiner 点
     *
     * @brief[en] Whether this is a Steiner point
     */
    var steiner: Bool
    /**
     * @brief[zh-cn] 节点是否有效（非哨兵）
     *
     * @brief[en] Whether the node is valid (not a sentinel)
     */
    var valid: Bool

    /**
     * @brief[zh-cn] 构造链表节点
     * @param[zh-cn] i 顶点索引
     * x X 坐标
     * y Y 坐标
     * valid 是否有效，默认 true
     *
     * @brief[en] Constructs a linked list node
     * @param[en] i Vertex index
     * x X coordinate
     * y Y coordinate
     * valid Whether valid, default true
     */
    init(i: Int64, x: Float64, y: Float64, valid!: Bool = true) {
        this.i = i
        this.x = x
        this.y = y
        this.z = 0
        this.steiner = false
        this.valid = valid
        this.prev = None
        this.next = None
        this.prevZ = None
        this.nextZ = None
    }
}

/** 哨兵节点，用于表示空引用（valid=false：无效哨兵——insertNode 首节点走自闭环分支） */
let SENTINEL = Node(-1, 0.0, 0.0, valid: false)

/** 辅助函数，安全获取 Node 的 prev/next 等字段 */
func prevOf(n: Node): Node { return n.prev.getOrThrow() }
func nextOf(n: Node): Node { return n.next.getOrThrow() }
func prevZOf(n: Node): Node { return n.prevZ.getOrThrow() }
func nextZOf(n: Node): Node { return n.nextZ.getOrThrow() }


/**
 * 检查节点是否有效（非哨兵）
 */
func isValid(n: Node): Bool { return n.valid }

/**
 * 主入口：对多边形进行 earcut 三角剖分
 */
public func earcut(data: Array<Float64>, holeIndices: Array<Int64>, dim: Int64): Array<UInt32> {
    let hasHoles = holeIndices.size > 0
    let outerLen = if (hasHoles) { holeIndices[0] * dim } else { data.size }
    var outerNode = linkedList(data, 0, outerLen, dim, true)
    let result = ArrayList<UInt32>()

    if (!outerNode.valid || refEq(nextOf(outerNode), prevOf(outerNode))) {
        return result.toArray()
    }

    var minX = 0.0
    var minY = 0.0
    var invSize = 0.0

    if (hasHoles) {
        outerNode = eliminateHoles(data, holeIndices, outerNode, dim)
    }

    if (data.size > 80 * dim) {
        minX = data[0]; minY = data[1]
        var maxX = minX; var maxY = minY
        var i = dim
        while (i < outerLen) {
            let x = data[i]; let y = data[i + 1]
            if (x < minX) { minX = x }; if (y < minY) { minY = y }
            if (x > maxX) { maxX = x }; if (y > maxY) { maxY = y }
            i += dim
        }
        invSize = if (maxX - minX > maxY - minY) { maxX - minX } else { maxY - minY }
        invSize = if (invSize != 0.0) { 32767.0 / invSize } else { 0.0 }
    }

    earcutLinked(outerNode, result, dim, minX, minY, invSize, 0)
    return result.toArray()
}

/**
 * 从多边形点创建双向循环链表
 */
func linkedList(data: Array<Float64>, start: Int64, end: Int64, dim: Int64, clockwise: Bool): Node {
    var last = SENTINEL

    if (clockwise == (signedArea(data, start, end, dim) > 0.0)) {
        var i = start
        while (i < end) {
            last = insertNode(i / dim, data[i], data[i + 1], last)
            i += dim
        }
    } else {
        var i = end - dim
        while (i >= start) {
            last = insertNode(i / dim, data[i], data[i + 1], last)
            i -= dim
        }
    }

    if (last.valid && equals(last, nextOf(last))) {
        removeNode(last)
        if (nextOf(last).valid) { last = nextOf(last) }
    }

    return last
}

/**
 * 消除共线或重复点
 */
func filterPoints(start: Node): Node {
    var p = start
    var endNode = start
    var again = true
    while (again) {
        again = false
        if (!p.steiner && (equals(p, nextOf(p)) || area(prevOf(p), p, nextOf(p)) == 0.0)) {
            removeNode(p)
            p = prevOf(p)
            endNode = p
            if (refEq(nextOf(p), p)) { break }
            again = true
        } else {
            p = nextOf(p)
        }
        if (refEq(p, endNode)) { break }
    }
    return endNode
}

/**
 * 主耳切三角剖分循环
 */
func earcutLinked(ear: Node, triangles: ArrayList<UInt32>, dim: Int64, minX: Float64, minY: Float64, invSize: Float64, pass: Int64): Unit {
    if (pass == 0 && invSize > 0.0) { indexCurve(ear, minX, minY, invSize) }

    var earNode = ear
    let stop = earNode

    while (!refEq(prevOf(earNode), nextOf(earNode))) {
        let prev = prevOf(earNode)
        let next = nextOf(earNode)

        if (if (invSize > 0.0) { isEarHashed(earNode, minX, minY, invSize) } else { isEar(earNode) }) {
            triangles.add(UInt32(prev.i))
            triangles.add(UInt32(earNode.i))
            triangles.add(UInt32(next.i))
            removeNode(earNode)
            earNode = nextOf(next)
            continue
        }

        earNode = next

        if (refEq(earNode, stop)) {
            if (pass == 0) { earcutLinked(filterPoints(earNode), triangles, dim, minX, minY, invSize, 1) }
            else if (pass == 1) { let cured = cureLocalIntersections(filterPoints(earNode), triangles); earcutLinked(cured, triangles, dim, minX, minY, invSize, 2) }
            else if (pass == 2) { splitEarcut(earNode, triangles, dim, minX, minY, invSize) }
            break
        }
    }
}

/**
 * 判断一个节点能否形成耳切三角形
 */
func isEar(ear: Node): Bool {
    let a = prevOf(ear); let b = ear; let c = nextOf(ear)
    if (area(a, b, c) >= 0.0) { return false }
    let ax = a.x; let bx = b.x; let cx = c.x
    let ay = a.y; let by = b.y; let cy = c.y
    let x0 = min(ax, bx, cx); let y0 = min(ay, by, cy)
    let x1 = max(ax, bx, cx); let y1 = max(ay, by, cy)
    var p = nextOf(c)
    while (!refEq(p, a)) {
        if (p.x >= x0 && p.x <= x1 && p.y >= y0 && p.y <= y1 &&
            pointInTriangleExceptFirst(ax, ay, bx, by, cx, cy, p.x, p.y) &&
            area(prevOf(p), p, nextOf(p)) >= 0.0) { return false }
        p = nextOf(p)
    }
    return true
}

/**
 * 使用 z-order 哈希加速的耳切判断
 */
func isEarHashed(ear: Node, minX: Float64, minY: Float64, invSize: Float64): Bool {
    let a = prevOf(ear); let b = ear; let c = nextOf(ear)
    if (area(a, b, c) >= 0.0) { return false }
    let ax = a.x; let bx = b.x; let cx = c.x
    let ay = a.y; let by = b.y; let cy = c.y
    let x0 = min(ax, bx, cx); let y0 = min(ay, by, cy)
    let x1 = max(ax, bx, cx); let y1 = max(ay, by, cy)
    let minZ = zOrder(x0, y0, minX, minY, invSize)
    let maxZ = zOrder(x1, y1, minX, minY, invSize)
    var p = prevZOf(ear); var n = nextZOf(ear)

    while (p.valid && p.z >= minZ && n.valid && n.z <= maxZ) {
        if (p.x >= x0 && p.x <= x1 && p.y >= y0 && p.y <= y1 && !refEq(p, a) && !refEq(p, c) &&
            pointInTriangleExceptFirst(ax, ay, bx, by, cx, cy, p.x, p.y) && area(prevOf(p), p, nextOf(p)) >= 0.0) { return false }
        p = prevZOf(p)
        if (n.x >= x0 && n.x <= x1 && n.y >= y0 && n.y <= y1 && !refEq(n, a) && !refEq(n, c) &&
            pointInTriangleExceptFirst(ax, ay, bx, by, cx, cy, n.x, n.y) && area(prevOf(n), n, nextOf(n)) >= 0.0) { return false }
        n = nextZOf(n)
    }
    while (p.valid && p.z >= minZ) {
        if (p.x >= x0 && p.x <= x1 && p.y >= y0 && p.y <= y1 && !refEq(p, a) && !refEq(p, c) &&
            pointInTriangleExceptFirst(ax, ay, bx, by, cx, cy, p.x, p.y) && area(prevOf(p), p, nextOf(p)) >= 0.0) { return false }
        p = prevZOf(p)
    }
    while (n.valid && n.z <= maxZ) {
        if (n.x >= x0 && n.x <= x1 && n.y >= y0 && n.y <= y1 && !refEq(n, a) && !refEq(n, c) &&
            pointInTriangleExceptFirst(ax, ay, bx, by, cx, cy, n.x, n.y) && area(prevOf(n), n, nextOf(n)) >= 0.0) { return false }
        n = nextZOf(n)
    }
    return true
}

/**
 * 修复局部自交点
 */
func cureLocalIntersections(start: Node, triangles: ArrayList<UInt32>): Node {
    var p = start
    var done = false
    while (!done) {
        let a = prevOf(p); let b = nextOf(nextOf(p))
        if (!equals(a, b) && intersects(a, p, nextOf(p), b) && locallyInside(a, b) && locallyInside(b, a)) {
            triangles.add(UInt32(a.i)); triangles.add(UInt32(p.i)); triangles.add(UInt32(b.i))
            removeNode(p); removeNode(nextOf(p))
            p = b
            done = true
        }
        p = nextOf(p)
        if (refEq(p, start)) { break }
    }
    return filterPoints(p)
}

/**
 * 将多边形分割为两个独立环并分别三角剖分
 */
func splitEarcut(start: Node, triangles: ArrayList<UInt32>, dim: Int64, minX: Float64, minY: Float64, invSize: Float64): Unit {
    var a = start
    var found = false
    while (!found) {
        var b = nextOf(nextOf(a))
        while (!refEq(b, prevOf(a))) {
            if (a.i != b.i && isValidDiagonal(a, b)) {
                let c = splitPolygon(a, b)
                let aFiltered = filterPoints(a)
                let cFiltered = filterPoints(c)
                earcutLinked(aFiltered, triangles, dim, minX, minY, invSize, 0)
                earcutLinked(cFiltered, triangles, dim, minX, minY, invSize, 0)
                found = true
                break
            }
            b = nextOf(b)
        }
        a = nextOf(a)
        if (refEq(a, start)) { break }
    }
}

/**
 * 将孔洞合并到外环中
 */
func eliminateHoles(data: Array<Float64>, holeIndices: Array<Int64>, outerNode: Node, dim: Int64): Node {
    let queue = ArrayList<Node>()
    var outer = outerNode

    for (i in 0..holeIndices.size) {
        let start = holeIndices[i] * dim
        let end = if (i < holeIndices.size - 1) { holeIndices[i + 1] * dim } else { data.size }
        let list = linkedList(data, start, end, dim, false)
        if (refEq(list, nextOf(list))) { list.steiner = true }
        queue.add(getLeftmost(list))
    }

    sort(queue, by: { a: Node, b: Node =>
        if (a.x < b.x) { Ordering.LT }
        else if (a.x > b.x) { Ordering.GT }
        else if (a.y < b.y) { Ordering.LT }
        else if (a.y > b.y) { Ordering.GT }
        else {
            let aSlope = (nextOf(a).y - a.y) / (nextOf(a).x - a.x)
            let bSlope = (nextOf(b).y - b.y) / (nextOf(b).x - b.x)
            if (aSlope < bSlope) { Ordering.LT }
            else if (aSlope > bSlope) { Ordering.GT }
            else { Ordering.EQ }
        }
    })

    for (i in 0..queue.size) { outer = eliminateHole(queue[i], outer) }
    return outer
}

/**
 * 将单个孔洞通过桥接边合并到外环
 */
func eliminateHole(hole: Node, outerNode: Node): Node {
    let bridge = findHoleBridge(hole, outerNode)
    if (!bridge.valid) { return outerNode }
    let bridgeReverse = splitPolygon(bridge, hole)
    filterPoints(bridgeReverse)
    return filterPoints(bridge)
}

/**
 * 寻找连接孔洞与外环的最优桥接点
 */
func findHoleBridge(hole: Node, outerNode: Node): Node {
    var p = outerNode
    let hx = hole.x; let hy = hole.y
    var qx = -Float64.Max
    var m = SENTINEL

    if (equals(hole, p)) { return p }

    var done = false
    while (!done) {
        if (!refEq(nextOf(p), SENTINEL) && equals(hole, nextOf(p))) { return nextOf(p) }
        if (!refEq(nextOf(p), SENTINEL) && hy <= p.y && hy >= nextOf(p).y && nextOf(p).y != p.y) {
            let x = p.x + (hy - p.y) * (nextOf(p).x - p.x) / (nextOf(p).y - p.y)
            if (x <= hx && x > qx) {
                qx = x
                m = if (p.x < nextOf(p).x) { p } else { nextOf(p) }
                if (x == hx) { return m }
            }
        }
        p = nextOf(p)
        if (refEq(p, outerNode)) { done = true }
    }

    if (!m.valid) { return SENTINEL }

    let stop = m; let mx = m.x; let my = m.y
    var tanMin = Float64.Max
    p = m
    done = false
    while (!done) {
        if (hx >= p.x && p.x >= mx && hx != p.x &&
            pointInTriangle(if (hy < my) { hx } else { qx }, hy, mx, my, if (hy < my) { qx } else { hx }, hy, p.x, p.y)) {
            let tan = abs(hy - p.y) / (hx - p.x)
            if (tan < tanMin || (tan == tanMin && (p.x > m.x || (p.x == m.x && sectorContainsSector(m, p))))) {
                if (locallyInside(p, hole)) { m = p; tanMin = tan }
            }
        }
        p = nextOf(p)
        if (refEq(p, stop)) { done = true }
    }
    return m
}

/**
 * 判断 m 的扇形是否包含 p 的扇形
 */
func sectorContainsSector(m: Node, p: Node): Bool {
    return area(prevOf(m), m, prevOf(p)) < 0.0 && area(nextOf(p), m, nextOf(m)) < 0.0
}

/**
 * 建立 z-order 索引
 */
func indexCurve(start: Node, minX: Float64, minY: Float64, invSize: Float64): Unit {
    var p = start
    var done = false
    while (!done) {
        if (p.z == 0) { p.z = zOrder(p.x, p.y, minX, minY, invSize) }
        p.prevZ = Some(prevOf(p)); p.nextZ = Some(nextOf(p))
        p = nextOf(p)
        if (refEq(p, start)) { done = true }
    }
    p.prevZ = Some(SENTINEL); p.prevZ = Some(SENTINEL)
    sortLinked(start)
}

/**
 * 链表归并排序
 */
func sortLinked(list: Node): Node {
    var inSize = 1
    var result = list
    var numMerges = 0
    var outerDone = false
    while (!outerDone) {
        var p = result; result = SENTINEL; var tail = SENTINEL; numMerges = 0
        while (p.valid) {
            numMerges++
            var q = p; var pSize = 0
            for (i in 0..inSize) { pSize++; if (q.valid) { q = nextZOf(q) }; if (!q.valid) { break } }
            var qSize = inSize
            while (pSize > 0 || (qSize > 0 && q.valid)) {
                var e = SENTINEL
                if (pSize != 0 && (qSize == 0 || !q.valid || p.z <= q.z)) { e = p; if (p.valid) { p = nextZOf(p) }; pSize-- }
                else { e = q; if (q.valid) { q = nextZOf(q) }; qSize-- }
                if (tail.valid) { tail.nextZ = Some(e) } else { result = e }
                e.prevZ = Some(tail); tail = e
            }
            p = q
        }
        tail.nextZ = Some(SENTINEL); inSize *= 2
        if (numMerges <= 1) { outerDone = true }
    }
    return result
}

/**
 * 计算 z-order 值
 */
func zOrder(x: Float64, y: Float64, minX: Float64, minY: Float64, invSize: Float64): Int64 {
    var xScaled: Int64 = Int64((x - minX) * invSize)
    var yScaled: Int64 = Int64((y - minY) * invSize)
    xScaled = (xScaled | (xScaled << 8)) & 0x00FF00FF
    xScaled = (xScaled | (xScaled << 4)) & 0x0F0F0F0F
    xScaled = (xScaled | (xScaled << 2)) & 0x33333333
    xScaled = (xScaled | (xScaled << 1)) & 0x55555555
    yScaled = (yScaled | (yScaled << 8)) & 0x00FF00FF
    yScaled = (yScaled | (yScaled << 4)) & 0x0F0F0F0F
    yScaled = (yScaled | (yScaled << 2)) & 0x33333333
    yScaled = (yScaled | (yScaled << 1)) & 0x55555555
    return xScaled | (yScaled << 1)
}

/**
 * 找到多边形环的最左节点
 */
func getLeftmost(start: Node): Node {
    var p = start; var leftmost = start
    var done = false
    while (!done) {
        if (p.x < leftmost.x || (p.x == leftmost.x && p.y < leftmost.y)) { leftmost = p }
        p = nextOf(p)
        if (refEq(p, start)) { done = true }
    }
    return leftmost
}

/**
 * 判断点是否在凸三角形内
 */
func pointInTriangle(ax: Float64, ay: Float64, bx: Float64, by: Float64, cx: Float64, cy: Float64, px: Float64, py: Float64): Bool {
    return (cx - px) * (ay - py) >= (ax - px) * (cy - py) &&
           (ax - px) * (by - py) >= (bx - px) * (ay - py) &&
           (bx - px) * (cy - py) >= (cx - px) * (by - py)
}

/**
 * 判断点是否在凸三角形内，但不等于第一个顶点
 */
func pointInTriangleExceptFirst(ax: Float64, ay: Float64, bx: Float64, by: Float64, cx: Float64, cy: Float64, px: Float64, py: Float64): Bool {
    return !(ax == px && ay == py) && pointInTriangle(ax, ay, bx, by, cx, cy, px, py)
}

/**
 * 判断两个节点之间的对角线是否有效
 */
func isValidDiagonal(a: Node, b: Node): Bool {
    return nextOf(a).i != b.i && prevOf(a).i != b.i && !intersectsPolygon(a, b) &&
           (locallyInside(a, b) && locallyInside(b, a) && middleInside(a, b) ||
            equals(a, b) && area(prevOf(a), a, nextOf(a)) > 0.0 && area(prevOf(b), b, nextOf(b)) > 0.0)
}

/**
 * 三角形有符号面积
 */
func area(p: Node, q: Node, r: Node): Float64 {
    return (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
}

/**
 * 判断两个节点是否坐标相等
 */
func equals(p1: Node, p2: Node): Bool {
    return p1.x == p2.x && p1.y == p2.y
}

/**
 * 判断两条线段是否相交
 */
func intersects(p1: Node, q1: Node, p2: Node, q2: Node): Bool {
    let o1 = sign(area(p1, q1, p2)); let o2 = sign(area(p1, q1, q2))
    let o3 = sign(area(p2, q2, p1)); let o4 = sign(area(p2, q2, q1))
    if (o1 != o2 && o3 != o4) { return true }
    if (o1 == 0 && onSegment(p1, p2, q1)) { return true }
    if (o2 == 0 && onSegment(p1, q2, q1)) { return true }
    if (o3 == 0 && onSegment(p2, p1, q2)) { return true }
    if (o4 == 0 && onSegment(p2, q1, q2)) { return true }
    return false
}

/**
 * 判断共线点 q 是否在线段 pr 上
 */
func onSegment(p: Node, q: Node, r: Node): Bool {
    return q.x <= max(p.x, r.x) && q.x >= min(p.x, r.x) && q.y <= max(p.y, r.y) && q.y >= min(p.y, r.y)
}

/**
 * 数值符号
 */
func sign(num: Float64): Int64 {
    return if (num > 0.0) { 1 } else if (num < 0.0) { -1 } else { 0 }
}

/**
 * 判断多边形对角线是否与任何多边形边相交
 */
func intersectsPolygon(a: Node, b: Node): Bool {
    var p = a
    var done = false
    while (!done) {
        if (p.i != a.i && nextOf(p).i != a.i && p.i != b.i && nextOf(p).i != b.i && intersects(p, nextOf(p), a, b)) { return true }
        p = nextOf(p)
        if (refEq(p, a)) { done = true }
    }
    return false
}

/**
 * 判断对角线是否在局部内部
 */
func locallyInside(a: Node, b: Node): Bool {
    return if (area(prevOf(a), a, nextOf(a)) < 0.0) {
        area(a, b, nextOf(a)) >= 0.0 && area(a, prevOf(a), b) >= 0.0
    } else {
        area(a, b, prevOf(a)) < 0.0 || area(a, nextOf(a), b) < 0.0
    }
}

/**
 * 判断对角线中点是否在多边形内部
 */
func middleInside(a: Node, b: Node): Bool {
    var p = a; var inside = false
    let px = (a.x + b.x) / 2.0; let py = (a.y + b.y) / 2.0
    var done = false
    while (!done) {
        if (((p.y > py) != (nextOf(p).y > py)) && nextOf(p).y != p.y &&
            (px < (nextOf(p).x - p.x) * (py - p.y) / (nextOf(p).y - p.y) + p.x)) { inside = !inside }
        p = nextOf(p)
        if (refEq(p, a)) { done = true }
    }
    return inside
}

/**
 * 用桥接边连接两个顶点
 */
func splitPolygon(a: Node, b: Node): Node {
    let a2 = Node(a.i, a.x, a.y); let b2 = Node(b.i, b.x, b.y)
    let an = nextOf(a); let bp = prevOf(b)
    a.next = Some(b); b.prev = Some(a)
    a2.next = Some(an); an.prev = Some(a2)
    b2.next = Some(a2); a2.prev = Some(b2)
    bp.next = Some(b2); b2.prev = Some(bp)
    return b2
}

/**
 * 创建节点并插入链表
 */
func insertNode(i: Int64, x: Float64, y: Float64, last: Node): Node {
    let p = Node(i, x, y)
    if (!last.valid) {
        p.prev = Some(p); p.next = Some(p)
    } else {
        p.next = Some(nextOf(last)); p.prev = Some(last)
        nextOf(last).prev = Some(p); last.next = Some(p)
    }
    return p
}

/**
 * 从链表中移除节点
 */
func removeNode(p: Node): Unit {
    nextOf(p).prev = Some(prevOf(p))
    prevOf(p).next = Some(nextOf(p))
    // Z 序链表：边界节点（nextZ/prevZ 为 None）时按 JS undefined 语义跳过对应更新
    if (p.prevZ.isSome() && p.nextZ.isSome()) {
        prevZOf(p).nextZ = nextZOf(p)
        nextZOf(p).prevZ = prevZOf(p)
    } else if (p.prevZ.isSome()) {
        prevZOf(p).nextZ = None
    } else if (p.nextZ.isSome()) {
        nextZOf(p).prevZ = None
    }
}

/**
 * 计算有符号面积
 */
func signedArea(data: Array<Float64>, start: Int64, end: Int64, dim: Int64): Float64 {
    var sum = 0.0; var j = end - dim; var i = start
    while (i < end) {
        sum += (data[j] - data[i]) * (data[i + 1] + data[j + 1])
        j = i; i += dim
    }
    return sum
}

/**
 * 返回三角剖分面积与多边形面积之间的百分比差异
 */
public func deviation(data: Array<Float64>, holeIndices: Array<Int64>, dim: Int64, triangles: Array<UInt32>): Float64 {
    let hasHoles = holeIndices.size > 0
    let outerLen = if (hasHoles) { holeIndices[0] * dim } else { data.size }
    var polygonArea = abs(signedArea(data, 0, outerLen, dim))
    if (hasHoles) {
        for (i in 0..holeIndices.size) {
            let start = holeIndices[i] * dim
            let end = if (i < holeIndices.size - 1) { holeIndices[i + 1] * dim } else { data.size }
            polygonArea -= abs(signedArea(data, start, end, dim))
        }
    }
    var trianglesArea = 0.0; var i = 0
    while (i < triangles.size) {
        let a = Int64(triangles[i]) * dim; let b = Int64(triangles[i + 1]) * dim; let c = Int64(triangles[i + 2]) * dim
        trianglesArea += abs((data[a] - data[c]) * (data[b + 1] - data[a + 1]) - (data[a] - data[b]) * (data[c + 1] - data[a + 1]))
        i += 3
    }
    return if (polygonArea == 0.0 && trianglesArea == 0.0) { 0.0 } else { abs((trianglesArea - polygonArea) / polygonArea) }
}

/**
 * Earcut 多边形三角剖分工具类
 *
 * 提供 earcut 算法的静态接口，将一个 2D 多边形（可能含孔洞）
 * 剖分为若干三角形，返回三角形顶点索引数组。
 *
 * 注意：本文件同时包含底层算法实现（earcut/deviation）与
 * Earcut 封装类（Windows 文件系统大小写不敏感，Earcut.cj 与
 * earcut.cj 实为同一文件，故合并于此）。
 *
 * 参见：https://github.com/mapbox/earcut
 */
public class Earcut {
    /**
     * @param[zh-cn] data 平面坐标数组，形如 [x0, y0, x1, y1, ...]
     * @param[zh-cn] holeIndices 孔洞起点的索引数组（每个元素表示一个孔洞在 data 中的起始顶点序号）
     * @param[zh-cn] dim 每个顶点的坐标分量数，默认 2（即 x、y）
     * @return[zh-cn] 三角面顶点索引数组，每 3 个连续数字表示一个三角形
     *
     * 对给定的 2D 点数组进行三角剖分
     *
     * @param[en] data Flat coordinate array, e.g. [x0, y0, x1, y1, ...]
     * @param[en] holeIndices Index array of hole starting points (each element indicates the starting vertex index of a hole in data)
     * @param[en] dim Number of coordinate components per vertex, default 2 (i.e. x, y)
     * @return[en] Array of triangle vertex indices, every 3 consecutive numbers represent a triangle
     *
     * Triangulate the given 2D point array
     */
    public static func triangulate(data: Array<Float64>, holeIndices: Array<Int64>, dim!: Int64 = 2): Array<UInt32> {
        return earcut(data, holeIndices, dim)
    }
}

