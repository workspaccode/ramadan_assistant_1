# دليل نموذج Data safety في Google Play — توبتى (app.tawabti)

خطوة بخطوة: ماذا تكتب وأين تضغط. أسماء الحقول بالإنجليزية كما تظهر في
Play Console. الإجابات مبنية على الكود الحالي (Manifest المدمج، pubspec،
سياسة الخصوصية بتاريخ 2026-10-11). راجعها مرة أخيرة عند أي تغيير في الحزم أو
الصلاحيات، وهي ليست استشارة قانونية.

## 0. قبل أن تبدأ

1. السياسة منشورة على رابط عام يعمل بلا تسجيل دخول:
   `https://<نطاقك>/privacy` (يخدمها الـ backend في `backend/`).
2. Play Console → التطبيق → **Policy and programs → App content** → ستجد كل
   النماذج في هذه الصفحة.
3. افتح صفحة بيانات Firebase الرسمية للتأكد من تصنيف كل SDK:
   `firebase.google.com/docs/android/play-data-disclosure`.

## 1. الأسئلة الأساسية (Data collection and security)

| السؤال | الإجابة | السبب |
|---|---|---|
| Does your app collect or share any of the required user data types? | **Yes** | الموقع، رمز FCM، ومزامنة اختيارية |
| Is all of the user data collected by your app encrypted in transit? | **Yes** | Firebase عبر HTTPS، والمزامنة ترفض أي رابط غير https داخل الكود |
| Which Account creation methods does your app support? | **My app does not allow users to create an account** | لا توجد حسابات |
| Do you provide a way for users to request that their data be deleted? | **Yes** | الرابط: `https://<نطاقك>/privacy#data-deletion` |

في Delete data URL ضع الرابط أعلاه. القسم 5 في السياسة يشرح: مسح بيانات
التطبيق أو إلغاء التثبيت يمسح كل شيء على الجهاز، وما رُفع لخادم أنت
تحدده يُحذف عند مشغّل ذلك الخادم.

## 2. أنواع البيانات (Data types)

اضغط **Next** ثم علّم الأنواع التالية فقط، واترك الباقي بلا علامة:

| الفئة | النوع | علّمه؟ |
|---|---|---|
| Location | Approximate location | **نعم** |
| Location | Precise location | **نعم** |
| Personal info | Political or religious beliefs | **نعم** (سجلات صلاة وصيام ترفع بالمزامنة الاختيارية) |
| Calendar | Calendar events | **نعم** (استيراد وتصدير الموعد، وترفع مع المزامنة) |
| App activity | Other user-generated content | **نعم** (مواعيد وملاحظات وروابط وسائط) |
| Device or other IDs | Device or other IDs | **نعم** (رمز FCM ومعرّف تثبيت Firebase) |

لا تعلّم: Name، Email، Phone، Address، Financial info، Health and fitness،
Messages، Photos and videos، Audio files، Files and docs، Contacts، Web
browsing، Installed apps، Crash logs، Diagnostics.

أسباب عدم التعليم:
- **Installed apps**: قائمة تطبيقات القراءة تبقى على الجهاز ولا ترسل.
- **Usage access**: يفحص التطبيق على الجهاز فقط هل تطبيق القراءة في المقدمة،
  بلا تخزين أو إرسال، فلا يُعد جمعًا.
- **Crash logs / Diagnostics**: لا يوجد Crashlytics أو Analytics في التطبيق.
  إن أضفتهما لاحقًا غيّر هذه الإجابة.
- **Advertising ID**: لا توجد صلاحية AD_ID في الـ Manifest المدمج.

## 3. تفاصيل كل نوع

لكل نوع ستُسأل نفس الأسئلة. هذه إجاباتها:

| النوع | Collected / Shared | Processed ephemerally? | Required or optional | Purposes |
|---|---|---|---|---|
| Approximate location | Collected · **لا مشاركة** | **Yes** | **Optional** (المستخدم يستطيع إدخال المدينة أو رفض الإذن) | App functionality |
| Precise location | Collected · **لا مشاركة** | **Yes** | **Optional** | App functionality |
| Political or religious beliefs | Collected · **لا مشاركة** | **No** | **Optional** (المزامنة مقفولة افتراضيًا) | App functionality |
| Calendar events | Collected · **لا مشاركة** | **No** | **Optional** | App functionality |
| Other user-generated content | Collected · **لا مشاركة** | **No** | **Optional** | App functionality |
| Device or other IDs | Collected · **لا مشاركة** | **No** | **Required** | App functionality |

ملاحظات عند الإجابة:
- **Shared = لا** في كل الصفوف: النقل إلى Firebase (مزوّد خدمة يعمل نيابة عنك)
  وإلى خادم يحدده المستخدم بنفسه لا يُعد مشاركة وفق تعريف Play. وبما أنك لا
  تملك الخادم ولا تستلم البيانات، لا يوجد طرف ثالث تشاركه معه.
- **الموقع Ephemeral = Yes**: الإحداثيات تُعالج لحظيًا لحساب المواقيت وقد تُرسل
  لخدمة التحويل إلى اسم مدينة، ولا تخزّن عندك.
- **Purposes**: اختر **App functionality** فقط. لا Analytics، لا Advertising،
  لا Personalization، لا Fraud prevention.

## 4. Security practices (الصفحة الأخيرة)

- Data is encrypted in transit: **Yes**
- You can request that data be deleted: **Yes** (الرابط في القسم 1)
- Committed to follow the Play Families Policy: **No** (التطبيق ليس للأطفال)
- Independent security review: **No** (اختياري، يمكن تركه)

اضغط **Next → Preview**، وتأكد أن المعاينة تطابق هذا الملف، ثم **Save → Submit**.

## 5. النماذج الأخرى في App content

| النموذج | الإجابة |
|---|---|
| Privacy policy | `https://<نطاقك>/privacy` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating (IARC) | Utility/Reference · بلا عنف ولا محتوى مستخدمين عام ولا مقامرة → Everyone |
| Target audience | **13+** (لا تختر أطفالًا، فلا تنطبق Families) |
| News app | No |
| Health apps declaration | لا ميزات صحية. الصيام تتبع ديني، لا طبي، فاختر "None of these" |
| Financial features | None |
| Government app | No |
| Advertising ID | **No** |

### Foreground services والصلاحيات الحساسة

| الصلاحية / الخدمة | ما تكتبه | ما ترفقه |
|---|---|---|
| `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | تشغيل صوت المنبهات الشخصية في الخلفية (خدمة إضافة `alarm`) | فيديو قصير لمنبه شخصي يعمل والشاشة مغلقة |
| `FOREGROUND_SERVICE_SPECIAL_USE` | `ReaderOverlayService`: بطاقة مساعدة اختيارية يفعّلها المستخدم تظهر فوق تطبيق القراءة الذي اختاره | فيديو: حوار الشرح ثم البطاقة ثم زر الإغلاق |
| `USE_EXACT_ALARM` / `SCHEDULE_EXACT_ALARM` | المنبهات الشخصية وتذكيرات المواعيد في وقتها الدقيق (حالة استخدام منبه) | وصف فقط |
| `USE_FULL_SCREEN_INTENT` | شاشة المنبه الشخصي على شاشة القفل | وصف فقط |
| `SYSTEM_ALERT_WINDOW` | ميزة اختيارية مقفولة افتراضيًا، تُظهر ورد اليوم وزرَي تم/إغلاق فوق تطبيق القراءة المحدد | نفس فيديو special use |
| `PACKAGE_USAGE_STATS` | اختياري ثانٍ، لإخفاء البطاقة عند مغادرة تطبيق القراءة. يعمل المساعد بدونه | نفس الفيديو |
| `READ_CALENDAR` / `WRITE_CALENDAR` | استيراد مواعيد من تقويم يختاره المستخدم وتصدير موعد واحد عند الطلب | وصف فقط |
| `RECEIVE_BOOT_COMPLETED` | إعادة جدولة التنبيهات بعد إعادة تشغيل الجهاز | وصف فقط |

تنبيه: `SYSTEM_ALERT_WINDOW` و`PACKAGE_USAGE_STATS` عرضة للرفض في المراجعة لأن
الميزة ليست جوهر التطبيق. جهّز بديلًا: إن رُفض أحدهما، اشحن نسخة بدونه
(المساعد اختياري ولا يتأثر الورد).

أذونات دخلت من المكتبات وقد يسألك المراجع عنها: `READ_EXTERNAL_STORAGE`،
`ACCESS_NOTIFICATION_POLICY`، وأذونات شارات المشغّلات القادمة من
`awesome_notifications`. افحصها قبل الرفع: إن لم تحتجها احذفها بـ
`tools:node="remove"` في `AndroidManifest.xml`.

## 6. متى تعيد هذا النموذج

- إضافة Crashlytics أو Analytics أو إعلانات: غيّر Diagnostics/App activity.
- إرسال أي بيانات إلى خادمك أنت (مثل رفع المزامنة تلقائيًا بلا إعداد
  المستخدم): ستصبح مشاركة/جمعًا عندك، وتحتاج حذفًا فعليًا من الخادم.
- إضافة حسابات: اختر طريقة إنشاء الحساب وأضف رابط حذف الحساب.
- تغيير أي صلاحية في الـ Manifest.

بعد أي تعديل: حدّث `legal/privacy_policy.html`، انسخه إلى
`backend/app/static/legal/privacy.html` (الأمر في `backend/README.md`)، وأعد
نشر الـ backend قبل تسليم النموذج.
