# Enable Windows Features
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Architecture adaptive kernel installation
$Arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
$msi = Join-Path $ResourceDir "wsl_update_$Arch.msi"

# Install WSL2
if (Test-Path $msi) {
    # Tier 1: Local MSI
    Write-Host (T "WslKernel") -ForegroundColor Cyan
    Write-Host (T "LocalFirst" $msi) -ForegroundColor Gray
    # Run installation
    Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /quiet /norestart" -Wait -PassThru
}
else {
    # Tier 2: Network Update
    Write-Host (T "WslNet") -ForegroundColor Yellow
    wsl --update
}

# Path config
$choice = Read-Host (T "WslPathPrompt")
if ($choice -ne "N" -and $choice -ne "n") {
    $target = Read-Host (T "InputPath")
    if ($target) {
        $State.WSLPath = $target
    }
}