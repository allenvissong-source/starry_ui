Add-Type -AssemblyName System.Drawing
$src = "D:\Starry-1.07\starry_ui\verify_button_filled_dark.png"
$bmp = New-Object System.Drawing.Bitmap($src)
Write-Output ("SIZE {0}x{1}" -f $bmp.Width, $bmp.Height)

# Downscale to a small JPEG for inline viewing
$tw = 420
$th = [int]($bmp.Height * $tw / $bmp.Width)
$thumb = New-Object System.Drawing.Bitmap($tw, $th)
$g = [System.Drawing.Graphics]::FromImage($thumb)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($bmp, 0, 0, $tw, $th)
$g.Dispose()
$enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]30)
$thumb.Save("D:\Starry-1.07\starry_ui\verify_dark_thumb.jpeg", $enc, $ep)
$thumb.Dispose()
Write-Output "THUMB_SAVED"

# Broad purple scan: anything meaningfully blue-violet
$purple = 0
$topPurple = @{}
for ($y = 0; $y -lt $bmp.Height; $y += 3) {
  for ($x = 0; $x -lt $bmp.Width; $x += 3) {
    $p = $bmp.GetPixel($x, $y)
    # broad: blue dominant, red mid-high, green lower than blue, not grey
    if ($p.B -gt 200 -and $p.R -gt 120 -and $p.R -lt 220 -and $p.G -lt $p.B -and ($p.B - $p.G) -gt 40) {
      $purple++
      $key = "#{0:X2}{1:X2}{2:X2}" -f $p.R, $p.G, $p.B
      if ($topPurple.ContainsKey($key)) { $topPurple[$key]++ } else { $topPurple[$key] = 1 }
    }
  }
}
Write-Output ("PURPLE_COUNT {0}" -f $purple)
Write-Output "PURPLE_TOP"
$topPurple.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 15 | ForEach-Object { Write-Output ("{0} count={1}" -f $_.Key, $_.Value) }
$bmp.Dispose()
Write-Output "DONE_SENTINEL"
