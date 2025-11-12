import 'package:flutter/material.dart';

import '../../../controllers/publish_controller.dart';
import '../../../core/utils/controller_scope.dart';
import '../../widgets/ai_info_button.dart';
import '../../widgets/genius_input.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/pill_buttons.dart';

class PublishPage extends StatelessWidget {
  const PublishPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context).publish;
    return GeniusScaffold(
      appBar: AppBar(
        title: const Text('Publish'),
        actions: const [AiInfoButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ValueListenableBuilder<PublishState>(
          valueListenable: controller,
          builder: (context, state, _) {
            final titleController = TextEditingController(text: state.title);
            return ListView(
              children: [
                GeniusInput(
                  controller: titleController,
                  hintText: 'Title',
                  onChanged: controller.setTitle,
                ),
                const SizedBox(height: 16),
                GeniusInput(
                  hintText: 'Tags (comma separated)',
                  onChanged: (value) => controller.setTags(value.split(',')),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: state.privacy,
                  decoration: const InputDecoration(labelText: 'Privacy'),
                  items: const [
                    DropdownMenuItem(value: 'public', child: Text('Public')),
                    DropdownMenuItem(value: 'private', child: Text('Private')),
                    DropdownMenuItem(value: 'unlisted', child: Text('Unlisted')),
                  ],
                  onChanged: (value) => controller.setPrivacy(value ?? 'public'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => controller.setCover('auto_cover'),
                  child: const Text('Generate Cover'),
                ),
                const SizedBox(height: 16),
                FilledPillButton(
                  label: 'Publish',
                  onPressed: () {},
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
