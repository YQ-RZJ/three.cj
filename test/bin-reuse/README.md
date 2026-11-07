# bin-reuse — three engine binary artifact reuse example

This project demonstrates **direct reuse of the three engine's binary artifacts**
(`bin-dependencies` + `three-deps.a`) instead of pulling in the engine source,
building it yourself, and collecting dependencies.

## Why binary reuse

| Approach | What you need | Best for |
|---|---|---|
| **Binary reuse (this project)** | Download the release static artifact package and extract it into `libs/` | Quick integration, evaluation, business development |
| Source dependency (see `[dependencies]` in the engine repo's cjpm.toml) | Engine source + 9 dependency packages + native static library package (`EXTEDN_LIBS_PATH` env) + exclude.rsp generation | When you need to modify the engine |

Binary reuse keeps "building the engine, collecting 20+ dependency libraries,
resolving symbol conflicts" entirely inside the engine CI. Downstream is reduced
to two steps: **extract + declare the link**.

## Quick start

### 1. Download the artifacts

Download the static artifact package `three-<os>-<arch>-static.zip` matching
your platform from the [three.cj releases](https://github.com/YQ-RZJ/three.cj/releases)
page, and extract it into this project's `libs/`.

Directory layout after extraction (matches the conventions in cjpm.toml):

```
libs/
├── three-deps.a        # merged archive: all native deps + toolchain C++ runtime
├── three/              # engine core: *.cjo + lib<package>.a + macro plugin dynamic libs
├── bgfx4cj/            # 9 dependency packages: each with *.cjo + lib<package>.a
├── fastjson/
├── httpclient4cj/
├── imgui4cj/
├── jolt4cj/
├── luajit4cj/
├── openalsoft4cj/
├── sdl4cj/
└── tracy4cj/
```

### 2. Build and run

```bash
cjpm build            # default host target
cjpm build --target x86_64-w64-mingw32   # or an explicit target (see cjpm.toml)
cjpm run
```

Windows / Linux / macOS need no extra environment variables.
**OHOS / iOS / Android** require the matching SDK environment variables first
(see the comments on each target in cjpm.toml):

| Platform | Environment variables |
|---|---|
| OHOS | `DEVECO_CANGJIE_HOME`, `DEVECO_OH_NATIVE_HOME` |
| iOS | `IOS_SYSROOT`, `IOS_XCODE_TOOLCHAIN` |
| Android | `CANGJIE_HOME`, `ANDROID_NDK_HOME` |

## How it works

- **`[target.<triple>.bin-dependencies].path-option`**: declares `libs/<module>/`
  as a binary module directory. cjc loads the `.cjo` files from it at compile time
  (import resolution, type checking), and cjpm automatically links the sibling
  `lib<package>.a` archives at link time — equivalent to a source dependency,
  but without the build;
- **`three-deps.a`**: the engine CI has merged all native static libraries
  (bgfx / SDL3 / OpenSSL / Jolt / LuaJIT / tracy — 24 of them) together with the
  toolchain C++ runtime (`libc++.a`/`libunwind.a`, `libstdc++.a`/`libgcc_eh.a`,
  `libc++_static.a`/`libc++abi.a`, etc.) into a single archive. Downstream pulls
  everything in with one line in `link-option`: `-l:three-deps.a`;
- **The system library/framework list at the tail of `link-option`**: contains
  only what the OS provides (d3d11/ws2_32 etc. on Windows, the Cocoa/UIKit
  frameworks on macOS/iOS, X11/pthread etc. on Linux, native_window.so on OHOS,
  EGL/NDK libs on Android). This list mirrors the engine repo's cjpm.toml per
  target — when the engine's dependency set changes, sync from the engine
  repo's cjpm.toml.

## Bring your own project (without this repo)

To integrate the engine binary artifacts into an existing project, follow
cjpm.toml in this directory:

1. Extract the artifacts somewhere in your project (e.g. `libs/`; you can also
   use per-platform directories with conditional configuration);
2. For your target, add `[target.<triple>.bin-dependencies]` with
   `path-option = ["./libs/<module>", ...]` (one entry per module directory);
3. In `[target.<triple>]`, add `-L libs -l:three-deps.a` to `link-option`,
   plus that platform's system library list;
4. To verify the static library inventory, check `MANIFEST.txt` inside the
   artifact package (lists every input archive and member count of
   three-deps.a).

## Caveats

- **cjc version match**: the `.cjo`/`.a` artifacts are bound to the compiler
  version; after upgrading the Cangjie SDK, switch to the release artifacts
  built with the matching version;
- **Macro plugin dynamic libraries**: the `lib-macro_*.dll/.dylib/.so` files in
  each module directory are loaded and executed by cjc **at compile time**.
  Do not delete them; on Windows, if macro loading fails, add their directory
  to `Path`;
- **Platform/artifact correspondence**: `--target` must match the platform of
  the extracted artifact package (e.g. don't use
  `three-macos-arm64-v8a-static.zip` with `x86_64-apple-darwin`);
- **OHOS specifics**: SDL3 is dynamically linked on OHOS; `libSDL3.so` must sit
  next to the app at runtime (it ships inside the artifact package).
  `-l:libnative_window.so` is provided by the system;
- **undefined symbols on first build**: check that `libs/three-deps.a` exists
  and comes from the platform package matching your target (MANIFEST.txt shows
  the archive contents).

## Directory contents

```
cjpm.toml      # cross-platform link configuration (companion to this README)
src/main.cj    # minimal usage example
src/renderer.cj
src/resources.cj
libs/          # extract the release static artifacts here (not committed, see .gitignore)
```
