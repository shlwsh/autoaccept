#!/bin/bash
# WSL 调用 Windows Git Credential Manager（路径含空格，供 git -c credential.helper 使用）
# 仅在 WSL 环境下可用；原生 Linux / macOS 不应调用本脚本

GCM_EXE="/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"

if [[ -x "$GCM_EXE" ]]; then
  exec "$GCM_EXE" "$@"
fi

# 非 WSL 或未安装 Windows Git：静默失败，由 git 回退到其他凭据方式
echo "git-credential-gcm.sh: GCM not available (non-WSL or Windows Git not installed)" >&2
exit 1
