$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$runtimeRoot = Join-Path $projectRoot '.hermes'
$envPath = Join-Path $runtimeRoot '.env'

if (-not (Get-Command hermes -ErrorAction SilentlyContinue)) {
    throw 'Hermes is not installed or not in PATH. See README.md.'
}
if (-not (Test-Path -LiteralPath $envPath)) {
    throw 'Run scripts/setup.ps1 first and fill .hermes/.env.'
}
$settings = @{}
foreach ($line in Get-Content -LiteralPath $envPath) {
    if ($line -match '^\s*([A-Z][A-Z0-9_]*)\s*=\s*(.*?)\s*$') {
        $settings[$matches[1]] = $matches[2].Trim([char]34).Trim([char]39)
    }
}
foreach ($name in @('TELEGRAM_BOT_TOKEN', 'DEEPSEEK_API_KEY', 'TELEGRAM_ALLOWED_USERS')) {
    if ([string]::IsNullOrWhiteSpace($settings[$name])) {
        throw "Fill $name in .hermes/.env before starting."
    }
}
if ($settings['TELEGRAM_ALLOWED_USERS'] -notmatch '^\d+(\s*,\s*\d+)*$') {
    throw 'TELEGRAM_ALLOWED_USERS must contain numeric user IDs separated by commas.'
}
if ($settings['TELEGRAM_ALLOW_ALL_USERS'] -ne 'false') {
    throw 'Set TELEGRAM_ALLOW_ALL_USERS=false in .hermes/.env.'
}

$previousHome = $env:HERMES_HOME
Push-Location $projectRoot
try {
    $env:HERMES_HOME = $runtimeRoot
    & hermes gateway run
    if ($LASTEXITCODE -ne 0) { throw "Hermes exited with code $LASTEXITCODE." }
} finally {
    $env:HERMES_HOME = $previousHome
    Pop-Location
}
