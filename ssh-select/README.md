# ssh-select

SSH 主机选择器，交互式选择 `~/.ssh/config` 中的主机并建立连接。

## 目录结构

```
ssh-select/
├── ssh-select.plugin.zsh  # oh-my-zsh 插件入口
├── zsh-ssh-select         # 旧版脚本（保留兼容）
└── README.md
```

## 安装方式

### Oh My Zsh（推荐）

```bash
git clone https://github.com/yourname/ssh-select.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ssh-select
```

编辑 `~/.zshrc`，在 `plugins` 中添加 `ssh-select`：

```zsh
plugins=(... ssh-select)
```

然后重启终端或执行 `source ~/.zshrc`。

### 手动加载

```zsh
# 添加到 ~/.zshrc
source /path/to/ssh-select/ssh-select.plugin.zsh
```

## 使用方法

### 交互式选择

```bash
$ ssh-select
```

弹出 fzf 列表，选择主机后回车即可连接。

### 直接连接指定主机

```bash
$ ssh-select web-server
```

### 配合 alias

```zsh
alias ss='ssh-select'
```

## 依赖

- zsh 5.0+
- [fzf](https://github.com/junegunn/fzf)
- `~/.ssh/config` 文件存在且可读

## License

MIT
