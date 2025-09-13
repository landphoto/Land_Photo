
# Land Photo — Flutter Starter (APK Ready)

هذا المشروع مهيأ حتى تبني APK بسرعة، ويا دعم:
- **تنبيه تحديث** (اختياري/إجباري) حسب `status.json` على الخادم
- **وضع صيانة** مع وقت وتاريخ

## تعليمات سريعة

### 1) المتطلبات
- Flutter 3.x
- Android SDK

### 2) إعداد التطبيق
- حدث `REMOTE_STATUS_URL` في `lib/main.dart` برابط `status.json` المستضاف على سيرفرك (S3 / Firebase Hosting وغيرها).
- حدّث اسم الحزمة داخل `android/app/build.gradle` لاحقًا إلى: `com.zebari.landphoto` (أو الاسم الذي تريده).
- ضع أيقونتك داخل `android/app/src/main/res/mipmap-*/ic_launcher.png` (بعد إنشاء مشروع Flutter كامل).

### 3) تثبيت الحزم
```bash
flutter pub get
```

### 4) تشغيل على جهاز
```bash
flutter run
```

### 5) بناء APK (Debug سريع)
```bash
flutter build apk
```

### 6) بناء APK (Release موقّع)
أنشئ keystore مرة واحدة:
```bash
keytool -genkey -v -keystore ~/landphoto.jks -keyalg RSA -keysize 2048 -validity 10000 -alias landphoto
```
ثم اعداد `key.properties` وربطه في `android/app/build.gradle`, وبعدها:
```bash
flutter build apk --release
```

### 7) status.json
نموذج موجود داخل `assets/status.json`. ارفعه على خادمك وخلي `REMOTE_STATUS_URL` يشير له. عدّل:
- `latest_version` و `min_supported_version`
- قسم `maintenance` (الوقت بصيغة UTC)

## ملاحظات
- هذا مجلد **بدايات**. لإنشاء مشروع Android كامل (ملفات Gradle و AndroidManifest)، نفّذ:
```bash
flutter create .
```
داخل هذا المجلد، بعدها انسخ `lib/` و `assets/` و `pubspec.yaml` فوقه.
