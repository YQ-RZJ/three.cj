# 接口
## interface IRenderTargetTexture
```cj
public interface IRenderTargetTexture
```
渲染目标纹理访问接口

### func rtClone\(\)
```cj
func rtClone(): IRenderTargetTexture
```
克隆自身（返回 IRenderTargetTexture）

### func rtIsData3DTexture\(\)
```cj
func rtIsData3DTexture(): Bool
```
是否 3D 数据纹理

### prop rtDepth: Int64
```cj
mut prop rtDepth: Int64
```
贴图深度（3D 纹理用）

### prop rtHeight: Int64
```cj
mut prop rtHeight: Int64
```
贴图高度（像素）

### prop rtIsArrayTexture: Bool
```cj
mut prop rtIsArrayTexture: Bool
```
是否数组纹理

### prop rtIsRenderTargetTexture: Bool
```cj
mut prop rtIsRenderTargetTexture: Bool
```
是否渲染目标纹理

### prop rtRenderTarget:?RenderTarget
```cj
mut prop rtRenderTarget:?RenderTarget
```
渲染目标反向引用（core 包内类型，同包直接引用避免 Any）

### prop rtWidth: Int64
```cj
mut prop rtWidth: Int64
```
贴图宽度（像素）

