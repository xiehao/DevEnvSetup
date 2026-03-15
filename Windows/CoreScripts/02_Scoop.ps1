Write-Host (T "ScoopInstall") -ForegroundColor Cyan

# Set environment variables
$env:SCOOP = $State.ScoopPath
$env:SCOOP_GLOBAL = $State.GlobalPath
[Environment]::SetEnvironmentVariable('SCOOP', $State.ScoopPath, 'User')
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $State.GlobalPath, 'Machine')

# Scoop executor with error-handler
function Exec-Scoop {
    param([string]$Command, [string]$ScoopArgs)
    Write-Host ">>> Executing: scoop $Command $ScoopArgs" -ForegroundColor Gray
    Invoke-Expression "scoop $Command $ScoopArgs"
    if ($LASTEXITCODE -ne 0) {
        # For bucket add, errors showing "bucket exists" are not considered 
        if ($Command -eq "bucket" -and $ScoopArgs -like "add*") {
            Write-Host "Bucket already exists, continuing..." -ForegroundColor DarkGray
        }
        else {
            Write-Host "[ERROR] Scoop command failed: $Command $ScoopArgs" -ForegroundColor Red
            exit 1
        }
    }
}

# Install Scoop (using native image)
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    # Network install via mirror
    Set-ExecutionPolicy RemoteSigned -Scope Process -Force
    Invoke-Expression "& {$(Invoke-WebRequest -useb scoop.201704.xyz)} -RunAsAdmin"
    if ($LASTEXITCODE -ne 0) {
        exit 1
    }
}

# Privilege for current user to have access to installed directory
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
icacls "$($State.ScoopPath)" /grant "${CurrentUser}:(OI)(CI)F" /T /Q /C

# Configure Buckets and Core tools
Write-Host "--- Configuring Tools and Buckets ---" -ForegroundColor Cyan

# Installing basic tools (7zip, git)
Exec-Scoop "install" "7zip git"

# Reset and add buckets (main, extras)
Invoke-Expression "scoop bucket rm main" 2>$null # 移除允许失败，因为可能本来就没有
Exec-Scoop "bucket" "add main"
Exec-Scoop "bucket" "add extras"

# Installing core apps (podman, vscode)
Exec-Scoop "install" "podman vscode"

# Cleaning up caches
Write-Host "Cleaning up Scoop cache..." -ForegroundColor Gray
Exec-Scoop "cache" "rm *"

# Add an exception for dobious ownership
git config --global --add safe.directory "$State.ScoopPath/*"

Write-Host "Scoop environment setup completed successfully." -ForegroundColor Green