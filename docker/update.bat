@echo off
echo [1/3] Downloading latest compose.yml
curl -sSL https://raw.githubusercontent.com/Devsh-Graphics-Programming/Nabla/master/compose.yml -o compose.yml
if errorlevel 1 exit /b %errorlevel%

echo [2/3] Updating containers with latest image(s)
docker compose -f compose.yml up -d --pull always
if errorlevel 1 exit /b %errorlevel%

echo [3/3] Removing dangling images
docker image prune -f
if errorlevel 1 exit /b %errorlevel%

echo Done.
