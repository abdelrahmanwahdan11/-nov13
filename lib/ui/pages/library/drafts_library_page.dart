import 'package:flutter/material.dart';

import '../../../controllers/downloads_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../data/dummy_data.dart';
import '../../../models/audio_item.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/pill_buttons.dart';
import '../../widgets/skeleton_card.dart';

class DraftsLibraryPage extends StatefulWidget {
  const DraftsLibraryPage({super.key});

  @override
  State<DraftsLibraryPage> createState() => _DraftsLibraryPageState();
}

class _DraftsLibraryPageState extends State<DraftsLibraryPage> {
  bool _loading = true;
  String _segment = 'all';

  @override
  void initState() {
    super.initState();
    _simulateFetch();
  }

  Future<void> _simulateFetch() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _onRefresh() async {
    await Future.wait<void>([
      _simulateFetch(),
      ControllerScope.of(context).downloads.simulateSync(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final downloads = ControllerScope.of(context).downloads;
    final items = DummyData.audioItems;
    final l10n = context.l10n;
    return GeniusScaffold(
      appBar: AppBar(
        title: Text(l10n.translate('library')),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/downloads'),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: downloads,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'all',
                      label: Text(l10n.translate('all')),
                      icon: const Icon(Icons.layers_outlined),
                    ),
                    ButtonSegment(
                      value: 'drafts',
                      label: Text(l10n.translate('drafts')),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    ButtonSegment(
                      value: 'downloads',
                      label: Text(l10n.translate('downloads')),
                      icon: const Icon(Icons.download_for_offline_outlined),
                    ),
                  ],
                  selected: {_segment},
                  onSelectionChanged: (selection) {
                    setState(() => _segment = selection.first);
                  },
                ),
                const SizedBox(height: 16),
                if (_loading)
                  ...List<Widget>.generate(
                    6,
                    (index) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SkeletonCard(),
                    ),
                  )
                else
                  ..._buildContent(
                    context: context,
                    downloads: downloads,
                    items: items,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildContent({
    required BuildContext context,
    required DownloadsController downloads,
    required List<AudioItem> items,
  }) {
    final l10n = context.l10n;
    switch (_segment) {
      case 'drafts':
        return _buildDraftTiles(context, l10n, items.take(8).toList());
      case 'downloads':
        return _buildDownloadTiles(context, l10n, downloads);
      default:
        return [
          ..._buildDraftSection(context, l10n, items.take(5).toList()),
          const SizedBox(height: 24),
          ..._buildDownloadSection(context, l10n, downloads),
        ];
    }
  }

  List<Widget> _buildDraftSection(
    BuildContext context,
    AppLocalizations l10n,
    List<AudioItem> drafts,
  ) {
    return [
      Text(l10n.translate('recent_drafts'),
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      ..._buildDraftTiles(context, l10n, drafts),
      if (drafts.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(l10n.translate('no_drafts')),
        ),
    ];
  }

  List<Widget> _buildDraftTiles(
    BuildContext context,
    AppLocalizations l10n,
    List<AudioItem> drafts,
  ) {
    return drafts
        .map(
          (item) => Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(item.imageUrl)),
              title: Text(item.title),
              subtitle: Text('${item.durationSec ~/ 60} min • ${item.mood}'),
              trailing: FilledPillButton(
                label: l10n.translate('publish'),
                onPressed: () {},
              ),
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildDownloadSection(
    BuildContext context,
    AppLocalizations l10n,
    DownloadsController downloads,
  ) {
    final entries = downloads.entries;
    if (entries.isEmpty) {
      return [
        Text(l10n.translate('no_downloads')),
        const SizedBox(height: 12),
        OutlinedPillButton(
          label: l10n.translate('browse_catalog'),
          onPressed: () => Navigator.of(context).pushNamed('/catalog'),
          icon: const Icon(Icons.explore_outlined),
        ),
      ];
    }
    return [
      Text(l10n.translate('downloads'),
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      ..._buildDownloadTiles(context, l10n, downloads),
    ];
  }

  List<Widget> _buildDownloadTiles(
    BuildContext context,
    AppLocalizations l10n,
    DownloadsController downloads,
  ) {
    return downloads.entries
        .map(
          (entry) => ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(entry.imageUrl)),
            title: Text(entry.title),
            subtitle: entry.isCompleted
                ? Text(l10n.translate('saved_offline'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(value: entry.progress),
                      const SizedBox(height: 4),
                      Text('${(entry.progress * 100).floor()}%'),
                    ],
                  ),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => downloads.remove(entry.id),
            ),
          ),
        )
        .toList();
  }
}
