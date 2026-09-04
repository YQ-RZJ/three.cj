import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 直接加载主页面（Index），并在 loadContent 成功后
    // 主动移除系统起始窗口（LOGO）：比 metadata 的 enable.remove.starting.window
    // 更可靠（后者在部分设备/版本不生效，导致 LOGO 持续覆盖在已渲染画面上）。
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');

      // 尽早移除系统 StartingWindow（LOGO），让应用界面尽快露出
      try {
        windowStage.removeStartingWindow().then(() => {
          hilog.info(DOMAIN, 'testTag', 'StartingWindow removed.');
        }).catch((removeErr: BusinessError) => {
          hilog.error(DOMAIN, 'testTag', 'Failed to remove StartingWindow: %{public}s', JSON.stringify(removeErr) ?? '');
        });
      } catch (e) {
        hilog.error(DOMAIN, 'testTag', 'removeStartingWindow exception: %{public}s', JSON.stringify(e) ?? '');
      }

      // XComponent 全屏 + 旋转支持（参考 PerlerBeads_OH）：
      // 1. 窗口全屏布局：内容铺满状态栏/导航栏区域，XComponent 100% 即占满全屏；
      // 2. 背景色置黑，避免旋转过渡期露白；
      // 3. AUTO_ROTATION：允许横竖屏自动旋转，旋转时 XComponent 尺寸变化，
      //    sdl4cj OHOS 驱动 OnSurfaceChanged 更新 native window 尺寸，
      //    ArkTS onAreaChange 事件驱动 resize（见 three_renderer.cj / Index.ets）。
      try {
        const mainWindow = windowStage.getMainWindowSync();
        mainWindow.setWindowLayoutFullScreen(true).catch((e: BusinessError) => {
          hilog.error(DOMAIN, 'testTag', 'setWindowLayoutFullScreen failed: %{public}s', JSON.stringify(e) ?? '');
        });
        // setWindowBackgroundColor 同步返回 void（无 Promise），失败由外层 try/catch 捕获
        mainWindow.setWindowBackgroundColor('#000000');
        mainWindow.setPreferredOrientation(window.Orientation.AUTO_ROTATION).catch((e: BusinessError) => {
          hilog.error(DOMAIN, 'testTag', 'setPreferredOrientation failed: %{public}s', JSON.stringify(e) ?? '');
        });
      } catch (e) {
        hilog.error(DOMAIN, 'testTag', 'Failed to set fullscreen/rotation. Cause: %{public}s',
          JSON.stringify(e) ?? '');
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}