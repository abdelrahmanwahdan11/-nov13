import 'package:flutter/material.dart';

import '../../../controllers/compare_controller.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../data/dummy_data.dart';
import '../../widgets/genius_scaffold.dart';

class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context).compare;
    final items = DummyData.audioItems;
    return GeniusScaffold(
      appBar: AppBar(title: const Text('Compare')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<CompareState>(
          valueListenable: controller,
          builder: (context, state, _) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<AudioItem?>(
                        value: state.first,
                        hint: const Text('First'),
                        isExpanded: true,
                        items: items
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.title, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: controller.setFirst,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<AudioItem?>(
                        value: state.second,
                        hint: const Text('Second'),
                        isExpanded: true,
                        items: items
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.title, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: controller.setSecond,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (state.first != null && state.second != null)
                  Expanded(
                    child: Column(
                      children: [
                        _CompareRow(label: 'Duration', first: '${state.first!.durationSec}s', second: '${state.second!.durationSec}s'),
                        _CompareRow(label: 'Mood', first: state.first!.mood, second: state.second!.mood),
                        _CompareRow(label: 'Plays', first: '${state.first!.plays}', second: '${state.second!.plays}'),
                        _CompareRow(label: 'Likes', first: '${state.first!.likes}', second: '${state.second!.likes}'),
                      ],
                    ),
                  )
                else
                  const Expanded(
                    child: Center(child: Text('Select two items to compare.')),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.label, required this.first, required this.second});

  final String label;
  final String first;
  final String second;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(first)),
          Expanded(child: Text(second)),
        ],
      ),
    );
  }
}
