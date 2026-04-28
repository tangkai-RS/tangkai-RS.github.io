param(
  [string]$TargetRepo = 'https://github.com/tangkai-RS/tangkai-RS.github.io.git',
  [string]$Branch = 'main',
  [string]$WorkDir = "$PSScriptRoot\\..\\.deploy-release"
)

$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$buildDir = Join-Path $root '_site'
$bundle = 'C:\Ruby40-x64\bin\bundle.bat'

if (-not (Test-Path $bundle)) {
  throw "Ruby/Bundler not found at $bundle"
}

Push-Location $root
try {
  & $bundle exec jekyll build

  if (-not (Test-Path $buildDir)) {
    throw "Jekyll build did not generate $buildDir"
  }

  if (Test-Path $WorkDir) {
    Remove-Item $WorkDir -Recurse -Force
  }

  git clone --branch $Branch $TargetRepo $WorkDir | Out-Host

  Get-ChildItem $WorkDir -Force |
    Where-Object { $_.Name -ne '.git' } |
    Remove-Item -Recurse -Force

  Copy-Item (Join-Path $buildDir '*') $WorkDir -Recurse -Force
  New-Item -ItemType File -Path (Join-Path $WorkDir '.nojekyll') -Force | Out-Null

  Push-Location $WorkDir
  try {
    git add -A
    if (-not (git diff --cached --quiet)) {
      $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
      git commit -m "Deploy static site ($timestamp)" | Out-Host
      git push origin $Branch | Out-Host
    }
    else {
      Write-Host 'No deployable changes detected.'
    }
  }
  finally {
    Pop-Location
  }
}
finally {
  Pop-Location
}
