"""中英文分词：查询与建索引用同一套算法，保证命中一致。

- 英文标识符：整词小写 + 驼峰/数字分段（addScalar -> addscalar, add, scalar）
- 中文：单字 + 相邻双字 bigram（向量 -> 向, 量, 向量）
返回可含重复项的列表；计数用 Counter，查询去重用 set。
"""

from __future__ import annotations

import re

_RAW = re.compile(r"[a-zA-Z_][a-zA-Z0-9_]*|[\u4e00-\u9fff]+")
_CAMEL = re.compile(r"(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-zA-Z])(?=\d)")
_MAX_TOK_LEN = 48
_DIGITS = re.compile(r"^\d+$")


def tokenize(text: str) -> list[str]:
    tokens: list[str] = []
    for raw in _RAW.findall(text):
        if raw[0].isascii():
            low = raw.lower()
            if len(low) <= _MAX_TOK_LEN and not _DIGITS.match(low):
                tokens.append(low)
            for part in _CAMEL.split(raw):
                part = part.lower().strip("_")
                if part and len(part) <= _MAX_TOK_LEN and not _DIGITS.match(part):
                    tokens.append(part)
        else:
            for i in range(len(raw)):
                tokens.append(raw[i])
            if len(raw) >= 2:
                for i in range(len(raw) - 1):
                    tokens.append(raw[i : i + 2])
    return tokens