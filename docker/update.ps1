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
    docker network ls --filter "type=custom" -q | ForEach-Object {
        try {
            docker network rm $_
        } catch {
            Write-Host "Warning: Failed to remove network ID $_"
        }
    }
} catch {
    Write-Host "Warning: network list/remove failed, continuing..."
}

docker compose -f compose.yml up -d --pull always --force-recreate

docker image prune -f
