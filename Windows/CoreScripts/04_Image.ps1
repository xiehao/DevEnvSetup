$status = podman machine inspect --format "{{.State}}"
if ($status -ne "running") {
    Write-Host (T "ImgStart")
    podman machine start 
}

if (podman images -q arch-cpp-dev) {
    Write-Host (T "ImgExists" "arch-cpp-dev") -ForegroundColor Green
}
else {
    $tar = Join-Path $ResourceDir "arch-cpp-dev.tar.zst"
    $df = Join-Path $ResourceDir "Dockerfile"

    # Tier 1: Local Load
    if (Test-Path $tar) {
        Write-Host (T "ImgLoad")
        podman load -i $tar
    }
    # Tier 2: Build from Dockerfile
    elseif (Test-Path $df) {
        Write-Host (T "ImgBuild")
        podman build -t arch-cpp-dev:latest -f $df $ResourceDir
    }
    else {
        Write-Warning (T "ImgMissing") 
    }
}