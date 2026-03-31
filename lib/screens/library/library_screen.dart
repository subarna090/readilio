import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/session_controller.dart';
import '../../models/story_session.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ollie_character.dart';
import '../camera/camera_screen.dart';
import '../paywall/paywall_screen.dart';
import '../playback/playback_screen.dart';
import '../settings/settings_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionController>();
    final storage = Get.find<StorageService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Stories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
        ],
      ),
      body: Obx(() {
        final sessions = ctrl.sessions;
        return CustomScrollView(
          slivers: [
            // Header / Ollie mascot
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    const OllieCharacter(state: OllieState.idle, size: 80),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello! 👋',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sessions.isEmpty
                                ? 'Let\'s capture your first story!'
                                : 'You have ${sessions.length} stor${sessions.length == 1 ? 'y' : 'ies'}.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: AppColors.textDark
                                        .withValues(alpha: 0.7)),
                          ),
                          if (!storage.isPremium) ...[
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => Get.to(() => const PaywallScreen()),
                              child: const Text(
                                'Upgrade to Premium ✨',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (sessions.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📚', style: TextStyle(fontSize: 64)),
                      SizedBox(height: 16),
                      Text('No stories yet.',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      SizedBox(height: 8),
                      Text('Tap + to capture your first storybook!',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _SessionCard(session: sessions[i]),
                    childCount: sessions.length,
                  ),
                ),
              ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final ctrl = Get.find<SessionController>();
          if (!ctrl.canStartNewSession) {
            Get.to(() => const PaywallScreen());
            return;
          }
          Get.to(() => const CameraScreen());
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text('New Story',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final StorySession session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionController>();
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Story?'),
            content: Text('Remove "${session.title}"?'),
            actions: [
              TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (_) => ctrl.deleteSession(session.id),
      child: GestureDetector(
        onTap: () {
          ctrl.touchSession(session.id);
          Get.to(() => PlaybackScreen(session: session));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                    child: Text('📖', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      '${session.pages.length} pages • ${DateFormat('MMM d').format(session.lastOpenedAt)}',
                      style: TextStyle(
                          color: AppColors.textDark.withValues(alpha: 0.55),
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_circle,
                  color: AppColors.primary, size: 36),
            ],
          ),
        ),
      ),
    );
  }
}
