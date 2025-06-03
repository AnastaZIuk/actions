$configFile = Join-Path $env:USERPROFILE ".docker\config.json"

if (Test-Path $configFile) {
    $config = Get-Content $configFile -Raw | ConvertFrom-Json
    $config.credsStore = ""
    $config | ConvertTo-Json -Depth 10 | Set-Content -Path $configFile -Encoding UTF8
} else {
    Write-Host "config.json not found, failed to apply credsStore patch."
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
