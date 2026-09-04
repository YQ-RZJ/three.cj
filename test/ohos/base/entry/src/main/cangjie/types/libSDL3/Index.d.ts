// ArkTS type declarations for libSDL3.so (SDL3 NAPI module, nm_modname=SDL3)
// base 工程仅用于触发 NMM 以 app 模块身份加载 libSDL3.so（副作用导入）。
// nativePermissionResult() 与窗口无关，C++ 侧仅做原子标志写，副作用最小。

/** 权限结果回调（与窗口无关，仅设置权限标志；作副作用调用触发 SO 加载） */
export declare function nativePermissionResult(result: boolean): void;
