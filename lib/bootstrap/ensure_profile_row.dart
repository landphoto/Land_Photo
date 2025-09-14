import '../services/profile_service.dart';

/// نادِ هذه الدالة بعد تسجيل الدخول مباشرة أو عند تشغيل التطبيق
Future<void> ensureProfileRowOnStartup() async {
  final _p = ProfileService();
  await _p.ensureRow();
}