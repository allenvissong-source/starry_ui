Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap("D:/Starry-1.07/starry_ui/verify_button_filled_dark.png")
$w = $bmp.Width
$h = $bmp.Height
Write-Output "SIZE ${w}x${h}"
$hist = @{}
$purple = 0
for ($y = 0; $y -lt $h; $y += 3) {
  for ($x = 0; $x -lt $w; $x += 3) {
    $p = $bmp.GetPixel($x, $y)
    $key = "{0:X2}{1:X2}{2:X2}" -f $p.R, $p.G, $p.B
    if ($hist.ContainsKey($key)) { $hist[$key]++ } else { $hist[$key] = 1 }
    if ($p.R -ge 150 -and $p.R -le 190 -and $p.G -ge 135 -and $p.G -le 170 -and $p.B -ge 235 -and $p.B -le 255) { $purple++ }
  }
}
Write-Output "TOP15"
$hist.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 15 | ForEach-Object { Write-Output ("#{0} count={1}" -f $_.Key, $_.Value) }
Write-Output "PURPLE-ISH"
$hist.GetEnumerator() | Where-Object {
  $r = [Convert]::ToInt32($_.Key.Substring(0,2),16)
  $g = [Convert]::ToInt32($_.Key.Substring(2,2),16)
  $b = [Convert]::ToInt32($_.Key.Substring(4,2),16)
  $r -ge 150 -and $r -le 190 -and $g -ge 135 -and $g -le 170 -and $b -ge 235 -and $b -le 255
} | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object {
  $r = [Convert]::ToInt32($_.Key.Substring(0,2),16)
  $g = [Convert]::ToInt32($_.Key.Substring(2,2),16)
  $b = [Convert]::ToInt32($_.Key.Substring(4,2),16)
  Write-Output ("#{0} count={1} (R={2} G={3} B={4})" -f $_.Key, $_.Value, $r, $g, $b)
}
$bmp.Dispose()
Write-Output "DONE_SENTINEL"
