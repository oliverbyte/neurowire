import 'package:flutter/material.dart';

import 'checklist_screen.dart';
import 'dialogs.dart';
import 'l10n/app_strings.dart';
import 'locale_controller.dart';
import 'models.dart';
import 'palette.dart';
import 'storage.dart';

/// Kept small and shared so every tile (trigger, add-button, dashed outline)
/// uses the exact same, clearly rectangular corner rounding.
const double _tileRadius = 12;

class HomeScreen extends StatefulWidget {
  final LocaleController localeController;

  const HomeScreen({super.key, required this.localeController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = TriggerRepository();
  List<Trigger> _triggers = [];
  bool _loading = true;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final triggers = await _repo.load();
    setState(() {
      _triggers = triggers;
      _loading = false;
    });
  }

  Future<void> _persist() => _repo.save(_triggers);

  Future<void> _addTrigger() async {
    final strings = AppStrings.of(context);
    final label = await promptText(context, title: strings.newButtonTitle, hint: strings.newButtonHint);
    if (label == null || label.trim().isEmpty) return;
    final nextIndex = _triggers.length;
    setState(() => _triggers.add(Trigger.create(
          label.trim(),
          [strings.newButtonDefaultItem],
          colorValue: BrandPalette.colorForIndex(nextIndex).toARGB32(),
          iconIndex: nextIndex,
        )));
    await _persist();
  }

  Future<void> _renameTrigger(Trigger trigger) async {
    final label = await promptText(context, title: AppStrings.of(context).renameTitle, initial: trigger.label);
    if (label == null || label.trim().isEmpty) return;
    setState(() => trigger.label = label.trim());
    await _persist();
  }

  Future<void> _deleteTrigger(Trigger trigger) async {
    final strings = AppStrings.of(context);
    final confirmed = await confirmDialog(
      context,
      title: strings.deleteButtonTitle,
      content: strings.deleteButtonContent(trigger.label),
    );
    if (!confirmed) return;
    setState(() => _triggers.remove(trigger));
    await _persist();
  }

  Future<void> _openChecklist(Trigger trigger) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChecklistScreen(trigger: trigger, repository: _repo),
      ),
    );
    setState(() {}); // reflect any renamed/edited items when coming back
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              editMode: _editMode,
              onToggleEdit: () => setState(() => _editMode = !_editMode),
              localeController: widget.localeController,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        (constraints.maxWidth / 108).floor().clamp(3, 6);
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1,
                      ),
                      itemCount: _triggers.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _triggers.length) {
                          return _AddTile(onTap: _addTrigger);
                        }
                        final trigger = _triggers[index];
                        return _TriggerTile(
                          trigger: trigger,
                          editMode: _editMode,
                          onTap: () =>
                              _editMode ? _renameTrigger(trigger) : _openChecklist(trigger),
                          onDelete: () => _deleteTrigger(trigger),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool editMode;
  final VoidCallback onToggleEdit;
  final LocaleController localeController;

  const _Header({required this.editMode, required this.onToggleEdit, required this.localeController});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primaryContainer],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NeuroWire',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.tagline,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
          Material(
            color: scheme.onPrimary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
            child: PopupMenuButton<Locale?>(
              tooltip: strings.language,
              icon: Icon(Icons.language_rounded, color: scheme.onPrimary),
              initialValue: localeController.override,
              onSelected: localeController.setOverride,
              itemBuilder: (context) => [
                CheckedPopupMenuItem(
                  value: null,
                  checked: localeController.override == null,
                  child: Text(strings.languageSystem),
                ),
                CheckedPopupMenuItem(
                  value: const Locale('de'),
                  checked: localeController.override?.languageCode == 'de',
                  child: Text(strings.languageGerman),
                ),
                CheckedPopupMenuItem(
                  value: const Locale('en'),
                  checked: localeController.override?.languageCode == 'en',
                  child: Text(strings.languageEnglish),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: scheme.onPrimary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
            child: IconButton(
              tooltip: editMode ? strings.done : strings.editButtons,
              icon: Icon(editMode ? Icons.check_rounded : Icons.edit_rounded, color: scheme.onPrimary),
              onPressed: onToggleEdit,
            ),
          ),
        ],
      ),
    );
  }
}

class _TriggerTile extends StatelessWidget {
  final Trigger trigger;
  final bool editMode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TriggerTile({
    required this.trigger,
    required this.editMode,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = trigger.color;
    final darker = HSLColor.fromColor(color)
        .withLightness((HSLColor.fromColor(color).lightness - 0.14).clamp(0.0, 1.0))
        .toColor();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Positioned.fill (not a plain Stack child) so the tile actually
        // stretches to the full square grid cell instead of shrinking to
        // fit its icon/label content.
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(_tileRadius),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, darker],
                ),
                borderRadius: BorderRadius.circular(_tileRadius),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(_tileRadius),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(BrandPalette.iconForIndex(trigger.iconIndex), color: Colors.white, size: 26),
                      const SizedBox(height: 8),
                      Text(
                        trigger.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (editMode)
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_tileRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_tileRadius),
        onTap: onTap,
        child: _DottedBorderBox(
          color: scheme.outlineVariant,
          child: Icon(Icons.add_rounded, size: 26, color: scheme.primary),
        ),
      ),
    );
  }
}

/// Lightweight dashed-outline tile so the "add" affordance visually differs
/// from the solid, colorful trigger buttons.
class _DottedBorderBox extends StatelessWidget {
  final Color color;
  final Widget child;

  const _DottedBorderBox({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color),
      child: Center(child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(_tileRadius));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}
