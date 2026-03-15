$Messages = @{
    "zh-CN" = @{
        # --- Main & Logic ---
        "Start"         = "=== 容器开发环境安装程序 ==="
        "StepRunning"   = ">>> 正在运行步骤 {0}: {1}"
        "ErrorExit"     = "[错误] 步骤 {0} 失败，退出码: {1}"
        "RebootNote"    = "[提示] 步骤 {0} 请求重启。请重启电脑后再次运行脚本。"
        "ResetChoice"   = "检测到环境已安装完成。是否重置并重新运行所有步骤？(Y/N, 默认: N)"
        "AllDone"       = "所有步骤已标记为完成。"
        "Success"       = "安装圆满完成！请根据 README 导入 VSCode 配置文件。"

        # --- Step 01: WSL ---
        "WslKernel"     = "正在安装本地 WSL 内核更新..."
        "WslNet"        = "未发现本地资源，尝试通过网络更新 WSL..."
        "WslPathPrompt" = "是否修改 WSL 默认存储路径？(默认: D:\WSL, 输入 N 跳过)"
        "InputPath"     = "请输入路径 [D:\WSL]"

        # --- Step 02: Scoop ---
        "ScoopInstall"  = "正在通过国内镜像安装 Scoop..."
        "ScoopBucket"   = "正在配置 Bucket 和基础工具 (7zip, git)..."

        # --- Step 03: Podman ---
        "PodmanLink"    = "正在创建数据存储符号链接..."
        "PodmanMirror"  = "正在配置 Podman 国内镜像加速..."
        "LocalFirst"    = "检测到本地资源 {0}，优先使用本地安装。"
        "NetFallback"   = "未发现本地资源，尝试通过网络下载安装..."
        "NetworkDrive"  = "检测到网络驱动器，正在拷贝到本地临时目录以规避大小限制..."

        # --- Step 05: Image ---
        "ImgStart"      = "正在启动 Podman 虚拟机..."
        "ImgLoad"       = "正在从本地压缩包导入镜像..."
        "ImgBuild"      = "正在从 Dockerfile 构建镜像..."
        "ImgExists"     = "镜像 {0} 已存在，跳过导入。"
        "ImgMissing"    = "[警告] 未发现镜像资源或 Dockerfile，环境可能不完整。"

        # --- Uninstall ---
        "UnTitle"       = "环境卸载管理器 (默认：不卸载)"
        "UnOpt1"        = "卸载 Podman 虚拟机 (包含所有容器和镜像)"
        "UnOpt2"        = "卸载 VS Code"
        "UnOpt3"        = "卸载 Scoop 及所有已安装工具"
        "UnOpt4"        = "清理 D 盘数据目录及进度记录"
        "UnAll"         = "全部卸载"
        "UnQuit"        = "取消并退出 (默认)"
        "UnSelect"      = "请选择要卸载的编号 (例如: 1,2,4)"
        "UnConfirm"     = "确认执行选中的卸载操作？(Y/N)"
        "UnCancel"      = "操作已取消。"
        "UnSuccess"     = "清理完成。"
    }
    "en-US" = @{
        "Start"         = "=== Container Environment Setup ==="
        "StepRunning"   = ">>> Running Step {0}: {1}"
        "ErrorExit"     = "[ERROR] Step {0} failed with Exit Code: {1}"
        "RebootNote"    = "[NOTE] Step {0} requested a reboot. Please restart and run again."
        "ResetChoice"   = "Setup already completed. Reset and re-run all steps? (Y/N, Default: N)"
        "AllDone"       = "All steps are already marked as completed."
        "Success"       = "Setup Completed Successfully! Check README for VSCode profile."

        "WslKernel"     = "Installing local WSL kernel update..."
        "WslNet"        = "Local MSI not found. Updating WSL via network..."
        "WslPathPrompt" = "Change default WSL path? (Default: D:\WSL, Enter 'N' to skip)"
        "InputPath"     = "Input path [D:\WSL]"

        "ScoopInstall"  = "Installing Scoop via mirror..."
        "ScoopBucket"   = "Configuring Buckets and basic tools (7zip, git)..."

        "PodmanLink"    = "Creating symbolic link for data storage..."
        "PodmanMirror"  = "Configuring Podman registry mirrors..."
        "LocalFirst"    = "Local resource {0} found. Using local installation."
        "NetFallback"   = "Local resource not found. Falling back to network..."
        "NetworkDrive"  = "Network drive detected. Copying to local temp to bypass limits..."

        "ImgStart"      = "Starting Podman machine..."
        "ImgLoad"       = "Loading image from local tarball..."
        "ImgBuild"      = "Building image from Dockerfile..."
        "ImgExists"     = "Image {0} already exists. Skipping."
        "ImgMissing"    = "[WARN] No image source found. Environment may be incomplete."

        "UnTitle"       = "Environment Uninstaller (Default: None)"
        "UnOpt1"        = "Remove Podman Machine (All images/containers)"
        "UnOpt2"        = "Uninstall VS Code"
        "UnOpt3"        = "Uninstall Scoop and all tools"
        "UnOpt4"        = "Clean Data Directories and state file"
        "UnAll"         = "Uninstall ALL"
        "UnQuit"        = "Quit (Default)"
        "UnSelect"      = "Select options to uninstall (e.g., 1,2,4)"
        "UnConfirm"     = "Confirm selected operations? (Y/N)"
        "UnCancel"      = "Cancelled."
        "UnSuccess"     = "Cleanup completed."
    }
}

$Lang = if ((Get-Culture).Name -eq "zh-CN") { "zh-CN" } else { "en-US" }

# Enforced T function, supporting formatted parameters
function T($Key, $Arg0, $Arg1) {
    $Raw = $Messages[$Lang][$Key]
    if ($null -eq $Raw) { return "MISSING_KEY: $Key" }
    if ($null -ne $Arg1) { return $Raw -f $Arg0, $Arg1 }
    if ($null -ne $Arg0) { return $Raw -f $Arg0 }
    return $Raw
}
