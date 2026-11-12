"""scan_common.py — three.cj 工程约束审计的共享扫描库。

用法约定：所有 audit_*.py 与本文件放在同一目录，直接 `import scan_common`。
只读分析；仓库根通过向上查找 cjpm.toml 定位。
"""
import os
import re
import sys
from collections import Counter


def find_repo_root(start=None):
    """从当前目录（或 start）向上查找包含 cjpm.toml 的目录。"""
    d = os.path.abspath(start or os.getcwd())
    while True:
        if os.path.isfile(os.path.join(d, 'cjpm.toml')):
            return d
        parent = os.path.dirname(d)
        if parent == d:
            raise SystemExit('未找到 cjpm.toml，请在本仓库内运行本脚本')
        d = parent


# public 声明（含顶层与成员）：捕获可见性/修饰、种类、名称
PUBLIC_DECL_RE = re.compile(
    r'^(\s*)((?:public\s+)(?:open\s+|abstract\s+|static\s+|mut\s+|override\s+)*'
    r'(func|prop|class|interface|struct|enum|const|let|var)\s+([A-Za-z_]\w*)?)'
)


class SourceFile:
    __slots__ = ('path', 'rel', 'package', 'lines', 'text', 'word_counts')

    def __init__(self, path, rel):
        self.path = path
        self.rel = rel.replace(os.sep, '/')
        with open(path, encoding='utf-8', errors='ignore') as f:
            self.text = f.read()
        self.lines = self.text.splitlines()
        self.word_counts = None
        m = re.search(r'^package\s+([\w.]+)', self.text, re.M)
        self.package = m.group(1) if m else '(nopkg:%s)' % self.rel


def load_sources(root, include_test=True):
    """收集 src/（及可选 test/）下的全部 .cj 文件。"""
    sources = []
    for base in ('src', 'test') if include_test else ('src',):
        base_dir = os.path.join(root, base)
        for dirpath, _, files in os.walk(base_dir):
            for name in files:
                if name.endswith('.cj'):
                    p = os.path.join(dirpath, name)
                    sources.append(SourceFile(p, os.path.relpath(p, root)))
    return sources


def public_decls(sf):
    """返回 [(line_no, indent, kind, name, text, is_open)]。init 无名时记 'init'。"""
    out = []
    for i, line in enumerate(sf.lines, 1):
        m = PUBLIC_DECL_RE.match(line)
        if not m:
            continue
        indent = len(m.group(1))
        head = m.group(2)
        kind = m.group(3)
        name = m.group(4) or 'init'
        out.append((i, indent, kind, name, line.rstrip(), 'open ' in head))
    return out


def name_usage_index(sources):
    """词级使用索引：name -> {package: count}，不含声明所在文件本身。"""
    word_re = {}
    index = {}
    for sf in sources:
        words = set(re.findall(r'[A-Za-z_]\w+', sf.text))
        for w in words:
            index.setdefault(w, {}).setdefault(sf.package, 0)
    # 精确计数：逐文件统计词频
    counts = {}
    for sf in sources:
        c = counts.setdefault(sf.package, {})
        for w in re.findall(r'[A-Za-z_]\w+', sf.text):
            c[w] = c.get(w, 0) + 1
    return counts


def precompute_word_counts(sources):
    """为每个文件预计算词频 Counter，供 usage_outside_file 使用。"""
    for sf in sources:
        sf.word_counts = Counter(re.findall(r'[A-Za-z_]\w+', sf.text))
    return sources


def usage_outside_file(sources, sf, name):
    """统计 name 在「除声明文件外」所有文件中的使用，按包分组。

    返回 {package: count}；测试包按其包名原样出现（调用方用 is_test_pkg 区分）。
    """
    total = Counter()
    for other in sources:
        if other.path == sf.path:
            continue
        c = getattr(other, 'word_counts', None)
        if c is None:
            continue
        n = c.get(name, 0)
        if n:
            total[other.package] += n
    return dict(total)


def package_usage(counts, sf, name):
    """返回 (other_pkgs, test_use, same_pkg_use)。

    other_pkgs: 其他业务包中该名字的使用次数（不含声明文件所在包）
    test_use:   测试相关包中的使用次数
    """
    d = counts.get(name, {})
    test_use = sum(v for k, v in d.items()
                   if k.startswith('test') or k in ('animation_test', 'binReuseTest')
                   or k.startswith('(nopkg:test'))
    other = {k: v for k, v in d.items() if k != sf.package and not k.startswith('(nopkg:%s' % sf.rel)}
    # 排除声明文件自己所在 nopkg 项已在上面处理；同包计数：
    same = d.get(sf.package, 0)
    return other, test_use, same


def resolve_modules(root, args):
    """把 'animation'、'rendering/bgfx' 等参数解析为 (包名前缀, 文件列表)。"""
    src = os.path.join(root, 'src')
    if not args:
        return [('all', [sf for sf in load_sources(root) if sf.rel.startswith('src/')])]
    result = []
    for a in args:
        a = a.strip('/').replace('\\', '/')
        full = os.path.join(src, a)
        if os.path.isdir(full):
            prefix = 'three.' + a.replace('/', '.')
            files = []
            for dirpath, _, fs in os.walk(full):
                for f in fs:
                    if f.endswith('.cj'):
                        files.append(SourceFile(os.path.join(dirpath, f),
                                                os.path.relpath(os.path.join(dirpath, f), root)))
            result.append((prefix, files))
        elif os.path.isfile(full):
            result.append((a, [SourceFile(full, os.path.relpath(full, root))]))
        else:
            raise SystemExit('模块不存在: %s' % a)
    return result


TEST_PKGS_HINT = ('test')


def is_test_pkg(pkg):
    return pkg.startswith('test') or pkg in ('animation_test', 'binReuseTest') or pkg.startswith('(nopkg:test')
