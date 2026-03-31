import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controllers/session_controller.dart';
import 'screens/library/library_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final storage = StorageService();
  await storage.init();
  Get.put(storage, permanent: true);

  final tts = TtsService();
  await tts.init();
  Get.put(tts, permanent: true);

  Get.put(SessionController(), permanent: true);

  runApp(const ReadilioApp());
}

class ReadilioApp extends StatelessWidget {
  const ReadilioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    return GetMaterialApp(
      title: 'Readilio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: storage.onboardingDone
          ? const LibraryScreen()
          : const OnboardingScreen(),
    );
  }
}
