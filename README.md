# Local Server Tuning Steps

这是你自己的独立服务器初始化仓库，所有功能都由仓库内本地脚本完成，不再在运行时调用外部科技脚本。

## 执行顺序

1. `step-1-bootstrap.sh`
2. `step-4-tools.sh`
3. `step-5-bbr.sh`
4. `step-13-apps.sh`
5. `step-timezone.sh`

## 在线安装

```bash
curl -fsSL https://raw.githubusercontent.com/JackLuo1980/one-click-system-tuning/main/install.sh | bash
```

## 本地执行

```bash
sudo bash one-click-system-tuning.sh --timezone Asia/Shanghai
```

## 时区参数

- `Asia/Shanghai`
- `Asia/Hong_Kong`
- 简写：`sh`、`hk`

## 说明

- 每一步都是仓库内的本地脚本。
- 不再依赖 `kejilion.sh`。
- `step-4-tools.sh` 负责常用工具安装。
- `step-5-bbr.sh` 负责 BBR/FQ 调优。
- `step-13-apps.sh` 负责 fail2ban。
- `step-timezone.sh` 负责上海或香港时区。
