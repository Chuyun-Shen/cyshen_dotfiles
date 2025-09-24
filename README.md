## 快速开始

1. **确认/切换到 Zsh**

```bash
echo $SHELL        # 期望输出类似 /bin/zsh
chsh -s $(which zsh)   # 如果你现在还是 bash，切到 zsh（重登或重启终端生效）
```

2. **安装可选依赖（推荐）**

* fzf（交互式模糊搜索/补全）
* zsh-syntax-highlighting（语法高亮）
* zsh-autosuggestions（历史建议）

常见安装方式：

```bash
# macOS（Homebrew）
brew install zsh fzf
brew install zsh-syntax-highlighting zsh-autosuggestions

# Debian/Ubuntu
sudo apt update
sudo apt install zsh fzf git

# Arch
sudo pacman -S zsh fzf git
```

> `zsh-syntax-highlighting` 与 `zsh-autosuggestions` 多通过 git 克隆到本地（见下文“插件放置”）。

3. **把本文的 `.zshrc` 内容放到 `~/.zshrc`**，按你的环境做两处检查：

* **Conda 路径**：默认写的是 `/home/chuyun/miniconda3`，请改成你的实际安装路径，或使用“通用写法（不改路径）”那段代码。
* **插件路径**：确保 `~/.zsh/plugins/...` 里真的有对应插件目录。

4. **重新加载**

```bash
exec zsh    # 或者：source ~/.zshrc
```

---

## 插件放置（推荐目录结构）

```text
~/.zsh/
└── plugins/
    ├── zsh-syntax-highlighting/
    │   └── zsh-syntax-highlighting.zsh
    └── zsh-autosuggestions/
        └── zsh-autosuggestions.zsh
```

安装示例：

```bash
mkdir -p ~/.zsh/plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
```

---

## 配置详解（逐段说明）

### 1) 彩色提示符（Prompt）

```zsh
autoload -Uz colors && colors
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f %# '
# 下面还有一段“粗体”的覆盖版本（会覆盖上面这行）
autoload -Uz colors && colors
PROMPT='%B%F{green}%n@%m%b%f:%B%F{blue}%~%b%f$ '
```

* 显示为：**绿色**的 `user@host` + **蓝色**的当前目录。
* `%#` / `$`：root 时显示 `#`，普通用户显示 `$`。
* **注意**：你现在有两段 `PROMPT`，**后面的会覆盖前面**。保留**其一**即可：

  * 想要**粗体**版本 → 留后面；
  * 想要**非粗体**版本 → 留前面并删掉后面两行。

### 2) 彩色 `ls/grep`

```zsh
if command -v dircolors >/dev/null 2>&1; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

alias ls='ls --color=auto'
alias ll='ls -lh --group-directories-first --color=auto'
alias la='ls -A --color=auto'
alias lla='ls -alh --group-directories-first --color=auto'

alias grep='grep --color=auto'
egrep='egrep --color=auto'
fgrep='fgrep --color=auto'
```

* Linux 下默认 OK。
* **macOS 提示**：mac 自带 `ls` 为 BSD 版，没有 `--color` / `--group-directories-first`。
  解决办法：

  ```bash
  brew install coreutils
  alias ls='gls --color=auto'
  alias ll='gls -lh --group-directories-first --color=auto'
  alias la='gls -A --color=auto'
  alias lla='gls -alh --group-directories-first --color=auto'
  ```

### 3) `fzf` 交互式补全（可选）

```zsh
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
```

* 检测到装了 `fzf` 就启用补全/小部件，没装则跳过。

### 4) 语法高亮 & 自动建议（可选）

```zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
```

* **加载顺序**：建议**先** highlighing，**再** autosuggestions，符合你的配置。
* 建议样式：建议文字为灰色（`fg=8`）。

### 5) Conda 支持 & OpenSSL 警告处理

当前写法（**需把路径改成你的 Miniconda/Anaconda 安装目录**）：

```zsh
__conda_setup="$('/home/chuyun/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "/home/chuyun/miniconda3/etc/profile.d/conda.sh" ]; then
    . "/home/chuyun/miniconda3/etc/profile.d/conda.sh"
  else
    export PATH="/home/chuyun/miniconda3/bin:$PATH"
  fi
fi
unset __conda_setup

export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
```

更**通用**的写法（不依赖硬编码路径，推荐）：

```zsh
if command -v conda >/dev/null 2>&1; then
  eval "$(conda shell.zsh hook)"
elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
  . "$HOME/miniconda3/etc/profile.d/conda.sh"
fi
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
```

> 也可以直接运行一次 `conda init zsh`，让 Conda 自己写入合适的初始化代码。

### 6) 历史记录优化

```zsh
HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=20000

setopt APPEND_HISTORY       # 追加模式
setopt SHARE_HISTORY        # 多终端共享
setopt HIST_IGNORE_ALL_DUPS # 不保存重复
setopt HIST_FIND_NO_DUPS    # 搜索不重复
setopt HIST_IGNORE_SPACE    # 以空格开头的不入史
```

### 7) dotfiles 快捷命令

```zsh
alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

* 用于管理“裸仓库”式 dotfiles。
* 初次配置参考：

  ```bash
  git init --bare $HOME/.dotfiles
  alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
  config config --local status.showUntrackedFiles no
  ```

---

## Bash 用户需要知道的事

* 这份配置是 **Zsh** 的。若你现在在 **Bash**：

  ```bash
  chsh -s $(which zsh)   # 切换默认 shell 为 zsh（登出/重启终端后生效）
  ```
* 想临时试用：直接运行 `zsh` 进入一个会话，不改变系统默认 shell。

---

## 常见问题（FAQ）

**Q1：提示 `no such file or directory: .../zsh-syntax-highlighting.zsh`？**
A：没有安装或路径不对。按“插件放置”一节克隆到 `~/.zsh/plugins/...`，或把 `source` 路径改成你实际目录。

**Q2：`ls: illegal option -- -`（macOS）？**
A：使用 BSD `ls` 导致。参考上文“彩色 ls/grep”里的 **macOS 解决方案**（安装 coreutils 并用 `gls`）。

**Q3：Conda 没生效或路径不对？**
A：优先使用“**通用写法**”，或执行 `conda init zsh`，然后重新打开终端。

**Q4：`fzf` 没有补全？**
A：确认 `fzf` 已安装；并且你的终端为 zsh。运行 `command -v fzf` 应有路径输出。

**Q5：两个 PROMPT 冲突？**
A：确实。**保留一个**即可；后写的会覆盖先写的。

---

## 进阶自定义

* **把主机名隐藏**（更简洁）：

  ```zsh
  PROMPT='%F{green}%n%f:%F{blue}%~%f %# '
  ```
* **在 git 目录显示分支**（需要 `vcs_info` 或 oh-my-zsh / powerlevel10k 等主题）：

  ```zsh
  autoload -Uz vcs_info
  precmd() { vcs_info }
  setopt prompt_subst
  PROMPT='%F{green}%n@%m%f:%F{blue}%~%f ${vcs_info_msg_0_}%# '
  zstyle ':vcs_info:git:*' formats '(%b)'
  ```

---

## 兼容性提示

* Linux 下选项基本即插即用。
* macOS 需要注意 **coreutils**（`gls`）与 Homebrew 安装插件的路径差异。
* 远程服务器可能没有图形字体支持，提示符中的颜色代码是纯终端 ANSI，不受影响。

---

## 复制用的模板（按需取舍）

> **建议：** 在你的 `.zshrc` 中只保留**一个** `PROMPT` 片段，并选择**通用 Conda 初始化**写法。

```zsh
# ========== Colors & Prompt ==========
autoload -Uz colors && colors
# 选 1：普通
# PROMPT='%F{green}%n@%m%f:%F{blue}%~%f %# '
# 选 2：粗体（推荐外观）
PROMPT='%B%F{green}%n@%m%b%f:%B%F{blue}%~%b%f$ '

# ========== GNU colors for ls/grep ==========
if command -v dircolors >/dev/null 2>&1; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
alias ls='ls --color=auto'
alias ll='ls -lh --group-directories-first --color=auto'
alias la='ls -A --color=auto'
alias lla='ls -alh --group-directories-first --color=auto'
alias grep='grep --color=auto'
egrep='egrep --color=auto'
fgrep='fgrep --color=auto'

# macOS（BSD ls）可改用：
# alias ls='gls --color=auto'
# alias ll='gls -lh --group-directories-first --color=auto'
# alias la='gls -A --color=auto'
# alias lla='gls -alh --group-directories-first --color=auto'

# ========== fzf（可选） ==========
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# ========== Syntax Highlighting & Autosuggestions（可选） ==========
[ -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[ -f ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# ========== Conda（通用写法，推荐） ==========
if command -v conda >/dev/null 2>&1; then
  eval "$(conda shell.zsh hook)"
elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
  . "$HOME/miniconda3/etc/profile.d/conda.sh"
fi
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

# ========== History ==========
HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=20000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_IGNORE_SPACE

# ========== Dotfiles bare repo helper ==========
alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

