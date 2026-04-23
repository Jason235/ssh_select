# ssh-select

SSH 主机选择器，用于交互式选择 `~/.ssh/config` 中的主机并建立连接。

## 目录结构

```
ssh-select/
├── zsh-ssh-select    # 插件主脚本
└── README.md         # 本文档
```

## 安装方式

### 方式一：手动安装（推荐）

```bash
# 1. 克隆或复制到 plugins 目录
git clone https://github.com/yourname/ssh-select.git ~/ssh-select

# 2. 添加到 .zshrc
# 使用 oh-my-zsh 的插件目录
git clone https://github.com/yourname/ssh-select.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/ssh-select

# 或手动链接
mkdir -p ~/.zsh/plugins/ssh-select
ln -s ~/ssh-select/zsh-ssh-select ~/.zsh/plugins/ssh-select/
```

编辑 `~/.zshrc`，添加插件：

```zsh
plugins=(ssh-select)
```

或手动加载（添加到 `~/.zshrc`）：

```zsh
# 加载 ssh-select 插件
fpath=(~/.zsh/plugins/ssh-select $fpath)
autoload -Uz ssh-select
alias ss='ssh-select'
```

### 方式二：Oh My Zsh 用户

```bash
# 克隆到 custom/plugins
git clone https://github.com/yourname/ssh-select.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/ssh-select
```

然后在 `.zshrc` 中启用：

```zsh
plugins=(ssh-select)
```

### 方式三：手动软链接

```bash
# 创建插件目录
mkdir -p ~/.zsh/plugins/ssh-select

# 创建软链接
ln -s /path/to/ssh-select/zsh-ssh-select ~/.zsh/plugins/ssh-select/zsh-ssh-select

# 添加到 .zshrc
echo 'fpath=(~/.zsh/plugins/ssh-select $fpath)' >> ~/.zshrc
echo 'autoload -Uz ssh-select' >> ~/.zshrc
```

## 使用方法

### 交互式选择

直接运行 `ssh-select`，会列出所有可用主机：

```bash
$ ssh-select
🔐 SSH Select (5 hosts found)
----------------------------------------
1) web-server
2) db-primary
3) staging
4) prod-api
5) dev-local
#? 
```

使用上下键选择，输入编号后回车即可连接。

### 直接连接指定主机

```bash
$ ssh-select web-server
# 直接连接到 web-server
```

### 配合 alias 使用

添加常用 alias（添加到 `~/.zshrc`）：

```zsh
alias ss='ssh-select'
alias ssweb='ssh-select web-server'
```

## 依赖

- zsh 5.0+
- [fzf](https://github.com/junegunn/fzf) 0.44+
- ~/.ssh/config 文件存在且可读

## 工作原理

- 解析 `~/.ssh/config` 中的 `Host` 指令
- 使用 `select` 语句提供交互式菜单
- 支持直接传入主机名参数进行快速连接

## License

MIT