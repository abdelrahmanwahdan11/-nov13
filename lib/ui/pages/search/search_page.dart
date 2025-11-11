import 'package:flutter/material.dart';

import '../../../controllers/search_controller.dart';
import '../../../core/utils/controller_scope.dart';
import '../../widgets/genius_scaffold.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context).search;
    return GeniusScaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: controller.updateQuery,
              decoration: const InputDecoration(
                hintText: 'Search by title, mood, tags',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final results = controller.results;
                  return RefreshIndicator(
                    onRefresh: () async {
                      await Future<void>.delayed(const Duration(milliseconds: 300));
                    },
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(item.imageUrl)),
                          title: Text(item.title),
                          subtitle: Text('${item.creator} • ${item.mood}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
