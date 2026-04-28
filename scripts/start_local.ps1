param(
  [switch]$InstallOnly
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

function Write-Step($message) {
  Write-Host "[homepage] $message"
}

if (-not (Get-Command bundle -ErrorAction SilentlyContinue)) {
  Write-Host "Ruby / Bundler is not installed yet." -ForegroundColor Yellow
  Write-Host "1. Install Ruby+Devkit from: https://rubyinstaller.org/downloads/"
  Write-Host "2. Reopen VS Code or PowerShell after installation."
  Write-Host "3. Run the VS Code task 'Homepage: Install Gems' once."
  Write-Host "4. Then run the task 'Homepage: Preview'."
  exit 1
}

if ($InstallOnly) {
  Write-Step "Installing Jekyll dependencies with bundle install..."
  bundle install
  exit $LASTEXITCODE
}

Write-Step "Starting local Jekyll preview..."
Write-Step "If this is your first run, press Ctrl+C after install and rerun preview."
bundle exec jekyll serve --livereload --host 127.0.0.1 --port 4000
