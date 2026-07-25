Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Bitmap]::FromFile("D:\Starry-1.07\starry_ui\verify_button_filled_dark.png")
$w = $src.Width; $h = $src.Height
# central workspace band
$cx = [int]($w*0.30); $cw = [int]($w*0.40)
$cy = [int]($h*0.22); $ch = [int]($h*0.42)
$rect = New-Object System.Drawing.Rectangle($cx,$cy,$cw,$ch)
$crop = $src.Clone($rect, $src.PixelFormat)
# downscale to max width 520
$scale = 520.0 / $crop.Width
$nw = [int]($crop.Width*$scale); $nh = [int]($crop.Height*$scale)
$dst = New-Object System.Drawing.Bitmap($nw,$nh)
$gfx = [System.Drawing.Graphics]::FromImage($dst)
$gfx.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gfx.DrawImage($crop, 0, 0, $nw, $nh)
$enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 55)
$dst.Save("D:\Starry-1.07\starry_ui\verify_dark_crop.jpeg", $enc, $ep)
$gfx.Dispose(); $dst.Dispose(); $crop.Dispose(); $src.Dispose()
Write-Output "CROP_SAVED ${nw}x${nh}"
Write-Output "DONE_SENTINEL"
