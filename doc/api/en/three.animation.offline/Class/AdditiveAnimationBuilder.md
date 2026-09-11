# Class
## class AdditiveAnimationBuilder
```cj
public class AdditiveAnimationBuilder
```
Additive animation builder

### func invoke\(RawAnimation,RawAnimation\)
```cj
public func invoke(base: RawAnimation, target: RawAnimation): Option < RawAnimation >
```
Builds an additive animation from base and target animations

Parameter: 

|Name|Type|Describe|
|---|---|---|
|base|RawAnimation|The base animation (rest pose / idle)|
|target|RawAnimation|The target animation (the motion to layer on)|

Return: 

- The additive animation (delta)

