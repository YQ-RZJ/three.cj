# Class
## class RagdollJoint
```cj
public class RagdollJoint
```
Swing-twist joint description from a ragdoll part to its parent

### func cone\(Vector3,Vector3,Float32,Float32,Float32,Float32\)
```cj
public static func cone(anchor: Vector3, twistAxis: Vector3, halfConeAngle: Float32, twistMin!: Float32 = - 3.1415927f32, twistMax!: Float32 = 3.1415927f32, maxFrictionTorque!: Float32 = 0.0f32): RagdollJoint
```
Convenience factory: a cone swing joint (equal swing range in both directions)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|anchor|Vector3|The joint anchor (same anchor in child/parent COM space)twistAxis The twist axis (along the bone direction)halfConeAngle The swing half-cone angle (radians); smaller is stiffertwistMin Minimum twist angle (radians, default -π free twist)twistMax Maximum twist angle (radians, default +π)maxFrictionTorque Maximum friction torque (default 0)|
|twistAxis|Vector3||
|halfConeAngle|Float32||
|twistMin|Float32||
|twistMax|Float32||
|maxFrictionTorque|Float32||

Return: 

- A cone joint description

### func init\(\)
```cj
public init()
```
Creates a joint description

### var maxFrictionTorque
```cj
public var maxFrictionTorque: Float32 = 0.0f32
```
Maximum friction torque

### var normalHalfConeAngle
```cj
public var normalHalfConeAngle: Float32 = 0.0f32
```
Normal-direction swing half-cone angle (radians)

### var planeAxis1
```cj
public var planeAxis1: Vector3 = Vector3(0.0, 0.0, 1.0)
```
Plane axis on the child part

### var planeAxis2
```cj
public var planeAxis2: Vector3 = Vector3(0.0, 0.0, 1.0)
```
Plane axis on the parent part

### var planeHalfConeAngle
```cj
public var planeHalfConeAngle: Float32 = 0.0f32
```
Plane-direction swing half-cone angle (radians)

### var position1
```cj
public var position1: Vector3 = Vector3()
```
Anchor in the child part's COM space

### var position2
```cj
public var position2: Vector3 = Vector3()
```
Anchor in the parent part's COM space

### var twistAxis1
```cj
public var twistAxis1: Vector3 = Vector3(0.0, 1.0, 0.0)
```
Twist axis on the child part

### var twistAxis2
```cj
public var twistAxis2: Vector3 = Vector3(0.0, 1.0, 0.0)
```
Twist axis on the parent part

### var twistMaxAngle
```cj
public var twistMaxAngle: Float32 = 3.1415927f32
```
Maximum twist angle (radians)

### var twistMinAngle
```cj
public var twistMinAngle: Float32 = - 3.1415927f32
```
Minimum twist angle (radians)

