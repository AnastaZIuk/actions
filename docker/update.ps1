$configDir = Join-Path $env:USERPROFILE ".docker"
$configFile = Join-Path $configDir "config.json"
$sourceUrl = "https://raw.githubusercontent.com/AnastaZIuk/actions/refs/heads/main/docker/windows-ctx-config.json"

New-Item -Path $configDir -ItemType Directory -Force | Out-Null

Invoke-WebRequest -Uri $sourceUrl -OutFile $configFile -Headers @{
    "Cache-Control" = "no-cache"
    "Pragma"        = "no-cache"
}

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Devsh-Graphics-Programming/Nabla/master/compose.yml" `
    -OutFile "compose.yml" `
    -Headers @{
        "Cache-Control" = "no-cache"
        "Pragma"        = "no-cache"
    }

try {
    docker compose -f compose.yml down
} catch {
    Write-Host "Warning: docker compose down failed, continuing..."
}

try {
    if (-not (docker network ls --format '{{.Name}}' | Where-Object { $_ -eq 'docker_default' })) {
        docker network create --driver nat docker_default
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error: failed to create network docker_default"
            exit 1
        }
    }
} catch {
    Write-Host "Error while checking or creating docker_default network: $_"
    exit 1
}

docker compose -f compose.yml up -d --pull always --force-recreate

docker image prune -f
