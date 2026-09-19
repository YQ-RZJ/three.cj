# Class
## class UiDrawList
```cj
public class UiDrawList
```
ImGui DrawList wrapper class

### func addBezierCubic\(Vector2,Vector2,Vector2,Vector2,UInt32,Float32,Int32\)
```cj
public func addBezierCubic(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, col: UInt32, thickness!: Float32 = 1.0, numSegments!: Int32 = 0): Unit
```
Draws a cubic Bézier curve

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p1|Vector2|Control point 1|
|p2|Vector2|Control point 2|
|p3|Vector2|Control point 3|
|p4|Vector2|Control point 4|
|col|UInt32|Color (IM_COL32 format)|
|thickness|Float32|Line width|
|numSegments|Int32|Segment count (0 = auto)|

### func addBezierQuadratic\(Vector2,Vector2,Vector2,UInt32,Float32,Int32\)
```cj
public func addBezierQuadratic(p1: Vector2, p2: Vector2, p3: Vector2, col: UInt32, thickness!: Float32 = 1.0, numSegments!: Int32 = 0): Unit
```
Draws a quadratic Bézier curve

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p1|Vector2|Control point 1|
|p2|Vector2|Control point 2|
|p3|Vector2|Control point 3|
|col|UInt32|Color (IM_COL32 format)|
|thickness|Float32|Line width|
|numSegments|Int32|Segment count (0 = auto)|

### func addCircleFilled\(Vector2,Float32,UInt32,Int32\)
```cj
public func addCircleFilled(center: Vector2, radius: Float32, col: UInt32, numSegments!: Int32 = 0): Unit
```
Draws a filled circle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector2|Center point|
|radius|Float32|Radius|
|col|UInt32|Color (IM_COL32 format)|
|numSegments|Int32|Segment count (0 = auto)|

### func addCircle\(Vector2,Float32,UInt32,Int32,Float32\)
```cj
public func addCircle(center: Vector2, radius: Float32, col: UInt32, numSegments!: Int32 = 0, thickness!: Float32 = 1.0): Unit
```
Draws a circle border

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector2|Center point|
|radius|Float32|Radius|
|col|UInt32|Color (IM_COL32 format)|
|numSegments|Int32|Segment count (0 = auto)|
|thickness|Float32|Line width|

### func addConcavePolyFilled\(PtrArray<ImVec2>,UInt32\)
```cj
public func addConcavePolyFilled(points: PtrArray < ImVec2 >, col: UInt32): Unit
```
Draws a concave polygon fill

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|PtrArray<ImVec2>|Vertex array|
|col|UInt32|Color (IM_COL32 format)|

### func addConvexPolyFilled\(PtrArray<ImVec2>,UInt32\)
```cj
public func addConvexPolyFilled(points: PtrArray < ImVec2 >, col: UInt32): Unit
```
Draws a convex polygon fill

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|PtrArray<ImVec2>|Vertex array|
|col|UInt32|Color (IM_COL32 format)|

### func addEllipseFilled\(Vector2,Vector2,UInt32,Float32,Int32\)
```cj
public func addEllipseFilled(center: Vector2, radius: Vector2, col: UInt32, rot!: Float32 = 0.0, numSegments!: Int32 = 0): Unit
```
Draws a filled ellipse

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector2|Ellipse center|
|radius|Vector2|Ellipse radius (x and y directions)|
|col|UInt32|Color (IM_COL32 format)|
|rot|Float32|Rotation angle (radians)|
|numSegments|Int32|Segment count (0 = auto)|

### func addEllipse\(Vector2,Vector2,UInt32,Float32,Int32,Float32\)
```cj
public func addEllipse(center: Vector2, radius: Vector2, col: UInt32, rot!: Float32 = 0.0, numSegments!: Int32 = 0, thickness!: Float32 = 1.0): Unit
```
Draws an ellipse border

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector2|Ellipse center|
|radius|Vector2|Ellipse radius (x and y directions)|
|col|UInt32|Color (IM_COL32 format)|
|rot|Float32|Rotation angle (radians)|
|numSegments|Int32|Segment count (0 = auto)|
|thickness|Float32|Line width|

### func addImageQuad\(VoidPtr,Vector2,Vector2,Vector2,Vector2,ImVec2,ImVec2,ImVec2,ImVec2,UInt32\)
```cj
public func addImageQuad(texRef: VoidPtr, a: Vector2, b: Vector2, c: Vector2, d: Vector2, uvA!: ImVec2 = ImVec2(0.0, 0.0), uvB!: ImVec2 = ImVec2(1.0, 0.0), uvC!: ImVec2 = ImVec2(1.0, 1.0), uvD!: ImVec2 = ImVec2(0.0, 1.0), tintCol!: UInt32 = 0xFFFFFFFF): Unit
```
Draws a quad-mapped image

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texRef|VoidPtr|Texture reference pointer|
|a|Vector2||
|b|Vector2||
|c|Vector2||
|d|Vector2||
|uvA|ImVec2||
|uvB|ImVec2||
|uvC|ImVec2||
|uvD|ImVec2||
|tintCol|UInt32|Tint color (default white = no tint)|

### func addImageRounded\(VoidPtr,Vector2,Vector2,Float32,ImVec2,ImVec2,UInt32\)
```cj
public func addImageRounded(texRef: VoidPtr, pMin: Vector2, pMax: Vector2, rounding: Float32, uvMin!: ImVec2 = ImVec2(0.0, 0.0), uvMax!: ImVec2 = ImVec2(1.0, 1.0), tintCol!: UInt32 = 0xFFFFFFFF): Unit
```
Draws a rounded image

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texRef|VoidPtr|Texture reference pointer|
|pMin|Vector2|Top-left corner|
|pMax|Vector2|Bottom-right corner|
|rounding|Float32|Corner rounding radius|
|uvMin|ImVec2|UV top-left (default 0,0)|
|uvMax|ImVec2|UV bottom-right (default 1,1)|
|tintCol|UInt32|Tint color (default white = no tint)|

### func addImage\(VoidPtr,Vector2,Vector2,ImVec2,ImVec2,UInt32\)
```cj
public func addImage(texRef: VoidPtr, pMin: Vector2, pMax: Vector2, uvMin!: ImVec2 = ImVec2(0.0, 0.0), uvMax!: ImVec2 = ImVec2(1.0, 1.0), tintCol!: UInt32 = 0xFFFFFFFF): Unit
```
Draws an image

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texRef|VoidPtr|Texture reference pointer|
|pMin|Vector2|Top-left corner|
|pMax|Vector2|Bottom-right corner|
|uvMin|ImVec2|UV top-left (default 0,0)|
|uvMax|ImVec2|UV bottom-right (default 1,1)|
|tintCol|UInt32|Tint color (default white=no tint)|

### func addLineH\(Float32,Float32,Float32,UInt32,Float32\)
```cj
public func addLineH(x1: Float32, x2: Float32, y: Float32, col: UInt32, thickness!: Float32 = 1.0): Unit
```
Draws a horizontal line segment

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x1|Float32|Start X|
|x2|Float32|End X|
|y|Float32|Line Y coordinate|
|col|UInt32|Color (IM_COL32 format)|
|thickness|Float32|Line width|

### func addLineV\(Float32,Float32,Float32,UInt32,Float32\)
```cj
public func addLineV(y1: Float32, y2: Float32, x: Float32, col: UInt32, thickness!: Float32 = 1.0): Unit
```
Draws a vertical line segment

Parameter: 

|Name|Type|Describe|
|---|---|---|
|y1|Float32|Start Y|
|y2|Float32|End Y|
|x|Float32|Line X coordinate|
|col|UInt32|Color (IM_COL32 format)|
|thickness|Float32|Line width|

### func addLine\(Vector2,Vector2,UInt32,Float32\)
```cj
public func addLine(p1: Vector2, p2: Vector2, col: UInt32, thickness!: Float32 = 1.0): Unit
```
Draws a line

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p1|Vector2|Start point|
|p2|Vector2|End point|
|col|UInt32|Color (IM_COL32 format)|
|thickness|Float32|Line width|

### func addNgonFilled\(Vector2,Float32,UInt32,Int32\)
```cj
public func addNgonFilled(center: Vector2, radius: Float32, col: UInt32, numSides: Int32): Unit
```
Draws a filled regular polygon

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector2|Center point|
|radius|Float32|Circumscribed circle radius|
|col|UInt32|Color (IM_COL32 format)|
|numSides|Int32|Number of sides|

### func addNgon\(Vector2,Float32,UInt32,Int32,Float32\)
```cj
public func addNgon(center: Vector2, radius: Float32, col: UInt32, numSides: Int32, thickness!: Float32 = 1.0): Unit
```
Draws a regular polygon border

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector2|Center point|
|radius|Float32|Circumscribed circle radius|
|col|UInt32|Color (IM_COL32 format)|
|numSides|Int32|Number of sides|
|thickness|Float32|Line width|

### func addPolyline\(PtrArray<ImVec2>,UInt32,Float32,Int32\)
```cj
public func addPolyline(points: PtrArray < ImVec2 >, col: UInt32, thickness!: Float32 = 1.0, flags!: Int32 = 0): Unit
```
Draws a polyline (open or closed polygon)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|PtrArray<ImVec2>|Vertex array|
|col|UInt32|Color|
|thickness|Float32|Line width|
|flags|Int32|ImDrawFlags|

### func addQuadFilled\(Vector2,Vector2,Vector2,Vector2,UInt32\)
```cj
public func addQuadFilled(a: Vector2, b: Vector2, c: Vector2, d: Vector2, col: UInt32): Unit
```
Draws a filled quad

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector2|Vertex A|
|b|Vector2|Vertex B|
|c|Vector2|Vertex C|
|d|Vector2|Vertex D|
|col|UInt32|Color (IM_COL32 format)|

### func addQuad\(Vector2,Vector2,Vector2,Vector2,UInt32,Float32\)
```cj
public func addQuad(a: Vector2, b: Vector2, c: Vector2, d: Vector2, col: UInt32, thickness!: Float32 = 1.0): Unit
```
Draws a quad border

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector2|Vertex A|
|b|Vector2|Vertex B|
|c|Vector2|Vertex C|
|d|Vector2|Vertex D|
|col|UInt32|Color (IM_COL32 format)|
|thickness|Float32|Line width|

### func addRectFilledMultiColor\(Vector2,Vector2,UInt32,UInt32,UInt32,UInt32\)
```cj
public func addRectFilledMultiColor(min: Vector2, max: Vector2, colUprLeft: UInt32, colUprRight: UInt32, colBotRight: UInt32, colBotLeft: UInt32): Unit
```
Draws a multi-color filled rectangle (one color per corner, linearly interpolated)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector2|Rectangle minimum|
|max|Vector2|Rectangle maximum|
|colUprLeft|UInt32|Top-left color|
|colUprRight|UInt32|Top-right color|
|colBotRight|UInt32|Bottom-right color|
|colBotLeft|UInt32|Bottom-left color|

### func addRectFilled\(Vector2,Vector2,UInt32,Float32,Int32\)
```cj
public func addRectFilled(min: Vector2, max: Vector2, col: UInt32, rounding!: Float32 = 0.0, flags!: Int32 = 0): Unit
```
Draws a filled rectangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector2|Rectangle minimum|
|max|Vector2|Rectangle maximum|
|col|UInt32|Color (IM_COL32 format)|
|rounding|Float32|Corner rounding radius (0 = sharp corners)|
|flags|Int32|ImDrawFlags (default 0)|

### func addRect\(Vector2,Vector2,UInt32,Float32,Float32,Int32\)
```cj
public func addRect(min: Vector2, max: Vector2, col: UInt32, rounding!: Float32 = 0.0, thickness!: Float32 = 1.0, flags!: Int32 = 0): Unit
```
Draws a rectangle border

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector2|Rectangle minimum|
|max|Vector2|Rectangle maximum|
|col|UInt32|Color (IM_COL32 format)|
|rounding|Float32|Corner rounding radius (0 = sharp corners)|
|thickness|Float32|Line width|
|flags|Int32|ImDrawFlags (default 0)|

### func addText\(Vector2,UInt32,String\)
```cj
public func addText(pos: Vector2, col: UInt32, text: String): Unit
```
Draws text

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pos|Vector2|Text position|
|col|UInt32|Color (IM_COL32 format)|
|text|String|Text content|

### func addTriangleFilled\(Vector2,Vector2,Vector2,UInt32\)
```cj
public func addTriangleFilled(a: Vector2, b: Vector2, c: Vector2, col: UInt32): Unit
```
Draws a filled triangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector2|Vertex A|
|b|Vector2|Vertex B|
|c|Vector2|Vertex C|
|col|UInt32|Color (IM_COL32 format)|

### func addTriangle\(Vector2,Vector2,Vector2,UInt32,Float32\)
```cj
public func addTriangle(a: Vector2, b: Vector2, c: Vector2, col: UInt32, thickness!: Float32 = 1.0): Unit
```
Draws a triangle border

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector2|Vertex A|
|b|Vector2|Vertex B|
|c|Vector2|Vertex C|
|col|UInt32|Color (IM_COL32 format)|
|thickness|Float32|Line width|

### func background\(\)
```cj
public static func background(): UiDrawList
```
Returns the background DrawList

Return: 

- UiDrawList instance

### func channelsMerge\(\)
```cj
public func channelsMerge(): Unit
```
Merges drawing channels

### func channelsSetCurrent\(Int32\)
```cj
public func channelsSetCurrent(channel: Int32): Unit
```
Switches to the specified channel

Parameter: 

|Name|Type|Describe|
|---|---|---|
|channel|Int32|Channel index|

### func channelsSplit\(Int32\)
```cj
public func channelsSplit(channels: Int32): Unit
```
Splits drawing channels

Parameter: 

|Name|Type|Describe|
|---|---|---|
|channels|Int32|Number of channels|

### func cloneOutput\(\)
```cj
public func cloneOutput(): VoidPtr
```
Clones the current DrawList output (drawing data snapshot)

Return: 

- Pointer to the cloned draw data

### func foreground\(\)
```cj
public static func foreground(): UiDrawList
```
Returns the foreground DrawList

Return: 

- UiDrawList instance

### func getClipRectMax\(\)
```cj
public func getClipRectMax(): Vector2
```
Returns the clip rectangle maximum

Return: 

- Maximum point

### func getClipRectMin\(\)
```cj
public func getClipRectMin(): Vector2
```
Returns the clip rectangle minimum

Return: 

- Minimum point

### func init\(VoidPtr\)
```cj
public init(dl!: VoidPtr)
```
Constructs from a raw ImDrawList pointer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dl|VoidPtr|Raw ImDrawList pointer|

### func isRectVisible\(Vector2,Vector2\)
```cj
public func isRectVisible(min: Vector2, max: Vector2): Bool
```
Determine whether the rectangle is visible

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector2|Rectangle minimum|
|max|Vector2|Rectangle maximum|

Return: 

- true if visible

### func pathArcToFast\(Vector2,Float32,Int32,Int32\)
```cj
public func pathArcToFast(center: Vector2, radius: Float32, aMinOf12: Int32, aMaxOf12: Int32): Unit
```
Fast path arc (fixed subdivisions, more efficient)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector2|Arc center|
|radius|Float32|Radius|
|aMinOf12|Int32|Start angle (in 1/12 circle units)|
|aMaxOf12|Int32|End angle (in 1/12 circle units)|

### func pathArcTo\(Vector2,Float32,Float32,Float32,Int32\)
```cj
public func pathArcTo(center: Vector2, radius: Float32, aMin: Float32, aMax: Float32, numSegments!: Int32 = 0): Unit
```
Draws a path arc

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector2|Arc center|
|radius|Float32|Radius|
|aMin|Float32|Start angle (radians)|
|aMax|Float32|End angle (radians)|
|numSegments|Int32|Segment count (0 = auto)|

### func pathBezierCubicCurveTo\(Vector2,Vector2,Vector2,Int32\)
```cj
public func pathBezierCubicCurveTo(p2: Vector2, p3: Vector2, p4: Vector2, numSegments!: Int32 = 0): Unit
```
Path cubic Bézier curve (starting from the current point)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p2|Vector2|Control point 2|
|p3|Vector2|Control point 3|
|p4|Vector2|End point|
|numSegments|Int32|Segment count (0 = auto)|

### func pathBezierQuadraticCurveTo\(Vector2,Vector2,Int32\)
```cj
public func pathBezierQuadraticCurveTo(p2: Vector2, p3: Vector2, numSegments!: Int32 = 0): Unit
```
Path quadratic Bézier curve (starting from the current point)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p2|Vector2|Control point 2|
|p3|Vector2|End point|
|numSegments|Int32|Segment count (0 = auto)|

### func pathClear\(\)
```cj
public func pathClear(): Unit
```
Clears the path

### func pathEllipticalArcTo\(Vector2,Vector2,Float32,Float32,Float32,Int32\)
```cj
public func pathEllipticalArcTo(center: Vector2, radius: Vector2, rot: Float32, aMin: Float32, aMax: Float32, numSegments!: Int32 = 0): Unit
```
Path elliptical arc

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector2|Ellipse center|
|radius|Vector2|Ellipse radius (x and y directions)|
|rot|Float32|Rotation angle (radians)|
|aMin|Float32|Start angle (radians)|
|aMax|Float32|End angle (radians)|
|numSegments|Int32|Segment count (0 = auto)|

### func pathFillConcave\(UInt32\)
```cj
public func pathFillConcave(col: UInt32): Unit
```
Path fill (concave polygon)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|col|UInt32|Color (IM_COL32 format)|

### func pathFillConvex\(UInt32\)
```cj
public func pathFillConvex(col: UInt32): Unit
```
Fills the path (convex polygon)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|col|UInt32|Color (IM_COL32 format)|

### func pathLineToMergeDuplicate\(Vector2\)
```cj
public func pathLineToMergeDuplicate(p: Vector2): Unit
```
Path line to point (merges duplicates)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|Vector2|Target point|

### func pathLineTo\(Vector2\)
```cj
public func pathLineTo(p: Vector2): Unit
```
Draws a line to a point on the path

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|Vector2|Target point|

### func pathMoveTo\(Vector2\)
```cj
public func pathMoveTo(p: Vector2): Unit
```
Moves path to a point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|Vector2|Target point|

### func pathRect\(Vector2,Vector2,Float32,Int32\)
```cj
public func pathRect(min: Vector2, max: Vector2, rounding!: Float32 = 0.0, flags!: Int32 = 0): Unit
```
Draws a path rectangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector2|Rectangle minimum|
|max|Vector2|Rectangle maximum|
|rounding|Float32|Corner rounding radius (0 = sharp corners)|
|flags|Int32|ImDrawFlags (default 0)|

### func pathStroke\(UInt32,Int32,Float32\)
```cj
public func pathStroke(col: UInt32, flags!: Int32 = 0, thickness!: Float32 = 1.0): Unit
```
Strokes the path

Parameter: 

|Name|Type|Describe|
|---|---|---|
|col|UInt32|Color (IM_COL32 format)|
|flags|Int32|ImDrawFlags (default 0)|
|thickness|Float32|Line width|

### func popClipRect\(\)
```cj
public func popClipRect(): Unit
```
Pops the clip rectangle

### func popTexture\(\)
```cj
public func popTexture(): Unit
```
Pops a texture

### func primQuadUV\(Vector2,Vector2,Vector2,Vector2,ImVec2,ImVec2,ImVec2,ImVec2,UInt32\)
```cj
public func primQuadUV(a: Vector2, b: Vector2, c: Vector2, d: Vector2, uvA: ImVec2, uvB: ImVec2, uvC: ImVec2, uvD: ImVec2, col: UInt32): Unit
```
Adds a primitive quad (with UV)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector2|Vertex A (top-left)|
|b|Vector2|Vertex B (top-right)|
|c|Vector2|Vertex C (bottom-right)|
|d|Vector2|Vertex D (bottom-left)|
|uvA|ImVec2|UV of vertex A|
|uvB|ImVec2|UV of vertex B|
|uvC|ImVec2|UV of vertex C|
|uvD|ImVec2|UV of vertex D|
|col|UInt32|Color (IM_COL32 format)|

### func primRectUV\(Vector2,Vector2,ImVec2,ImVec2,UInt32\)
```cj
public func primRectUV(a: Vector2, c: Vector2, uvA: ImVec2, uvC: ImVec2, col: UInt32): Unit
```
Adds a primitive rectangle (with UV)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector2|Top-left corner|
|c|Vector2|Bottom-right corner|
|uvA|ImVec2|UV top-left|
|uvC|ImVec2|UV bottom-right|
|col|UInt32|Color (IM_COL32 format)|

### func primRect\(Vector2,Vector2,UInt32\)
```cj
public func primRect(a: Vector2, c: Vector2, col: UInt32): Unit
```
Adds a primitive rectangle (no UV transform, fastest)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector2|Top-left corner|
|c|Vector2|Bottom-right corner|
|col|UInt32|Color (IM_COL32 format)|

### func primReserve\(Int32,Int32\)
```cj
public func primReserve(vtxCount: Int32, idxCount: Int32): Unit
```
Pre-allocates vertex/index buffers

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vtxCount|Int32|Vertex count|
|idxCount|Int32|Index count|

### func primUnreserve\(Int32,Int32\)
```cj
public func primUnreserve(vtxCount: Int32, idxCount: Int32): Unit
```
Un-reserves pre-allocated buffers

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vtxCount|Int32|Vertex count|
|idxCount|Int32|Index count|

### func pushClipRect\(Vector2,Vector2,Bool\)
```cj
public func pushClipRect(min: Vector2, max: Vector2, intersectWithCurrent!: Bool = false): Unit
```
Pushes a clip rectangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector2|Rectangle minimum|
|max|Vector2|Rectangle maximum|
|intersectWithCurrent|Bool|Whether to intersect with the current clip region (default false = replace)|

### func pushTexture\(VoidPtr\)
```cj
public func pushTexture(texRef: VoidPtr): Unit
```
Pushes a texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texRef|VoidPtr|Texture reference pointer|

### func window\(\)
```cj
public static func window(): UiDrawList
```
Returns the current window DrawList

Return: 

- UiDrawList instance

