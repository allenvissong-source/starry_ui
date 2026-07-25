Get-ChildItem -Path D:\Starry-1.07 -Recurse -Include *.svg,*.html -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch 'node_modules|\\build\\|\.dart_tool' } |
  Select-Object FullName, Length, LastWriteTime |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 40 |
  Format-Table -AutoSize
Write-Output "DONE_SENTINEL"
