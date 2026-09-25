import 'package:flutter/material.dart';

import 'dialogs.dart';
import 'l10n/app_strings.dart';
import 'models.dart';
import 'palette.dart';
import 'storage.dart';

class ChecklistScreen extends StatefulWidget {
  final Trigger trigger;
  final TriggerRepository repository;

  const ChecklistScreen({super.key, required this.trigger, required this.repository});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  // Checked state lives only in memory: every time this screen opens the
  // checklist starts fresh, unchecked, but with the same items/order.
  final Set<String> _checked = {};
  bool _editMode = false;

  List<ChecklistItem> get _items => widget.trigger.items;

  Future<void> _addItem() async {
    final strings = AppStrings.of(context);
    final text = await promptText(context, title: strings.addItemTitle, hint: strings.addItemHint);
    if (text == null || text.trim().isEmpty) return;
    setState(() => _items.add(ChecklistItem.create(text.trim())));
    await _persistAll();
  }

  Future<void> _renameItem(ChecklistItem item) async {
    final text = await promptText(context, title: AppStrings.of(context).editItemTitle, initial: item.text);
    if (text == null || text.trim().isEmpty) return;
    setState(() => item.text = text.trim());
    await _persistAll();
  }

  Future<void> _deleteItem(ChecklistItem item) async {
    final strings = AppStrings.of(context);
    final confirmed = await confirmDialog(
      context,
      title: strings.deleteItemTitle,
      content: strings.deleteItemContent(item.text),
    );
    if (!confirmed) return;
    setState(() {
      _items.remove(item);
      _checked.remove(item.id);
    });
    await _persistAll();
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    _persistAll();
  }

  Future<void> _persistAll() async {
    final all = await widget.repository.load();
    final index = all.indexWhere((t) => t.id == widget.trigger.id);
    if (index != -1) {
      all[index] = widget.trigger;
    }
    await widget.repository.save(all);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.trigger.color;
    final doneCount = _checked.length;
    final total = _items.length;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            _ChecklistHeader(
              trigger: widget.trigger,
              editMode: _editMode,
              doneCount: doneCount,
              total: total,
              onBack: () => Navigator.of(context).pop(),
              onToggleEdit: () => setState(() => _editMode = !_editMode),
            ),
            Expanded(
              child: _items.isEmpty
                  ? Center(child: Text(AppStrings.of(context).emptyChecklist))
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      itemCount: _items.length,
                      onReorder: _editMode ? _reorder : (_, _) {},
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _editMode
                            ? _EditableRow(
                                key: ValueKey(item.id),
                                index: index,
                                item: item,
                                color: color,
                                onRename: () => _renameItem(item),
                                onDelete: () => _deleteItem(item),
                              )
                            : _CheckRow(
                                key: ValueKey(item.id),
                                item: item,
                                color: color,
                                checked: _checked.contains(item.id),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked) {
                                      _checked.add(item.id);
                                    } else {
                                      _checked.remove(item.id);
                                    }
                                  });
                                },
                              );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _editMode
          ? FloatingActionButton(
              backgroundColor: color,
              onPressed: _addItem,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }
}

class _ChecklistHeader extends StatelessWidget {
  final Trigger trigger;
  final bool editMode;
  final int doneCount;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onToggleEdit;

  const _ChecklistHeader({
    required this.trigger,
    required this.editMode,
    required this.doneCount,
    required this.total,
    required this.onBack,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final color = trigger.color;
    final progress = total == 0 ? 0.0 : doneCount / total;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, HSLColor.fromColor(color).withLightness(
            (HSLColor.fromColor(color).lightness - 0.12).clamp(0.0, 1.0),
          ).toColor()],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: onBack,
              ),
              Icon(BrandPalette.iconForIndex(trigger.iconIndex), color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trigger.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              Material(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                child: IconButton(
                  tooltip: editMode ? strings.done : strings.editChecklist,
                  icon: Icon(editMode ? Icons.check_rounded : Icons.edit_rounded, color: Colors.white),
                  onPressed: onToggleEdit,
                ),
              ),
            ],
          ),
          if (!editMode && total > 0) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.28),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.progressLabel(doneCount, total),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final ChecklistItem item;
  final Color color;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _CheckRow({
    super.key,
    required this.item,
    required this.color,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onChanged(!checked),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Checkbox(
                value: checked,
                activeColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                onChanged: (value) => onChanged(value ?? false),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    decoration: checked ? TextDecoration.lineThrough : null,
                    color: checked
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  final int index;
  final ChecklistItem item;
  final Color color;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _EditableRow({
    super.key,
    required this.index,
    required this.item,
    required this.color,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: ReorderableDragStartListener(
          index: index,
          child: Icon(Icons.drag_indicator_rounded, color: color),
        ),
        title: Text(item.text, style: const TextStyle(fontWeight: FontWeight.w500)),
        onTap: onRename,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
