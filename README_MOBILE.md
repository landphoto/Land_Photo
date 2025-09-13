
# بناء الـAPK بالكامل من الموبايل (بدون VS Code)

## الإعداد السريع (اقتراح سهل)
1) نزّل الحزمة الجاهزة `LandPhoto_Flutter_Ready.zip` وفكّها.
2) **من جوّالك** افتح تطبيق GitHub أو المتصفح:
   - سوّي Repository جديد (خاص أو عام).
   - ارفع ملفات مشروعك (lib/، assets/، pubspec.yaml…).
   - نزّل هذا الملف `android-apk.yml` داخل `.github/workflows/` (موجود هنا).
3) افتح تبويب **Actions** في GitHub وشغّل Workflow.
4) بعد ما يكمّل، ادخل **Actions ➝ آخر Job ➝ Artifacts** ونزّل `app-debug-apk` أو `app-release-unsigned-apk` على جوّالك.

> ملاحظة: الإصدار Release بالمخطط هذا **غير موقّع**. تگدر تبلّش Debug للتجربة فورًا، وبعدها نضيف التوقيع لاحقًا.

## اسم التطبيق واسم الحزمة
- اسم التطبيق (الظاهر للمستخدم): عدّله داخل `android/app/src/main/AndroidManifest.xml` أو من `app_name` بالموارد بعد ما تنشئ مشروع Flutter كامل (أمر `flutter create .`).
- **اسم الحزمة (ApplicationId)**: داخل `android/app/build.gradle` → `defaultConfig.applicationId "com.yourorg.landphoto"`. اكتب اسم الحزمة **نفس اسم تطبيقك الحالي تمامًا** كما طلبت.

> إذا تريدني أنا أعدّلهم لك، قولّي اسم الحزمة والاسم الظاهر بالضبط حتى أجهّزلك ملفات جاهزة للرفع.

## الصيانة لمدة شهر وتبدي الآن
- الملف `status.json` هنا مهيّأ بحيث `active: true` ويبدأ الآن وينتهي بعد شهر.
- ارفعه على استضافة (مثلاً GitHub Pages/ Firebase Hosting/ S3) وخلي `REMOTE_STATUS_URL` في `lib/main.dart` يشير إلى رابط هذا الملف.

## نشر APK مباشرة من الجوال
- بعد ما ينزل Artifact على جوالك، تگدر ترسله للناس مباشرة أو ترفعه لأي مخزن ملفات.
- إذا تريد توقّع APK (توزيعه رسمي): خلّيني أضيف خطوة توقيع تلقائي في الـWorkflow لما توفّر لي keystore/pass.

