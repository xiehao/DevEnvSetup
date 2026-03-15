# 容器化编程环境一键配置工具 (README)

本工具专为本科生编程课程设计，旨在通过自动化脚本一键完成 **WSL2、Scoop 包管理器、Podman 容器引擎** 以及 **VSCode** 的开发环境配置。

---

## 📂 项目目录结构

请确保在运行脚本前，你的文件夹布局如下所示：

```text
DevEnvSetup/
├── Windows/                   # Windows 版本脚本
│   ├── Install.bat            # [学生运行] 鼠标右键-以管理员身份运行
│   ├── Install.ps1            # 主控程序逻辑
│   ├── Uninstall.bat          # [学生运行] 鼠标右键-以管理员身份运行
│   ├── Uninstall.ps1          # 主控程序逻辑
│   ├── DownloadResources.ps1  # [教师运行] 用于预下载大文件到 Resources
│   ├── .setup_state.json      # 自动生成：记录安装进度，支持断点续传
│   └── CoreScripts/           # 存放核心逻辑子脚本
│       ├── 01_WSL.ps1         # WSL2 环境配置
│       ├── 02_Scoop.ps1       # Scoop 安装、国内镜像配置与工具软件安装
│       ├── 03_Podman.ps1      # Podman 路径重定向与初始化
│       └── 04_Image.ps1       # 镜像导入与构建
│
└── Resources/                 # 共享资源（存放所有大文件）
    ├── Messages.ps1           # 中英文提示字符串常量集合
    ├── wsl_update_x64.msi     # (可选预下载) WSL2 内核更新包
    ├── fedora-coreos-wsl.xz   # (可选预下载) Podman 离线虚拟机镜像
    ├── Container.code-profile # VSCode 配置文件备份
    ├── arch-cpp-dev.tar.zst   # (可选) 预打包的容器镜像
    └── Dockerfile             # 用于构建镜像的定义文件

```

---

## 🛠️ 安装前准备

### 1. 教师/管理员：下载资源

在分发给学生之前，请先运行 `DownloadResources.ps1`。该脚本会按本机架构自动从网络下载 `wsl_update_xxx.msi` 和 `fedora-coreos-xxx-wsl.xz` 并放入项目根目录的 `Resources`（其中xxx表示架构名称）。

### 2. 学生：环境要求

* **操作系统**：Windows 10 (版本 1903 或更高) 或 Windows 11。
* **硬件**：建议剩余磁盘空间 > 20GB，且 CPU 已在 BIOS 中开启**虚拟化技术 (VT-x/AMD-V)**。

---

## 🚀 安装步骤

1. 将整个 `DevEnvSetup` 文件夹拷贝到你的本地磁盘（**建议放在非系统盘**，如 `D:\DevEnvSetup`）。
2. 进入文件夹，找到 **`Install.bat`**。
3. **右键点击** 该文件，选择 **“以管理员身份运行”**。
4. 根据屏幕提示进行操作：
* **路径选择**：脚本会询问是否将 WSL 和 Scoop 安装在 D 盘，建议按回车接受默认设置以节省 C 盘空间。
* **等待重启**：若脚本提示开启了系统功能，请保存好资料并重启电脑，重启后再次运行该 `.bat` 文件，它将从中断处继续。



---

## 💡 安装后必读 (重要)

安装程序完成后，请务必执行以下手动步骤以完善配置：

### 1. VSCode 配置文件导入

由于 VSCode 权限限制，你需要手动导入环境配置：

* 打开 **VSCode**。
* 点击左下角的 **齿轮图标 (Manage)** -> **配置文件 (Profiles)** -> **导入配置文件... (Import Profile...)**。
* 在弹出的窗口中选择：`..\Resources\Container.code-profile`。

### 2. C 盘残留清理

如果你以前尝试安装过 Docker 或 WSL，C 盘可能残留了巨大的虚拟磁盘文件。请检查并删除以下位置的无效文件：

* `%LocalAppData%\Packages\` (搜索文件夹名包含 `Canonical` 或 `Docker` 的目录并清理其下 `.vhdx`)。
* `%LocalAppData%\Docker\wsl` (若存在)。

### 3. 环境变量生效

虽然脚本尝试自动刷新环境变量，但最稳妥的方式是 **重启一次电脑**，以确保 `scoop` 和 `podman` 命令在所有终端中均可直接使用。

### 4. Podman 国内镜像配置

考虑到国内网络环境，脚本会在初始化 Podman 时自动写入 Docker Hub 的国内镜像配置。若需要更换镜像源，可编辑 `CoreScripts/03_Podman.ps1` 中的镜像列表后重新运行安装流程。

---

> **遇到问题？**
> 如果脚本运行过程中卡住（尤其是网络下载阶段），请关闭窗口并重新运行 `Install.bat`，脚本会自动从失败的步骤重试。
