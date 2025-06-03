Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Devsh-Graphics-Programming/Nabla/master/compose.yml" -OutFile "compose.yml"

docker compose -f compose.yml down

docker network ls --filter "type=custom" -q | ForEach-Object {
    docker network rm $_
}

docker compose -f compose.yml up -d --pull always --force-recreate

docker image prune -f
