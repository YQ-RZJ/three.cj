# 类
## class UiDrawList
```cj
public class UiDrawList
```
ImGui DrawList 封装类

### func addBezierCubic\(Vector2,Vector2,Vector2,Vector2,UInt32,Float32,Int32\)
```cj
public func addBezierCubic(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, col: UInt32, thickness!: Float32 = 1.0, numSegments!: Int32 = 0): Unit
```
绘制三次贝塞尔曲线

参数: 

|名称|类型|描述|
|---|---|---|
|p1|Vector2|控制点 1|
|p2|Vector2|控制点 2|
|p3|Vector2|控制点 3|
|p4|Vector2|控制点 4|
|col|UInt32||
|thickness|Float32||
|numSegments|Int32||

### func addBezierQuadratic\(Vector2,Vector2,Vector2,UInt32,Float32,Int32\)
```cj
public func addBezierQuadratic(p1: Vector2, p2: Vector2, p3: Vector2, col: UInt32, thickness!: Float32 = 1.0, numSegments!: Int32 = 0): Unit
```
绘制二次贝塞尔曲线

参数: 

|名称|类型|描述|
|---|---|---|
|p1|Vector2|控制点 1|
|p2|Vector2|控制点 2|
|p3|Vector2|控制点 3|
|col|UInt32||
|thickness|Float32||
|numSegments|Int32||

### func addCircleFilled\(Vector2,Float32,UInt32,Int32\)
```cj
public func addCircleFilled(center: Vector2, radius: Float32, col: UInt32, numSegments!: Int32 = 0): Unit
```
绘制填充圆形

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector2|圆心|
|radius|Float32||
|col|UInt32||
|numSegments|Int32||

### func addCircle\(Vector2,Float32,UInt32,Int32,Float32\)
```cj
public func addCircle(center: Vector2, radius: Float32, col: UInt32, numSegments!: Int32 = 0, thickness!: Float32 = 1.0): Unit
```
绘制圆形边框

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector2|圆心|
|radius|Float32||
|col|UInt32||
|numSegments|Int32||
|thickness|Float32||

### func addConcavePolyFilled\(CPointer<ImVec2>,Int32,UInt32\)
```cj
public func addConcavePolyFilled(points: CPointer < ImVec2 >, numPoints: Int32, col: UInt32): Unit
```
绘制凹多边形填充

参数: 

|名称|类型|描述|
|---|---|---|
|points|CPointer<ImVec2>||
|numPoints|Int32||
|col|UInt32||

### func addConvexPolyFilled\(CPointer<ImVec2>,Int32,UInt32\)
```cj
public func addConvexPolyFilled(points: CPointer < ImVec2 >, numPoints: Int32, col: UInt32): Unit
```
绘制凸多边形填充

参数: 

|名称|类型|描述|
|---|---|---|
|points|CPointer<ImVec2>||
|numPoints|Int32||
|col|UInt32||

### func addEllipseFilled\(Vector2,Vector2,UInt32,Float32,Int32\)
```cj
public func addEllipseFilled(center: Vector2, radius: Vector2, col: UInt32, rot!: Float32 = 0.0, numSegments!: Int32 = 0): Unit
```
绘制填充椭圆

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector2|椭圆中心|
|radius|Vector2|椭圆半径（x, y 两个方向）|
|col|UInt32||
|rot|Float32||
|numSegments|Int32||

### func addEllipse\(Vector2,Vector2,UInt32,Float32,Int32,Float32\)
```cj
public func addEllipse(center: Vector2, radius: Vector2, col: UInt32, rot!: Float32 = 0.0, numSegments!: Int32 = 0, thickness!: Float32 = 1.0): Unit
```
绘制椭圆边框

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector2|椭圆中心|
|radius|Vector2|椭圆半径（x, y 两个方向）|
|col|UInt32||
|rot|Float32||
|numSegments|Int32||
|thickness|Float32||

### func addImageQuad\(CPointer<Unit>,Vector2,Vector2,Vector2,Vector2,ImVec2,ImVec2,ImVec2,ImVec2,UInt32\)
```cj
public func addImageQuad(texRef: CPointer < Unit >, a: Vector2, b: Vector2, c: Vector2, d: Vector2, uvA!: ImVec2 = ImVec2(0.0, 0.0), uvB!: ImVec2 = ImVec2(1.0, 0.0), uvC!: ImVec2 = ImVec2(1.0, 1.0), uvD!: ImVec2 = ImVec2(0.0, 1.0), tintCol!: UInt32 = 0xFFFFFFFF): Unit
```
绘制四点映射图片

参数: 

|名称|类型|描述|
|---|---|---|
|texRef|CPointer<Unit>|纹理引用指针|
|a|Vector2||
|b|Vector2||
|c|Vector2||
|d|Vector2||
|uvA|ImVec2||
|uvB|ImVec2||
|uvC|ImVec2||
|uvD|ImVec2||
|tintCol|UInt32||

### func addImageRounded\(CPointer<Unit>,Vector2,Vector2,Float32,ImVec2,ImVec2,UInt32\)
```cj
public func addImageRounded(texRef: CPointer < Unit >, pMin: Vector2, pMax: Vector2, rounding: Float32, uvMin!: ImVec2 = ImVec2(0.0, 0.0), uvMax!: ImVec2 = ImVec2(1.0, 1.0), tintCol!: UInt32 = 0xFFFFFFFF): Unit
```
绘制圆角图片

参数: 

|名称|类型|描述|
|---|---|---|
|texRef|CPointer<Unit>|纹理引用指针|
|pMin|Vector2|左上角|
|pMax|Vector2|右下角|
|rounding|Float32|圆角半径|
|uvMin|ImVec2||
|uvMax|ImVec2||
|tintCol|UInt32||

### func addImage\(CPointer<Unit>,Vector2,Vector2,ImVec2,ImVec2,UInt32\)
```cj
public func addImage(texRef: CPointer < Unit >, pMin: Vector2, pMax: Vector2, uvMin!: ImVec2 = ImVec2(0.0, 0.0), uvMax!: ImVec2 = ImVec2(1.0, 1.0), tintCol!: UInt32 = 0xFFFFFFFF): Unit
```
绘制图片

参数: 

|名称|类型|描述|
|---|---|---|
|texRef|CPointer<Unit>|纹理引用指针|
|pMin|Vector2|左上角|
|pMax|Vector2|右下角|
|uvMin|ImVec2|UV 左上角（默认 0,0）|
|uvMax|ImVec2|UV 右下角（默认 1,1）|
|tintCol|UInt32|色调颜色（默认白色=不着色）|

### func addLineH\(Float32,Float32,Float32,UInt32,Float32\)
```cj
public func addLineH(x1: Float32, x2: Float32, y: Float32, col: UInt32, thickness!: Float32 = 1.0): Unit
```
绘制水平线段

参数: 

|名称|类型|描述|
|---|---|---|
|x1|Float32||
|x2|Float32||
|y|Float32||
|col|UInt32||
|thickness|Float32||

### func addLineV\(Float32,Float32,Float32,UInt32,Float32\)
```cj
public func addLineV(y1: Float32, y2: Float32, x: Float32, col: UInt32, thickness!: Float32 = 1.0): Unit
```
绘制垂直线段

参数: 

|名称|类型|描述|
|---|---|---|
|y1|Float32||
|y2|Float32||
|x|Float32||
|col|UInt32||
|thickness|Float32||

### func addLine\(Vector2,Vector2,UInt32,Float32\)
```cj
public func addLine(p1: Vector2, p2: Vector2, col: UInt32, thickness!: Float32 = 1.0): Unit
```
绘制线条

参数: 

|名称|类型|描述|
|---|---|---|
|p1|Vector2|起点|
|p2|Vector2|终点|
|col|UInt32|颜色（IM_COL32 格式）|
|thickness|Float32|线宽|

### func addNgonFilled\(Vector2,Float32,UInt32,Int32\)
```cj
public func addNgonFilled(center: Vector2, radius: Float32, col: UInt32, numSides: Int32): Unit
```
绘制填充正多边形

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector2||
|radius|Float32||
|col|UInt32||
|numSides|Int32||

### func addNgon\(Vector2,Float32,UInt32,Int32,Float32\)
```cj
public func addNgon(center: Vector2, radius: Float32, col: UInt32, numSides: Int32, thickness!: Float32 = 1.0): Unit
```
绘制正多边形边框

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector2||
|radius|Float32||
|col|UInt32||
|numSides|Int32||
|thickness|Float32||

### func addPolyline\(CPointer<ImVec2>,Int32,UInt32,Float32,Int32\)
```cj
public func addPolyline(points: CPointer < ImVec2 >, numPoints: Int32, col: UInt32, thickness!: Float32 = 1.0, flags!: Int32 = 0): Unit
```
绘制折线（开放或闭合多边形）

参数: 

|名称|类型|描述|
|---|---|---|
|points|CPointer<ImVec2>|顶点数组|
|numPoints|Int32||
|col|UInt32|颜色|
|thickness|Float32|线宽|
|flags|Int32|ImDrawFlags|

### func addQuadFilled\(Vector2,Vector2,Vector2,Vector2,UInt32\)
```cj
public func addQuadFilled(a: Vector2, b: Vector2, c: Vector2, d: Vector2, col: UInt32): Unit
```
绘制填充四边形

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector2||
|b|Vector2||
|c|Vector2||
|d|Vector2||
|col|UInt32||

### func addQuad\(Vector2,Vector2,Vector2,Vector2,UInt32,Float32\)
```cj
public func addQuad(a: Vector2, b: Vector2, c: Vector2, d: Vector2, col: UInt32, thickness!: Float32 = 1.0): Unit
```
绘制四边形边框

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector2||
|b|Vector2||
|c|Vector2||
|d|Vector2||
|col|UInt32||
|thickness|Float32||

### func addRectFilledMultiColor\(Vector2,Vector2,UInt32,UInt32,UInt32,UInt32\)
```cj
public func addRectFilledMultiColor(min: Vector2, max: Vector2, colUprLeft: UInt32, colUprRight: UInt32, colBotRight: UInt32, colBotLeft: UInt32): Unit
```
绘制多色填充矩形

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector2|矩形最小点|
|max|Vector2|矩形最大点|
|colUprLeft|UInt32||
|colUprRight|UInt32||
|colBotRight|UInt32||
|colBotLeft|UInt32||

### func addRectFilled\(Vector2,Vector2,UInt32,Float32,Int32\)
```cj
public func addRectFilled(min: Vector2, max: Vector2, col: UInt32, rounding!: Float32 = 0.0, flags!: Int32 = 0): Unit
```
绘制填充矩形

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector2|矩形最小点|
|max|Vector2|矩形最大点|
|col|UInt32||
|rounding|Float32||
|flags|Int32||

### func addRect\(Vector2,Vector2,UInt32,Float32,Float32,Int32\)
```cj
public func addRect(min: Vector2, max: Vector2, col: UInt32, rounding!: Float32 = 0.0, thickness!: Float32 = 1.0, flags!: Int32 = 0): Unit
```
绘制矩形边框

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector2|矩形最小点|
|max|Vector2|矩形最大点|
|col|UInt32||
|rounding|Float32||
|thickness|Float32||
|flags|Int32||

### func addText\(Vector2,UInt32,String\)
```cj
public func addText(pos: Vector2, col: UInt32, text: String): Unit
```
绘制文本

参数: 

|名称|类型|描述|
|---|---|---|
|pos|Vector2|文本位置|
|col|UInt32||
|text|String||

### func addTriangleFilled\(Vector2,Vector2,Vector2,UInt32\)
```cj
public func addTriangleFilled(a: Vector2, b: Vector2, c: Vector2, col: UInt32): Unit
```
绘制填充三角形

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector2|顶点 A|
|b|Vector2|顶点 B|
|c|Vector2|顶点 C|
|col|UInt32||

### func addTriangle\(Vector2,Vector2,Vector2,UInt32,Float32\)
```cj
public func addTriangle(a: Vector2, b: Vector2, c: Vector2, col: UInt32, thickness!: Float32 = 1.0): Unit
```
绘制三角形边框

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector2|顶点 A|
|b|Vector2|顶点 B|
|c|Vector2|顶点 C|
|col|UInt32||
|thickness|Float32||

### func background\(\)
```cj
public static func background(): UiDrawList
```
获取背景 DrawList

返回: 

- UiDrawList 实例

### func channelsMerge\(\)
```cj
public func channelsMerge(): Unit
```
合并绘制通道

### func channelsSetCurrent\(Int32\)
```cj
public func channelsSetCurrent(channel: Int32): Unit
```
切换到指定通道

参数: 

|名称|类型|描述|
|---|---|---|
|channel|Int32|通道索引|

### func channelsSplit\(Int32\)
```cj
public func channelsSplit(channels: Int32): Unit
```
分割绘制通道

参数: 

|名称|类型|描述|
|---|---|---|
|channels|Int32|通道数量|

### func cloneOutput\(\)
```cj
public func cloneOutput(): CPointer < Unit >
```
克隆当前 DrawList 输出（绘制数据快照）

### func foreground\(\)
```cj
public static func foreground(): UiDrawList
```
获取前景 DrawList

返回: 

- UiDrawList 实例

### func getClipRectMax\(\)
```cj
public func getClipRectMax(): Vector2
```
获取剪裁矩形最大点

返回: 

- 最大点

### func getClipRectMin\(\)
```cj
public func getClipRectMin(): Vector2
```
获取剪裁矩形最小点

返回: 

- 最小点

### func init\(CPointer<Unit>\)
```cj
public init(dl!: CPointer < Unit >)
```


参数: 

|名称|类型|描述|
|---|---|---|
|dl|CPointer<Unit>||

### func isRectVisible\(Vector2,Vector2\)
```cj
public func isRectVisible(min: Vector2, max: Vector2): Bool
```
判断矩形是否可见

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector2|矩形最小点|
|max|Vector2|矩形最大点|

### func pathArcToFast\(Vector2,Float32,Int32,Int32\)
```cj
public func pathArcToFast(center: Vector2, radius: Float32, aMinOf12: Int32, aMaxOf12: Int32): Unit
```
快速路径圆弧（固定细分，更高效）

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector2||
|radius|Float32||
|aMinOf12|Int32||
|aMaxOf12|Int32||

### func pathArcTo\(Vector2,Float32,Float32,Float32,Int32\)
```cj
public func pathArcTo(center: Vector2, radius: Float32, aMin: Float32, aMax: Float32, numSegments!: Int32 = 0): Unit
```
路径圆弧

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector2|圆弧中心|
|radius|Float32||
|aMin|Float32||
|aMax|Float32||
|numSegments|Int32||

### func pathBezierCubicCurveTo\(Vector2,Vector2,Vector2,Int32\)
```cj
public func pathBezierCubicCurveTo(p2: Vector2, p3: Vector2, p4: Vector2, numSegments!: Int32 = 0): Unit
```
路径三次贝塞尔曲线

参数: 

|名称|类型|描述|
|---|---|---|
|p2|Vector2||
|p3|Vector2||
|p4|Vector2||
|numSegments|Int32||

### func pathBezierQuadraticCurveTo\(Vector2,Vector2,Int32\)
```cj
public func pathBezierQuadraticCurveTo(p2: Vector2, p3: Vector2, numSegments!: Int32 = 0): Unit
```
路径二次贝塞尔曲线

参数: 

|名称|类型|描述|
|---|---|---|
|p2|Vector2||
|p3|Vector2||
|numSegments|Int32||

### func pathClear\(\)
```cj
public func pathClear(): Unit
```
清空路径

### func pathEllipticalArcTo\(Vector2,Vector2,Float32,Float32,Float32,Int32\)
```cj
public func pathEllipticalArcTo(center: Vector2, radius: Vector2, rot: Float32, aMin: Float32, aMax: Float32, numSegments!: Int32 = 0): Unit
```
路径椭圆弧

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector2||
|radius|Vector2||
|rot|Float32||
|aMin|Float32||
|aMax|Float32||
|numSegments|Int32||

### func pathFillConcave\(UInt32\)
```cj
public func pathFillConcave(col: UInt32): Unit
```
路径填充（凹多边形）

参数: 

|名称|类型|描述|
|---|---|---|
|col|UInt32||

### func pathFillConvex\(UInt32\)
```cj
public func pathFillConvex(col: UInt32): Unit
```
路径填充（凸多边形）

参数: 

|名称|类型|描述|
|---|---|---|
|col|UInt32||

### func pathLineToMergeDuplicate\(Vector2\)
```cj
public func pathLineToMergeDuplicate(p: Vector2): Unit
```
路径画线到点（合并重复点）

参数: 

|名称|类型|描述|
|---|---|---|
|p|Vector2||

### func pathLineTo\(Vector2\)
```cj
public func pathLineTo(p: Vector2): Unit
```
路径画线到点

参数: 

|名称|类型|描述|
|---|---|---|
|p|Vector2|目标点|

### func pathMoveTo\(Vector2\)
```cj
public func pathMoveTo(p: Vector2): Unit
```
路径移动到点

参数: 

|名称|类型|描述|
|---|---|---|
|p|Vector2|目标点|

### func pathRect\(Vector2,Vector2,Float32,Int32\)
```cj
public func pathRect(min: Vector2, max: Vector2, rounding!: Float32 = 0.0, flags!: Int32 = 0): Unit
```
路径矩形

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector2|矩形最小点|
|max|Vector2|矩形最大点|
|rounding|Float32||
|flags|Int32||

### func pathStroke\(UInt32,Int32,Float32\)
```cj
public func pathStroke(col: UInt32, flags!: Int32 = 0, thickness!: Float32 = 1.0): Unit
```
路径描边

参数: 

|名称|类型|描述|
|---|---|---|
|col|UInt32||
|flags|Int32||
|thickness|Float32||

### func popClipRect\(\)
```cj
public func popClipRect(): Unit
```
弹出剪裁矩形

### func popTexture\(\)
```cj
public func popTexture(): Unit
```
弹出纹理

### func primQuadUV\(Vector2,Vector2,Vector2,Vector2,ImVec2,ImVec2,ImVec2,ImVec2,UInt32\)
```cj
public func primQuadUV(a: Vector2, b: Vector2, c: Vector2, d: Vector2, uvA: ImVec2, uvB: ImVec2, uvC: ImVec2, uvD: ImVec2, col: UInt32): Unit
```
添加原始四边形（带 UV）

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector2||
|b|Vector2||
|c|Vector2||
|d|Vector2||
|uvA|ImVec2||
|uvB|ImVec2||
|uvC|ImVec2||
|uvD|ImVec2||
|col|UInt32||

### func primRectUV\(Vector2,Vector2,ImVec2,ImVec2,UInt32\)
```cj
public func primRectUV(a: Vector2, c: Vector2, uvA: ImVec2, uvC: ImVec2, col: UInt32): Unit
```
添加原始矩形（带 UV）

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector2|左上角|
|c|Vector2|右下角|
|uvA|ImVec2|UV 左上|
|uvC|ImVec2|UV 右下|
|col|UInt32||

### func primRect\(Vector2,Vector2,UInt32\)
```cj
public func primRect(a: Vector2, c: Vector2, col: UInt32): Unit
```
添加原始矩形（无 UV 变换，最快）

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector2|左上角|
|c|Vector2|右下角|
|col|UInt32||

### func primReserve\(Int32,Int32\)
```cj
public func primReserve(vtxCount: Int32, idxCount: Int32): Unit
```
预分配顶点/索引缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|vtxCount|Int32|顶点数|
|idxCount|Int32|索引数|

### func primUnreserve\(Int32,Int32\)
```cj
public func primUnreserve(vtxCount: Int32, idxCount: Int32): Unit
```
取消预分配

参数: 

|名称|类型|描述|
|---|---|---|
|vtxCount|Int32||
|idxCount|Int32||

### func pushClipRect\(Vector2,Vector2,Bool\)
```cj
public func pushClipRect(min: Vector2, max: Vector2, intersectWithCurrent!: Bool = false): Unit
```
压入剪裁矩形

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector2|矩形最小点|
|max|Vector2|矩形最大点|
|intersectWithCurrent|Bool||

### func pushTexture\(CPointer<Unit>\)
```cj
public func pushTexture(texRef: CPointer < Unit >): Unit
```
压入纹理

参数: 

|名称|类型|描述|
|---|---|---|
|texRef|CPointer<Unit>||

### func window\(\)
```cj
public static func window(): UiDrawList
```
获取当前窗口 DrawList

返回: 

- UiDrawList 实例

