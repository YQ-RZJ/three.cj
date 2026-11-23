# 接口
## interface IRenderer
```cj
public interface IRenderer
```
渲染器接口：CubeCamera.update 的 renderer 参数类型，声明渲染目标切换方法

### func getRenderTarget\(\)
```cj
func getRenderTarget(): Option < IRenderTarget >
```
获取当前渲染目标

返回: 

- 当前渲染目标（None 表示默认帧缓冲）

### func setRenderTarget\(IRenderTarget,Int64,Int64\)
```cj
func setRenderTarget(renderTarget: IRenderTarget, cubeFace: Int64, mipLevel: Int64): Unit
```
设置渲染目标（CubeCamera 6 面渲染：cubeFace 0~5 + mipLevel）

参数: 

|名称|类型|描述|
|---|---|---|
|renderTarget|IRenderTarget|渲染目标cubeFace 立方体面索引（0~5）mipLevel mipmap 层级|
|cubeFace|Int64||
|mipLevel|Int64||

