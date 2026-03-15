$Arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
$ResourceDir = Join-Path (Split-Path $PSScriptRoot -Parent) "Resources"
if (!(Test-Path $ResourceDir)) { New-Item -ItemType Directory -Path $ResourceDir }

# Podman WSL OS 官方源 (v5.7.1)
$PodmanArch = if ($Arch -eq "x64") { "x86_64" } else { "aarch64" }
$PodmanOSUrl = "https://github.com/containers/podman-machine-os/releases/download/v5.7.1/podman-machine.$PodmanArch.wsl.tar.zst"

$Files = @(
    @{ Name = "wsl_update_$Arch.msi"; Url = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_$Arch.msi" },
    @{ Name = "podman-machine-$PodmanArch-wsl.tar.zst"; Url = $PodmanOSUrl }
)

foreach ($File in $Files) {
    $Path = Join-Path $ResourceDir $File.Name
    if (!(Test-Path $Path)) {
        Write-Host "Downloading $($File.Name)..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $File.Url -OutFile $Path
    }
}
Write-Host "Download complete for $Arch architecture. Please put Dockerfile, arch-cpp-dev.tar.zst and Container.code-profile in the root Resources folder." -ForegroundColor Green
