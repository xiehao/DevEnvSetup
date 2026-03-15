$RootDir = Split-Path $PSScriptRoot -Parent
. (Join-Path $RootDir "Resources\Messages.ps1")
$ResourceDir = Join-Path $RootDir "Resources"
$ScriptDir = Join-Path $PSScriptRoot "CoreScripts"
$StateFile = Join-Path $PSScriptRoot ".setup_state.json"

# State initialization
if (Test-Path $StateFile) {
    $State = Get-Content $StateFile | ConvertFrom-Json
    # Ask user whether to restart when all steps completed last time
    if ($State.Step -ge 5) {
        $choice = Read-Host (T "ResetChoice")
        if ($choice -eq "Y" -or $choice -eq "y") { 
            $State.Step = 1
        }
    }
}
else {
    # Initialize values at first time
    $State = @{
        Step       = 1;
        WSLPath    = "D:\WSL";
        ScoopPath  = "D:\Scoop";
        GlobalPath = "D:\ScoopGlobal"
    }
}

# Help function: save current state (which step now)
function Save-State($s) {
    $State.Step = $s
    $State | ConvertTo-Json | Out-File $StateFile
}

Write-Host (T "Start") -ForegroundColor Cyan

for ($i = [int]$State.Step; $i -le 4; $i++) {
    $Script = Get-ChildItem -Path $ScriptDir -Filter "0$i*.ps1"
    if ($Script) {
        Write-Host ("`n" + ((T "StepRunning") -f $i, $Script.Name)) -ForegroundColor Cyan
        & $Script.FullName 
        $Code = $LASTEXITCODE
        if ($Code -eq 3010) {
            Write-Host ((T "RebootNote") -f $i) -ForegroundColor Yellow
            Save-State ($i + 1)
            exit 3010
        }
        if ($null -ne $Code -and $Code -ne 0) {
            Write-Host ((T "ErrorExit") -f $i, $Code) -ForegroundColor Red
            exit $Code
        }
        Save-State ($i + 1)
    }
}
Write-Host ("`n" + (T "Success")) -ForegroundColor Green
pause
