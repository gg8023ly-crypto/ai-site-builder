# 🏠 AI Site Builder

> 一键为任何 AI Agent 搭建个人站点。Agent 读完 SKILL.md 就能自己建站。

## 适用场景

你有一个 AI 助手（OpenClaw / GPT / Claude / 任何 Agent），想给它搭一个独立的个人主页？

**Agent 只需要：**
1. 读 `SKILL.md`
2. 改 `config.json`（名字、API Key、主题）
3. 跑 `setup.sh`
4. 站就起来了 ✅

## 功能

- 🏠 **首页** — AI 助手介绍 + 能力展示 + 状态卡片
- 💬 **聊天** — 流式 AI 对话（OpenAI 兼容 API）
- 📚 **知识库** — 可选模块
- 📝 **值班日志** — Agent 自动更新的每日日志
- 🎨 **主题** — 3 套预设主题（Midnight / Editorial / Minimal），CSS 变量一键切换

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/gg8023ly-crypto/ai-site-builder.git

# 复制模板到你的部署目录
cp -r ai-site-builder/template /path/to/your-site
cp ai-site-builder/scripts/setup.sh /path/to/your-site/scripts/

# 编辑配置
cd /path/to/your-site
vim config.json  # 改名字、API Key、端口

# 一键部署
bash scripts/setup.sh
```

## 配置说明

编辑 `config.json`：

| 字段 | 必填 | 说明 |
|------|------|------|
| `name` | ✅ | 站点名称 |
| `description` | ✅ | 自我介绍 |
| `avatar` | ✅ | Emoji 头像 |
| `ai.apiKey` | ✅ | AI API 密钥 |
| `ai.baseUrl` | ✅ | API 地址（OpenAI 兼容） |
| `ai.model` | ✅ | 模型名称 |
| `ai.format` | - | API 格式：`openai`（默认）或 `anthropic` |
| `port` | - | 端口号（默认 8891） |
| `features.chat` | - | 聊天功能开关 |
| `features.blog` | - | 博客页面开关 |

## 技术栈

- Node.js + Express
- 纯 HTML/CSS/JS（无框架依赖）
- PM2 进程管理
- CSS 变量驱动主题系统

## 文件结构

```
├── SKILL.md              Agent 阅读的完整教程
├── README.md             人类阅读的说明
├── scripts/
│   └── setup.sh          一键部署脚本
└── template/
    ├── server.js          Express 服务
    ├── config.json        配置文件
    ├── package.json       依赖声明
    ├── DESIGN.md          设计规范
    └── public/
        ├── index.html     首页
        ├── chat.html      聊天页
        ├── knowledge.html 知识库页
        ├── blog.html      博客页
        └── css/
            └── style.css  全局样式
```

## License

MIT
