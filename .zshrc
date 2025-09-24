##### ========== 颜色与提示符 ==========
autoload -Uz colors && colors
# 设置类似 Bash 的彩色提示符：绿色 user@host，蓝色工作目录
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f %# '

##### ========== 保持 ls/grep 的彩色高亮 ==========
if command -v dircolors >/dev/null 2>&1; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
alias ls='ls --color=auto'
alias ll='ls -lh --group-directories-first --color=auto'
alias la='ls -A --color=auto'
alias lla='ls -alh --group-directories-first --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

##### ========== fzf 集成交互补全（若已安装） ==========
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

##### ========== 插件 ==========
# 语法高亮
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# 历史自动建议
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# 子串历史搜索（↑/↓ 按“包含当前输入的片段”筛历史）
if [ -f ~/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source ~/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
  # 上/下键绑定（含兼容序列）
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '\eOA' history-substring-search-up
  bindkey '\eOB' history-substring-search-down
fi

##### ========== Conda 激活 & OpenSSL 警告处理==========
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

##### ========== Bash 风格的粗体彩色提示符 ==========
autoload -Uz colors && colors
PROMPT='%B%F{green}%n@%m%b%f:%B%F{blue}%~%b%f$ '

##### ========== 历史配置 ==========
HISTFILE=~/.zsh_history     # 历史文件路径
HISTSIZE=20000              # 内存里最多保存多少条历史
SAVEHIST=20000              # 写入文件多少条历史

setopt APPEND_HISTORY       # 将命令追加到历史文件（而不是覆盖）
setopt SHARE_HISTORY        # 多个 zsh 会话共享历史，实时同步
setopt HIST_IGNORE_ALL_DUPS # 不保存重复命令
setopt HIST_FIND_NO_DUPS    # 搜索历史时不重复
setopt HIST_IGNORE_SPACE    # 以空格开头的命令不入历史

##### ========== 你的别名（保持） ==========
alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
