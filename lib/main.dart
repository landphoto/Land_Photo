import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LandPhotoApp());
}

class LandPhotoApp extends StatefulWidget {
  const LandPhotoApp({super.key});
  @override
  State<LandPhotoApp> createState() => _LandPhotoAppState();
}

class _LandPhotoAppState extends State<LandPhotoApp> {
  Future<AppStatus> _statusFuture = AppStatus.load();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Land Photo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      home: FutureBuilder<AppStatus>(
        future: _statusFuture,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final status = snap.data!;
          if (status.forceUpdate) {
            return UpdateRequiredScreen(latestVersion: status.latestVersion, storeUrl: status.storeUrl);
          }
          if (status.maintenanceActive) {
            return MaintenanceScreen(
              title: status.maintenanceTitle,
              message: status.maintenanceMessage,
              start: status.maintenanceStart!,
              end: status.maintenanceEnd!,
            );
          }
          return LandPhotoHome(status: status);
        },
      ),
    );
  }
}

class LandPhotoHome extends StatelessWidget {
  final AppStatus status;
  const LandPhotoHome({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Land Photo')),
      body: Column(
        children: [
          if (status.softUpdate)
            MaterialBanner(
              content: Text('إصدار جديد ${status.latestVersion} متوفر. ننصح بالتحديث.'),
              leading: const Icon(Icons.system_update),
              actions: [
                TextButton(onPressed: () => status.openStore(), child: const Text('تحديث')),
                TextButton(onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(), child: const Text('لاحقاً')),
              ],
            ),
          if (status.maintenanceSoon)
            ListTile(
              leading: const Icon(Icons.warning_amber_rounded),
              title: const Text('تنبيه صيانة قريباً'),
              subtitle: Text('سيتم إيقاف الخدمة مؤقتاً في ${status.maintenanceWindowLabel}'),
            ),
          const Divider(),
          const Expanded(
            child: Center(child: Text('هنا نعرض واجهة مشروع Land Photo الحالية\n(شبّكها على مشروعك لاحقاً).')),
          ),
        ],
      ),
    );
  }
}

class UpdateRequiredScreen extends StatelessWidget {
  final String latestVersion;
  final String storeUrl;
  const UpdateRequiredScreen({super.key, required this.latestVersion, required this.storeUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.system_update, size: 72),
              const SizedBox(height: 16),
              Text('يجب تحديث التطبيق إلى الإصدار $latestVersion', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('للاستمرار باستخدام Land Photo يرجى التحديث الآن.'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(storeUrl);
                  if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('تحديث الآن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MaintenanceScreen extends StatelessWidget {
  final String title;
  final String message;
  final DateTime start;
  final DateTime end;
  const MaintenanceScreen({super.key, required this.title, required this.message, required this.start, required this.end});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final remaining = end.difference(now);
    String fmt(Duration d) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return '${h}h ${m}m';
    }
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.build_circle_rounded, size: 80),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text('الانتهاء المتوقع: ${end.toLocal()}'),
              const SizedBox(height: 4),
              Text('الوقت المتبقي: ${fmt(remaining)}'),
            ],
          ),
        ),
      ),
    );
  }
}

class AppStatus {
  static const REMOTE_STATUS_URL = 'https://raw.githubusercontent.com/landphoto/Land_Photo/main/assets/status.json';

  final String latestVersion;
  final String minSupportedVersion;
  final String storeUrl;
  final bool maintenanceActive;
  final bool maintenanceSoon;
  final String maintenanceTitle;
  final String maintenanceMessage;
  final DateTime? maintenanceStart;
  final DateTime? maintenanceEnd;
  final String maintenanceWindowLabel;
  final String currentVersion;

  AppStatus({
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.storeUrl,
    required this.maintenanceActive,
    required this.maintenanceSoon,
    required this.maintenanceTitle,
    required this.maintenanceMessage,
    required this.maintenanceStart,
    required this.maintenanceEnd,
    required this.maintenanceWindowLabel,
    required this.currentVersion,
  });

  bool get forceUpdate => _cmpVersion(currentVersion, minSupportedVersion) < 0;
  bool get softUpdate => _cmpVersion(currentVersion, latestVersion) < 0 && !forceUpdate;

  static Future<AppStatus> load() async {
    final pkg = await PackageInfo.fromPlatform();
    final currentVersion = pkg.version;
    try {
      final res = await http.get(Uri.parse(REMOTE_STATUS_URL)).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final map = json.decode(res.body) as Map<String, dynamic>;
        return AppStatus.fromJson(map, currentVersion);
      }
    } catch (_) {}
    return AppStatus(
      latestVersion: currentVersion,
      minSupportedVersion: currentVersion,
      storeUrl: 'https://play.google.com/store/apps/details?id=com.example.landphoto',
      maintenanceActive: false,
      maintenanceSoon: false,
      maintenanceTitle: 'صيانة',
      maintenanceMessage: 'التطبيق تحت الصيانة مؤقتاً.',
      maintenanceStart: null,
      maintenanceEnd: null,
      maintenanceWindowLabel: '',
      currentVersion: currentVersion,
    );
  }

  factory AppStatus.fromJson(Map<String, dynamic> j, String currentVersion) {
    final maintenance = j['maintenance'] as Map<String, dynamic>?;
    final bool active = maintenance?['active'] == true;
    final String title = maintenance?['title'] ?? 'صيانة مجدولة';
    final String message = maintenance?['message'] ?? 'سيتم إيقاف الخدمة مؤقتاً للصيانة.';
    DateTime? start;
    DateTime? end;
    String window = '';
    if (maintenance != null) {
      if (maintenance['start_utc'] != null) start = DateTime.parse(maintenance['start_utc']);
      if (maintenance['end_utc'] != null) end = DateTime.parse(maintenance['end_utc']);
      if (start != null && end != null) {
        window = '${start.toLocal()} - ${end.toLocal()}';
      }
    }
    final now = DateTime.now().toUtc();
    bool soon = false;
    if (!active && start != null) {
      final diff = start.difference(now);
      if (diff.inHours >= 0 && diff.inHours <= 24) soon = true;
    }
    return AppStatus(
      latestVersion: j['latest_version'] ?? currentVersion,
      minSupportedVersion: j['min_supported_version'] ?? currentVersion,
      storeUrl: j['store_url'] ?? 'https://play.google.com/store/apps/details?id=com.example.landphoto',
      maintenanceActive: active,
      maintenanceSoon: soon,
      maintenanceTitle: title,
      maintenanceMessage: message,
      maintenanceStart: start?.toLocal(),
      maintenanceEnd: end?.toLocal(),
      maintenanceWindowLabel: window,
      currentVersion: currentVersion,
    );
  }

  static int _cmpVersion(String a, String b) {
    List<int> pa = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> pb = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    while (pa.length < 3) pa.add(0);
    while (pb.length < 3) pb.add(0);
    for (int i = 0; i < 3; i++) {
      if (pa[i] != pb[i]) return pa[i] - pb[i];
    }
    return 0;
  }

  void openStore() async {
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}