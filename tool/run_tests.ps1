param([string]$LogPath = (Join-Path ([IO.Path]::GetTempPath()) 'starry-ui-tests.log'))
$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..')
try {
  flutter test test/tier2_sheet5_components_test.dart test/no_hardcoded_colors_test.dart *> $LogPath
  $result = $LASTEXITCODE
  Write-Output "Log: $LogPath"
} finally {
  Pop-Location
}
exit $result
