param([string]$LogPath = (Join-Path ([IO.Path]::GetTempPath()) 'starry-widgetbook.log'))
$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..')
try {
  flutter run -d chrome --web-port=54417 -t lib/main.dart *> $LogPath
  $result = $LASTEXITCODE
  Write-Output "Log: $LogPath"
} finally {
  Pop-Location
}
exit $result
