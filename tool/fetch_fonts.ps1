# Fetch/collect font assets for starry_ui.
# - Copies MiSans-VF.ttf and Twemoji.ttf from the main project (single source of truth).
# - Downloads Outfit and Inter variable fonts from the Google Fonts GitHub repo (OFL licensed).
param(
  [string]$MainFonts = (Join-Path $PSScriptRoot '../../starry/assets/fonts')
)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$dest = Join-Path $PSScriptRoot '../fonts'
New-Item -ItemType Directory -Force -Path $dest | Out-Null

foreach ($font in @('MiSans-VF.ttf', 'Twemoji.ttf')) {
  if (-not (Test-Path (Join-Path $MainFonts $font) -PathType Leaf)) {
    throw "Missing $font; pass -MainFonts with the licensed main-application fonts directory"
  }
}
Copy-Item -Force (Join-Path $mainFonts 'MiSans-VF.ttf') (Join-Path $dest 'MiSans-VF.ttf')
Copy-Item -Force (Join-Path $mainFonts 'Twemoji.ttf')   (Join-Path $dest 'Twemoji.ttf')

$downloads = @(
  @{ Url = 'https://github.com/google/fonts/raw/main/ofl/outfit/Outfit%5Bwght%5D.ttf'; Out = 'Outfit-VF.ttf' },
  @{ Url = 'https://github.com/google/fonts/raw/main/ofl/inter/Inter%5Bopsz,wght%5D.ttf'; Out = 'Inter-VF.ttf' }
)
foreach ($d in $downloads) {
  $outPath = Join-Path $dest $d.Out
  Invoke-WebRequest -Uri $d.Url -OutFile $outPath -UseBasicParsing
  Write-Output ("DOWNLOADED {0} -> {1} bytes {2}" -f $d.Url, $outPath, (Get-Item $outPath).Length)
}

Write-Output '=== FINAL fonts dir ==='
Get-ChildItem $dest | Select-Object Name, Length | Format-Table -AutoSize | Out-String | Write-Output
Write-Output 'FETCH_FONTS_DONE'
