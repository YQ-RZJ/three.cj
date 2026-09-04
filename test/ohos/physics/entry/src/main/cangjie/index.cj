package ohos_app_cangjie_entry

import ohos.ark_interop.*
import ohos.ark_interop.JSContext
import ohos.ark_interop.JSCallInfo
import ohos.ark_interop.JSValue
import ohos.app.ability.ui_ability.*
import ohos.resource_manager.*

// Cangjie-side functions exposed to ArkTS via `import { ... } from 'libohos_app_cangjie_entry.so'`.

// ===== three 渲染控制（详见 three_renderer.cj） =====

// startThreeRender(context): 绑定 XComponent 的 native window 并启动渲染。
// 参数为 ArkTS 传入的 UIAbilityContext（physics 无音频，仅保留统一接口）。
func startThreeRenderWrapper(runtime: JSContext, callInfo: JSCallInfo): JSValue {
    var ctxOpt: Option<UIAbilityContext> = None
    if (callInfo.count > 0) {
        ctxOpt = Some(createUIAbilityContextFromJSValue(runtime, callInfo[0]))
    }
    let ok = match (ctxOpt) {
        case Some(ctx) => startThreeRender(ctx)
        case None => startThreeRender(None)
    }
    return runtime.boolean(ok).toJSValue()
}

// stopThreeRender(): 停止渲染
func stopThreeRenderWrapper(runtime: JSContext, callInfo: JSCallInfo): JSValue {
    stopThreeRender()
    return runtime.boolean(true).toJSValue()
}

// isThreeRendering(): 查询渲染状态
func isThreeRenderingWrapper(runtime: JSContext, callInfo: JSCallInfo): JSValue {
    return runtime.boolean(isThreeRendering()).toJSValue()
}

// resizeThreeRender(w, h): 事件驱动 resize —— ArkTS 侧 XComponent onAreaChange
// （旋转/窗口尺寸变化时触发）把新尺寸传给渲染线程（写入原子，非轮询）
func resizeThreeRenderWrapper(runtime: JSContext, callInfo: JSCallInfo): JSValue {
    var w: Int32 = 0
    var h: Int32 = 0
    if (callInfo.count > 0) {
        w = Int32(callInfo[0].toNumber())
    }
    if (callInfo.count > 1) {
        h = Int32(callInfo[1].toNumber())
    }
    resizeThreeRender(w, h)
    return runtime.boolean(true).toJSValue()
}

// Register the module so ArkTS can import from 'libohos_app_cangjie_entry.so'
let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports => {=>
        exports["startThreeRender"] = runtime.function(startThreeRenderWrapper).toJSValue()
        exports["stopThreeRender"] = runtime.function(stopThreeRenderWrapper).toJSValue()
        exports["isThreeRendering"] = runtime.function(isThreeRenderingWrapper).toJSValue()
        exports["resizeThreeRender"] = runtime.function(resizeThreeRenderWrapper).toJSValue()
    }()
}
