# 旅行攻略合集 · Interactive Travel Guide

一个个人旅行规划仓库:每个目的地一份逐日 Markdown 行程 + 地图坐标 + 配图,统一在一个交互式 HTML 地图里浏览。

## 已收录的目的地

| 大洲 | 目的地 |
|---|---|
| 欧洲 | 冰岛、意大利多洛米蒂+威尼斯、挪威+丹麦、挪威峡湾、苏格兰、瑞典+丹麦 |
| 亚洲 | 格鲁吉亚、日本北海道、土耳其 |
| 非洲 | 埃及 |
| 大洋洲 | 新西兰南岛 |

## 目录结构

```
travel_guide/
├── interactive-map.html        # 交互式地图前端(单文件)
├── build_map.py                # 构建脚本:汇总所有目的地数据
├── map-data.bundle.js          # 构建产物(已 ignore,本地自动生成)
├── europe/
│   └── iceland/
│       ├── map-data.json       # 该目的地的地图数据(坐标、路线)
│       ├── *.md                # 行程文档
│       └── images/             # 景点配图
├── asia/ · africa/ · oceania/  # 同上结构
└── scripts/
    ├── pre-commit              # 提交前自动重建 bundle
    └── install-hooks.sh        # 安装 hook
```

每个目的地文件夹都是**自包含**的三件套:`map-data.json` + `*.md` + `images/`。

## 快速开始

```bash
git clone git@github.com:RinshannKaihou/travel-guide.git
cd travel-guide

# 安装 git hook(只需一次)
bash scripts/install-hooks.sh

# 构建 bundle(本地预览前必须跑一次)
python3 build_map.py

# 直接用浏览器打开
open interactive-map.html
```

## 新增/修改一个目的地

1. 在对应大洲下建文件夹,放入 `map-data.json`、行程 `*.md`、`images/`。
2. `git add` + `git commit` —— pre-commit hook 会自动跑 `build_map.py` 把新数据合并进 bundle。
3. 刷新浏览器即可看到新行程。

### `map-data.json` 字段

```json
{
  "plan_id": "iceland",          // 唯一 ID,与文件夹名一致
  "name": "冰岛环岛",            // 显示名称
  "color": "#9ecbf3",            // 路线颜色
  "center": [64.96, -18.5],      // 地图中心 [lat, lng]
  "zoom": 6,
  "points": [ ... ],             // 景点坐标
  "routes": [ ... ]              // 路线段
}
```

## 工作原理

`build_map.py` 扫描 `europe/`、`asia/`、`africa/`、`oceania/` 各子目录,把每个目的地的 JSON + Markdown 合并打包成 `map-data.bundle.js`。HTML 通过 `window.ITINERARY_INDEX / PLANS / CONTENTS / IMAGE_DIRS` 四个全局变量读取数据 —— 纯静态,无后端。

## 版本管理约定

- `.DS_Store`、`.skills/`、`.claude/settings.local.json`、`map-data.bundle.js` 不入库。
- 提交前自动重建 bundle(via `scripts/pre-commit`)。
- 新目的地或重大重构后打 tag(如 `v1.0`、`v1.1`)。
