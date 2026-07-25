$roots = @('D:\Starry-1.07')
foreach ($r in $roots) {
  if (Test-Path $r) {
    Write-Output "=== ROOT $r ==="
    Get-ChildItem -Path $r -Recurse -Include *.svg,*.html,*.png,*.jpg,*.jpeg -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -notmatch 'node_modules|\\build\\|\.dart_tool|verify_|sample_|thumb|crop' } |
      Select-Object FullName, Length, LastWriteTime |
      Sort-Object LastWriteTime -Descending |
      Select-Object -First 40 |
      Format-Table -AutoSize
  }
}
Write-Output "DONE_SENTINEL"
