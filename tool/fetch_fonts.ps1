# Fetch/collect font assets for starry_ui.
# - Copies MiSans-VF.ttf and Twemoji.ttf from the main project (single source of truth).
# - Downloads Outfit and Inter variable fonts from the Google Fonts GitHub repo (OFL licensed).
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$dest = 'D:\Starry-1.07\starry_ui\fonts'
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$mainFonts = '\\wsl.localhost\Ubuntu\home\allen\projects\starry\Starry-Flutter-Frontend\assets\fonts'
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
