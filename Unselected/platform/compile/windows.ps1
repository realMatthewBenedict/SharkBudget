$FLUTTER = (Get-Command flutter).Source
$FLUTTER_ROOT = Split-Path (Split-Path $FLUTTER -Parent) -Parent
$DART_SDK_PATH = Join-Path $FLUTTER_ROOT "bin/cache/dart-sdk"

# Get this from where VsDevCmd.bat in Developer Command Prompt for VS
$VS_DEV_CMD = "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\Common7\Tools\VsDevCmd.bat"

#$test = cmd /c "set VSCMD_DEBUG=3 && `"$VS_DEV_CMD`" > vsdev_debug.txt 2>&1 && type vsdev_debug.txt"
#Write-Output $test

cmd /c @"
"$VS_DEV_CMD" && clang-cl /TC /LD -Wno-deprecated-declarations /Fe:windows\runner\libbackend.dll /I"$DART_SDK_PATH\include" "$DART_SDK_PATH\include\dart_api_dl.c" platform\*.c platform\third_party\*.c
"@