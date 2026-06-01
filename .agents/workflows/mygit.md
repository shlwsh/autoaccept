---
description: 自动总结 ROS 2 代码与文档变更并提交到远程仓库
---

# Git 自动提交工作流 (antigravity-autoaccept)

这个工作流会自动完成以下操作:

1. 检测 Git 仓库的所有变更（JS 代码、元数据、配置、文档等）
2. 使用 AI 分析变更并生成提交信息（未配置 API Key 时按规则生成中文说明）
3. 提交到本地仓库
4. 推送到远程仓库

## 使用方法

```bash
bun run mygit
bun run mygit:check-ai   # 仅验证 AI API 是否可达
```

在 Cursor 中也可通过工作流 `/mygit` 触发（需已配置 `.agents/workflows`）。

## 工作流程

1. **检查 Git 仓库** — 确认当前目录是 Git 仓库
2. **检测变更** — 获取所有修改、新增、删除的文件
3. **添加到暂存区** — 执行 `git add -A`，自动排除 `logs/`、`log/`、`build/`、`install/`；`.env` / `.env.mygit` 等会强制纳入提交
4. **生成提交信息** — 先探测 LLM 连通性；通过后再调用 AI。未配置 Key、连接失败或调用失败时，按规则自动生成中文提交信息
5. **提交** — 执行 `git commit`
6. **推送** — 执行 `git push`

## 环境变量（用于 AI 提交说明）

在项目根目录创建或编辑 `.env.mygit`（模板见 `.agent/skills/mygit/resources/env.mygit.template`）：

```env
DASHSCOPE_API_KEY=sk-xxx
DASHSCOPE_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
DASHSCOPE_MODEL=deepseek-v3
MYGIT_HTTP_PROXY=http://127.0.0.1:7897
```

也可使用 `OPENAI_API_KEY` / `OPENAI_API_BASE` / `OPENAI_API_MODEL`。

**加速选项**（`.env.mygit`）：

- `MYGIT_NO_AI=1` 或 `MYGIT_FAST_RULES=1`：跳过 AI，仅用规则生成（最快）
- `MYGIT_AI_TIMEOUT_MS=15000`：AI 超时后自动回退规则（默认 15s）
- `MYGIT_AI_PROBE_TIMEOUT_MS=8000`：提交前连通性探测超时（失败则不调用 AI）
- 含 PDF/ZIP 等二进制时，diff 不对二进制做全文 diff，且默认跳过 AI（`MYGIT_FORCE_AI=1` 可强制）

WSL2 下推送若遇 TLS/凭据问题，可配置 `GITHUB_TOKEN` 或使用 `./scripts/mygit.sh`（Python 版，含 Windows Git 集成）。

## 注意事项

- 确保已配置 Git 用户信息（`git config user.name` 和 `git config user.email`）
- 确保有远程仓库的推送权限
- 提交信息使用中文，并遵循 Conventional Commits（如 `feat(src): ...`）
- 未配置 API Key 时仍可通过规则回退正常提交
- 推送到 `*.winning.com.cn` 内网远程时会自动绕过本地 HTTP 代理
- 运行日志写入 `logs/app.log`，该目录不会被 mygit 提交

## 示例输出

```
📝 检测到以下变更:
  修改: src/extension.js
  未跟踪: docs-zh/mygit-wsl-setup.md

🤖 正在生成提交信息...

📋 生成的提交信息 (规则生成（未配置或 AI 不可用）):
──────────────────────────────────────────────────
chore(src): 修改 1 个文件，未跟踪 1 个文件

- 修改: src/extension.js
- 未跟踪: docs-zh/mygit-wsl-setup.md
──────────────────────────────────────────────────

✅ 代码已提交到本地仓库
🚀 正在推送到远程仓库 origin...
✅ 代码已推送到远程仓库
```
