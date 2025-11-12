import 'package:flutter/material.dart';

import '../../../controllers/feed_controller.dart';
import '../../../data/dummy_data.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/skeleton_card.dart';

class DiscoverCatalogPage extends StatefulWidget {
  const DiscoverCatalogPage({super.key});

  @override
  State<DiscoverCatalogPage> createState() => _DiscoverCatalogPageState();
}

class _DiscoverCatalogPageState extends State<DiscoverCatalogPage> {
  bool _grid = true;
  bool _loading = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 800)).then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = DummyData.audioItems.take(_page * 8).toList();
    return GeniusScaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: Icon(_grid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _grid = !_grid),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Filters', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: const [
                          Chip(label: Text('Chill')),
                          Chip(label: Text('Focus')),
                          Chip(label: Text('Hype')),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >
                    notification.metrics.maxScrollExtent - 200) {
                  setState(() {
                    _page = (_page + 1).clamp(1, 3);
                  });
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() => _loading = true);
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                  setState(() => _loading = false);
                },
                child: _grid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                    child: Image.network(item.imageUrl, fit: BoxFit.cover, width: double.infinity),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text(item.mood, style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= items.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: SkeletonCard(),
                            );
                          }
                          final item = items[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            leading: CircleAvatar(backgroundImage: NetworkImage(item.imageUrl)),
                            title: Text(item.title),
                            subtitle: Text(item.mood),
                          );
                        },
                      ),
              ),
            ),
    );
  }
}
