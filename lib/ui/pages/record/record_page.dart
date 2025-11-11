import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../controllers/record_controller.dart';
import '../../../core/utils/controller_scope.dart';
import '../../widgets/genius_scaffold.dart';

class RecordStudioPage extends StatefulWidget {
  const RecordStudioPage({super.key});

  @override
  State<RecordStudioPage> createState() => _RecordStudioPageState();
}

class _RecordStudioPageState extends State<RecordStudioPage> {
  Timer? _timer;
  RecordController? _record;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _record ??= ControllerScope.of(context).record;
    _timer ??= Timer.periodic(const Duration(milliseconds: 300), (_) {
      final random = Random();
      _record?.updateMicLevel(random.nextDouble());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context).record;
    return GeniusScaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ValueListenableBuilder<RecordState>(
          valueListenable: controller,
          builder: (context, state, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text('Mic Level: ${(state.micLevel * 100).round()}%'),
                const SizedBox(height: 24),
                LinearProgressIndicator(value: state.micLevel),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: controller.toggleRecording,
                  child: Text(state.isRecording ? 'Pause' : 'Start Recording'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: state.isRecording ? null : () => controller.stopWithFile('temp.wav'),
                  child: const Text('Finish'),
                ),
                const SizedBox(height: 24),
                Text('Calibration Tips'),
                const SizedBox(height: 12),
                const Text('Hold device steady and speak at natural volume.'),
              ],
            );
          },
        ),
      ),
    );
  }
}
