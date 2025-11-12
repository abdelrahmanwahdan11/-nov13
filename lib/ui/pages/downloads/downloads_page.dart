import 'package:flutter/material.dart';

import '../../../controllers/downloads_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../data/dummy_data.dart';
import '../../../models/audio_item.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/pill_buttons.dart';
import '../../widgets/skeleton_card.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  String _segment = 'in_progress';
  bool _syncing = false;

  DownloadsController get _controller => ControllerScope.of(context).downloads;

  Future<void> _refresh() async {
    setState(() => _syncing = true);
    await _controller.simulateSync();
    if (mounted) {
      setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GeniusScaffold(
      appBar: AppBar(
        title: Text(l10n.translate('downloads')),
        actions: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              if (_controller.completed.isEmpty) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () async {
                  await _controller.clearCompleted();
                },
                child: Text(l10n.translate('clear_all')),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final entries = _segment == 'completed'
              ? _controller.completed
              : _controller.inProgress;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'in_progress',
                      label: Text(l10n.translate('in_progress')),
                      icon: const Icon(Icons.downloading_outlined),
                    ),
                    ButtonSegment(
                      value: 'completed',
                      label: Text(l10n.translate('completed')),
                      icon: const Icon(Icons.download_done_outlined),
                    ),
                  ],
                  selected: {_segment},
                  onSelectionChanged: (selection) {
                    setState(() => _segment = selection.first);
                  },
                ),
                const SizedBox(height: 24),
                if (_syncing)
                  ...List<Widget>.generate(
                    3,
                    (index) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SkeletonCard(),
                    ),
                  )
                else if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        const Icon(Icons.download_for_offline_outlined, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          l10n.translate('no_downloads'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...entries.map((entry) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                entry.imageUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.title,
                                      style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text(_formatDuration(entry.durationSec)),
                                  const SizedBox(height: 12),
                                  if (!entry.isCompleted)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        LinearProgressIndicator(value: entry.progress),
                                        const SizedBox(height: 4),
                                        Text('${(entry.progress * 100).floor()}%'),
                                      ],
                                    )
                                  else if (entry.completedAt != null)
                                    Text(
                                      l10n.translate('downloaded_on').replaceFirst(
                                            '{date}',
                                            _formatDate(entry.completedAt!),
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!entry.isCompleted)
                                  IconButton(
                                    tooltip: entry.isPaused
                                        ? l10n.translate('resume')
                                        : l10n.translate('pause'),
                                    icon: Icon(
                                      entry.isPaused
                                          ? Icons.play_arrow_rounded
                                          : Icons.pause_rounded,
                                    ),
                                    onPressed: () {
                                      if (entry.isPaused) {
                                        _controller.resume(entry.id);
                                      } else {
                                        _controller.pause(entry.id);
                                      }
                                    },
                                  ),
                                IconButton(
                                  tooltip: l10n.translate('remove'),
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _controller.remove(entry.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                Text(
                  l10n.translate('start_downloads'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _SuggestionsGrid(onSelect: _controller.startDownload),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final rem = seconds % 60;
    return '${minutes}m ${rem.toString().padLeft(2, '0')}s';
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}

class _SuggestionsGrid extends StatelessWidget {
  const _SuggestionsGrid({required this.onSelect});

  final void Function(AudioItem) onSelect;

  @override
  Widget build(BuildContext context) {
    final downloads = ControllerScope.of(context).downloads;
    final l10n = context.l10n;
    final available = DummyData.audioItems
        .where((item) => downloads.entryFor(item.id) == null)
        .take(6)
        .toList();
    if (available.isEmpty) {
      return Text(l10n.translate('all_downloaded'));
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final item in available)
          SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    item.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                OutlinedPillButton(
                  label: l10n.translate('download'),
                  icon: const Icon(Icons.download_rounded),
                  onPressed: () => onSelect(item),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
