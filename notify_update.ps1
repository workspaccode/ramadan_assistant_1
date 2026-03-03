# Ramadan Assistant - FCM Update Notifier
# This script sends a rich update notification to all users subscribed to the 'updates' topic.
# Requirement: Google Cloud SDK (gcloud) installed and logged in.

# --- UPDATE DETAILS ---
$VERSION = "1.0.5"
$PATCH = "1"
$TRACK = "auto-update" # Use 'auto-update' for Shorebird patches, 'manual-update' for store releases

$TITLE_AR = "تحديث جديد متاح"
$BODY_AR = "نسخة 1.0.5 جاهزة الآن بمميزات جديدة!"

$FEATURES_AR = "• واجهة زجاجية (Glassmorphism) جديدة كلياً
• نظام أذكار متطور يشبه الأذان
• تحسينات في سرعة التطبيق".Replace("\n", "`n")
$FEATURES_EN = "• Brand new Glassmorphism UI
• Advanced Alarm-like Azkar system
• Performance optimizations".Replace("\n", "`n")

$FIXES_AR = "• إصلاح مشكلة إشعارات الخلفية
• إصلاح استهلاك البطارية".Replace("\n", "`n")
$FIXES_EN = "• Fixed background notification issues
• Optimized battery consumption".Replace("\n", "`n")
# ----------------------

$PROJECT_ID = "apps-41d38"

Write-Host "🚀 Preparing to send update notification for v$VERSION..." -ForegroundColor Cyan

# Get Access Token
try {
    $TOKEN = gcloud auth print-access-token
} catch {
    Write-Host "❌ Error: Could not get gcloud access token. Make sure Google Cloud SDK is installed and you are logged in (gcloud auth login)." -ForegroundColor Red
    exit
}

$HEADERS = @{
    "Authorization" = "Bearer $TOKEN"
    "Content-Type"  = "application/json"
}

$BODY = @{
    "message" = @{
        "topic" = "updates"
        "notification" = @{
            "title" = $TITLE_AR
            "body"  = $BODY_AR
        }
        "data" = @{
            "type"        = "update"
            "track"       = $TRACK
            "version"     = $VERSION
            "patch"       = $PATCH
            "title_ar"    = $TITLE_AR
            "description_ar" = $BODY_AR
            "features_ar" = $FEATURES_AR
            "features_en" = $FEATURES_EN
            "fixes_ar"    = $FIXES_AR
            "fixes_en"    = $FIXES_EN
        }
    }
} | ConvertTo-Json -Depth 10

Write-Host "📡 Sending request to Firebase..." -ForegroundColor Yellow

try {
    $RESPONSE = Invoke-RestMethod -Method Post -Uri "https://fcm.googleapis.com/v1/projects/$PROJECT_ID/messages:send" -Headers $HEADERS -Body $BODY
    Write-Host "✅ Success! Message sent. ID: $($RESPONSE.name)" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to send notification." -ForegroundColor Red
    $_.Exception.Message
}
