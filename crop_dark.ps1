Add-Type -AssemblyName System.Drawing
$src = "D:\Starry-1.07\starry_ui\verify_button_filled_dark.png"
$bmp = New-Object System.Drawing.Bitmap($src)
$W = $bmp.Width; $H = $bmp.Height
Write-Output ("SIZE {0}x{1}" -f $W, $H)

# Crop central workspace band (exclude left nav + right knobs panel)
$cx = [int]($W * 0.28); $cw = [int]($W * 0.44)
$cy = [int]($H * 0.20); $ch = [int]($H * 0.50)
$rect = New-Object System.Drawing.Rectangle($cx, $cy, $cw, $ch)
$crop = $bmp.Clone($rect, $bmp.PixelFormat)

# Sample the crop: histogram of all non-dark, non-grey colors
$colors = @{}
for ($y = 0; $y -lt $crop.Height; $y += 2) {
  for ($x = 0; $x -lt $crop.Width; $x += 2) {
    $p = $crop.GetPixel($x, $y)
    $mx = [Math]::Max($p.R, [Math]::Max($p.G, $p.B))
    $mn = [Math]::Min($p.R, [Math]::Min($p.G, $p.B))
    # skip near-grey (low saturation) and very dark
    if (($mx - $mn) -gt 30 -and $mx -gt 80) {
      $key = "#{0:X2}{1:X2}{2:X2}" -f $p.R, $p.G, $p.B
      if ($colors.ContainsKey($key)) { $colors[$key]++ } else { $colors[$key] = 1 }
    }
  }
}
Write-Output "CROP_COLOR_TOP"
$colors.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 20 | ForEach-Object { Write-Output ("{0} count={1}" -f $_.Key, $_.Value) }

# Save crop as small jpeg for viewing
$tw = 420
$th = [int]($crop.Height * $tw / $crop.Width)
$thumb = New-Object System.Drawing.Bitmap($tw, $th)
$g = [System.Drawing.Graphics]::FromImage($thumb)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($crop, 0, 0, $tw, $th)
$g.Dispose()
$enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]55)
$thumb.Save("D:\Starry-1.07\starry_ui\verify_dark_crop.jpeg", $enc, $ep)
$thumb.Dispose(); $crop.Dispose(); $bmp.Dispose()
Write-Output "DONE_SENTINEL"
