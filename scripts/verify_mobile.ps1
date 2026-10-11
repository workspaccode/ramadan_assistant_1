param(
    [string]$FlutterPath = 'flutter',
    [switch]$BuildAndroid
)
$ErrorActionPreference = 'Stop'
$taskProject = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath $taskProject
try {
    & $FlutterPath gen-l10n
    if ($LASTEXITCODE -ne 0) { throw 'Localization generation failed' }
    & $FlutterPath analyze
    if ($LASTEXITCODE -ne 0) { throw 'Static analysis failed' }
    # One Flutter test process avoids competing native-assets DLL generation on Windows.
    & $FlutterPath test --concurrency=1
    if ($LASTEXITCODE -ne 0) { throw 'Regression tests failed' }
    if ($BuildAndroid) {
        & $FlutterPath build apk --debug
        if ($LASTEXITCODE -ne 0) { throw 'Android build failed' }
    }
} finally {
    Pop-Location
}
