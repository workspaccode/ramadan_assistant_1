import 'dart:convert';
import 'dart:io';

void main() {
  const version = "1.0.5";
  const patch = "1";
  const track = "auto-update";

  const titleAr = "تحديث جديد متاح";
  const bodyAr = "نسخة $version جاهزة الآن بمميزات جديدة!";
  const featuresAr =
      "• واجهة زجاجية (Glassmorphism) جديدة كلياً\n• نظام أذكار متطور يشبه الأذان\n• تحسينات في سرعة التطبيق";
  const featuresEn =
      "• Brand new Glassmorphism UI\n• Advanced Alarm-like Azkar system\n• Performance optimizations";
  const fixesAr = "• إصلاح مشكلة إشعارات الخلفية\n• إصلاح استهلاك البطارية";
  const fixesEn =
      "• Fixed background notification issues\n• Optimized battery consumption";

  final scriptContent =
      '''# Ramadan Assistant - FCM Update Notifier
# This script sends a rich update notification to all users subscribed to the 'updates' topic.
# Requirement: Google Cloud SDK (gcloud) installed and logged in.

# --- UPDATE DETAILS ---
\$VERSION = "$version"
\$PATCH = "$patch"
\$TRACK = "$track" # Use 'auto-update' for Shorebird patches, 'manual-update' for store releases

\$TITLE_AR = "$titleAr"
\$BODY_AR = "$bodyAr"

\$FEATURES_AR = "$featuresAr".Replace("\\n", "`n")
\$FEATURES_EN = "$featuresEn".Replace("\\n", "`n")

\$FIXES_AR = "$fixesAr".Replace("\\n", "`n")
\$FIXES_EN = "$fixesEn".Replace("\\n", "`n")
# ----------------------

\$PROJECT_ID = "apps-41d38"

Write-Host "🚀 Preparing to send update notification for v\$VERSION..." -ForegroundColor Cyan

# Get Access Token
try {
    \$TOKEN = gcloud auth print-access-token
} catch {
    Write-Host "❌ Error: Could not get gcloud access token. Make sure Google Cloud SDK is installed and you are logged in (gcloud auth login)." -ForegroundColor Red
    exit
}

\$HEADERS = @{
    "Authorization" = "Bearer \$TOKEN"
    "Content-Type"  = "application/json"
}

\$BODY = @{
    "message" = @{
        "topic" = "updates"
        "notification" = @{
            "title" = \$TITLE_AR
            "body"  = \$BODY_AR
        }
        "data" = @{
            "type"        = "update"
            "track"       = \$TRACK
            "version"     = \$VERSION
            "patch"       = \$PATCH
            "title_ar"    = \$TITLE_AR
            "description_ar" = \$BODY_AR
            "features_ar" = \$FEATURES_AR
            "features_en" = \$FEATURES_EN
            "fixes_ar"    = \$FIXES_AR
            "fixes_en"    = \$FIXES_EN
        }
    }
} | ConvertTo-Json -Depth 10

Write-Host "📡 Sending request to Firebase..." -ForegroundColor Yellow

try {
    \$RESPONSE = Invoke-RestMethod -Method Post -Uri "https://fcm.googleapis.com/v1/projects/\$PROJECT_ID/messages:send" -Headers \$HEADERS -Body \$BODY
    Write-Host "✅ Success! Message sent. ID: \$(\$RESPONSE.name)" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to send notification." -ForegroundColor Red
    \$_.Exception.Message
}
''';

  final file = File('notify_update.ps1');
  // UTF-8 with BOM (Byte Order Mark) is essential for PowerShell 5.1 to read Arabic correctly
  final bytes = [0xEF, 0xBB, 0xBF] + utf8.encode(scriptContent);
  file.writeAsBytesSync(bytes);
  print('Successfully wrote notify_update.ps1 with UTF-8 BOM');
}
