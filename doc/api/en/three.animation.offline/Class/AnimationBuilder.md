# Class
## class AnimationBuilder
```cj
public class AnimationBuilder
```
Animation builder

### func invoke\(RawAnimation\)
```cj
public func invoke(input: RawAnimation): Option < SkeletalAnimationData >
```
Builds runtime SkeletalAnimationData

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawAnimation|The offline animation data|

Return: 

- Some(SkeletalAnimationData) on success; None when the input is invalid

