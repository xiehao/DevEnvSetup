# Symbolic Link for Path Redirection
Write-Host (T "PodmanLink") -ForegroundColor Cyan
$LocalAppPath = "$env:LOCALAPPDATA\containers"
if (!(Test-Path $LocalAppPath)) {
    $target = Join-Path $State.WSLPath "podman-data"
    if (!(Test-Path $target)) {
        New-Item -ItemType Directory -Path $target -Force
    }
    # Create directory link using CMD
    cmd /c mklink /j "$LocalAppPath" "$target"
}

# Initialize podman machine
if (!(podman machine list | Select-String "podman-machine-default")) {
    # Find local rootfs resource
    $rootfs = Get-ChildItem -Path $ResourceDir -Filter "podman-machine-*.tar*" | Select-Object -First 1
    
    if ($rootfs) {
        Write-Host (T "LocalFirst" $rootfs.Name) -ForegroundColor Green

        # Execute initialization
        podman machine init --image-path "$($rootfs.FullName)" --rootful
    } else {
        Write-Host (T "NetFallback") -ForegroundColor Yellow
        podman machine init --rootful
    }
}

# Configure registry mirrors for better connectivity in CN
Write-Host (T "PodmanMirror") -ForegroundColor Cyan
$MirrorConfig = @'
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "docker.io"

[[registry.mirror]]
location = "docker.m.daocloud.io"

[[registry.mirror]]
location = "mirror.ccs.tencentyun.com"
'@

$RemoteDir = "/etc/containers/registries.conf.d"
$RemoteFile = "$RemoteDir/99-cn-mirrors.conf"
$startedByScript = $false
$status = podman machine inspect --format "{{.State}}" 2>$null
if ($status -ne "running") {
    podman machine start
    $startedByScript = $true
}

podman machine ssh -- "sudo mkdir -p $RemoteDir"
$MirrorConfig | podman machine ssh -- "sudo tee $RemoteFile > /dev/null"

if ($startedByScript) {
    podman machine stop
}
