// ArkTS type declarations for libohos_app_cangjie_entry.so (Cangjie module)

/**
 * 启动 three 渲染：绑定 XComponent 的 native window 并驱动渲染循环。
 * @param context UIAbilityContext（physics 无音频，仅保留统一接口）
 * @returns 初始化成功返回 true，失败（如 surface 未就绪）返回 false
 */
export declare function startThreeRender(context: object): boolean;

/** 停止 three 渲染（渲染线程退出并关闭渲染器） */
export declare function stopThreeRender(): boolean;

/** 查询渲染是否正在运行 */
export declare function isThreeRendering(): boolean;

/**
 * 事件驱动 resize：旋转/窗口尺寸变化时由 ArkTS 侧 XComponent onAreaChange 触发，
 * 把新尺寸（物理像素 px）传给渲染线程，线程下一帧应用（非轮询）。
 * @param w 新宽度（px）
 * @param h 新高度（px）
 */
export declare function resizeThreeRender(w: number, h: number): boolean;
