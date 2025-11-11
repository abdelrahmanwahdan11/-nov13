import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/skeleton_card.dart';

class DraftsLibraryPage extends StatefulWidget {
  const DraftsLibraryPage({super.key});

  @override
  State<DraftsLibraryPage> createState() => _DraftsLibraryPageState();
}

class _DraftsLibraryPageState extends State<DraftsLibraryPage> {
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 800)).then((_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = DummyData.audioItems;
    return GeniusScaffold(
      appBar: AppBar(title: const Text('Drafts & Library')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _filter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'recent', child: Text('Recent')),
                DropdownMenuItem(value: 'long', child: Text('Long form')),
              ],
              onChanged: (value) => setState(() => _filter = value ?? 'all'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? ListView.builder(
                      itemCount: 6,
                      itemBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SkeletonCard(),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _loading = true;
                        });
                        await Future<void>.delayed(const Duration(milliseconds: 500));
                        setState(() {
                          _loading = false;
                        });
                      },
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            leading: CircleAvatar(backgroundImage: NetworkImage(item.imageUrl)),
                            title: Text(item.title),
                            subtitle: Text('${item.durationSec ~/ 60} min'),
                            trailing: IconButton(
                              icon: const Icon(Icons.download_for_offline_outlined),
                              onPressed: () {},
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
