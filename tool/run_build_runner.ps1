param([string]$LogPath = (Join-Path ([IO.Path]::GetTempPath()) 'starry-build-runner.log'))
$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..')
try {
  dart run build_runner build --delete-conflicting-outputs *> $LogPath
  $result = $LASTEXITCODE
  Write-Output "Log: $LogPath"
} finally {
  Pop-Location
}
exit $result
