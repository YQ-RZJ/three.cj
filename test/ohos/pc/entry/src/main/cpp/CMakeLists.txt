cmake_minimum_required(VERSION 3.5.0)
project(three_ohos_pc)

# ============================================================================
# three.cj PC(2in1) 原生构建
#
# 背景：OHOS 仓颉插件不支持 2in1 deviceTypes（hvigor ERROR 01103012），
#       因此 pc 工程移除 cangjieOptions，改用 "C/C++ & ArkTS" 混合模式：
#   1) 调用 OHOS 仓颉 SDK 自带的 cjpm 编译仓颉工程 -> libohos_app_cangjie_entry.so
#      （cjpm.toml 的 link-option 用 --whole-archive 直接链接 entry/libs 下
#        预编译的 requireCJLib 桥接库 librequirecj_napi.a，其 NAPI 模块通过
#        __attribute__((constructor)) 自动注册 requireCJLib，确保 constructor
#        不因"无外部符号引用"而被链接器丢弃）
#   2) 将仓颉产物 + 仓颉 runtime .so 拷贝到 entry/libs/${OHOS_ARCH}，
#      由 hvigor 自动打包进 HAP
# ============================================================================

# ---- 按 hvigor 传入的 CPU 架构映射到 cjpm target ----
if(OHOS_ARCH STREQUAL "arm64-v8a")
    set(CJPM_TARGET "aarch64-linux-ohos")
    set(CJ_RUNTIME_ARCH "linux_ohos_aarch64_cjnative")
elseif(OHOS_ARCH STREQUAL "x86_64")
    set(CJPM_TARGET "x86_64-linux-ohos")
    set(CJ_RUNTIME_ARCH "linux_ohos_x86_64_cjnative")
else()
    set(CJPM_TARGET "")
endif()

if(CJPM_TARGET)
    set(CJ_SDK_ROOT "$ENV{DEVECO_CANGJIE_HOME}")
    set(CJ_BUILD_TOOLS "${CJ_SDK_ROOT}/build-tools")
    set(CJPM_TOOLS_BIN "${CJ_BUILD_TOOLS}/tools/bin")
    set(CJPM_EXE "${CJPM_TOOLS_BIN}/cjpm.exe")
    # cjpm.exe 是 Windows 宿主程序，启动即加载 Cangjie 宿主 runtime/std DLL；
    # PATH 必须补齐宿主目录（runtime/lib、lib、bin、tools/lib），否则 cjpm
    # 以 0xC0000139 (STATUS_ENTRYPOINT_NOT_FOUND) 秒退，hvigor 报 00308018。
    # 目录集与 DevEco 插件 getCjpmProcessEnv 的
    # [runtimeLibPath, cjcPath, toolsBin, toolsLib] 一致。
    set(CJ_HOST_RUNTIME_LIBS "${CJ_BUILD_TOOLS}/runtime/lib/windows_x86_64_cjnative")
    set(CJ_HOST_STD_LIBS "${CJ_BUILD_TOOLS}/lib/windows_x86_64_cjnative")
    set(CJ_CJC_BIN "${CJ_BUILD_TOOLS}/bin")
    set(CJ_TOOLS_LIB "${CJ_BUILD_TOOLS}/tools/lib")
    # 本 CMakeLists 位于 entry/src/main/cpp，需向上 3 级才回到 entry 根目录（含 cjpm.toml）。
    # 少一层会导致 cjpm 在 entry/src 下找不到 cjpm.toml，ninja 秒级失败（hvigor 00308018）。
    set(ENTRY_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../..")       # entry 根目录（含 cjpm.toml）
    set(CJPM_RELEASE_DIR "${ENTRY_ROOT}/target/${CJPM_TARGET}/release")
    set(OUT_LIBS_DIR "${ENTRY_ROOT}/libs/${OHOS_ARCH}")
    file(MAKE_DIRECTORY "${OUT_LIBS_DIR}")                        # 确保 hvigor 打包 native libs 的目录存在

# 纯 CMake 黑白名单过滤拷贝（hvigorfile.ts 经 CJ_STD_INCLUDE / CJ_STD_EXCLUDE 配置）：
# 白名单为空 -> 全量拷贝仅剔除黑名单；白名单非空 -> 只拷白名单（黑名单优先）。
# 1) 收集 SDK runtime 目录全部 .so（根目录优先，同名子目录文件忽略）
set(CJ_RT_DIR "${CJ_SDK_ROOT}/build-tools/runtime/lib/${CJ_RUNTIME_ARCH}")
set(CJ_RUNTIME_ALL "")
set(_seen "")
file(GLOB _rt_root "${CJ_RT_DIR}/*.so")
foreach(_f IN LISTS _rt_root)
    get_filename_component(_n "${_f}" NAME)
    list(APPEND CJ_RUNTIME_ALL "${_n}")
    list(APPEND _seen "${_n}")
endforeach()
file(GLOB _rt_sub "${CJ_RT_DIR}/*/*.so")
foreach(_f IN LISTS _rt_sub)
    get_filename_component(_n "${_f}" NAME)
    list(FIND _seen "${_n}" _idx)
    if(_idx EQUAL -1)
        list(APPEND CJ_RUNTIME_ALL "${_n}")
        list(APPEND _seen "${_n}")
    endif()
endforeach()
# 2) 黑名单剔除（优先级最高）
set(CJ_RUNTIME_PICK "")
foreach(_n IN LISTS CJ_RUNTIME_ALL)
    set(_excluded FALSE)
    if(NOT "$ENV{CJ_STD_EXCLUDE}" STREQUAL "")
        string(REPLACE "," ";" _ex_list "$ENV{CJ_STD_EXCLUDE}")
        foreach(_e IN LISTS _ex_list)
            string(STRIP "${_e}" _e)
            # 支持通配符模式："*" 匹配任意字符序列（glob -> regex，
            # 如 "libcangjie-std-unittest*"、"*.so"、单独 "*" = 全部）
            set(_re "${_e}")
            string(REPLACE "*" ".*" _re "${_re}")
            if(_n MATCHES "^${_re}$")
                set(_excluded TRUE)
                break()
            endif()
        endforeach()
    endif()
    if(NOT _excluded)
        list(APPEND CJ_RUNTIME_PICK "${_n}")
    endif()
endforeach()
# 3) 白名单过滤（非空时只保留白名单；同样支持通配符）
if(NOT "$ENV{CJ_STD_INCLUDE}" STREQUAL "")
    set(_pick "${CJ_RUNTIME_PICK}")
    set(CJ_RUNTIME_PICK "")
    string(REPLACE "," ";" _in_list "$ENV{CJ_STD_INCLUDE}")
    foreach(_e IN LISTS _in_list)
        string(STRIP "${_e}" _e)
        set(_re "${_e}")
        string(REPLACE "*" ".*" _re "${_re}")
        foreach(_p IN LISTS _pick)
            if(_p MATCHES "^${_re}$")
                list(APPEND CJ_RUNTIME_PICK "${_p}")
            endif()
        endforeach()
    endforeach()
endif()
# 4) 拷贝命中清单；5) 删除输出目录中不在清单内的 std/runtime .so
#    （保证从黑名单移除一个库后重新构建能补拷回来，名单即唯一事实）
foreach(_n IN LISTS CJ_RUNTIME_PICK)
    if(EXISTS "${CJ_RT_DIR}/${_n}")
        file(COPY_FILE "${CJ_RT_DIR}/${_n}" "${OUT_LIBS_DIR}/${_n}")
    else()
        file(GLOB _alt "${CJ_RT_DIR}/*/${_n}")
        list(GET _alt 0 _alt0)
        file(COPY_FILE "${_alt0}" "${OUT_LIBS_DIR}/${_n}")
    endif()
endforeach()
file(GLOB _dst_so "${OUT_LIBS_DIR}/*.so")
foreach(_f IN LISTS _dst_so)
    get_filename_component(_n "${_f}" NAME)
    # 仅清理仓颉 runtime/std 系 .so（libcangjie-* / libsecurec / libboundscheck），
    # 其他 .so（工程自有库如 libSDL3、手动放入的第三方库等）一律保留。
    set(_is_cj_runtime FALSE)
    if(_n MATCHES "^libcangjie-" OR _n MATCHES "^libsecurec" OR _n MATCHES "^libboundscheck" OR _n MATCHES "^libpcre2-")
        set(_is_cj_runtime TRUE)
    endif()
    if(_is_cj_runtime)
        list(FIND CJ_RUNTIME_PICK "${_n}" _idx)
        if(_idx EQUAL -1)
            file(REMOVE "${_f}")
        endif()
    endif()
endforeach()
list(LENGTH CJ_RUNTIME_ALL _all_count)
list(LENGTH CJ_RUNTIME_PICK _picked)
message(STATUS "[cjpm] runtime .so copied ${_picked}/${_all_count} include='$ENV{CJ_STD_INCLUDE}' exclude='$ENV{CJ_STD_EXCLUDE}'")

    # cjpm 构建仓颉 .so（link-option 链接 entry/libs 下的 requirecj_napi.a），
    # 并拷贝产物 + runtime .so 到 entry/libs/<abi>
    add_custom_target(cjpm_build ALL
        COMMAND ${CMAKE_COMMAND} -E echo "[cjpm] building ${CJPM_TARGET} ..."
        COMMAND ${CMAKE_COMMAND} -E env
            "PATH=${CJ_HOST_RUNTIME_LIBS};${CJ_HOST_STD_LIBS};${CJ_CJC_BIN};${CJPM_TOOLS_BIN};${CJ_TOOLS_LIB};$ENV{PATH}"
            "CANGJIE_HOME=$ENV{CANGJIE_HOME}"
            "DEVECO_CANGJIE_HOME=${CJ_SDK_ROOT}"
            "DEVECO_OH_NATIVE_HOME=$ENV{DEVECO_OH_NATIVE_HOME}"
            "AARCH64_LIBS=$ENV{AARCH64_LIBS}"
            "AARCH64_MACRO_LIBS=$ENV{AARCH64_MACRO_LIBS}"
            "AARCH64_KIT_LIBS=$ENV{AARCH64_KIT_LIBS}"
            "X86_64_OHOS_LIBS=$ENV{X86_64_OHOS_LIBS}"
            "X86_64_MACRO_LIBS=$ENV{X86_64_MACRO_LIBS}"
            "X86_64_KIT_LIBS=$ENV{X86_64_KIT_LIBS}"
            "EXTEDN_LIBS_PATH=$ENV{EXTEDN_LIBS_PATH}"
            "COMPILE_CONDITION_ENTRY=$ENV{COMPILE_CONDITION_ENTRY}"
            "${CJPM_EXE}" build --target ${CJPM_TARGET}
        COMMAND ${CMAKE_COMMAND} -E echo "[cjpm] copying cangjie .so -> ${OUT_LIBS_DIR}"
        COMMAND powershell -NoProfile -Command
            "Get-ChildItem -Path '${CJPM_RELEASE_DIR}' -Filter *.so -Recurse | Copy-Item -Destination '${OUT_LIBS_DIR}' -Force"
        # runtime .so 黑白名单拷贝在 configure 期完成（见上方 file(COPY_FILE) 段），
        # hvigor 每次构建都会重新 configure，名单变更即时生效。
        WORKING_DIRECTORY "${ENTRY_ROOT}"
        COMMENT "Build cangjie .so via cjpm (${CJPM_TARGET})"
    )
endif()
