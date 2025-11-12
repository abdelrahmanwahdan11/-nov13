import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../controllers/record_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../models/recording_clip.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/pill_buttons.dart';
import '../../widgets/waveform_stub.dart';

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
    _timer ??= Timer.periodic(const Duration(milliseconds: 320), (_) {
      final random = Random();
      final controller = _record;
      if (controller == null) return;
      final double intensity = controller.value.isRecording
          ? 0.4 + random.nextDouble() * 0.6
          : 0.1 + random.nextDouble() * 0.4;
      controller.registerSample(intensity, const Duration(milliseconds: 320));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration value) {
    final int minutes = value.inMinutes;
    final int seconds = value.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context).record;
    final player = ControllerScope.of(context).player;
    final palette = context.geniusPalette;
    return GeniusScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ValueListenableBuilder<RecordState>(
            valueListenable: controller,
            builder: (context, state, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth > 900;
                  final Widget controls = _RecordControls(
                    state: state,
                    onStart: controller.startRecording,
                    onPause: controller.pauseRecording,
                    onResume: controller.resumeRecording,
                    onFinish: () {
                      final RecordingClip? clip = controller.stopRecording();
                      if (clip != null) {
                        player.playRecording(clip);
                      }
                    },
                    onCancel: controller.cancelRecording,
                    palette: palette,
                    formatDuration: _formatDuration,
                  );
                  final Widget recordings = _RecordingsList(
                    state: state,
                    palette: palette,
                    onPlay: player.playRecording,
                    onDelete: controller.removeClip,
                    formatDuration: _formatDuration,
                  );
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: controls),
                        const SizedBox(width: 32),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(right: 8),
                            child: recordings,
                          ),
                        ),
                      ],
                    );
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: controls),
                      SliverToBoxAdapter(child: const SizedBox(height: 32)),
                      SliverToBoxAdapter(child: recordings),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RecordControls extends StatelessWidget {
  const _RecordControls({
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
    required this.onCancel,
    required this.palette,
    required this.formatDuration,
  });

  final RecordState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  final VoidCallback onCancel;
  final GeniusPalette palette;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canFinish = state.elapsed > Duration.zero;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: palette.outline, width: geniusStrokeWidth),
        color: palette.surface.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: palette.outline.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            formatDuration(state.elapsed),
            style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: state.micLevel),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: palette.surface,
                color: palette.accent,
              );
            },
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: WaveformStub(
              key: ValueKey<bool>(state.isRecording || state.isPaused),
              height: 72,
              waveform: state.waveform,
              animate: true,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              if (!state.isRecording && !state.isPaused)
                FilledPillButton(
                  label: context.l10n.translate('record_start'),
                  onPressed: onStart,
                ),
              if (state.isRecording)
                OutlinedPillButton(
                  label: context.l10n.translate('record_pause'),
                  onPressed: onPause,
                ),
              if (state.isPaused)
                FilledPillButton(
                  label: context.l10n.translate('record_resume'),
                  onPressed: onResume,
                ),
              OutlinedPillButton(
                label: context.l10n.translate('record_cancel'),
                onPressed: canFinish ? onCancel : null,
              ),
              FilledPillButton(
                label: context.l10n.translate('record_finish'),
                onPressed: canFinish ? onFinish : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.translate('record_tip_title'),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.translate('record_tip_body'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: palette.inkSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _RecordingsList extends StatelessWidget {
  const _RecordingsList({
    required this.state,
    required this.palette,
    required this.onPlay,
    required this.onDelete,
    required this.formatDuration,
  });

  final RecordState state;
  final GeniusPalette palette;
  final void Function(RecordingClip) onPlay;
  final void Function(String) onDelete;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (state.clips.isEmpty) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radiusLg),
          border: Border.all(color: palette.outline, width: geniusStrokeWidth),
          color: palette.surface.withOpacity(0.9),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.translate('record_empty_title'),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.translate('record_empty_body'),
              style: theme.textTheme.bodyMedium?.copyWith(color: palette.inkSecondary, height: 1.5),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(state.clips.length, (int index) {
        final RecordingClip clip = state.clips[index];
        return Padding(
          padding: EdgeInsets.only(bottom: index == state.clips.length - 1 ? 0 : 16),
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 320 + index * 40),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 20, end: 0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
              );
            },
            child: _RecordingTile(
              clip: clip,
              palette: palette,
              onPlay: () => onPlay(clip),
              onDelete: () => onDelete(clip.id),
              formatDuration: formatDuration,
            ),
          ),
        );
      }),
    );
  }
}

class _RecordingTile extends StatelessWidget {
  const _RecordingTile({
    required this.clip,
    required this.palette,
    required this.onPlay,
    required this.onDelete,
    required this.formatDuration,
  });

  final RecordingClip clip;
  final GeniusPalette palette;
  final VoidCallback onPlay;
  final VoidCallback onDelete;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: palette.outline, width: geniusStrokeWidth),
        color: palette.surface.withOpacity(0.88),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          '${context.l10n.translate('record_clip')} ${clip.friendlyLabel}',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '${formatDuration(clip.duration)} • ${context.l10n.translate('record_saved_at')} ${TimeOfDay.fromDateTime(clip.createdAt).format(context)}',
          style: theme.textTheme.bodySmall?.copyWith(color: palette.inkSecondary),
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              onPressed: onPlay,
              tooltip: context.l10n.translate('record_play'),
              icon: const Icon(Icons.play_circle_fill),
            ),
            IconButton(
              onPressed: onDelete,
              tooltip: context.l10n.translate('record_delete'),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
