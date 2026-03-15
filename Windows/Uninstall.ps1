$RootDir = Split-Path $PSScriptRoot -Parent
. (Join-Path $RootDir "Resources\Messages.ps1")

# Load state file
$StateFile = Join-Path $PSScriptRoot ".setup_state.json"
if (Test-Path $StateFile) {
    $State = Get-Content $StateFile | ConvertFrom-Json
} else {
    # Default values
    $State = @{ ScoopPath = "D:\Scoop"; GlobalPath = "D:\ScoopGlobal"; WSLPath = "D:\WSL" }
}

# Close related processes forcely
Write-Host "Closing all potential background processes..." -ForegroundColor Gray
$TargetProcs = "Code", "podman*", "git*", "wsl*", "ssh-agent", "gpg-agent", "node"
foreach ($p in $TargetProcs) { 
    Stop-Process -Name $p -Force -ErrorAction SilentlyContinue 
}
Start-Sleep -Seconds 2 # Wait for OS to release file handlers

# Error handler
function Exec-Uninstall {
    param([string]$Desc, [scriptblock]$Action)
    Write-Host ">>> $Desc..." -ForegroundColor Cyan
    try {
        & $Action
        Write-Host "Done." -ForegroundColor Gray
    } catch {
        Write-Host "[ERROR] Failed to $Desc : $_" -ForegroundColor Red
        $choice = Read-Host "Critical error. Continue anyway? (Y/N)"
        if ($choice -ne "Y" -and $choice -ne "y") { exit 1 }
    }
}

$Options = @(
    @{ ID = 1; Key = "UnOpt1"; Action = { 
        Exec-Uninstall (T "UnOpt1") {
            if (Get-Command podman -ErrorAction SilentlyContinue) {
                podman machine stop 2>$null
                podman machine rm 
            }
        }
    }},
    @{ ID = 2; Key = "UnOpt2"; Action = { 
        Exec-Uninstall (T "UnOpt2") {
            if (Get-Command scoop -ErrorAction SilentlyContinue) {
                scoop uninstall vscode podman git 7zip 
            }
        }
    }},
    @{ ID = 3; Key = "UnOpt3"; Action = {
        Exec-Uninstall (T "UnOpt3") {
            # Try native uninstaller by scoop
            if (Get-Command scoop -ErrorAction SilentlyContinue) {
                $env:SCOOP_CHECK_ADMIN = 0
                scoop uninstall scoop 2>$null
            }
            
            # Cleanup related environment variables
            [Environment]::SetEnvironmentVariable('SCOOP', $null, 'User')
            [Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $null, 'Machine')
            
            # Physically purge via CMD (bypass Junction restriction of PS)
            $paths = @($State.ScoopPath, $State.GlobalPath, "$env:USERPROFILE\.scoop")
            foreach ($p in $paths) {
                if ($p -and (Test-Path $p)) {
                    Write-Host "Deep cleaning folder: $p" -ForegroundColor Gray
                    # Using cmd /c rd is often more thorough than Remove-Item
                    cmd /c "rd /s /q `"$p`"" 2>$null
                    if (Test-Path $p) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
                }
            }
        }
    }},
    @{ ID = 4; Key = "UnOpt4"; Action = {
        Exec-Uninstall (T "UnOpt4") {
            $LocalAppPath = "$env:LOCALAPPDATA\containers"
            if (Test-Path $LocalAppPath) { cmd /c "rd /q `"$LocalAppPath`"" }
            
            if ($State.WSLPath -and (Test-Path $State.WSLPath)) {
                cmd /c "rd /s /q `"$($State.WSLPath)`""
            }
            if (Test-Path $StateFile) { Remove-Item $StateFile -Force }
        }
    }}
)

# Menu display
Clear-Host
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  $(T 'UnTitle')" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

foreach ($Opt in $Options) { Write-Host " [$($Opt.ID)] $(T $Opt.Key)" }
Write-Host " [A] $(T 'UnAll')" -ForegroundColor Red
Write-Host " [Q] $(T 'UnQuit')"
Write-Host "------------------------------------------"

$Input = Read-Host (T "UnSelect")
if ([string]::IsNullOrWhiteSpace($Input) -or $Input.ToLower() -eq "q") { Write-Host (T "UnCancel"); exit }

# Build task queue
$Selection = if ($Input.ToLower() -eq "a") { $Options } else {
    $Ids = $Input -split ','; $Ids | ForEach-Object { $id = $_.Trim(); $Options | Where-Object { $_.ID -eq $id } }
}

if ($Selection) {
    if ((Read-Host (T "UnConfirm")) -eq "Y") {
        # Uninstall in a correct order
        $Selection | Sort-Object { $_.ID } | ForEach-Object { & $_.Action }
        Write-Host "`n$(T 'UnSuccess')" -ForegroundColor Green
    }
}
pause
