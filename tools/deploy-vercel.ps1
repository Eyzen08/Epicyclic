<#
.SYNOPSIS
Builds the Flutter web release and deploys it to Vercel as a static site.

.DESCRIPTION
Vercel's build image does not ship the Flutter SDK, so this script builds
build/web locally and uploads it as a prebuilt static deployment
(.vercel/output). It stages the bundle, writes cache headers for the
unhashed entry points, and promotes the result to production.

The deployed app runs in demo mode (no Supabase defines). To ship a Supabase
build, pass extra defines through -BuildArg, e.g.

  -BuildArg '--dart-define=APP_MODE=supabase','--dart-define=SUPABASE_URL=...','--dart-define=SUPABASE_ANON_KEY=...'

.PARAMETER SkipBuild
Deploy the existing build/web without rebuilding. Use when only headers or
project settings changed.

.PARAMETER Preview
Create a preview deployment instead of promoting to production.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File tools\deploy-vercel.ps1

.EXAMPLE
powershell -ExecutionPolicy Bypass -File tools\deploy-vercel.ps1 -SkipBuild -Preview
#>
[CmdletBinding()]
param(
  [switch]$SkipBuild,
  [switch]$Preview,
  [string]$Project = 'epicyclic-store',
  [string]$Scope = 'eyzen08s-projects',
  [string]$Flutter = 'C:\dev\flutter\flutter\bin\flutter.bat',
  [string[]]$BuildArg = @()
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root

try {
  if (-not $SkipBuild) {
    if (-not (Test-Path $Flutter)) {
      $found = Get-Command flutter -ErrorAction SilentlyContinue
      if (-not $found) {
        throw "Flutter not found. Pass -Flutter <path to flutter.bat>."
      }
      $Flutter = $found.Source
    }

    Write-Host 'Building the web release...' -ForegroundColor Cyan
    & $Flutter build web --release --no-wasm-dry-run @BuildArg
    if ($LASTEXITCODE -ne 0) {
      throw "flutter build web failed (exit $LASTEXITCODE)."
    }
  }

  $source = Join-Path $root 'build\web'
  if (-not (Test-Path (Join-Path $source 'index.html'))) {
    throw 'build\web\index.html is missing. Run again without -SkipBuild.'
  }

  $output = Join-Path $root '.vercel\output'
  $static = Join-Path $output 'static'
  if (Test-Path $static) { Remove-Item $static -Recurse -Force }
  New-Item -ItemType Directory -Path $static -Force | Out-Null
  Copy-Item (Join-Path $source '*') $static -Recurse -Force

  # preview.html is a local device-frame harness, not part of the storefront.
  Remove-Item (Join-Path $static 'preview.html') -Force -ErrorAction SilentlyContinue

  # Entry points keep their names across builds, so they must revalidate.
  # Flutter's build output is otherwise content-stable enough for a short
  # shared cache.
  $config = @'
{
  "version": 3,
  "routes": [
    {
      "src": "/assets/(.*)",
      "headers": { "cache-control": "public, max-age=3600" },
      "continue": true
    },
    {
      "src": "/canvaskit/(.*)",
      "headers": { "cache-control": "public, max-age=3600" },
      "continue": true
    },
    { "handle": "filesystem" },
    { "src": "/(.*)", "dest": "/index.html" }
  ]
}
'@
  $configPath = Join-Path $output 'config.json'
  [System.IO.File]::WriteAllText(
    $configPath,
    ($config -replace "`r`n", "`n"),
    (New-Object System.Text.UTF8Encoding($false))
  )

  $cli = Get-Command vercel.cmd -ErrorAction SilentlyContinue
  if (-not $cli) { $cli = Get-Command vercel -ErrorAction SilentlyContinue }
  if (-not $cli) { throw 'The Vercel CLI is not installed. Run: npm install -g vercel' }

  $deployArgs = @(
    'deploy', '--prebuilt', '--yes',
    '--project', $Project,
    '--scope', $Scope
  )
  if ($Preview) {
    $deployArgs += '--target=preview'
  } else {
    $deployArgs += '--prod'
  }

  Write-Host "Deploying to Vercel project '$Project'..." -ForegroundColor Cyan
  & $cli.Source @deployArgs
  $deployCode = $LASTEXITCODE

  if ($deployCode -ne 0) {
    # A fresh clone has no project yet; create it and retry once.
    Write-Host "Deployment failed (exit $deployCode). Ensuring project '$Project' exists..." -ForegroundColor Yellow
    & $cli.Source project add $Project --scope $Scope
    if ($LASTEXITCODE -ne 0) {
      throw "Vercel deployment failed and project '$Project' could not be created."
    }
    & $cli.Source @deployArgs
    $deployCode = $LASTEXITCODE
  }

  if ($deployCode -ne 0) {
    throw "vercel deploy failed (exit $deployCode)."
  }
}
finally {
  Pop-Location
}
