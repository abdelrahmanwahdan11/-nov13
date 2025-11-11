import 'package:flutter/material.dart';

import '../../../controllers/player_controller.dart';
import '../../../core/utils/controller_scope.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/waveform_stub.dart';

class PlayerDetailPage extends StatelessWidget {
  const PlayerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context).player;
    return GeniusScaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ValueListenableBuilder<PlayerState>(
          valueListenable: controller,
          builder: (context, state, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    height: 240,
                    color: Theme.of(context).colorScheme.surface,
                    child: const Center(child: Icon(Icons.graphic_eq, size: 96)),
                  ),
                ),
                const SizedBox(height: 24),
                const WaveformStub(height: 64),
                const SizedBox(height: 24),
                Text('${state.position.inSeconds ~/ 60}:${(state.position.inSeconds % 60).toString().padLeft(2, '0')}'),
                Slider(
                  value: state.position.inSeconds.toDouble(),
                  max: state.duration.inSeconds.toDouble(),
                  onChanged: (value) {},
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => controller.seekBy(const Duration(seconds: -15)),
                      icon: const Icon(Icons.replay_15),
                    ),
                    IconButton(
                      onPressed: controller.togglePlay,
                      icon: Icon(state.isPlaying ? Icons.pause_circle : Icons.play_circle),
                      iconSize: 64,
                    ),
                    IconButton(
                      onPressed: () => controller.seekBy(const Duration(seconds: 15)),
                      icon: const Icon(Icons.forward_15),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: controller.toggleLike, icon: Icon(state.isLiked ? Icons.favorite : Icons.favorite_border)),
                    IconButton(onPressed: controller.toggleSave, icon: Icon(state.isSaved ? Icons.bookmark : Icons.bookmark_border)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('0.5x'),
                    Expanded(
                      child: Slider(
                        value: state.speed,
                        min: 0.5,
                        max: 2,
                        onChanged: controller.changeSpeed,
                      ),
                    ),
                    const Text('2x'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
