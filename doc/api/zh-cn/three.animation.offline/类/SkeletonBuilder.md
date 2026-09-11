# 类
## class SkeletonBuilder
```cj
public class SkeletonBuilder
```
骨骼构建器

### func invoke\(RawSkeleton\)
```cj
public func invoke(input: RawSkeleton): Option < SkeletonData >
```
构建运行时 SkeletonData

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawSkeleton|离线骨骼数据|

返回: 

- Some(SkeletonData) 构建成功，None 表示输入无效

