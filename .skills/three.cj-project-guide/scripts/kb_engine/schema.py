"""共享常量：数据库标识、schema 版本、检索默认值、文档分类表。"""

APPLICATION_ID = 0x54484A43  # "THJC"
SCHEMA_VERSION = "1"
ROUTING_ASSET = "routing-index-v1.json.gz"

DEFAULT_MAX_CHARS = 24000  # 叶子展开的总字符上限
DEFAULT_MAX_PAGES = 20  # 子树展开的页数上限

# 目录分类：doc/api/zh-cn/<pkg>/<目录>/xxx.md
KIND_BY_DIR = {
    "类": "class",
    "接口": "interface",
    "枚举": "enum",
    "结构体": "struct",
    "函数": "function",
    "宏": "macro",
    "类型别名": "alias",
    "变量与常量": "constants",
    "异常": "exception",
}
# 包根目录的聚合索引文件（如 函数.md / 类.md）
AGGREGATE_STEMS = {
    "函数": "function-list",
    "类": "class-list",
    "接口": "interface-list",
    "枚举": "enum-list",
    "结构体": "struct-list",
    "函数": "function-list",
    "宏": "macro-list",
    "类型别名": "alias-list",
    "变量与常量": "constants-list",
    "readme": "readme",
}