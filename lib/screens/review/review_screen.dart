import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/session_controller.dart';
import '../../models/story_session.dart';
import '../../theme/app_theme.dart';
import '../playback/playback_screen.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Your Story'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final session = await ctrl.saveCurrentSession();
                Get.offAll(() => PlaybackScreen(session: session));
              } catch (_) {
                Get.snackbar('Error', 'Failed to save story. Please try again.');
              }
            },
            child: const Text(
              'Play Story',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final pages = ctrl.processedPages;
        if (pages.isEmpty) {
          return const Center(child: Text('No pages processed.'));
        }
        return Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.textDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Review the text extracted from each page. Tap to edit if needed.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: pages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    _PageReviewCard(pageIndex: i, page: pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final session = await ctrl.saveCurrentSession();
                    Get.offAll(() => PlaybackScreen(session: session));
                  } catch (_) {
                    Get.snackbar('Error', 'Failed to save story. Please try again.');
                  }
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Story'),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _PageReviewCard extends StatefulWidget {
  final int pageIndex;
  final StoryPage page;

  const _PageReviewCard({required this.pageIndex, required this.page});

  @override
  State<_PageReviewCard> createState() => _PageReviewCardState();
}

class _PageReviewCardState extends State<_PageReviewCard> {
  bool _isEditing = false;
  late TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.page.rawText);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _saveEdit() {
    Get.find<SessionController>()
        .updatePageText(widget.pageIndex, _textCtrl.text);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Page ${widget.page.pageNumber}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
                if (widget.page.isEdited) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, size: 16, color: AppColors.secondary),
                ],
                if (widget.page.avgConfidence < 0.8 && !widget.page.isEdited) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.warning_amber,
                      size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  const Text('Low confidence — please review',
                      style: TextStyle(fontSize: 12, color: Colors.orange)),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                  child: Text(_isEditing ? 'Cancel' : 'Edit'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.page.rawText.isEmpty)
              const Text(
                'No text detected on this page.',
                style: TextStyle(
                    color: Colors.red, fontStyle: FontStyle.italic),
              )
            else if (_isEditing)
              Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: TextField(
                      controller: _textCtrl,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Edit text here...',
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _saveEdit,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 40)),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              )
            else
              Text(
                widget.page.rawText,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
          ],
        ),
      ),
    );
  }
}
