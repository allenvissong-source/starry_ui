Add-Type -AssemblyName System.Drawing
$path = 'D:\Starry-1.07\starry_ui\verify_button_filled_light.png'
$bmp = [System.Drawing.Bitmap]::FromFile($path)
Write-Output ("size={0}x{1}" -f $bmp.Width, $bmp.Height)
$hist = @{}
for ($y = 0; $y -lt $bmp.Height; $y += 3) {
  for ($x = 0; $x -lt $bmp.Width; $x += 3) {
    $c = $bmp.GetPixel($x, $y)
    $key = ('{0:X2}{1:X2}{2:X2}' -f $c.R, $c.G, $c.B)
    if ($hist.ContainsKey($key)) { $hist[$key] += 1 } else { $hist[$key] = 1 }
  }
}
$bmp.Dispose()
Write-Output "TOP COLORS:"
$hist.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 15 | ForEach-Object {
  Write-Output ("#{0}  count={1}" -f $_.Key, $_.Value)
}
Write-Output "PURPLE-ISH (R 150-190, G 135-170, B 235-255):"
$hist.GetEnumerator() | ForEach-Object {
  $r = [Convert]::ToInt32($_.Key.Substring(0,2),16)
  $g = [Convert]::ToInt32($_.Key.Substring(2,2),16)
  $b = [Convert]::ToInt32($_.Key.Substring(4,2),16)
  if ($r -ge 150 -and $r -le 190 -and $g -ge 135 -and $g -le 170 -and $b -ge 235 -and $b -le 255) {
    Write-Output ("#{0}  count={1}  (R={2} G={3} B={4})" -f $_.Key, $_.Value, $r, $g, $b)
  }
}
Write-Output "DONE_SENTINEL"
