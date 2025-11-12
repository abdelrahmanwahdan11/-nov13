import 'package:flutter/material.dart';

import '../../../controllers/player_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/controller_scope.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/waveform_stub.dart';

class PlayerDetailPage extends StatelessWidget {
  const PlayerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context).player;
    final palette = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    return GeniusScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ValueListenableBuilder<PlayerState>(
            valueListenable: controller,
            builder: (context, state, _) {
              final String title = state.trackTitle ?? context.l10n.translate('player_default_title');
              final String subtitle = state.isLocal
                  ? context.l10n.translate('player_local_source')
                  : context.l10n.translate('player_streaming_source');
              final Duration duration = state.duration.inSeconds > 0
                  ? state.duration
                  : const Duration(minutes: 5);
              final double maxSeconds = duration.inSeconds.toDouble().clamp(1, double.infinity);
              final double progress = state.position.inSeconds.clamp(0, maxSeconds).toDouble();
              return LayoutBuilder(
                builder: (context, constraints) {
                  final bool wide = constraints.maxWidth > 720;
                  final Widget artwork = ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      width: wide ? constraints.maxWidth * 0.4 : double.infinity,
                      height: wide ? constraints.maxWidth * 0.4 : 260,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(color: palette.outline, width: geniusStrokeWidth),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 450),
                          child: Icon(
                            state.isPlaying ? Icons.graphic_eq : Icons.audiotrack,
                            key: ValueKey<bool>(state.isPlaying),
                            size: wide ? 128 : 96,
                            color: palette.ink,
                          ),
                        ),
                      ),
                    ),
                  );

                  final Widget controls = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Column(
                          key: ValueKey<String>(title),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.inkSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      WaveformStub(
                        height: wide ? 96 : 72,
                        waveform: state.waveform,
                        animate: state.isPlaying,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(state.position)),
                          Text(_formatDuration(duration)),
                        ],
                      ),
                      Slider(
                        value: progress,
                        max: maxSeconds,
                        onChanged: (value) => controller.seekTo(Duration(seconds: value.round())),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => controller.seekBy(const Duration(seconds: -15)),
                            icon: const Icon(Icons.replay_15),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: InkResponse(
                              radius: 48,
                              onTap: controller.togglePlay,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  state.isPlaying ? Icons.pause_circle : Icons.play_circle,
                                  key: ValueKey<bool>(state.isPlaying),
                                  size: 72,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.seekBy(const Duration(seconds: 15)),
                            icon: const Icon(Icons.forward_15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: controller.toggleLike,
                            icon: Icon(state.isLiked ? Icons.favorite : Icons.favorite_border),
                          ),
                          IconButton(
                            onPressed: controller.toggleSave,
                            icon: Icon(state.isSaved ? Icons.bookmark : Icons.bookmark_border),
                          ),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('0.5x', style: Theme.of(context).textTheme.bodySmall),
                          Expanded(
                            child: Slider(
                              value: state.speed,
                              min: 0.5,
                              max: 2,
                              divisions: 6,
                              label: '${state.speed.toStringAsFixed(1)}x',
                              onChanged: controller.changeSpeed,
                            ),
                          ),
                          Text('2x', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  );

                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: artwork),
                        const SizedBox(width: 32),
                        Expanded(child: controls),
                      ],
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        artwork,
                        const SizedBox(height: 24),
                        controls,
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration value) {
    final int minutes = value.inMinutes;
    final int seconds = value.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
