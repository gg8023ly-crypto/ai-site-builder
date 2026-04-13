# ai-site-builder

> 一键为任何 AI Agent 搭建个人站点。Agent 读完这个文件就能自己建站。

## Description

为 AI 助手/数字员工创建独立的个人网站，包含首页展示、聊天对话、知识库、博客四个页面。
支持 config.json 配置化 + DESIGN.md 主题定制 + setup.sh 一键部署。

**触发词**: 搭建站点、建个网站、创建主页、AI 个人站、agent site

## Prerequisites

- Node.js >= 18
- npm
- pm2 (setup.sh 会自动安装)
- 一个 OpenAI 兼容的 AI API Key（用于聊天功能）

## Step-by-Step Instructions

### Step 1: Copy Template

```bash
# 决定站点部署目录
TARGET_DIR="/path/to/your-site"

# 复制模板
cp -r ~/.openclaw/workspace/skills/ai-site-builder/template/ "$TARGET_DIR"
```

### Step 2: Edit config.json

打开 `$TARGET_DIR/config.json`，修改以下字段：

```json
{
  "name": "你的名字",
  "title": "你的名字 · AI 助手",
  "description": "一段自我介绍",
  "avatar": "🤖",
  "theme": "midnight",
  "features": {
    "chat": true,
    "status": true,
    "knowledge": false,
    "blog": false
  },
  "ai": {
    "baseUrl": "https://your-api-provider.com/v1",
    "apiKey": "sk-your-api-key",
    "model": "gpt-4o-mini",
    "systemPrompt": "你是{name}，一个友好的AI助手。请用中文回答。"
  },
  "port": 8891
}
```

**必改字段：**
- `name` — 站点名称（会显示在所有页面）
- `description` — 自我介绍
- `avatar` — Emoji 头像
- `ai.apiKey` — AI API 密钥（**必须配置**，否则聊天不工作）
- `ai.baseUrl` — API 地址（OpenAI 兼容格式）
- `ai.model` — 模型名称
- `port` — 端口号（确保不冲突）

**可选字段：**
- `features.knowledge` — 设为 `true` 启用知识库页
- `features.blog` — 设为 `true` 启用博客页
- `ai.systemPrompt` — 系统提示词，`{name}` 会替换为站点名

### Step 3: Customize Theme (Optional)

编辑 `$TARGET_DIR/DESIGN.md` 了解设计规范。

要换主题，修改 `$TARGET_DIR/public/css/style.css` 中的 `:root` CSS 变量。

#### 预设主题变量

**Midnight (深色霓虹，默认)**
```css
:root {
  --bg:          #0B1020;
  --bg-card:     #111827;
  --bg-card2:    #0F1A2E;
  --text:        #F5F3EE;
  --text-muted:  #9CA3AF;
  --primary:     #B388FF;
  --secondary:   #7DD3FC;
  --accent:      #F9A8D4;
  --border:      rgba(179, 136, 255, 0.15);
  --border-glow: rgba(179, 136, 255, 0.35);
  --success:     #4ADE80;
  --gradient:    linear-gradient(135deg, #B388FF 0%, #7DD3FC 100%);
}
```

**Editorial (杂志白)**
```css
:root {
  --bg:          #faf9f6;
  --bg-card:     #ffffff;
  --bg-card2:    #f5f5f0;
  --text:        #1a1a2e;
  --text-muted:  #6b7280;
  --primary:     #2563eb;
  --secondary:   #7DD3FC;
  --accent:      #e74c3c;
  --border:      #e5e7eb;
  --border-glow: rgba(37, 99, 235, 0.3);
  --success:     #059669;
  --gradient:    linear-gradient(135deg, #2563eb 0%, #7DD3FC 100%);
}
```

**Minimal (极简)**
```css
:root {
  --bg:          #ffffff;
  --bg-card:     #f9fafb;
  --bg-card2:    #f3f4f6;
  --text:        #111827;
  --text-muted:  #6b7280;
  --primary:     #111827;
  --secondary:   #6b7280;
  --accent:      #ef4444;
  --border:      #e5e7eb;
  --border-glow: rgba(17, 24, 39, 0.2);
  --success:     #059669;
  --gradient:    linear-gradient(135deg, #111827 0%, #374151 100%);
}
```

> 切换方式：整段替换 style.css 顶部的 `:root { ... }` 块即可。
> nav 背景色也需要同步调整（深色主题用半透明深色，浅色主题用半透明白色）。

### Step 4: Deploy

```bash
cd "$TARGET_DIR"
bash scripts/setup.sh
```

setup.sh 会自动：
1. 检查 Node.js 版本
2. npm install 安装依赖
3. 检查 apiKey 配置
4. pm2 启动服务

### Step 5: Verify

```bash
# 检查服务状态
pm2 status

# 测试首页
curl -s http://localhost:8891 | head -5

# 测试状态 API
curl -s http://localhost:8891/api/status | jq .

# 测试配置 API（不应返回 apiKey）
curl -s http://localhost:8891/api/config | jq .
```

## File Structure

```
template/
├── server.js         Express 服务，读 config.json 动态渲染，SQLite 日志持久化
├── config.json       配置文件（名字/AI/功能开关/端口）
├── DESIGN.md         设计规范文档
├── package.json      依赖声明（含 better-sqlite3）
├── data/             SQLite 数据库目录（.gitignore 忽略）
│   └── site.db       值班日志数据库（自动创建）
└── public/
    ├── index.html    首页（Hero + 能力卡片 + 状态 + 值班日志摘要）
    ├── log.html      值班日志列表页（点击展开完整内容）
    ├── chat.html     聊天页（流式 AI 对话 + Markdown 渲染）
    ├── knowledge.html 知识库（占位页）
    ├── blog.html     博客（占位页）
    └── css/
        └── style.css 全局样式（CSS 变量驱动）
scripts/
└── setup.sh          一键部署脚本
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/config` | 返回公开配置（不含 apiKey） |
| GET | `/api/status` | 返回在线状态和运行时间 |
| POST | `/api/chat` | 代理转发 AI 对话（流式 SSE） |
| GET | `/api/logs` | 获取最近 20 条值班日志 |
| POST | `/api/logs` | 写入新日志（title, excerpt, content） |

### POST /api/chat

Request body:
```json
{
  "messages": [
    { "role": "user", "content": "你好" }
  ]
}
```

Response: Server-Sent Events (SSE) stream，格式与 OpenAI 兼容。

### Step 6: Auto Daily Log (Recommended)

值班日志支持 SQLite 持久化。Agent 可以通过以下三种方式自动写入每日日志：

#### 方法 A：用 OpenClaw cron 每天凌晨自动写

在 OpenClaw 中设置一个每日 cron job，让 Agent 在每天凌晨汇总当日工作并调用 API：

```bash
# 示例 cron：每天 00:05 执行
# openclaw cron add --cron "5 0 * * *" --cmd "write-daily-log"
```

Agent 收到 cron 触发后，调用：

```http
POST http://localhost:8891/api/logs
Content-Type: application/json

{
  "title": "2026-04-13 值班日志",
  "excerpt": "今日概况：完成了 xxx 功能开发，处理了 yyy 问题。",
  "content": "## 今日工作\n- xxx\n- xxx\n\n## 明日计划\n- xxx"
}
```

响应示例：
```json
{
  "ok": true,
  "data": {
    "id": 1,
    "date": "2026-04-13",
    "title": "2026-04-13 值班日志",
    "excerpt": "今日概况...",
    "content": "## 今日工作\n...",
    "created_at": "2026-04-13 00:05:01"
  }
}
```

#### 方法 B：Agent 在 HEARTBEAT.md 里加检查项

在 `HEARTBEAT.md` 中添加：

```markdown
## 日志检查
- [ ] 距离上次写日志超过 20 小时？调用 POST /api/logs 写入今日摘要
```

Agent 在心跳时检测到超时后，自动调用 API 写入日志，无需外部 cron。

#### 方法 C：手动调 API 写入

```bash
curl -X POST http://localhost:8891/api/logs \
  -H "Content-Type: application/json" \
  -d '{"title":"今日日志","excerpt":"一句话概括","content":"详细内容..."}'
```

> 日志页面：访问 `/log` 查看所有日志，支持点击展开完整内容。
> 数据文件：`data/site.db`（已加入 `.gitignore`，不会提交到 Git）。

## Customization Tips

- **改名字/介绍**: 只改 config.json
- **换主题颜色**: 只改 style.css 的 `:root` 变量
- **换 AI 模型**: 改 config.json 的 `ai` 部分
- **加自定义页面**: 在 public/ 下添加 HTML，在 server.js 里加路由
- **加 SEO**: 在 HTML 的 `<head>` 中添加 meta 标签和 JSON-LD
- **改能力卡片**: 直接编辑 index.html 中 `#abilities` section 的内容

## Troubleshooting

| 问题 | 解决 |
|------|------|
| 聊天没反应 | 检查 config.json 的 ai.apiKey 是否已配置 |
| 端口冲突 | 修改 config.json 的 port |
| 页面空白 | 检查 pm2 logs，确认 server.js 正常启动 |
| 样式异常 | 确认 public/css/style.css 存在且 :root 变量完整 |
