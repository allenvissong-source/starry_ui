Set-Location D:\Starry-1.07\starry_ui
dart run build_runner build --delete-conflicting-outputs *> D:\Starry-1.07\starry_ui\tool\build_runner.log
"EXITCODE=$LASTEXITCODE" | Out-File -Append D:\Starry-1.07\starry_ui\tool\build_runner.log
"DONE_SENTINEL" | Out-File -Append D:\Starry-1.07\starry_ui\tool\build_runner.log
