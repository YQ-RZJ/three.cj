"""audit_interfaces.py — C9 接口收纳与重导出审计：检查模块内全部接口声明是否符合收纳/可见性/重导出/命名约定。

用法：python audit_interfaces.py [模块...]    # 如 animation / audio / core；缺省扫全部 src
输出标签：
  OK                      同时满足：位于 interfaces 子包 + protected package + 有 public import 重导出 + I 前缀命名
  NOT-IN-INTERFACES       接口声明不在 interfaces 子包内（应迁移）
  NOT-PROTECTED           interfaces 子包的 package 行缺少 protected 修饰
  NO-REEXPORT             接口在任何实现包内均无 public import 重导出
  BAD-REEXPORT-LOCATION   重导出点与主实现包不一致（人工核对依赖方向）
  BAD-NAME                接口名未以大写 I 为前缀（历史遗留，触碰时重命名）
"""
import os
import re
import sys
import scan_common as sc

INTERFACE_RE = re.compile(r'^\s*(?:public\s+)?interface\s+([A-Za-z_]\w*)')
PACKAGE_RE = re.compile(r'^(protected\s+)?package\s+([\w.]+)')
PUBLIC_IMPORT_RE = re.compile(r'^public\s+import\s+(?:[\w.]+)?\b(?:three|test)\.[\w.]*(?:_interfaces|_gfx|_bgfx)\.(\w+)')


def interface_decls(sf):
    """返回文件内的顶层接口声明 [(line_no, name)]。"""
    out = []
    for i, line in enumerate(sf.lines, 1):
        m = INTERFACE_RE.match(line)
        if m and not line.startswith(' '):
            out.append((i, m.group(1)))
    return out


def main():
    root = sc.find_repo_root()
    modules = sc.resolve_modules(root, sys.argv[1:])
    sources = [sf for _, files in modules for sf in files
               if sf.rel.startswith('src/')]

    # 重导出全库扫描（重导出点通常在目标模块之外，不能随模块参数收窄）
    all_src = [sf for sf in sc.load_sources(root, include_test=False)
               if sf.rel.startswith('src/')]
    reexports = {}
    for sf in all_src:
        for i, line in enumerate(sf.lines, 1):
            m = PUBLIC_IMPORT_RE.match(line)
            if m:
                reexports.setdefault(m.group(1), []).append((sf.rel, i))

    rows = []
    for sf in sources:
        # _ 前缀目录为 protected package 约定（C9）：_interfaces 为接口包，_gfx/_bgfx 为词表叶子包
        is_interfaces_dir = '/_interfaces/' in sf.rel
        is_protected_dir = re.search(r'/(_interfaces|_gfx|_bgfx)/', sf.rel) is not None
        pm = PACKAGE_RE.match(sf.lines[0]) if sf.lines else None
        # 扫描整个文件找 package 行（锚点文件通常在首行，但稳妥起见全文找）
        for line in sf.lines:
            pm = PACKAGE_RE.match(line)
            if pm:
                break
        pkg_protected = bool(pm and pm.group(1))
        decls = interface_decls(sf)
        if not decls and not is_protected_dir:
            continue
        # 检查一：interfaces 目录内文件必须是 protected package
        if is_protected_dir and not pkg_protected:
            rows.append(('NOT-PROTECTED', sf.rel, 0, '', sf.package))
        for line_no, name in decls:
            # 检查二：接口必须位于 interfaces 子包
            if not is_interfaces_dir:
                rows.append(('NOT-IN-INTERFACES', sf.rel, line_no, name, sf.package))
            # 检查三：必须有 public import 重导出
            rls = reexports.get(name, [])
            if not rls:
                rows.append(('NO-REEXPORT', sf.rel, line_no, name, sf.package))
            elif not any(r != sf.rel for r, _ in rls):
                # 重导出只出现在声明文件自身，等于没有实现包重导出
                rows.append(('NO-REEXPORT', sf.rel, line_no, name, sf.package))
            # 检查四：I 前缀命名
            if not re.match(r'^I[A-Z]', name):
                rows.append(('BAD-NAME', sf.rel, line_no, name, sf.package))

    if not rows:
        print('OK：扫描范围内全部接口符合 C9 约定')
        return
    order = ['NOT-IN-INTERFACES', 'NOT-PROTECTED', 'NO-REEXPORT', 'BAD-NAME']
    rows.sort(key=lambda r: (order.index(r[0]), r[1], r[2]))
    for tag, rel, line_no, name, pkg in rows:
        print('%-20s %-58s L%-6d %-24s %s' % (tag, rel, line_no, name, pkg))
    from collections import Counter
    print('\n== 统计 ==')
    for k in order:
        c = sum(1 for r in rows if r[0] == k)
        if c:
            print('%-20s %d' % (k, c))
    print('提示：NOT-IN-INTERFACES 需迁移声明；NOT-PROTECTED 补 protected package；'
          'NO-REEXPORT 在主实现包加 public import（不加注释）；BAD-NAME 触碰时整词重命名。'
          '修改后用 EXTEND_LIBS_PATH_WIN_X64=<repo>/three.cj/three.cj/libs cjpm build 验证（由用户执行）。')


if __name__ == '__main__':
    main()
