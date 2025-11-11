import 'package:flutter/material.dart';

import '../../../controllers/edit_controller.dart';
import '../../../core/utils/controller_scope.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/waveform_stub.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context).edit;
    return GeniusScaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ValueListenableBuilder<EditState>(
          valueListenable: controller,
          builder: (context, state, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WaveformStub(height: 48),
                const SizedBox(height: 24),
                Text('Trim'),
                RangeSlider(
                  values: RangeValues(state.trimStart, state.trimEnd),
                  onChanged: (values) => controller.setTrim(values.start, values.end),
                ),
                SwitchListTile(
                  value: state.normalize,
                  onChanged: controller.toggleNormalize,
                  title: const Text('Normalize'),
                ),
                SwitchListTile(
                  value: state.denoise,
                  onChanged: controller.toggleDenoise,
                  title: const Text('Denoise'),
                ),
                ListTile(
                  title: const Text('Speed'),
                  subtitle: Slider(
                    value: state.speed,
                    min: 0.5,
                    max: 2,
                    onChanged: controller.setSpeed,
                  ),
                ),
                ListTile(
                  title: const Text('Pitch'),
                  subtitle: Slider(
                    value: state.pitch,
                    min: -12,
                    max: 12,
                    onChanged: controller.setPitch,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Preview'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
