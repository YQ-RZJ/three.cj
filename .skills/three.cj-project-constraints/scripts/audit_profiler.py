"""audit_profiler.py — C7 性能埋点审计：找出疑似热点但未带 @Zone 的成员函数。

用法：python audit_profiler.py <模块...>     # 无参数 = 全 src
启发式（仅提示，人工确认后补埋）：
  - 成员函数名命中热点词：update/run/render/execute/simulate/step/process/
    tick/dispatch/flush/sample/copy/upload/submit/resolve
  - 可见性 public/open/internal（内部管道同样可能是热点）
  - 函数体非平凡（简单转发/空实现跳过）
  - 声明前 6 行内没有 @Zone[
输出：CANDIDATE-ZONE + 建议链路名（package.ClassName.func，与方法名保持字面一致）。
统计部分另给出各文件现有 @Zone 数，便于观察埋点密度是否失衡。
"""
import re
import sys
from collections import Counter
import scan_common as sc

FUNC_RE = re.compile(r'^(\s*)(?:(public|internal|protected|private)\s+)?'
                     r'(?:(open|static|override)\s+)*(func)\s+([A-Za-z_]\w*)')
HOT_NAMES = {'update', 'run', 'render', 'execute', 'simulate', 'step', 'process',
             'tick', 'dispatch', 'flush', 'sample', 'copy', 'upload', 'submit', 'resolve'}
CLASS_RE = re.compile(r'^\s*(?:public\s+|internal\s+|protected\s+|private\s+)?(?:abstract\s+|open\s+)*class\s+([A-Za-z_]\w*)')
TRIVIAL_RE = re.compile(r'\{\s*\}|=>\s*[\w."()\[\] ]+$')


def func_block_len(sf, start):
    """估算函数体长度：到下一个同类缩进声明或文件尾。"""
    indent = len(sf.lines[start - 1]) - len(sf.lines[start - 1].lstrip())
    n = 0
    for i in range(start, min(start + 200, len(sf.lines))):
        ln = sf.lines[i]
        if ln.strip() and (len(ln) - len(ln.lstrip())) <= indent and not ln.strip().startswith((')', '@')):
            break
        n += 1
    return n


def main():
    root = sc.find_repo_root()
    modules = sc.resolve_modules(root, sys.argv[1:])
    zone_counter = Counter()
    rows = []
    for prefix, files in modules:
        for sf in files:
            if not sf.rel.startswith('src/'):
                continue
            zc = sum(1 for ln in sf.lines if '@Zone[' in ln)
            if zc:
                zone_counter[sf.rel] = zc
            cur_class = ''
            for i, ln in enumerate(sf.lines, 1):
                cm = CLASS_RE.match(ln)
                if cm:
                    cur_class = cm.group(1)
                fm = FUNC_RE.match(ln)
                if not fm:
                    continue
                name = fm.group(5)
                if name not in HOT_NAMES:
                    continue
                body_len = func_block_len(sf, i)
                if body_len <= 4 and TRIVIAL_RE.search(ln):
                    continue
                window = '\n'.join(sf.lines[max(0, i - 7):i])
                if '@Zone[' in window:
                    continue
                pkg = sf.package
                suggested = '%s.%s.%s' % (pkg, cur_class, name) if cur_class else '%s.%s' % (pkg, name)
                rows.append((sf.rel, i, name, body_len, suggested))
    rows.sort()
    for rel, line, name, blen, suggested in rows:
        print('CANDIDATE-ZONE  %-56s L%-6d %-18s ~%d 行\n%-17s 建议: @Zone[%s]' % (rel, line, name, blen, '', suggested))
    print('\n== 热点候选 %d 处 ==（人工确认：函数含循环/FFI/锁/递归/大对象操作才值得埋点）' % len(rows))
    if zone_counter:
        print('\n== 现有 @Zone 埋点密度（前 10）==')
        for rel, n in zone_counter.most_common(10):
            print('  %-56s %d' % (rel, n))
    print('宏来自 src/profiler/macros/ProfileMacros.cj，受 THREE_PROFILER 环境变量按链路前缀门控。')


if __name__ == '__main__':
    main()
