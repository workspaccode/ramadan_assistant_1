# Creates a release upload keystore for Google Play and writes android/key.properties.
# Run from the project root:  powershell -ExecutionPolicy Bypass -File scripts/create_release_keystore.ps1
#
# Keep the .jks file + passwords safe: Google Play App Signing lets you reset the
# upload key, but losing the *signing* key means you can never update the app.

$ErrorActionPreference = "Stop"

Write-Host "=== Ramadan Assistant - Release Keystore Generator ===" -ForegroundColor Green

# --- Collect input (never hardcode secrets in scripts) ---
$storePassword = Read-Host -AsSecureString "Enter keystore password (min 6 chars)"
$plainStore = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))
if ($plainStore.Length -lt 6) { Write-Error "Password must be at least 6 characters."; exit 1 }

$keyPassword = Read-Host -AsSecureString "Enter key password (can be the same)"
$plainKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))

$alias = Read-Host "Key alias (default: upload)"
if ([string]::IsNullOrWhiteSpace($alias)) { $alias = "upload" }

# --- Locate keytool ---
$keytool = Get-Command keytool -ErrorAction SilentlyContinue
if (-not $keytool) {
    $jdkHome = Get-ChildItem "C:\Program Files\Android\Android Studio\jbr" -ErrorAction SilentlyContinue
    $candidate = Join-Path $jdkHome.FullName "bin\keytool.exe"
    if (Test-Path $candidate) { $keytool = @{ Source = $candidate } }
    else { Write-Error "keytool not found. Install Android Studio JDK or add Java to PATH."; exit 1 }
}

$keystorePath = Join-Path $PSScriptRoot "..\android\app\upload-keystore.jks"
$keystorePath = (Resolve-Path (Split-Path $keystorePath)).Path + "\upload-keystore.jks"

Write-Host "`nGenerating keystore at: $keystorePath" -ForegroundColor Cyan

& $keytool.Source -genkeypair -v `
    -keystore $keystorePath `
    -alias $alias `
    -keyalg RSA -keysize 2048 -validity 10000 `
    -storepass $plainStore -keypass $plainKey `
    -dname "CN=Tawabti, OU=Mobile, O=Tawabti, L=City, S=State, C=SA"

if ($LASTEXITCODE -ne 0) { Write-Error "keytool failed."; exit 1 }

# --- Write key.properties (relative storeFile path used by build.gradle.kts) ---
$props = @"
storePassword=$plainStore
keyPassword=$plainKey
keyAlias=$alias
storeFile=upload-keystore.jks
"@

$propsPath = Join-Path $PSScriptRoot "..\android\key.properties"
$propsPath | Out-File -FilePath $propsPath -Encoding ascii
Write-Host "`nkey.properties written to android\key.properties" -ForegroundColor Cyan

# --- Remind about .gitignore ---
$gitignore = Join-Path $PSScriptRoot "..\.gitignore"
$missing = @("android/key.properties", "*.jks") | Where-Object {
    -not (Test-Path $gitignore) -or -not (Select-String -Path $gitignore -Pattern ([regex]::Escape($_)) -Quiet)
}
if ($missing) {
    Write-Warning "Add these lines to .gitignore: $($missing -join ', ')"
}

Write-Host "`nDone. Build a signed release with:" -ForegroundColor Green
Write-Host "  flutter build appbundle --release"
Write-Host "Keep a backup of upload-keystore.jks + passwords in a safe place!" -ForegroundColor Yellow