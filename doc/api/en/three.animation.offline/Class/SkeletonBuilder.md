# Class
## class SkeletonBuilder
```cj
public class SkeletonBuilder
```
Skeleton builder - converts RawSkeleton to runtime Skeleton

### func invoke\(RawSkeleton\)
```cj
public func invoke(input: RawSkeleton): Option < SkeletonData >
```
Builds runtime SkeletonData

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawSkeleton|The offline skeleton data|

Return: 

- Some(SkeletonData) on success; None when the input is invalid

