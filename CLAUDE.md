# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

个人旅行攻略合集。每个目的地一份逐日 Markdown 行程 + 地图坐标 + 配图,统一用一个 HTML 互动地图浏览。已部署到 GitHub Pages。

## 目录结构

```
.
├── index.html                  # 互动地图前端(GitHub Pages 入口,不要改名)
├── build_map.py                # 构建脚本:汇总各目的地数据
├── map-data.bundle.js          # 构建产物,pre-commit hook 自动维护(详见下方)
├── README.md                   # 给人看的项目说明
├── CLAUDE.md                   # 本文件
├── europe/  asia/  africa/  oceania/    # 按大洲分类的目的地
│   └── <slug>/                 # 每个目的地一个文件夹
│       ├── map-data.json       # 该目的地的坐标和路线
│       ├── *.md                # 行程文档(任意文件名,通常含"规划"/"攻略"/"执行手册")
│       └── images/             # 配图,md 里用 ./images/ 相对路径引用
├── scripts/
│   ├── pre-commit              # git hook 源码
│   └── install-hooks.sh        # hook 安装脚本(clone 后跑一次)
├── 北欧9天最终方案.md         # 历史规划文档,保留作记录
└── 北欧多国游方案.md 等           # 同上
```

## 常用命令

```bash
# 首次 clone 后跑一次,把 scripts/pre-commit 装进 .git/hooks/
bash scripts/install-hooks.sh

# 手动重建 bundle(本地预览前必须跑;commit 时 hook 会自动跑)
python3 build_map.py

# 本地预览 —— 纯静态,不需要 server,直接浏览器打开即可
open index.html

# 验证某个目的地的数据合规性(JSON schema、md 结构、图片存在性)
python3 ~/.claude/skills/travel-itinerary-builder/scripts/validate_itinerary.py <continent>/<slug>
```

## 工作原理(Architecture)

纯静态站点,没有后端。数据流:

1. `build_map.py` 扫描 `europe/`、`asia/`、`africa/`、`oceania/` 下每个目的地文件夹,读取 `map-data.json` + 一个 `.md` 文件。
2. 输出单一 bundle `map-data.bundle.js`,挂载 4 个全局变量:
   - `window.ITINERARY_INDEX` —— 所有目的地的元数据列表(按大洲+名称排序)
   - `window.ITINERARY_PLANS` —— `{plan_id: {points, routes}}` 地图数据
   - `window.ITINERARY_CONTENTS` —— `{plan_id: <md 全文>}`,用 JS 模板字符串装载(已转义 `\``、`${`)
   - `window.ITINERARY_IMAGE_DIRS` —— `{plan_id: "./<continent>/<slug>/images/"}`
3. `index.html` 在 `DOMContentLoaded` 时读这四个变量渲染 Leaflet 地图 + 侧栏 md。

**多 md 文件的选择规则**:`build_map.py:find_md_file()` 优先选名字含"执行手册"/"规划"/"攻略"的文件,否则取第一个匹配。一个目的地有多份 md(如草稿+定稿)时,用关键字命名定稿那份避免歧义。

**路线颜色由 `route.type` 决定**:`drive`/`fly`/`ferry`/`train` 分别对应 `index.html` 里 `--line-drive`/`--line-fly`/`--line-ferry`/`--line-train` 四个 CSS 变量,改类型即改颜色。

## 关键约定(违反会出错)

1. **`map-data.bundle.js` 是构建产物,不要手编**。它由 `build_map.py` 扫描所有目的地后生成。pre-commit hook 已配置:任何源文件改动都会自动重建并 `git add` 这个文件。
2. **目的地文件夹名 = `map-data.json` 里的 `plan_id`**,统一用 kebab-case 语义 slug(`iceland`、`norway-denmark`、`japan-hokkaido`、`new-zealand-south-island`)。不要用 `a`/`b`/`c` 这种旧式编号——那是已淘汰的命名方式。
3. **`plan_id` 必须是 4 个大洲之一的子目录**:`europe/`、`asia/`、`africa/`、`oceania/`。其他目录(`scripts/`、根目录散文件)不会被 `build_map.py` 扫描。
4. **图片用相对路径** `./images/<filename>.jpg`,放在该目的地文件夹的 `images/` 里。
5. **不要跳过 pre-commit hook**(不要 `--no-verify`)。它保证仓库里 bundle 永远与源同步,关系到 GitHub Pages 部署正确性。
6. **不要在项目内创建 `.skills/` 副本**。这个 skill 的真理来源是 `~/.claude/skills/travel-itinerary-builder/`,跨项目共享。

## 添加新目的地的 SOP

```bash
# 1. 选大洲建文件夹
mkdir -p europe/<slug>/images

# 2. 准备三件套
#    - europe/<slug>/map-data.json   (plan_id 必须等于 <slug>)
#    - europe/<slug>/<任意名>.md     (含 # D1｜...、# D2｜... 等天数标题)
#    - europe/<slug>/images/*.jpg    (md 里 ./images/ 引用的图)

# 3. commit —— hook 会自动 build bundle 并入库
git add europe/<slug>
git commit -m "feat: 新增 <slug> 攻略"
git push
```

`map-data.json` 必填字段:`plan_id`、`name`、`color`、`center: [lat, lng]`、`zoom`、`points[]`、`routes[]`。每个 `point` 必填:`id`、`name`、`lat`、`lng`、`img`、`desc`、`tags`、`docAnchor`(对应 md 里的 `# D<N>｜` 锚点,如 `d1`)。`route.type` 限四选一:`drive`/`fly`/`ferry`/`train`。完整 schema 在 `~/.claude/skills/travel-itinerary-builder/references/output-schema.md`。

## 部署

- 远程:`git@github.com:RinshannKaihou/travel-guide.git`
- GitHub Pages 已启用,从 `main` 分支根目录部署
- 线上地址:https://rinshannkaihou.github.io/travel-guide/
- push main → 1-2 分钟自动上线

## 不要碰

- `map-data.bundle.js`(产物)
- `.git/hooks/pre-commit`(改源文件 `scripts/pre-commit` 然后跑 `bash scripts/install-hooks.sh`)
- 根目录的"北欧9天最终方案.md"等历史文档(保留作记录,虽然结构不符合新 schema)

## 这个项目用的 skill

`travel-itinerary-builder`,位于 `~/.claude/skills/travel-itinerary-builder/`。当用户说"我想去 xx 旅游"、"帮我规划 x 天"、"生成 xx 攻略"时该 skill 会触发,自动产出 md + json + 配图三件套。

skill 自带一份 `build_map.py` 副本(用于在新项目里 bootstrap),但本项目根目录的 `build_map.py` 是 canonical 版本,以本项目为准。
