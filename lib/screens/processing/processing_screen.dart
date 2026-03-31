import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/session_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ollie_character.dart';
import '../review/review_screen.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final SessionController _ctrl = Get.find();

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    await _ctrl.processAllPages();
    if (mounted) {
      Get.off(() => const ReviewScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final total = _ctrl.capturedImagePaths.length;
          final current = _ctrl.currentProcessingPage.value;
          final progress = total > 0 ? current / total : 0.0;

          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const OllieCharacter(state: OllieState.reading, size: 160),
                const SizedBox(height: 32),
                Text(
                  'Reading page $current of $total...',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _processingQuip(current),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: AppColors.accent,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  static const _quips = [
    'Ollie is putting on his reading glasses...',
    'Decoding the adventures inside...',
    'Finding all the magical words...',
    'Almost ready for storytime!',
    'Just a few more words to find...',
  ];

  String _processingQuip(int page) {
    return _quips[page.clamp(0, _quips.length - 1)];
  }
}
