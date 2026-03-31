import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/playback_controller.dart';
import '../../models/story_session.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ollie_character.dart';
import '../library/library_screen.dart';

class PlaybackScreen extends StatelessWidget {
  final StorySession session;
  const PlaybackScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(PlaybackController());
    ctrl.init(session);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(session.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ctrl.pause();
            Get.offAll(() => const LibraryScreen());
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            tooltip: 'Replay',
            onPressed: ctrl.replay,
          ),
        ],
      ),
      body: Column(
        children: [
          // Page tabs
          _PageTabs(session: session),

          // Main text area with word highlighting
          Expanded(
            flex: 5,
            child: Obx(() {
              final pageIdx = ctrl.currentPageIndex.value;
              final page = session.pages[pageIdx];
              return _WordHighlightView(
                words: page.words,
                currentWordIndex: ctrl.localWordIndex,
              );
            }),
          ),

          // Ollie character
          Obx(() => SizedBox(
                height: 100,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    OllieCharacter(
                      state: ctrl.isPlaying.value
                          ? OllieState.reading
                          : ctrl.isDone.value
                              ? OllieState.celebrating
                              : OllieState.idle,
                      size: 80,
                    ),
                    const SizedBox(width: 16),
                    if (ctrl.isDone.value)
                      Expanded(
                        child: Text(
                          '🎉 The End! Great reading!',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
              )),

          // Controls
          _PlaybackControls(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PageTabs extends StatelessWidget {
  final StorySession session;
  const _PageTabs({required this.session});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PlaybackController>();
    return SizedBox(
      height: 48,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: session.pages.length,
            itemBuilder: (_, i) {
              final isActive = ctrl.currentPageIndex.value == i;
              return GestureDetector(
                onTap: () => ctrl.goToPage(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'P${i + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}

class _WordHighlightView extends StatelessWidget {
  final List<String> words;
  final int currentWordIndex;

  const _WordHighlightView({
    required this.words,
    required this.currentWordIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 4,
        runSpacing: 8,
        children: List.generate(words.length, (i) {
          final isHighlighted = i == currentWordIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.wordHighlight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: isHighlighted
                  ? Border.all(color: AppColors.wordHighlightBorder, width: 1.5)
                  : null,
            ),
            child: Text(
              words[i],
              style: TextStyle(
                fontSize: 22,
                height: 1.6,
                fontWeight: isHighlighted
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: AppColors.textDark,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PlaybackController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause button
          Obx(() => GestureDetector(
                onTap: ctrl.togglePlayPause,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    ctrl.isPlaying.value ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              )),
          const SizedBox(height: 12),
          // Speed control
          Row(
            children: [
              const Text('Speed:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => Slider(
                      value: ctrl.playbackRate.value,
                      min: 0.75,
                      max: 1.5,
                      divisions: 3,
                      label: '${ctrl.playbackRate.value}x',
                      activeColor: AppColors.primary,
                      onChanged: ctrl.setRate,
                    )),
              ),
              Obx(() => Text(
                    '${ctrl.playbackRate.value}x',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
