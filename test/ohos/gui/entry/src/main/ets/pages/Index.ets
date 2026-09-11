import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
// 关键：必须先于仓颉入口 import，让 NMM 以 app 模块身份加载 libSDL3.so（constructor 在
// NMM 加载上下文内执行 napi_module_register，name='SDL3'）。否则 libSDL3.so 会被仓颉侧
// dlb_load 抢先 dlopen（isApp:0、头插注册），随后 XComponent libraryname='SDL3' 触发 NMM
// 按名加载时 constructor 不再重跑，导致 [NMM:1466] Name mismatch，SDLNapiInit 不被调用、
// nativeXComponentMap 为空、SDL_CreateWindow 返回 NULL。
import sdl from 'libSDL3.so';
import { startThreeRender, stopThreeRender, isThreeRendering, resizeThreeRender } from 'libohos_app_cangjie_entry.so';

const DOMAIN: number = 0x0000;
const TAG: string = 'ThreeXComponent';

@Entry
@Component
struct Index {
  @State renderStatus: string = 'idle';
  private xcController: XComponentController = new XComponentController();

  build() {
    Stack() {
      // XComponent：libraryname='SDL3' 触发 mmg 加载 libSDL3.so，进入 nm 注册模式——
      // mmg 加载时调用 SDL 的 OHOS_XcomponentExport 把本 XComponent 注册进 SDL 内部
      // 注册表并挂接触摸/键鼠回调；随后 onLoad 里 startThreeRender 创建 SDL 窗口时，
      // SDL 会直接从注册表取本 XComponent 的 native window 建窗（无需 NodeController
      // 适配层），native window 经 SDL_PROP_WINDOW_OHOS_WINDOW_POINTER 交给 bgfx 渲染，
      // 输入事件按 xcompentId 路由进该 SDL 窗口。base 工程保持纯仓颉，无需 C++ 工程。
      XComponent({
        id: 'xComponentId',
        type: XComponentType.SURFACE,
        libraryname: 'SDL3',
        controller: this.xcController
      })
        .id('xComponentId')
        .width('100%')
        .height('100%')
        .onLoad(() => {
          sdl.nativePermissionResult(false)
          hilog.info(DOMAIN, TAG, 'XComponent onLoad');
          // 统一传递 UIAbilityContext（base 无音频，仓颉侧仅保留接口一致性）
          const ok = startThreeRender(getContext(this) as common.UIAbilityContext);
          hilog.info(DOMAIN, TAG, 'startThreeRender result: %{public}s', ok ? 'true' : 'false');
          this.renderStatus = ok ? 'rendering' : 'failed';
        })
        .onDestroy(() => {
          hilog.info(DOMAIN, TAG, 'XComponent onDestroy, stop three render');
          stopThreeRender();
          this.renderStatus = 'stopped';
        })
        // 旋转/窗口尺寸变化时触发：把 XComponent 新尺寸（vp）转 px 通知渲染线程。
        // 事件驱动 resize（非轮询）——与参考项目 xcomponent-vsync-master 的
        // OnSurfaceChanged 事件驱动等价，仅在实际尺寸变化时调用一次。
        // 传逻辑像素（vp）：SDL OHOS 驱动已按 density 将 XComponent 物理像素
        // 换算为逻辑尺寸（window->w/h = physical / density），引擎的
        // _width/_height 须与之一致（逻辑像素），否则 pixelRatio = drawable/_width
        // 会算错（两者同为物理像素时 pixelRatio 恒为 1.0，DPI 缩放失效）。
        .onAreaChange((oldValue: Area, newValue: Area) => {
          const widthVp = newValue.width;
          const heightVp = newValue.height;
          if (typeof widthVp === 'number' && typeof heightVp === 'number') {
            const w = Math.round(widthVp);
            const h = Math.round(heightVp);
            resizeThreeRender(w, h);
            hilog.info(DOMAIN, TAG, 'onAreaChange -> resizeThreeRender(%{public}d, %{public}d)', w, h);
          }
        })

      // 顶部状态标签（便于确认渲染线程状态）
      Text(`three render: ${this.renderStatus}`)
        .fontSize(14)
        .fontColor(Color.White)
        .backgroundColor('#66000000')
        .padding(8)
        .borderRadius(4)
        .position({ x: 16, y: 40 })
    }
    .alignContent(Alignment.TopStart)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}
