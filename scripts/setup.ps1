$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$runtimeRoot = Join-Path $projectRoot '.hermes'

if (-not (Get-Command hermes -ErrorAction SilentlyContinue)) {
    throw 'Hermes is not installed or not in PATH. Follow the README installation steps.'
}

New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
foreach ($file in @(@('.env.example', '.env'), @('config.example.yaml', 'config.yaml'))) {
    $destination = Join-Path $runtimeRoot $file[1]
    if (-not (Test-Path -LiteralPath $destination)) {
        Copy-Item -LiteralPath (Join-Path $projectRoot $file[0]) -Destination $destination
    }
}
Write-Host 'Project initialized. Existing settings were preserved.'
Write-Host 'Fill TELEGRAM_BOT_TOKEN, DEEPSEEK_API_KEY and TELEGRAM_ALLOWED_USERS in .hermes/.env.'
Write-Host 'Then run: powershell -NoProfile -File ./scripts/start.ps1'
