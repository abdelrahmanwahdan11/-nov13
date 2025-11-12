import 'package:flutter/material.dart';

import '../../../controllers/search_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../models/audio_item.dart';
import '../../widgets/genius_app_bar.dart';
import '../../widgets/genius_input.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/pill_buttons.dart';
import '../../widgets/skeleton_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final ScrollController _scrollController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final SearchController controller = ControllerScope.of(context).search;
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final SearchController controller = ControllerScope.of(context).search;
    final AppLocalizations l10n = context.l10n;
    return GeniusScaffold(
      appBar: GeniusAppBar(
        title: l10n.translate('search'),
        actions: [
          IconButton(
            onPressed: () => _openFilters(context, controller, l10n),
            icon: const Icon(Icons.tune),
            tooltip: l10n.translate('filters'),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final SearchState state = controller.state;
          if (_textController.text != state.query) {
            _textController.value = TextEditingValue(
              text: state.query,
              selection: TextSelection.collapsed(offset: state.query.length),
            );
          }
          final GeniusPalette palette = Theme.of(context).brightness == Brightness.dark
              ? geniusTheme.dark
              : geniusTheme.light;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GeniusInput(
                  controller: _textController,
                  hintText: l10n.translate('search_hint'),
                  onChanged: controller.updateQuery,
                  suffix: state.query.isEmpty
                      ? const Icon(Icons.search)
                      : IconButton(
                          onPressed: () => controller.updateQuery(''),
                          icon: const Icon(Icons.close),
                        ),
                ),
                const SizedBox(height: 16),
                if (state.filters.isNotEmpty)
                  _ActiveFiltersRow(
                    palette: palette,
                    l10n: l10n,
                    state: state,
                    onRemove: controller.removeFilter,
                  ),
                if (state.filters.isNotEmpty) const SizedBox(height: 12),
                if (state.history.isNotEmpty)
                  _HistorySection(
                    palette: palette,
                    l10n: l10n,
                    controller: controller,
                  ),
                if (state.history.isNotEmpty) const SizedBox(height: 12),
                if (state.suggestions.isNotEmpty)
                  _SuggestionSection(
                    palette: palette,
                    l10n: l10n,
                    controller: controller,
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: state.isLoading
                        ? ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: _scrollController,
                            itemCount: 6,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemBuilder: (context, index) => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: SkeletonCard(),
                            ),
                          )
                        : state.visible.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 48),
                                    child: Column(
                                      children: [
                                        Icon(Icons.search_off,
                                            size: 56, color: palette.inkSecondary),
                                        const SizedBox(height: 12),
                                        Text(
                                          l10n.translate('search_empty'),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: palette.inkSecondary,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                itemCount:
                                    state.visible.length + (state.isPaginating ? 1 : 0),
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  if (index >= state.visible.length) {
                                    return const SkeletonCard();
                                  }
                                  final AudioItem item = state.visible[index];
                                  return _SearchResultTile(item: item, palette: palette);
                                },
                              ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openFilters(BuildContext context, SearchController controller, AppLocalizations l10n) {
    final Map<String, dynamic> filters = Map<String, dynamic>.from(controller.state.filters);
    String mood = filters['mood'] as String? ?? '';
    String duration = filters['duration'] as String? ?? '';
    String sort = filters['sort'] as String? ?? 'recent';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _FilterSheet(
          controller: controller,
          l10n: l10n,
          initialMood: mood,
          initialDuration: duration,
          initialSort: sort,
        );
      },
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.palette,
    required this.l10n,
    required this.controller,
  });

  final GeniusPalette palette;
  final AppLocalizations l10n;
  final SearchController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          label: l10n.translate('recent_searches'),
          actionLabel: l10n.translate('clear_history'),
          onAction: controller.clearHistory,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: controller.state.history
              .map(
                (entry) => _FilterChip(
                  label: entry,
                  palette: palette,
                  onTap: () => controller.useHistory(entry),
                  onRemove: () => controller.removeHistoryEntry(entry),
                  showRemove: true,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SuggestionSection extends StatelessWidget {
  const _SuggestionSection({
    required this.palette,
    required this.l10n,
    required this.controller,
  });

  final GeniusPalette palette;
  final AppLocalizations l10n;
  final SearchController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: l10n.translate('suggestions')),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: controller.state.suggestions
              .map(
                (suggestion) => _FilterChip(
                  label: suggestion,
                  palette: palette,
                  onTap: () => controller.applySuggestion(suggestion),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ActiveFiltersRow extends StatelessWidget {
  const _ActiveFiltersRow({
    required this.palette,
    required this.l10n,
    required this.state,
    required this.onRemove,
  });

  final GeniusPalette palette;
  final AppLocalizations l10n;
  final SearchState state;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = <Widget>[];
    state.filters.forEach((key, value) {
      if (value is! String || value.isEmpty) {
        return;
      }
      chips.add(
        _FilterChip(
          label: _filterLabel(key, value, l10n),
          palette: palette,
          onTap: () => onRemove(key),
          onRemove: () => onRemove(key),
          showRemove: true,
        ),
      );
    });
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('active_filters'),
          style: TextStyle(color: palette.inkSecondary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }

  String _filterLabel(String key, String value, AppLocalizations l10n) {
    switch (key) {
      case 'mood':
        return '${l10n.translate('mood')}: $value';
      case 'duration':
        return '${l10n.translate('duration')}: ${l10n.translate(_durationKey(value))}';
      case 'sort':
        return '${l10n.translate('sort')}: ${l10n.translate(_sortKey(value))}';
      default:
        return value;
    }
  }

  String _durationKey(String value) {
    switch (value) {
      case 'short':
        return 'search_duration_short';
      case 'medium':
        return 'search_duration_medium';
      case 'long':
        return 'search_duration_long';
      default:
        return value;
    }
  }

  String _sortKey(String value) {
    switch (value) {
      case 'popular':
        return 'search_sort_popular';
      case 'duration':
        return 'search_sort_duration';
      default:
        return 'search_sort_recent';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.palette,
    required this.onTap,
    this.onRemove,
    this.showRemove = false,
  });

  final String label;
  final GeniusPalette palette;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final bool showRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: palette.outline, width: geniusStrokeWidth),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(color: palette.ink, fontWeight: FontWeight.w600)),
              if (showRemove) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onRemove,
                  customBorder: const CircleBorder(),
                  child: Icon(Icons.close, size: 16, color: palette.inkSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.actionLabel, this.onAction});

  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final GeniusPalette palette = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: palette.ink,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: palette.ink,
              textStyle: const TextStyle(decoration: TextDecoration.underline),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.controller,
    required this.l10n,
    required this.initialMood,
    required this.initialDuration,
    required this.initialSort,
  });

  final SearchController controller;
  final AppLocalizations l10n;
  final String initialMood;
  final String initialDuration;
  final String initialSort;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _mood;
  late String _duration;
  late String _sort;

  @override
  void initState() {
    super.initState();
    _mood = widget.initialMood;
    _duration = widget.initialDuration;
    _sort = widget.initialSort;
  }

  @override
  Widget build(BuildContext context) {
    final GeniusPalette palette = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: palette.outline, width: geniusStrokeWidth),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.inkSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.l10n.translate('filters'),
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _FilterGroup(
                  title: widget.l10n.translate('mood'),
                  options: widget.controller.availableMoods,
                  selected: _mood,
                  onSelect: (value) => setState(() => _mood = value == _mood ? '' : value),
                ),
                const SizedBox(height: 16),
                _FilterGroup(
                  title: widget.l10n.translate('duration'),
                  options: widget.controller.durationOptions,
                  selected: _duration,
                  onSelect: (value) => setState(() => _duration = value == _duration ? '' : value),
                  labelResolver: (value) => widget.l10n.translate(_durationKey(value)),
                ),
                const SizedBox(height: 16),
                _FilterGroup(
                  title: widget.l10n.translate('sort'),
                  options: widget.controller.sortOptions,
                  selected: _sort,
                  onSelect: (value) => setState(() => _sort = value),
                  labelResolver: (value) => widget.l10n.translate(_sortKey(value)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedPillButton(
                        label: widget.l10n.translate('search_filters_reset'),
                        onPressed: () {
                          setState(() {
                            _mood = '';
                            _duration = '';
                            _sort = 'recent';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledPillButton(
                        label: widget.l10n.translate('apply'),
                        onPressed: () {
                          final Map<String, String> next = <String, String>{};
                          if (_mood.isNotEmpty) {
                            next['mood'] = _mood;
                          }
                          if (_duration.isNotEmpty) {
                            next['duration'] = _duration;
                          }
                          if (_sort.isNotEmpty && _sort != 'recent') {
                            next['sort'] = _sort;
                          }
                          widget.controller.updateFilters(next);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _durationKey(String value) {
    switch (value) {
      case 'short':
        return 'search_duration_short';
      case 'medium':
        return 'search_duration_medium';
      case 'long':
        return 'search_duration_long';
      default:
        return value;
    }
  }

  String _sortKey(String value) {
    switch (value) {
      case 'popular':
        return 'search_sort_popular';
      case 'duration':
        return 'search_sort_duration';
      default:
        return 'search_sort_recent';
    }
  }
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.labelResolver,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final String Function(String value)? labelResolver;

  @override
  Widget build(BuildContext context) {
    final GeniusPalette palette = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: palette.inkSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: options
              .map(
                (option) => _SelectableChip(
                  label: labelResolver?.call(option) ?? option,
                  selected: option == selected,
                  onTap: () => onSelect(option),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final GeniusPalette palette = theme.brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    final Color background = selected ? theme.colorScheme.primary : theme.colorScheme.surface;
    final Color foreground = selected ? theme.colorScheme.onPrimary : palette.ink;
    return Material(
      color: background,
      shape: StadiumBorder(
        side: BorderSide(color: palette.outline, width: geniusStrokeWidth),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.item, required this.palette});

  final AudioItem item;
  final GeniusPalette palette;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(theme.brightness == Brightness.dark ? 0.7 : 0.85),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.outline, width: geniusStrokeWidth),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 72,
                height: 72,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }
                    final double? value = progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!.toDouble()
                        : null;
                    return Container(
                      color: palette.surface.withOpacity(0.6),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.creator} • ${_formatDuration(item.durationSec)}',
                    style: TextStyle(color: palette.inkSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _Tag(label: item.mood),
                      ...item.tags.map((tag) => _Tag(label: tag)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              color: theme.colorScheme.primary,
              tooltip: context.l10n.translate('play'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours > 0 ? '${duration.inHours}:' : ''}$minutes:$secs';
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final GeniusPalette palette = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.outline, width: geniusStrokeWidth),
        color: palette.surface.withOpacity(0.8),
      ),
      child: Text(
        label,
        style: TextStyle(color: palette.inkSecondary, fontSize: 12),
      ),
    );
  }
}
