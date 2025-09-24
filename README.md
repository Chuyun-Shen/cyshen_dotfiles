# `.zshrc` 自用版本
风格和原生的比较相似，但是做了很多基础功能，实用且好用。
这份文档带你从 **安装 Zsh**、**从 Bash 切换到 Zsh**、**安装必要插件与工具**、**应用本仓库的 `.zshrc` 配置**，到最后用 **`config` 裸仓库** 同步你的 dotfiles（包含 **Fork 流程** 与日常 **pull/push 同步**）。

---

## 1. 安装 Zsh 与必要工具

### 1.1 安装 Zsh

* **macOS（Homebrew）**

  ```bash
  brew install zsh
  ```
* **Debian / Ubuntu**

  ```bash
  sudo apt update
  sudo apt install zsh
  ```
* **Arch / Manjaro**

  ```bash
  sudo pacman -S zsh
  ```
* **Fedora**

  ```bash
  sudo dnf install zsh
  ```

### 1.2 安装可选增强工具（建议）

* `fzf`（模糊查找/历史搜索增强）
* `git`（用于管理 dotfiles）
* **macOS 额外建议**：`coreutils`（提供 `gls`，以支持 GNU 风格的 `ls --color`）

示例：

```bash
# macOS
brew install fzf git coreutils
# 安装 fzf 的按键/补全（按提示操作）
"$(brew --prefix)"/opt/fzf/install

# Debian / Ubuntu
sudo apt install fzf git

# Arch
sudo pacman -S fzf git
```

---

## 2. 从 Bash 切换到 Zsh

1. 查看当前 Shell：

```bash
echo $SHELL
```

2. 切换默认登录 Shell 为 Zsh：

```bash
chsh -s "$(which zsh)"
```

> 注：切换后**重新登录**或**重启终端**生效。也可临时输入 `zsh` 进入 Zsh 会话。

---

## 3. 安装 Zsh 插件（本配置使用）

我们使用三个插件：

* `zsh-syntax-highlighting`（命令语法高亮）
* `zsh-autosuggestions`（基于历史的自动建议）
* `zsh-history-substring-search`（↑/↓ 依据“输入子串”在历史中搜索匹配）

建议把插件放在 `~/.zsh/plugins/` 下：

```bash
mkdir -p ~/.zsh/plugins

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ~/.zsh/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions \
  ~/.zsh/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-history-substring-search \
  ~/.zsh/plugins/zsh-history-substring-search
```

---

## 4. 应用本仓库的 `.zshrc`

1. **备份**你现有的 `.zshrc`（如有）：

```bash
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.bak.$(date +%Y%m%d%H%M%S)
```

2. 将仓库中的 `.zshrc` 放到 `~/.zshrc`（直接复制粘贴或 `cp`）。

3. 重新加载：

```bash
exec zsh
# 或：source ~/.zshrc
```

> **功能点提示**
>
> * 提示符：绿色 `user@host` + 蓝色当前目录（有普通版和粗体覆盖版）。
> * 彩色 `ls/grep`：Linux 直接可用；macOS 建议安装 `coreutils` 用 `gls`。
> * `fzf`：若已安装，会自动注入 Ctrl-R/Alt-C/Ctrl-T 等增强。
> * 插件：已启用语法高亮、自动建议和**子串历史搜索**（输入任意片段后按 `↑/↓` 在历史里跳）。
> * Conda：使用 `$HOME/miniconda3` 的通用初始化逻辑，并设置 `CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1`。
> * 历史：20k 条，去重与共享历史已开启。
> * `config`：dotfiles 裸仓库便捷别名。

---

## 5. 用 `config` 裸仓库同步到 GitHub

### 5.1 目标与术语

* **目标**：用一个隐藏的裸仓库（`~/.dotfiles`）管理 `$HOME` 下受控文件（如 `~/.zshrc`），工作区就是 `$HOME` 本身。
* **命令别名**：本仓库的 `.zshrc` 里已定义

  ```zsh
  alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
  ```

### 5.2 首次 Fork & 初始化（你是使用他人的 dotfiles 仓库时）

1. **在 GitHub 上 Fork** 原始仓库到你自己的账户（例如得到 `git@github.com:<你>/dotfiles.git`）。

2. **在本机初始化裸仓库并忽略敏感/庞大文件**：

```bash
git init --bare "$HOME/.dotfiles"
config config --local status.showUntrackedFiles no

# 建议的全局忽略（按需增减）
cat > ~/.gitignore <<'EOF'
.zsh_history
.ssh/
.cache/
.local/
.miniconda3/
.conda/
.DS_Store
node_modules/
EOF
config add ~/.gitignore
config commit -m "chore: add global ignore"
```

3. **连接远端（origin 指向你自己的 Fork）并拉取**

```bash
config remote add origin git@github.com:<你的用户名>/dotfiles.git
# 或 HTTPS：
# config remote add origin https://github.com/<你的用户名>/dotfiles.git

# 如果远端已有内容（常见），先把远端取回并在 $HOME 工作区检出
config fetch origin
config checkout -f main 2>/dev/null || config checkout -f master
```

4. **（可选）绑定 upstream**（指向原始仓库，方便后续同步上游更新）

```bash
config remote add upstream git@github.com:<原始作者>/dotfiles.git
# 或 HTTPS：
# config remote add upstream https://github.com/<原始作者>/dotfiles.git
```

> 之后你就可以用 `config` 在 `$HOME` 直接增删改文件并提交推送了。

### 5.3 已有本地修改时的安全同步（日常工作流）

**查看状态与差异**

```bash
config status
config diff
```

**从远端拉取（推荐 rebase 方式，保持历史整洁）**

```bash
# 建议设置默认行为：
config config pull.rebase true
config config rebase.autoStash true

# 拉取（如果默认没设好，也可以手动）：
config pull --rebase origin main   # 或 master
```

**有本地未提交改动时（更稳妥的做法）**

```bash
config stash push -u -m "pre-pull"
config pull --rebase origin main   # 或 master
config stash pop                   # 可能出现冲突，按提示解决
```

**解决冲突**

1. 打开有冲突的文件（例如 `~/.zshrc`），手动删除 `<<<<<<<`, `=======`, `>>>>>>>` 标记并合并内容。
2. 标记解决并继续：

   ```bash
   config add ~/.zshrc
   config rebase --continue    # 如果当前处于 rebase 流程
   ```

   如果是 `stash pop` 造成冲突，解决后：

   ```bash
   config add ~/.zshrc
   config commit -m "Resolve conflicts after stash pop"
   ```

**提交与推送**

```bash
config add ~/.zshrc
config commit -m "Update .zshrc"
config push
```

### 5.4 同步上游（upstream）更新到你的 Fork（可选）

当上游仓库有更新时：

```bash
config fetch upstream
config checkout main            # 或 master
config rebase upstream/main     # 或 upstream/master
config push origin main         # 将合并后的结果推回你的 Fork
```

### 5.5 常见问题

* **“refusing to merge unrelated histories”**
  远端不是空仓库且历史不一致：

  ```bash
  config pull origin main --allow-unrelated-histories
  ```

  解决冲突后再 `config push`。

* **SSH 推送失败**：配置公钥。

  ```bash
  ssh-keygen -t ed25519 -C "<你的邮箱>"
  cat ~/.ssh/id_ed25519.pub  # 复制到 GitHub > Settings > SSH and GPG keys
  ssh -T git@github.com      # 测试
  ```

* **不想跟踪某些文件/目录**：加入 `~/.gitignore`，然后：

  ```bash
  config rm --cached <文件/目录> -r
  config commit -m "chore: update ignore"
  ```

---

## 6. Conda 初始化说明（与本 `.zshrc` 配置匹配）

本 `.zshrc` 使用如下逻辑（通用，优先 `$HOME/miniconda3`）：

```zsh
__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
  else
    export PATH="/home/chuyun/miniconda3/bin:$PATH"
  fi
fi
unset __conda_setup
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
```

> 如果你的 Conda 路径不同，请自行调整；或执行一次 `conda init zsh` 让 Conda 写入官方初始化片段。

---

## 7. 功能速览与快捷键

* **子串历史搜索**：输入任意片段（如 `ls -a`）→ 按 `↑/↓` 在历史中按**包含该片段**搜索并跳转。
* **自动建议**（灰色提示）：基于历史，`→` 或 `End` 可接受建议（终端配置不同略有差别）。
* **`fzf` 常用**：

  * `Ctrl-R`：模糊搜索历史命令
  * `Ctrl-T`：模糊选文件插入命令行
  * `Alt-C`：模糊选目录并 `cd`

---

## 8. 一键安装插件（可选附录）

```bash
mkdir -p ~/.zsh/plugins
for repo in zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search; do
  url=https://github.com/zsh-users/$repo
  dest="$HOME/.zsh/plugins/$repo"
  [ -d "$dest" ] || git clone "$url" "$dest"
done
echo "Plugins installed under ~/.zsh/plugins"
```

