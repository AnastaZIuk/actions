Add-Type -AssemblyName System.Web.Extensions

$configFile = Join-Path $env:USERPROFILE ".docker\config.json"

if (Test-Path $configFile) {
    $jsonText = Get-Content $configFile -Raw
    $jsonObj = [System.Web.Script.Serialization.JavaScriptSerializer]::new().DeserializeObject($jsonText)
    $jsonObj["credsStore"] = ""

    $jsonNet = [Newtonsoft.Json.JsonConvert]::SerializeObject($jsonObj, [Newtonsoft.Json.Formatting]::Indented)
    [System.IO.File]::WriteAllText($configFile, $jsonNet, [System.Text.Encoding]::UTF8)
} else {
    Write-Host "config.json not found, skipping credsStore patch."
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
