# Class
## class Scene
```cj
public class Scene <: Object3D & IScene
```
Scene, the root node of the scene graph

### func clone\(\)
```cj
public override func clone(): Object3D
```
Return a new scene instance with the same values as this instance

Return: 

- New scene instance

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy values from the given scene instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- Returns this

### func init\(\)
```cj
public init()
```
Construct a new scene

### prop backgroundJson: String
```cj
public open mut prop backgroundJson: String
```


### prop environmentJson: String
```cj
public open mut prop environmentJson: String
```


### prop fogExp2Json: String
```cj
public open mut prop fogExp2Json: String
```


### prop fogJson: String
```cj
public open mut prop fogJson: String
```


### prop overrideMaterialJson: String
```cj
public open mut prop overrideMaterialJson: String
```


### var backgroundBlurriness
```cj
public var backgroundBlurriness: Float64
```
Background blurriness (0=sharp, 1=fully blurred), default 0

### var backgroundIntensity
```cj
public var backgroundIntensity: Float64
```
Background intensity (multiplication factor), default 1

### var backgroundRotation
```cj
public var backgroundRotation: Euler
```
Background rotation (Euler angles), default Identity

### var background
```cj
public var background: Option < IBackground >
```
Background: Some(Color)/Some(Texture)/Some(CubeTexture) or None (no background), default None

### var environmentIntensity
```cj
public var environmentIntensity: Float64
```
Environment map intensity, default 1

### var environmentNode
```cj
public var environmentNode: Option < Any >
```
Environment node (injected at runtime by NodeManager), renderer uses it instead of scene.environment for environment lighting

### var environmentRotation
```cj
public var environmentRotation: Euler
```
Environment map rotation, default Identity

### var environment
```cj
public var environment: Option < Texture >
```
Environment map (Texture/CubeTexture), default None

### var fogExp2
```cj
public var fogExp2: Option < FogExp2 >
```
Exponential fog (mutually exclusive with fog)

### var fog
```cj
public var fog: Option < Fog >
```
Linear fog

### var overrideMaterial
```cj
public var overrideMaterial: Option < Material >
```
Override material (all scene objects' materials replaced with this), default None

