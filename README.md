# AWD Ubuntu Base - QAX Edition

本镜像基于 `Ubuntu 20.04`，为 AWD（Attack With Defense）竞赛定制，适用于通过平台接口自动获取 Flag 的 PHP 题目环境。内置 SSH、MySQL、Apache2、PHP7.4，并自动监控核心服务状态，适合快速部署和评测。

---

## 📦 镜像特性

- ✅ **自动获取 Flag**：每 5 秒通过接口 `https://${IP}/Getkey/index/index` 获取 flag，写入 `/flag` 文件并导出为环境变量 `$QAXFLAG`
- ✅ **自动导入数据库**：首次启动自动导入 `/var/www/html/db.sql`
- ✅ **支持解析隐藏文件**：Apache 已配置可访问 `.xxx.php` 等以 `.` 开头的文件
- ✅ **核心服务自愈机制**：若检测到 SSH、MySQL、Apache 任一服务未监听，将自动重启
- ✅ **基于 TUNA 镜像源**：更快速的软件安装
- ✅ **时区配置**：设定为 `Asia/Shanghai`
- ✅ **完整 PHP7.4 + MySQL 运行环境**：内置 `php7.4`、`libapache2-mod-php7.4` 和 `php7.4-mysql`

---

## 🔐 默认账户信息

| 服务类型 | 用户名 | 密码     |
|----------|--------|----------|
| 系统 SSH | root   | ikun666  |
| 系统 SSH | ctf    | 123456   |
| MySQL    | ctf    | 123456   |

> ⚠️ **建议比赛前自行修改密码以确保安全。**

---

## 🚀 端口说明

| 服务    | 端口号 |
|---------|--------|
| SSH     | 22     |
| Apache2 | 80     |
| MySQL   | 3306   |

---

## 🛠️ 文件结构说明
```
.
├── Dockerfile # 环境构建脚本
├── update_flag.sh # 启动后持续运行：服务检测 + 自动拉 flag
├── html/ # 网站目录 (自动复制到 /var/www/html)
│ ├── index.php
│ ├── db.sql # 启动时自动导入的 SQL 脚本
│ └── ... # 其他 PHP 文件
└── README.md # 本文件
```
---

## 📋 使用说明

### 一、构建镜像

```bash
docker build -t awd_qax_php .
```
### 二、运行容器
```bash
docker run -d -p 2222:22 -p 8080:80 -p 3307:3306 --name awd_qax awd_qax_php
```


## 📡 Flag 拉取机制详解
update_flag.sh 会在容器启动后每 5 秒执行以下流程：

检查 SSH / MySQL / Apache2 服务是否运行，未运行则尝试重启

若 MySQL 已运行且首次启动，则导入 /var/www/html/db.sql

通过以下命令请求平台 Flag 接口：

```bash
curl -k https://${IP}/Getkey/index/index
```
将返回结果写入：

`/flag`文件

环境变量 $QAXFLAG

日志记录路径：/root/update_flag.log
