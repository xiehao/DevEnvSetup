# macOS 容器化编程环境一键配置

本目录提供 macOS 上的自动化配置脚本，完成 **Homebrew、Podman、VSCode** 的安装与配置，并保持与 Windows 版本一致的 Podman/VScode 逻辑。

## 目录结构

```text
macOS/
├── Install.sh                 # 自动安装脚本
├── Uninstall.sh               # 卸载脚本
├── DownloadResources.sh       # [教师运行] 预下载 macOS 专用 Podman 镜像
├── 手动安装指南.md              # 自动化脚本失效时的备选方案
├── CoreScripts/
│   ├── 01_Homebrew.sh
│   ├── 02_Podman.sh
│   └── 03_Image.sh
└── ../Resources/              # 与 Windows 共用
```

## 安装前准备（教师/管理员）

在分发给学生之前，请先运行资源下载脚本，下载 macOS 专用的 Podman 虚拟机镜像（applehv 格式）：

```bash
bash DownloadResources.sh
```

> **注意**：macOS 使用 Apple Hypervisor Framework，与 Windows WSL 使用不同格式的 Podman 镜像。请勿混用。

## 使用方法

1. 进入 `macOS` 目录。
2. 执行安装脚本：

```bash
bash Install.sh
```

如需卸载，执行：

```bash
bash Uninstall.sh
```

如自动化脚本失效，请参考 `手动安装指南.md` 手动完成配置。

## 说明

- 不使用 WSL。
- Homebrew 使用国内镜像源以提升下载速度。
- Podman 初始化、镜像导入/构建逻辑与 Windows 保持一致。
- 资源文件位于项目根目录的 `Resources`，Windows 与 macOS 共用。
- macOS 的 Podman 虚拟机镜像格式为 **applehv**（Apple Hypervisor），与 Windows 的 WSL 格式不同。
