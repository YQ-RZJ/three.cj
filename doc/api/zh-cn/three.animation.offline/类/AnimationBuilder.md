# 类
## class AnimationBuilder
```cj
public class AnimationBuilder
```
动画构建器

### func invoke\(RawAnimation\)
```cj
public func invoke(input: RawAnimation): Option < SkeletalAnimationData >
```
构建运行时 SkeletalAnimationData

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawAnimation|离线动画数据|

返回: 

- Some(SkeletalAnimationData) 构建成功，None 表示输入无效

