Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile("D:\Starry-1.07\starry_ui\verify_button_filled_dark.png")
$w = $img.Width; $h = $img.Height
Write-Output "SIZE ${w}x${h}"
$hist = @{}
# brand purple #AB99FF => R171 G153 B255
$brandCount = 0
for ($y=0; $y -lt $h; $y += 2) {
  for ($x=0; $x -lt $w; $x += 2) {
    $p = $img.GetPixel($x,$y)
    $r=$p.R; $g=$p.G; $b=$p.B
    # near brand purple within tolerance +-18
    if ([math]::Abs($r-171) -le 18 -and [math]::Abs($g-153) -le 18 -and [math]::Abs($b-255) -le 12) {
      $brandCount++
      $key = "#{0:X2}{1:X2}{2:X2}" -f $r,$g,$b
      if ($hist.ContainsKey($key)) { $hist[$key]++ } else { $hist[$key] = 1 }
    }
  }
}
Write-Output "BRAND_PURPLE_COUNT $brandCount"
Write-Output "BRAND_TOP"
$hist.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 15 | ForEach-Object { Write-Output ("{0} count={1}" -f $_.Key, $_.Value) }
$img.Dispose()
Write-Output "DONE_SENTINEL"
